import 'package:dio/dio.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/services/youtube_engine/direct_ytdlp_engine.dart';
import 'package:deemusiq/services/youtube_engine/yt_dlp_provisioner.dart';

/// Installs (or refreshes) yt-dlp behind a modal progress dialog.
///
/// Returns the approved binary, or `null` when the user cancelled or the
/// download failed — callers then fall back to the manual-path dialog.
Future<YtDlpBinaryResolution?> showYtDlpInstallDialog(
  BuildContext context, {
  bool forceLatest = false,
}) {
  return showDialog<YtDlpBinaryResolution?>(
    context: context,
    barrierDismissible: false,
    builder: (context) => YtDlpInstallDialog(forceLatest: forceLatest),
  );
}

class YtDlpInstallDialog extends StatefulWidget {
  const YtDlpInstallDialog({super.key, this.forceLatest = false});

  final bool forceLatest;

  @override
  State<YtDlpInstallDialog> createState() => _YtDlpInstallDialogState();
}

class _YtDlpInstallDialogState extends State<YtDlpInstallDialog> {
  final _status = ValueNotifier<YtDlpInstallStatus>(
    const YtDlpInstallStatus(phase: YtDlpInstallPhase.checking),
  );
  final _cancelToken = CancelToken();
  var _cancelled = false;

  @override
  void initState() {
    super.initState();
    _install();
  }

  @override
  void dispose() {
    _status.dispose();
    super.dispose();
  }

  Future<void> _install() async {
    _status.value = const YtDlpInstallStatus(phase: YtDlpInstallPhase.checking);
    final resolution = await YtDlpProvisioner.instance.ensure(
      forceLatest: widget.forceLatest,
      cancelToken: _cancelToken,
      onStatus: (status) {
        if (mounted) _status.value = status;
      },
    );
    if (!mounted) return;
    Navigator.of(context).pop(_cancelled ? null : resolution);
  }

  void _cancel() {
    _cancelled = true;
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('yt-dlp install cancelled by user');
    }
    Navigator.of(context).pop(null);
  }

  String _phaseLabel(BuildContext context, YtDlpInstallStatus status) {
    final version = status.version ?? 'latest';
    return switch (status.phase) {
      YtDlpInstallPhase.checking => context.l10n.yt_dlp_install_phase_checking,
      YtDlpInstallPhase.downloading =>
        context.l10n.yt_dlp_install_phase_downloading(version),
      YtDlpInstallPhase.verifying =>
        context.l10n.yt_dlp_install_phase_verifying,
      YtDlpInstallPhase.installing =>
        context.l10n.yt_dlp_install_phase_installing(version),
      YtDlpInstallPhase.done =>
        context.l10n.yt_dlp_install_phase_done(version),
      YtDlpInstallPhase.failed => context.l10n.yt_dlp_install_phase_failed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(context.l10n.yt_dlp_install_title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ValueListenableBuilder<YtDlpInstallStatus>(
          valueListenable: _status,
          builder: (context, status, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(_phaseLabel(context, status)),
              if (status.phase != YtDlpInstallPhase.failed)
                LinearProgressIndicator(value: status.progress),
              if (status.phase == YtDlpInstallPhase.failed &&
                  status.message != null)
                Text(status.message!, style: theme.typography.small),
              if (status.phase == YtDlpInstallPhase.failed)
                Button.primary(
                  onPressed: _install,
                  child: Text(context.l10n.yt_dlp_install_retry),
                ),
            ],
          ),
        ),
      ),
      actions: [
        Button.text(
          onPressed: _cancel,
          child: Text(context.l10n.cancel),
        ),
      ],
    );
  }
}
