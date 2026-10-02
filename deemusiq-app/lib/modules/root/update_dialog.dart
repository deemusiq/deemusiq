import 'package:deemusiq/components/links/anchor_button.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:version/version.dart';

class RootAppUpdateDialog extends StatelessWidget {
  final Version? version;
  final int? nightlyBuildNum;
  final String downloadUrl;
  final String? sha256;
  final bool signatureVerified;
  final bool digestVerified;

  const RootAppUpdateDialog({
    super.key,
    this.version,
    this.downloadUrl = 'https://deemusiq.co.za/#download',
    this.sha256,
    this.signatureVerified = false,
    this.digestVerified = false,
  }) : nightlyBuildNum = null;

  const RootAppUpdateDialog.nightly({
    super.key,
    required this.nightlyBuildNum,
    this.downloadUrl = 'https://deemusiq.co.za/#download',
    this.sha256,
    this.signatureVerified = false,
    this.digestVerified = false,
  }) : version = null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.spotube_has_an_update),
      actions: [
        Button.primary(
          child: Text(context.l10n.download_now),
          onPressed: () => launchUrlString(
            downloadUrl,
            mode: LaunchMode.externalApplication,
          ),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            nightlyBuildNum != null
                ? context.l10n.nightly_version(nightlyBuildNum!)
                : context.l10n.release_version(version!),
          ),
          if (sha256 != null) ...[
            const Gap(8),
            Text('SHA-256: $sha256', textAlign: TextAlign.center),
          ],
          const Gap(8),
          Text(
            signatureVerified
                ? 'Signed update metadata verified'
                : digestVerified
                    ? 'Update metadata digest verified'
                    : 'Update metadata fetched over the configured site',
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(context.l10n.read_the_latest),
              AnchorButton(
                context.l10n.release_notes,
                style: const TextStyle(color: Colors.blue),
                onTap: () => launchUrlString(
                  downloadUrl,
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
