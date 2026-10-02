import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:html/dom.dart' hide Text;
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Element;
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/pages/library/user_local_tracks/user_local_tracks.dart';
import 'package:deemusiq/modules/root/update_dialog.dart';

import 'package:deemusiq/provider/database/database.dart';
import 'package:deemusiq/services/dio/dio.dart';
import 'package:deemusiq/services/logger/logger.dart';

import 'package:deemusiq/utils/platform.dart';
import 'package:deemusiq/utils/primitive_utils.dart';
import 'package:collection/collection.dart';
import 'package:html/parser.dart' as parser;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:deemusiq/collections/env.dart';

import 'package:version/version.dart';

const updateMetadataUrl = String.fromEnvironment(
  'DEEMUSIQ_UPDATE_METADATA_URL',
  defaultValue: 'https://deemusiq.co.za/downloads/version.json',
);
const updateDownloadUrl = String.fromEnvironment(
  'DEEMUSIQ_UPDATE_URL',
  defaultValue: 'https://deemusiq.co.za/#download',
);
const updateSigningPublicKey = String.fromEnvironment(
  'DEEMUSIQ_UPDATE_ED25519_PUBLIC_KEY',
);

class AppUpdateRelease {
  const AppUpdateRelease({
    required this.version,
    this.buildNumber,
    this.downloadUrl,
    this.sha256,
  });

  final String version;
  final int? buildNumber;
  final String? downloadUrl;
  final String? sha256;
}

class AppUpdateMetadata {
  const AppUpdateMetadata({
    required this.versions,
    required this.releases,
    required this.nightlyBuildNumber,
    required this.contentDigest,
    required this.digestVerified,
    required this.signatureVerified,
  });

  final Map<String, String> versions;
  final Map<String, AppUpdateRelease> releases;
  final int? nightlyBuildNumber;
  final String? contentDigest;
  final bool digestVerified;
  final bool signatureVerified;

  AppUpdateRelease? releaseFor(String platform) =>
      releases[platform] ??
      (versions[platform] == null
          ? null
          : AppUpdateRelease(version: versions[platform]!));
}

