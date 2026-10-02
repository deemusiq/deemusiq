import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jsf/jsf.dart';
import 'package:youtube_explode_dart/js_challenge.dart';

import 'package:deemusiq/services/logger/logger.dart';

/// QuickJS-backed EJS solver for youtube_explode_dart's JavaScript challenges
/// (n-cipher and signature deciphering, bot-detection player challenges).
///
/// Uses the `jsf` package (QuickJS via FFI), which is safe to create and use
/// inside a background isolate — unlike platform-channel JS runtimes.
/// The runtime must only be touched from the isolate that created it.
///
/// [solveBulk] is overridden (instead of relying on [BaseEJSSolver]'s) so the
/// player JavaScript is fetched with a real browser User-Agent: the base
/// implementation uses package:http's default `Dart/3.x (dart:io)` UA, which
/// is a trivial bot signal when pulling YouTube player assets.
class QuickJSEJSSolver extends BaseEJSSolver {
  final JsRuntime _runtime;

  QuickJSEJSSolver._(this._runtime);

  /// Downloads (once, hash-verified by youtube_explode_dart) the EJS lib+core
  /// modules and installs them into a fresh QuickJS runtime. The runtime is
  /// resource-bounded so hostile or broken player JS can neither hang the
  /// extraction isolate nor exhaust memory.
  static Future<QuickJSEJSSolver> init() async {
    final modules = await EJSBuilder.getJSModules();
    final runtime = JsRuntime(
      options: const JsRuntimeOptions(
        memoryLimitBytes: 64 * 1024 * 1024,
        maxStackSizeBytes: 2 * 1024 * 1024,
        timeout: Duration(seconds: 10),
      ),
    );
    try {
      runtime.execInitScript(modules);
    } catch (e) {
      runtime.dispose();
      rethrow;
    }
    return QuickJSEJSSolver._(runtime);
  }

  /// What a browser sends when fetching the YouTube player script.
  static const _playerFetchHeaders = {
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
    'accept': '*/*',
    'accept-language': 'en-US,en;q=0.9',
  };

  final _playerCache = <String, String>{};
  final _sigCache = <(String, String, JSChallengeType), String>{};
  final _preprocPlayer = <String, String>{};

  Future<String> _fetchPlayerScript(String playerUrl) async {
    final cached = _playerCache[playerUrl];
    if (cached != null) return cached;
    final response = await http
        .get(Uri.parse(playerUrl), headers: _playerFetchHeaders)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw StateError(
        'QuickJSEJSSolver: player fetch failed with ${response.statusCode}',
      );
    }
    return _playerCache[playerUrl] = response.body;
  }

  @override
  Future<Map<String, String?>> solveBulk(
    String playerUrl,
    Map<JSChallengeType, List<String>> requests,
  ) async {
    final uncachedRequests = <JSChallengeType, List<String>>{};
    final cachedResults = <String, String?>{};

    for (final entry in requests.entries) {
      final uncached = <String>[];
      for (final challenge in entry.value) {
        final key = (playerUrl, challenge, entry.key);
        final cached = _sigCache[key];
        if (cached != null) {
          cachedResults[challenge] = cached;
        } else {
          uncached.add(challenge);
        }
      }
      if (uncached.isNotEmpty) uncachedRequests[entry.key] = uncached;
    }

    if (uncachedRequests.isEmpty) return cachedResults;

    late String playerScript;
    var isPreprocessed = false;
    final preproc = _preprocPlayer[playerUrl];
    if (preproc != null) {
      playerScript = preproc;
      isPreprocessed = true;
    } else {
      playerScript = await _fetchPlayerScript(playerUrl);
    }

    final jsCall = EJSBuilder.buildJSCall(
      playerScript,
      uncachedRequests,
      isPreprocessed: isPreprocessed,
    );

    final resultJson = await executeJavaScript(jsCall);
    final data = json.decode(resultJson) as Map<String, dynamic>;

    if (data['type'] != 'result') {
      throw StateError('QuickJSEJSSolver: unexpected response type: ${data['type']}');
    }

    final preprocessed = data['preprocessed_player'];
    if (preprocessed is String) {
      _preprocPlayer[playerUrl] = preprocessed;
    }

    for (final response in data['responses'] as List) {
      if (response['type'] != 'result') {
        throw StateError(
          'QuickJSEJSSolver: unexpected item response type: ${response['type']}',
        );
      }
      final responseData = response['data'] as Map<String, dynamic>;
      for (final entry in responseData.entries) {
        final challenge = entry.key;
        final decoded = entry.value as String?;

        JSChallengeType? challengeType;
        for (final typeEntry in uncachedRequests.entries) {
          if (typeEntry.value.contains(challenge)) {
            challengeType = typeEntry.key;
            break;
          }
        }
        if (challengeType == null) continue;

        if (decoded != null) {
          _sigCache[(playerUrl, challenge, challengeType)] = decoded;
        }
        cachedResults[challenge] = decoded;
      }
    }

    return cachedResults;
  }

  @override
  Future<String> executeJavaScript(String jsCode) async {
    try {
      // The EJS call is `JSON.stringify(jsc(...))` — a synchronous string
      // expression. evalAsync additionally resolves the value if the runtime
      // wraps it in a promise. The outer timeout covers async job pumping;
      // the synchronous budget is enforced by JsRuntimeOptions.timeout.
      final result = await _runtime
          .evalAsync(jsCode)
          .timeout(const Duration(seconds: 15));
      if (result is String) return result;
      throw StateError(
        'QuickJSEJSSolver: expected String from eval, got ${result.runtimeType}',
      );
    } catch (e, stack) {
      AppLogger.log.w('QuickJSEJSSolver: JS execution failed: $e');
      AppLogger.reportError(e, stack, 'QuickJSEJSSolver.executeJavaScript');
      rethrow;
    }
  }

  @override
  void dispose() {
    _runtime.dispose();
  }
}
