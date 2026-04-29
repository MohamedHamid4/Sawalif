import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// حالة فارغة جذابة مع أنيميشن Lottie
class EmptyState extends StatelessWidget {
  final String animationPath;
  final String title;
  final String? description;
  final String? buttonText;
  final VoidCallback? onButtonTap;
  final double animationSize;

  const EmptyState({
    super.key,
    required this.animationPath,
    required this.title,
    this.description,
    this.buttonText,
    this.onButtonTap,
    this.animationSize = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie أو أيقونة fallback
            _buildAnimation(),
            const SizedBox(height: AppSizes.lg),

            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),

            if (description != null) ...[
              const SizedBox(height: AppSizes.sm),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (buttonText != null && onButtonTap != null) ...[
              const SizedBox(height: AppSizes.xl),
              ElevatedButton(
                onPressed: onButtonTap,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xl,
                    vertical: AppSizes.md,
                  ),
                ),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    return Lottie.asset(
      animationPath,
      width: animationSize,
      height: animationSize,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.chat_bubble_outline_rounded,
        size: animationSize * 0.5,
        color: AppColors.primary.withValues(alpha: 0.3),
      ),
    );
  }
}
