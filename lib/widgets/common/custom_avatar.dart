import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/extensions/string_extensions.dart';

/// أفاتار مخصص مع نقطة الحالة (Online/Offline)
class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool showOnlineDot;
  final bool isOnline;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 48,
    this.showOnlineDot = false,
    this.isOnline = false,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildAvatar(),
          if (showOnlineDot) _buildOnlineDot(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (context, imageProvider) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (context, url) => _buildInitialsAvatar(),
        errorWidget: (context, url, error) => _buildInitialsAvatar(),
      );
    }
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: backgroundColor != null
            ? null
            : _getGradientForName(name),
        color: backgroundColor,
      ),
      child: Center(
        child: Text(
          name.initials,
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineDot() {
    final dotSize = size * 0.27;
    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOnline ? AppColors.online : AppColors.lightTextSecondary,
          border: Border.all(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  /// توليد تدرج لوني بناءً على اسم المستخدم
  LinearGradient _getGradientForName(String name) {
    final gradients = [
      AppColors.primaryGradient,
      AppColors.sunsetGradient,
      AppColors.warmGradient,
      const LinearGradient(colors: [Color(0xFF06D6A0), Color(0xFF0AC4A4)]),
      const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
      const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
    ];
    final index = name.isEmpty ? 0 : name.codeUnitAt(0) % gradients.length;
    return gradients[index];
  }
}
