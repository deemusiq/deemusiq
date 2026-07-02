import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_undraw/flutter_undraw.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter_extension.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/extensions/context.dart';

class NoDefaultMetadataPlugin extends StatelessWidget {
  final VoidCallback? onRetry;
  const NoDefaultMetadataPlugin({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 10,
        children: [
          Undraw(
            height: 200 * context.theme.scaling,
            illustration: UndrawIllustration.stars,
            color: context.theme.colorScheme.primary,
          ),
          AutoSizeText(
            context.l10n.no_default_metadata_provider_selected,
            style: context.theme.typography.h4,
            maxLines: 1,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Button.primary(
                leading: const Icon(DeeMusiqIcons.extensions),
                child: Text(context.l10n.manage_metadata_providers),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Metadata Providers"),
                      content: const Text(
                        "External plugins have been removed. DeeMusiq uses its native backend for metadata.",
                      ),
                      actions: [
                        if (onRetry != null)
                          Button.outline(
                            leading: const Icon(DeeMusiqIcons.refresh),
                            onPressed: () {
                              ctx.maybePop();
                              onRetry?.call();
                            },
                            child: const Text("Retry"),
                          ),
                        Button.primary(
                          onPressed: () => ctx.maybePop(),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (onRetry != null)
                Button.outline(
                  leading: const Icon(DeeMusiqIcons.refresh),
                  child: const Text("Retry"),
                  onPressed: onRetry,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
