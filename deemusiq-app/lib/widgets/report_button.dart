import 'package:flutter/material.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/services/logger/logger.dart';
import 'package:deemusiq/services/wallet/wallet_api.dart';

/// Reusable "Report this" button + dialog. Use anywhere a track/album/artist/
/// is rendered. Posts to /reports and shows a snackbar on success.
class ReportButton extends StatelessWidget {
  final String targetKind; // "track" | "album" | "artist" | "comment" | "user"
  final String targetId;
  final String targetLabel; // shown in the dialog ("this track", "this artist")

  const ReportButton({
    super.key,
    required this.targetKind,
    required this.targetId,
    required this.targetLabel,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.flag_outlined, size: 18),
      tooltip: context.l10n.report,
      onPressed: () => _open(context),
    );
  }

  /// Opens the report dialog directly (e.g. from a context-menu entry where
  /// an icon button doesn't fit).
  static Future<void> show(
    BuildContext context, {
    required String targetKind,
    required String targetId,
    required String targetLabel,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => _ReportDialog(
        targetKind: targetKind,
        targetId: targetId,
        targetLabel: targetLabel,
      ),
    );
  }

  void _open(BuildContext context) {
    show(
      context,
      targetKind: targetKind,
      targetId: targetId,
      targetLabel: targetLabel,
    );
  }
}

class _ReportDialog extends StatefulWidget {
  final String targetKind;
  final String targetId;
  final String targetLabel;
  const _ReportDialog({
    required this.targetKind,
    required this.targetId,
    required this.targetLabel,
  });

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  String _reason = "spam";
  final _details = TextEditingController();
  final _evidence = TextEditingController();
  bool _busy = false;
  String? _error;

  static const _reasons = [
    "spam",
    "copyright",
    "harassment",
    "csam",
    "illegal",
    "other",
  ];

  @override
  void dispose() {
    _details.dispose();
    _evidence.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await WalletApiClient.instance.reportContent(
        targetKind: widget.targetKind,
        targetId: widget.targetId,
        reason: _reason,
        description: _details.text.trim().isEmpty ? null : _details.text.trim(),
        evidenceUrl: _evidence.text.trim().isEmpty ? null : _evidence.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.report_submitted)),
      );
    } on WalletApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e, st) {
      AppLogger.reportError(e, st, 'report content');
      if (mounted) setState(() => _error = context.l10n.report_network_error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reasonLabels = {
      "spam": l10n.report_reason_spam,
      "copyright": l10n.report_reason_copyright,
      "harassment": l10n.report_reason_harassment,
      "csam": l10n.report_reason_csam,
      "illegal": l10n.report_reason_illegal,
      "other": l10n.report_reason_other,
    };
    final error = _error;
    return AlertDialog(
      title: Text(l10n.report_dialog_title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.report_what_wrong(widget.targetLabel),
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _reason,
              decoration: InputDecoration(labelText: l10n.report_reason_label),
              items: _reasons
                  .map((r) => DropdownMenuItem(
                      value: r, child: Text(reasonLabels[r] ?? r)))
                  .toList(),
              onChanged: (v) => setState(() => _reason = v ?? "spam"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _details,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.report_details_label,
                hintText: l10n.report_details_hint,
              ),
            ),
            if (_reason == "copyright") ...[
              const SizedBox(height: 8),
              TextField(
                controller: _evidence,
                decoration: InputDecoration(
                  labelText: l10n.report_evidence_label,
                  hintText: "https://example.com/your-original-track",
                ),
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(_busy ? l10n.report_submitting : l10n.submit),
        ),
      ],
    );
  }
}
