import 'package:shadcn_flutter/shadcn_flutter.dart';

/// Overlays a [PrimaryBadge] count pill on the top-right corner of [child].
/// Standardizes on the shadcn badge idiom (the Material `Badge` overlay is no
/// longer used in the app chrome). Renders [child] alone when [count] is zero.
class CountBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const CountBadge({
    super.key,
    required this.count,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -8,
          right: -8,
          child: PrimaryBadge(
            child: Text(count.toString()),
          ),
        ),
      ],
    );
  }
}
