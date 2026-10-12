import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/components/fallbacks/error_box.dart';

/// Standard three-state rendering for an [AsyncValue]: [builder] with real
/// data, [builder] again with `null` while the first load runs (render a
/// skeleton there — FakeData is skeleton-only), or an [ErrorBox] when the
/// load failed with no cached data, so fabricated content never reaches the
/// screen as if it were real.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
  });

  final AsyncValue<T> value;

  /// Builds the content. `data` is null only while the first load is in
  /// progress — wrap the skeleton branch in a Skeletonizer over FakeData.
  final Widget Function(T? data) builder;

  /// Retry action for the error state, e.g. `ref.invalidate(provider)`.
  /// When null the [ErrorBox] renders without a retry button.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final error = value.error;
    if (error != null && value.asData?.value == null) {
      return Center(
        child: ErrorBox(error: error, onRetry: onRetry),
      );
    }
    return builder(value.asData?.value);
  }
}
