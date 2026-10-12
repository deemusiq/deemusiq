part of 'metadata.dart';

@freezed
class DeeMusiqImageObject with _$DeeMusiqImageObject {
  factory DeeMusiqImageObject({
    required String url,
    int? width,
    int? height,
  }) = _DeeMusiqImageObject;

  factory DeeMusiqImageObject.fromJson(Map<String, dynamic> json) =>
      _$DeeMusiqImageObjectFromJson(json);
}

enum ImagePlaceholder {
  albumArt,
  artist,
  collection,
  online,
}

/// Generated once so the random avatar stays stable for the app's lifetime
/// (previously a side effect of the lazy [placeholderUrlMap] map).
final _onlinePlaceholderUrl =
    "https://avatars.dicebear.com/api/bottts/${PrimitiveUtils.uuid.v4()}.png";

String placeholderUrlFor(ImagePlaceholder placeholder) => switch (placeholder) {
      ImagePlaceholder.albumArt => Assets.images.albumPlaceholder.path,
      ImagePlaceholder.artist => Assets.images.userPlaceholder.path,
      ImagePlaceholder.collection => Assets.images.placeholder.path,
      ImagePlaceholder.online => _onlinePlaceholderUrl,
    };

extension DeeMusiqImageExtensions on List<DeeMusiqImageObject>? {
  /// Returns the URL of the image at the specified index.
  String asUrlString({
    int index = 1,
    required ImagePlaceholder placeholder,
  }) {
    final sortedImage =
        this?.sorted((a, b) => (a.width ?? 0).compareTo(b.width ?? 0));

    return sortedImage != null && sortedImage.isNotEmpty
        ? sortedImage[
                index > sortedImage.length - 1 ? sortedImage.length - 1 : index]
            .url
        : placeholderUrlFor(placeholder);
  }

  Uri asUri({
    int index = 1,
    required ImagePlaceholder placeholder,
  }) {
    final url = asUrlString(placeholder: placeholder, index: index);
    if (url.startsWith("http")) {
      return Uri.parse(url);
    }
    return Uri.file(url);
  }

  String smallest(ImagePlaceholder placeholder) {
    final sortedImage = this?.sorted((a, b) {
      final widthComparison = (a.width ?? 0).compareTo(b.width ?? 0);
      if (widthComparison != 0) return widthComparison;
      return (a.height ?? 0).compareTo(b.height ?? 0);
    });

    return sortedImage != null && sortedImage.isNotEmpty
        ? sortedImage.first.url
        : placeholderUrlFor(placeholder);
  }

  String from200PxTo300PxOrSmallestImage([
    ImagePlaceholder placeholder = ImagePlaceholder.albumArt,
  ]) {
    final placeholderUrl = placeholderUrlFor(placeholder);

    // Sort images by width and height to find the smallest one
    final sortedImage = this?.sorted((a, b) {
      final widthComparison = (a.width ?? 0).compareTo(b.width ?? 0);
      if (widthComparison != 0) return widthComparison;
      return (a.height ?? 0).compareTo(b.height ?? 0);
    });

    return sortedImage != null && sortedImage.isNotEmpty
        ? sortedImage.firstWhere(
            (image) {
              final width = image.width ?? 0;
              final height = image.height ?? 0;
              return width >= 200 &&
                  height >= 200 &&
                  width <= 300 &&
                  height <= 300;
            },
            orElse: () => sortedImage.first,
          ).url
        : placeholderUrl;
  }
}
