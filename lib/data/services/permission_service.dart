import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// 🔐 خدمة موحّدة لإدارة صلاحيات التطبيق
class PermissionService {
  /// طلب صلاحية الكاميرا
  Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// طلب صلاحية المعرض (يدعم Android 13+ و iOS تلقائياً)
  Future<bool> requestGallery() async {
    var status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) return true;

    // fallback للأندرويد القديم
    status = await Permission.storage.request();
    return status.isGranted;
  }

  /// طلب صلاحية الإشعارات
  Future<bool> requestNotifications() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// التحقق من صلاحية معينة
  Future<bool> hasPermission(Permission permission) async {
    return await permission.isGranted;
  }

  /// التحقق إذا الصلاحية مرفوضة بشكل دائم
  Future<bool> isPermanentlyDenied(Permission permission) async {
    return await permission.isPermanentlyDenied;
  }

  /// فتح إعدادات التطبيق
  Future<void> openSettings() async {
    await openAppSettings();
  }

  /// عرض dialog لشرح الحاجة للصلاحية
  Future<bool> showPermissionRationale({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    String allowText = 'السماح',
    String cancelText = 'إلغاء',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        title: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(width: AppSizes.sm),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(allowText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// عرض dialog لفتح الإعدادات (للصلاحيات المرفوضة دائماً)
  Future<void> showOpenSettingsDialog({
    required BuildContext context,
    required String title,
    required String message,
    String openText = 'فتح الإعدادات',
    String cancelText = 'إلغاء',
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(openText),
          ),
        ],
      ),
    );
  }
}
