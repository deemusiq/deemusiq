import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/assets.gen.dart';
import 'package:deemusiq/collections/env.dart';
import 'package:deemusiq/components/button/back_button.dart';
import 'package:deemusiq/components/links/hyper_link.dart';
import 'package:deemusiq/components/titlebar/titlebar.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/hooks/controllers/use_package_info.dart';
import 'package:deemusiq/services/metadata/deemusiq_native_plugin.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:auto_route/auto_route.dart';

final _licenseProvider = FutureProvider<String>((ref) async {
  return await rootBundle.loadString("LICENSE");
});

@RoutePage()
class AboutDeeMusiqPage extends HookConsumerWidget {
  static const name = "about";

  const AboutDeeMusiqPage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final packageInfo = usePackageInfo();
    final license = ref.watch(_licenseProvider);
    final theme = Theme.of(context);

    const colon = TableCell(child: Text(":"));

    return SafeArea(
      bottom: false,
      child: Scaffold(
        headers: [
          TitleBar(
            leading: const [BackButton()],
            title: Text(context.l10n.about_spotube),
          )
        ],
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Assets.branding.deemusiqLogoPng.image(
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 12),
                // Launcher icons (full icon + adaptive foreground layer).
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Assets.icons.appIcon.image(
                        height: 52,
                        width: 52,
                        excludeFromSemantics: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Assets.icons.appIconFg.image(
                        height: 52,
                        width: 52,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Column(
                    children: [
                      Text(context.l10n.spotube_description).semiBold().large(),
                      const SizedBox(height: 20),
                      Table(
                        columnWidths: const {
                          0: FixedTableSize(95),
                          1: FixedTableSize(10),
                          2: IntrinsicTableSize(),
                        },
                        defaultRowHeight: const FixedTableSize(40),
                        rows: [
                          // BSD-4-Clause attribution to upstream (NOTICE.md)
                          TableRow(
                            cells: [
                              TableCell(
                                  child: Text(context.l10n.about_built_on)),
                              colon,
                              const TableCell(
                                child: Hyperlink(
                                  "Spotube by KRTirtho",
                                  "https://github.com/team-spotube/spotube",
                                ),
                              )
                            ],
                          ),
                          TableRow(
                            cells: [
                              TableCell(child: Text(context.l10n.version)),
                              colon,
                              TableCell(child: Text("v${packageInfo.version}"))
                            ],
                          ),
                          TableRow(
                            cells: [
                              TableCell(child: Text(context.l10n.channel)),
                              colon,
                              TableCell(child: Text(Env.releaseChannel.name))
                            ],
                          ),
                          TableRow(
                            cells: [
                              TableCell(child: Text(context.l10n.build_number)),
                              colon,
                              TableCell(
                                child: Text(packageInfo.buildNumber
                                    .replaceAll(".", " ")),
                              )
                            ],
                          ),
                          TableRow(
                            cells: [
                              TableCell(
                                  child: Text(context.l10n.about_website)),
                              colon,
                              const TableCell(
                                child: Hyperlink(
                                  "deemusiq.co.za",
                                  "https://deemusiq.co.za/",
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            cells: [
                              TableCell(child: Text(context.l10n.repository)),
                              colon,
                              TableCell(
                                child: Hyperlink(
                                  '${kDeeMusiqPluginRepository.owner}/${kDeeMusiqPluginRepository.name}',
                                  kDeeMusiqPluginRepository.repoUrl,
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            cells: [
                              TableCell(child: Text(context.l10n.license)),
                              colon,
                              const TableCell(
                                child: Hyperlink(
                                  "BSD-4-Clause",
                                  "https://deemusiq.co.za/license",
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            cells: [
                              TableCell(child: Text(context.l10n.bug_issues)),
                              colon,
                              TableCell(
                                child: Hyperlink(
                                  context.l10n.support,
                                  "mailto:deemusiq@protonmail.com",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.l10n.about_made_in_sa,
                  textAlign: TextAlign.center,
                  style: theme.typography.small,
                ),
                Text(
                  context.l10n.copyright(DateTime.now().year),
                  textAlign: TextAlign.center,
                  style: theme.typography.small,
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 750),
                  child: SafeArea(
                    child: license.when(
                      data: (data) {
                        return Text(
                          data,
                          style: theme.typography.small,
                        );
                      },
                      loading: () {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      error: (e, s) {
                        return Text(
                          e.toString(),
                          style: theme.typography.small,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