String _updateHex(Iterable<int> bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();

/// Decodes a hex string to bytes, or null when it isn't well-formed hex.
Uint8List? _updateHexDecode(String value) {
  if (value.length.isOdd || !RegExp(r'^[0-9a-fA-F]+$').hasMatch(value)) {
    return null;
  }
  final out = Uint8List(value.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(value.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}

String? _normalizedDigest(Object? value) {
  if (value == null) return null;
  final normalized = value.toString().trim().toLowerCase();
  if (!RegExp(r'^(?:sha256:)?[0-9a-f]{64}$').hasMatch(normalized)) {
    throw const FormatException('Invalid SHA-256 update metadata');
  }
  return normalized.replaceFirst('sha256:', '');
}

Future<AppUpdateMetadata> parseAppUpdateMetadata(
  Uint8List body,
  Headers headers, {
  String publicKeyBase64 = updateSigningPublicKey,
}) async {
  final decoded = jsonDecode(utf8.decode(body));
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Update metadata must be a JSON object');
  }
  final digestValue = _normalizedDigest(
    headers.value('x-deemusiq-content-sha256') ?? decoded['sha256'],
  );
  var digestVerified = false;
  if (digestValue != null) {
    final actual = _updateHex((await Sha256().hash(body)).bytes);
    if (actual != digestValue) {
      throw const FormatException('Update metadata digest mismatch');
    }
    digestVerified = true;
  }

  // Signature sources, in preference order: the legacy `x-deemusiq-signature`
  // header / in-body `signature` field (base64), or the download worker's
  // `X-Body-Signature` header (hex Ed25519 over the raw body bytes).
  final signatureValue =
      headers.value('x-deemusiq-signature') ?? decoded['signature']?.toString();
  var signatureVerified = false;
  if (publicKeyBase64.trim().isNotEmpty) {
    Uint8List? signatureBytes;
    if (signatureValue != null && signatureValue.trim().isNotEmpty) {
      try {
        signatureBytes = base64Decode(signatureValue.trim());
      } on FormatException {
        signatureBytes = null;
      }
    }
    if (signatureBytes == null) {
      final bodySignature = headers.value('x-body-signature')?.trim();
      if (bodySignature != null && bodySignature.isNotEmpty) {
        signatureBytes = _updateHexDecode(bodySignature);
      }
    }
    if (signatureBytes == null) {
      throw const FormatException('Signed update metadata is missing');
    }
    final publicKeyBytes = base64Decode(publicKeyBase64.trim());
    if (publicKeyBytes.length != 32) {
      throw const FormatException('Invalid update signing public key');
    }
    if (signatureBytes.length != 64) {
      throw const FormatException('Invalid update metadata signature');
    }
    final publicKey = SimplePublicKey(
      publicKeyBytes,
      type: KeyPairType.ed25519,
    );
    signatureVerified = await Ed25519().verify(
      body,
      signature: Signature(signatureBytes, publicKey: publicKey),
    );
    if (!signatureVerified) {
      throw const FormatException('Update metadata signature is invalid');
    }
  }

  final versions = <String, String>{};
  final rawVersions = decoded['versions'];
  if (rawVersions is Map) {
    for (final entry in rawVersions.entries) {
      final version = entry.value?.toString().trim();
      if (entry.key is String && version != null && version.isNotEmpty) {
        versions[entry.key as String] = version;
      }
    }
  }

  final releases = <String, AppUpdateRelease>{};
  final rawReleases = decoded['releases'];
  if (rawReleases is Map) {
    for (final entry in rawReleases.entries) {
      if (entry.key is! String || entry.value is! Map) continue;
      final release = Map<String, dynamic>.from(entry.value as Map);
      final version = release['version']?.toString().trim();
      if (version == null || version.isEmpty) continue;
      final rawBuildNumber = release['build_number'];
      final buildNumber = rawBuildNumber is num
          ? rawBuildNumber.toInt()
          : int.tryParse(rawBuildNumber?.toString() ?? '');
      releases[entry.key as String] = AppUpdateRelease(
        version: version,
        buildNumber: buildNumber,
        downloadUrl: release['download_url']?.toString(),
        sha256: _normalizedDigest(release['sha256'] ?? release['digest']),
      );
    }
  }

  final rawNightlyBuild = decoded['nightly_build_number'];
  final nightlyBuildNumber = rawNightlyBuild is num
      ? rawNightlyBuild.toInt()
      : int.tryParse(rawNightlyBuild?.toString() ?? '');
  return AppUpdateMetadata(
    versions: versions,
    releases: releases,
    nightlyBuildNumber: nightlyBuildNumber,
    contentDigest: digestValue,
    digestVerified: digestVerified,
    signatureVerified: signatureVerified,
  );
}

enum UserAgentDevice {
  desktop,
  mobile,
}

abstract class ServiceUtils {
  static final _englishMatcherRegex = RegExp(
    "^[a-zA-Z0-9\\s!\"#\$%&\\'()*+,-.\\/:;<=>?@\\[\\]^_`{|}~]*\$",
  );
  static bool onlyContainsEnglish(String text) {
    return _englishMatcherRegex.hasMatch(text);
  }

  static String clearArtistsOfTitle(String title, List<String> artists) {
    return title
        .replaceAll(RegExp(artists.join("|"), caseSensitive: false), "")
        .trim();
  }

  static String getTitle(
    String title, {
    List<String> artists = const [],
    bool onlyCleanArtist = false,
  }) {
    final match = RegExp(r"(?<=\().+?(?=\))").firstMatch(title)?.group(0);
    final artistInBracket =
        artists.any((artist) => match?.contains(artist) ?? false);

    if (artistInBracket) {
      title = title.replaceAll(
        RegExp(" *\\([^)]*\\) *"),
        '',
      );
    }

    title = clearArtistsOfTitle(title, artists);
    if (onlyCleanArtist) {
      artists = [];
    }

    return "$title ${artists.map((e) => e.replaceAll(",", " ")).join(", ")}"
        .replaceAll(RegExp(r"\s*\[[^\]]*]"), ' ')
        .replaceAll(RegExp(r"\sfeat\.|\sft\.", caseSensitive: false), ' ')
        .replaceAll(RegExp(r"\s+"), ' ')
        .trim();
  }

  static Future<String?> extractLyrics(Uri url) async {
    final response = await globalDio.getUri(
      url,
      options: Options(responseType: ResponseType.plain),
    );

    Document document = parser.parse(response.data);
    String? lyrics = document.querySelector('div.lyrics')?.text.trim();
    if (lyrics == null) {
      lyrics = "";
      document
          .querySelectorAll("div[class^=\"Lyrics__Container\"]")
          .forEach((element) {
        if (element.text.trim().isNotEmpty) {
          final snippet = element.innerHtml.replaceAll("<br>", "\n").replaceAll(
                RegExp("<(?!\\s*br\\s*\\/?)[^>]+>", caseSensitive: false),
                "",
              );
          final el = document.createElement("textarea");
          el.innerHtml = snippet;
          lyrics = "$lyrics${el.text.trim()}\n\n";
        }
      });
    }

    return lyrics;
  }

  @Deprecated("In favor spotify lyrics api, this isn't needed anymore")
  static Future<List?> searchSong(
    String title,
    List<String> artist, {
    String? apiKey,
    bool optimizeQuery = false,
    bool authHeader = false,
  }) async {
    if (apiKey == "" || apiKey == null) {
      apiKey = PrimitiveUtils.getRandomElement(/* lyricsSecrets */ []);
    }
    const searchUrl = 'https://api.genius.com/search?q=';
    String song =
        optimizeQuery ? getTitle(title, artists: artist) : "$title $artist";

    String reqUrl = "$searchUrl${Uri.encodeComponent(song)}";
    Map<String, String> headers = {"Authorization": 'Bearer $apiKey'};
    final response = await globalDio.getUri(
      Uri.parse(authHeader ? reqUrl : "$reqUrl&access_token=$apiKey"),
      options: Options(
        headers: authHeader ? headers : null,
        responseType: ResponseType.json,
      ),
    );
    Map data = response.data["response"];
    if (data["hits"]?.length == 0) return null;
    List results = data["hits"]?.map((val) {
      return <String, dynamic>{
        "id": val["result"]["id"],
        "full_title": val["result"]["full_title"],
        "albumArt": val["result"]["song_art_image_url"],
        "url": val["result"]["url"],
        "author": val["result"]["primary_artist"]["name"],
      };
    }).toList();
    return results;
  }

  @Deprecated("In favor spotify lyrics api, this isn't needed anymore")
  static Future<String?> getLyrics(
    String title,
    List<String> artists, {
    required String apiKey,
    bool optimizeQuery = false,
    bool authHeader = false,
  }) async {
    final results = await searchSong(
      title,
      artists,
      apiKey: apiKey,
      optimizeQuery: optimizeQuery,
      authHeader: authHeader,
    );
    if (results == null) return null;
    title = getTitle(
      title,
      artists: artists,
      onlyCleanArtist: true,
    ).trim();
    final ratedLyrics = results.map((result) {
      final gTitle = (result["full_title"] as String).toLowerCase();
      int points = 0;
      final hasTitle = gTitle.contains(title);
      final hasAllArtists =
          artists.every((artist) => gTitle.contains(artist.toLowerCase()));
      final String lyricAuthor = result["author"].toLowerCase();
      final fromOriginalAuthor =
          lyricAuthor.contains(artists.first.toLowerCase());

      for (final criteria in [
        hasTitle,
        hasAllArtists,
        fromOriginalAuthor,
      ]) {
        if (criteria) points++;
      }
      return {"result": result, "points": points};
    }).sorted(
      (a, b) => ((a["points"] as int).compareTo(a["points"] as int)),
    );
    final worthyOne = ratedLyrics.first["result"];

    String? lyrics = await extractLyrics(Uri.parse(worthyOne["url"]));
    return lyrics;
  }

  static DateTime parseSpotifyAlbumDate(DeeMusiqSimpleAlbumObject? album) {
    final releaseDate = album?.releaseDate;
    if (releaseDate == null) {
      return DateTime.parse("1975-01-01");
    }

    // Release dates come in "yyyy", "yyyy-MM" or "yyyy-MM-dd" precision —
    // pad the partial forms instead of letting DateTime.parse throw.
    final parts = releaseDate.split("-");
    final year = int.tryParse(parts.first);
    if (year == null) {
      return DateTime.parse("1975-01-01");
    }
    final month = parts.length > 1 ? int.tryParse(parts[1]) ?? 1 : 1;
    final day = parts.length > 2 ? int.tryParse(parts[2]) ?? 1 : 1;
    return DateTime(year, month.clamp(1, 12), day.clamp(1, 31));
  }

  static List<T> sortTracks<T extends DeeMusiqTrackObject>(
      List<T> tracks, SortBy sortBy) {
    if (sortBy == SortBy.none) return tracks;
    return List<T>.from(tracks)
      ..sort((a, b) {
        switch (sortBy) {
          case SortBy.ascending:
            return a.name.compareTo(b.name);
          case SortBy.descending:
            return b.name.compareTo(a.name);
          case SortBy.newest:
            {
              final aDate = parseSpotifyAlbumDate(a.album);
              final bDate = parseSpotifyAlbumDate(b.album);
              return bDate.compareTo(aDate);
            }
          case SortBy.oldest:
            {
              final aDate = parseSpotifyAlbumDate(a.album);
              final bDate = parseSpotifyAlbumDate(b.album);
              return aDate.compareTo(bDate);
            }
          case SortBy.duration:
            return a.durationMs.compareTo(b.durationMs);
          case SortBy.artist:
            return a.artists.first.name.compareTo(b.artists.first.name);
          case SortBy.album:
            return a.album.name.compareTo(b.album.name);
          default:
            return 0;
        }
      });
  }

  static String get _updatePlatform {
    if (kIsAndroid) return 'android';
    if (kIsWindows) return 'windows';
    if (kIsMacOS) return 'macos';
    if (kIsLinux) return 'linux';
    return 'android';
  }

  static Uri get _updateEndpoint {
    final metadataUri = Uri.tryParse(updateMetadataUrl);
    final downloadUri = Uri.tryParse(updateDownloadUrl);
    if (metadataUri == null || downloadUri == null) {
      throw const FormatException('Invalid update endpoint configuration');
    }
    final local = {'localhost', '127.0.0.1', '::1'};
    final metadataSecure = metadataUri.scheme == 'https' ||
        (metadataUri.scheme == 'http' && local.contains(metadataUri.host));
    final downloadSecure = downloadUri.scheme == 'https' ||
        (downloadUri.scheme == 'http' && local.contains(downloadUri.host));
    if (!metadataSecure ||
        !downloadSecure ||
        metadataUri.host.toLowerCase() != downloadUri.host.toLowerCase() ||
        metadataUri.port != downloadUri.port) {
      throw const FormatException(
        'Update metadata and downloads must use the same secure site origin',
      );
    }
    return metadataUri;
  }

  static String _approvedDownloadUrl(
    AppUpdateRelease release,
    Uri metadataEndpoint,
  ) {
    final candidate = Uri.tryParse(release.downloadUrl ?? '');
    if (candidate != null &&
        candidate.scheme == 'https' &&
        candidate.host.toLowerCase() == metadataEndpoint.host.toLowerCase() &&
        candidate.port == metadataEndpoint.port) {
      return candidate.toString();
    }
    return updateDownloadUrl;
  }

  static Future<void> checkForUpdates(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (!Env.enableUpdateChecker) return;
    final database = ref.read(databaseProvider);
    final checkUpdate = await (database.selectOnly(database.preferencesTable)
          ..addColumns([database.preferencesTable.checkUpdate])
          ..where(database.preferencesTable.id.equals(0)))
        .map((row) => row.read(database.preferencesTable.checkUpdate))
        .getSingleOrNull();

    if (checkUpdate == false) return;
    final packageInfo = await PackageInfo.fromPlatform();

    try {
      final endpoint = _updateEndpoint;
      final response = await globalDio.getUri<List<int>>(
        endpoint,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          headers: const {'Accept': 'application/json'},
        ),
      );
      final responseData = response.data;
      if (responseData == null) {
        throw const FormatException('Update metadata response is empty');
      }
      final bytes = responseData is Uint8List
          ? responseData
          : Uint8List.fromList(responseData);
      final metadata = await parseAppUpdateMetadata(bytes, response.headers);
      if (!context.mounted) return;
      if (Env.releaseChannel == ReleaseChannel.nightly) {
        await _checkNightly(context, packageInfo, metadata, endpoint);
      } else {
        await _checkStable(context, packageInfo, metadata, endpoint);
      }
    } catch (error, stack) {
      AppLogger.log.w('Update check failed: ${error.toString()}');
      AppLogger.reportError(error, stack, 'Update checker');
    }
  }

  static Future<void> _checkNightly(
    BuildContext context,
    PackageInfo packageInfo,
    AppUpdateMetadata metadata,
    Uri endpoint,
  ) async {
    final buildNumber = metadata.nightlyBuildNumber ??
        metadata.releaseFor(_updatePlatform)?.buildNumber;
    final currentBuildNumber = int.tryParse(packageInfo.buildNumber);
    if (buildNumber == null ||
        currentBuildNumber == null ||
        buildNumber <= currentBuildNumber ||
        !context.mounted) {
      return;
    }
    final release = metadata.releaseFor(_updatePlatform);
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(66),
      builder: (context) => RootAppUpdateDialog.nightly(
        nightlyBuildNum: buildNumber,
        downloadUrl: release == null
            ? updateDownloadUrl
            : _approvedDownloadUrl(release, endpoint),
        sha256: release?.sha256,
        signatureVerified: metadata.signatureVerified,
        digestVerified: metadata.digestVerified,
      ),
    );
  }

  static Future<void> _checkStable(
    BuildContext context,
    PackageInfo packageInfo,
    AppUpdateMetadata metadata,
    Uri endpoint,
  ) async {
    final release = metadata.releaseFor(_updatePlatform);
    if (release == null) return;
    final currentVersion = packageInfo.version == 'Unknown'
        ? null
        : Version.parse(packageInfo.version);
    final latestVersion = Version.parse(
      release.version.replaceFirst(RegExp(r'^v'), ''),
    );

    if (currentVersion == null ||
        (latestVersion.isPreRelease && !currentVersion.isPreRelease) ||
        (!latestVersion.isPreRelease && currentVersion.isPreRelease) ||
        latestVersion <= currentVersion ||
        !context.mounted) {
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(66),
      builder: (context) => RootAppUpdateDialog(
        version: latestVersion,
        downloadUrl: _approvedDownloadUrl(release, endpoint),
        sha256: release.sha256,
        signatureVerified: metadata.signatureVerified,
        digestVerified: metadata.digestVerified,
      ),
    );
  }

  static Future<Uint8List?> downloadImage(
    String imageUrl,
  ) async {
    try {
      final fileStream = DefaultCacheManager().getImageFile(imageUrl);

      final bytes = List<int>.empty(growable: true);

      await for (final data in fileStream) {
        if (data is FileInfo) {
          bytes.addAll(await data.file.readAsBytes());
          break;
        }
      }

      return Uint8List.fromList(bytes);
    } catch (e, stackTrace) {
      AppLogger.reportError(e, stackTrace);
      return null;
    }
  }

  static int randomNumber(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  static String randomUserAgent(UserAgentDevice type) {
    if (type == UserAgentDevice.desktop) {
      return "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_${randomNumber(11, 15)}_${randomNumber(4, 9)}) AppleWebKit/${randomNumber(530, 537)}.${randomNumber(30, 37)} (KHTML, like Gecko) Chrome/${randomNumber(80, 105)}.0.${randomNumber(3000, 4500)}.${randomNumber(60, 125)} Safari/${randomNumber(530, 537)}.${randomNumber(30, 36)}";
    } else {
      return "Mozilla/5.0 (Linux; Android ${randomNumber(8, 13)}) AppleWebKit/${randomNumber(530, 537)}.${randomNumber(30, 36)} (KHTML, like Gecko) Chrome/${randomNumber(101, 116)}.0.${randomNumber(3000, 6000)}.${randomNumber(60, 125)} Mobile Safari/${randomNumber(530, 537)}.${randomNumber(30, 36)}";
    }
  }

  static String sanitizeFilename(String input, {String replacement = ''}) {
    final result = input
        // illegalRe
        .replaceAll(
          RegExp(r'[\/\?<>\\:\*\|"]'),
          replacement,
        )
        // controlRe
        .replaceAll(
          RegExp(
            r'[\x00-\x1f\x80-\x9f]',
          ),
          replacement,
        )
        // reservedRe
        .replaceFirst(
          RegExp(r'^\.+$'),
          replacement,
        )
        // windowsReservedRe
        .replaceFirst(
          RegExp(
            r'^(con|prn|aux|nul|com[0-9]|lpt[0-9])(\..*)?$',
            caseSensitive: false,
          ),
          replacement,
        )
        // windowsTrailingRe
        .replaceFirst(RegExp(r'[\. ]+$'), replacement);

    return result.length > 255 ? result.substring(0, 255) : result;
  }
}
