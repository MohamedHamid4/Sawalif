// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../data/services/moderation_service.dart';
import '../../l10n/app_localizations.dart';

/// Bottom sheet للإبلاغ عن مستخدم/رسالة
Future<void> showReportSheet(
  BuildContext context, {
  required String reportedUserId,
  String? messageId,
  String? chatId,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXxl)),
    ),
    builder: (_) => _ReportSheet(
      reportedUserId: reportedUserId,
      messageId: messageId,
      chatId: chatId,
    ),
  );
}

class _ReportSheet extends StatefulWidget {
  final String reportedUserId;
  final String? messageId;
  final String? chatId;

  const _ReportSheet({
    required this.reportedUserId,
    this.messageId,
    this.chatId,
  });

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  String? _reasonKey;
  final _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_reasonKey == null) return;

    setState(() => _isSubmitting = true);
    try {
      await context.read<ModerationService>().reportUser(
            reportedUserId: widget.reportedUserId,
            reason: _reasonKey!,
            messageId: widget.messageId,
            chatId: widget.chatId,
            additionalDetails: _detailsController.text.trim().isEmpty
                ? null
                : _detailsController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      SnackBarHelper.showSuccess(context, l10n.reportSubmitted);
    } catch (_) {
      if (!mounted) return;
      SnackBarHelper.showError(context, l10n.errorUnknown);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final reasons = <_Reason>[
      _Reason('inappropriate', '🔞 ${l10n.reportInappropriate}'),
      _Reason('harassment', '💢 ${l10n.reportHarassment}'),
      _Reason('spam', '📢 ${l10n.reportSpam}'),
      _Reason('impersonation', '🎭 ${l10n.reportImpersonation}'),
      _Reason('other', '⚖️ ${l10n.reportOther}'),
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.md,
        right: AppSizes.md,
        top: AppSizes.md,
        bottom: viewInsets + AppSizes.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.lightDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              l10n.reportReason,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSizes.md),
            ...reasons.map((r) => RadioListTile<String>(
                  value: r.key,
                  groupValue: _reasonKey,
                  onChanged: (v) => setState(() => _reasonKey = v),
                  activeColor: AppColors.primary,
                  title: Text(r.label),
                  contentPadding: EdgeInsets.zero,
                )),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _detailsController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.reportDetails,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _reasonKey == null || _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(l10n.submitReport),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Reason {
  final String key;
  final String label;
  const _Reason(this.key, this.label);
}
