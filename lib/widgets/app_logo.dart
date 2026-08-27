import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const AppLogo({
    super.key,
    this.size = 44,
    this.showText = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.heroGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
          ),
          padding: const EdgeInsets.all(2.5),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.heroGradient,
                  ),
                  child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 24),
                );
              },
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Fusion',
                  style: GoogleFonts.outfit(
                    fontSize: size * 0.48,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    letterSpacing: -0.6,
                  ),
                ),
                TextSpan(
                  text: 'Fiesta',
                  style: GoogleFonts.outfit(
                    fontSize: size * 0.48,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondaryDark,
                    letterSpacing: -0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final bool isLive;

  const StatusBadge({
    super.key,
    required this.status,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData? icon;

    switch (status.toLowerCase()) {
      case 'live':
      case 'live now':
        bg = AppColors.statusLive;
        fg = Colors.white;
        icon = Icons.fiber_manual_record;
        break;
      case 'approved':
      case 'upcoming':
        bg = AppColors.primary;
        fg = Colors.white;
        icon = Icons.event_available;
        break;
      case 'pending':
      case 'pending approval':
        bg = AppColors.statusPending;
        fg = Colors.white;
        icon = Icons.hourglass_top;
        break;
      case 'completed':
        bg = AppColors.statusCompleted;
        fg = Colors.white;
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
      case 'rejected':
        bg = AppColors.statusCancelled;
        fg = Colors.white;
        icon = Icons.cancel_outlined;
        break;
      default:
        bg = Colors.grey;
        fg = Colors.white;
    }

    final isLiveNow = status.toLowerCase() == 'live' || status.toLowerCase() == 'live now' || isLive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLiveNow ? bg : bg.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLiveNow ? Colors.white.withOpacity(0.4) : bg.withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: bg.withOpacity(isLiveNow ? 0.4 : 0.15),
            blurRadius: isLiveNow ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: isLiveNow ? fg : bg),
            const SizedBox(width: 4),
          ],
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: isLiveNow ? fg : bg,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
