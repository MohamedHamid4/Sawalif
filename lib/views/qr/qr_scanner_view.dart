import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/permission_service.dart';
import '../../l10n/app_localizations.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// شاشة مسح QR Code لإضافة صديق
class QrScannerView extends StatefulWidget {
  const QrScannerView({super.key});

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  final MobileScannerController _controller = MobileScannerController();
  final PermissionService _perm = PermissionService();
  bool _isProcessing = false;
  bool _hasCameraPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureCameraPermission();
    });
  }

  /// التحقق من إذن الكاميرا - وإلا اطلبه أو أرجع المستخدم
  Future<void> _ensureCameraPermission() async {
    if (await _perm.hasPermission(Permission.camera)) {
      if (mounted) setState(() => _hasCameraPermission = true);
      return;
    }

    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final shouldRequest = await _perm.showPermissionRationale(
      context: context,
      title: l10n.permissionCameraTitle,
      message: l10n.permissionCameraMessage,
      icon: Icons.qr_code_scanner_rounded,
      allowText: l10n.allow,
      cancelText: l10n.cancel,
    );

    if (!shouldRequest) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final granted = await _perm.requestCamera();
    if (!mounted) return;
    if (granted) {
      setState(() => _hasCameraPermission = true);
      return;
    }
    if (await _perm.isPermanentlyDenied(Permission.camera)) {
      if (!mounted) return;
      await _perm.showOpenSettingsDialog(
        context: context,
        title: l10n.permissionDenied,
        message: l10n.permissionDeniedSettings,
        openText: l10n.openSettings,
        cancelText: l10n.cancel,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _isProcessing = true);

    final username = _parseUsername(raw);
    final l10n = AppLocalizations.of(context);

    if (username == null) {
      SnackBarHelper.showError(context, l10n.invalidQr);
      // اسمح بالمحاولة مجدداً بعد قليل
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() => _isProcessing = false);
      return;
    }

    final user = await context.read<UserRepository>().findUserByUsername(username);
    if (!mounted) return;

    if (user == null) {
      SnackBarHelper.showError(context, l10n.userNotFound);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() => _isProcessing = false);
      return;
    }

    // تجنّب فتح محادثة مع النفس
    final currentUid = context.read<AuthViewModel>().currentUid;
    if (user.uid == currentUid) {
      SnackBarHelper.showInfo(context, '@${user.username}');
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) setState(() => _isProcessing = false);
      return;
    }

    final chatRepo = context.read<ChatRepository>();
    final chat = await chatRepo.getOrCreateChat(currentUid!, user.uid, user);
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(AppRoutes.chat, arguments: chat);
  }

  /// يتوقع: sawalif://user/{username}
  String? _parseUsername(String raw) {
    final uri = Uri.tryParse(raw);
    if (uri == null) return null;
    if (uri.scheme != AppStrings.qrUriScheme) return null;
    if (uri.host != AppStrings.qrUriUserHost) return null;
    if (uri.pathSegments.isEmpty) return null;

    final candidate = Validators.normalizeUsername(uri.pathSegments.first);
    if (Validators.validateUsername(candidate, context) != null) return null;
    return candidate;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanQrCode),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                final torch = state.torchState;
                return Icon(
                  torch == TorchState.on
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_rounded),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_hasCameraPermission)
            MobileScanner(controller: _controller, onDetect: _onDetect)
          else
            const ColoredBox(color: Colors.black, child: SizedBox.expand()),
          // إطار المسح
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              ),
            ),
          ),
          // نص توجيهي
          Positioned(
            bottom: AppSizes.xxl,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md, vertical: AppSizes.sm),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Text(
                  l10n.pointCameraAtQr,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}
