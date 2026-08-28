import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Ambient mesh glow background for true Glassmorphism depth
class AmbientGlassBackground extends StatelessWidget {
  final Widget child;
  final bool showGlows;

  const AmbientGlassBackground({
    super.key,
    required this.child,
    this.showGlows = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Solid canvas backdrop
        Container(
          width: double.infinity,
          height: double.infinity,
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        ),

        if (showGlows) ...[
          // Top-Left Primary Sapphire Glow Orb
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFF1D4ED8) : const Color(0xFF60A5FA)).withOpacity(isDark ? 0.30 : 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Top-Right Electric Cyan Glow Orb
          Positioned(
            top: 40,
            right: -60,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFF06B6D4) : const Color(0xFF38BDF8)).withOpacity(isDark ? 0.25 : 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Center-Right Amber / Golden Glow Orb
          Positioned(
            top: size.height * 0.40,
            right: -50,
            child: Container(
              width: size.width * 0.65,
              height: size.width * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFF59E0B).withOpacity(isDark ? 0.15 : 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom-Left Emerald Glow Orb
          Positioned(
            bottom: -60,
            left: -30,
            child: Container(
              width: size.width * 0.75,
              height: size.width * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(isDark ? 0.20 : 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],

        // Child Content
        child,
      ],
    );
  }
}

/// Frosted Glass Container with Real Backdrop Blur and Crisp Highlight Border
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurSigma;
  final Color? customColor;
  final Border? customBorder;
  final Color? glowColor;
  final VoidCallback? onTap;
  final BoxConstraints? constraints;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blurSigma = 16,
    this.customColor,
    this.customBorder,
    this.glowColor,
    this.onTap,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBgColor = customColor ??
        (isDark
            ? const Color(0xFF0F172A).withOpacity(0.60)
            : Colors.white.withOpacity(0.68));

    final effectiveBorder = customBorder ??
        Border.all(
          color: isDark ? Colors.white.withOpacity(0.14) : Colors.white.withOpacity(0.75),
          width: 1.2,
        );

    Widget content = Container(
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? (isDark ? Colors.black : AppColors.primary)).withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: defaultBgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: effectiveBorder,
              gradient: isDark
                  ? LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.75),
                        Colors.white.withOpacity(0.40),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Frosted Glass Metric KPI Card
class GlassMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const GlassMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: onTap,
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      glowColor: accentColor,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accentColor.withOpacity(0.35), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// High-Performance Frosted Glass Interactive Button with Tactile Feedback
class GlassButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isLoading;
  final Color? color;
  final double height;
  final double? width;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isLoading = false,
    this.color,
    this.height = 48,
    this.width,
    this.borderRadius = 14,
    this.padding,
    this.textStyle,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final effectiveColor = widget.color ?? (widget.isPrimary ? AppColors.primary : (isDark ? AppColors.secondaryLight : AppColors.primary));

    // Colors according to state
    Color textColor;
    Color iconColor;
    Gradient? backgroundGradient;
    Color? backgroundColor;
    List<BoxShadow>? shadows;
    Border border;

    if (!isEnabled && !widget.isLoading) {
      // Disabled state
      textColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
      iconColor = textColor;
      backgroundGradient = null;
      backgroundColor = isDark ? const Color(0xFF1E293B).withOpacity(0.5) : const Color(0xFFE2E8F0).withOpacity(0.7);
      shadows = null;
      border = Border.all(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06),
        width: 1,
      );
    } else if (widget.isPrimary) {
      // Primary state
      textColor = Colors.white;
      iconColor = Colors.white;
      backgroundGradient = widget.color != null
          ? LinearGradient(
              colors: [widget.color!, widget.color!.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : AppColors.heroGradient;
      backgroundColor = null;
      shadows = [
        BoxShadow(
          color: (widget.color ?? AppColors.primary).withOpacity(isDark ? 0.40 : 0.28),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];
      border = Border.all(
        color: Colors.white.withOpacity(0.35),
        width: 1.2,
      );
    } else {
      // Secondary / Frosted Outline state
      textColor = effectiveColor;
      iconColor = effectiveColor;
      backgroundGradient = null;
      backgroundColor = isDark
          ? const Color(0xFF0F172A).withOpacity(0.7)
          : Colors.white.withOpacity(0.85);
      shadows = [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
      border = Border.all(
        color: effectiveColor.withOpacity(0.45),
        width: 1.3,
      );
    }

    return AnimatedScale(
      scale: _isPressed && isEnabled ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: backgroundGradient,
          color: backgroundColor,
          border: border,
          boxShadow: shadows,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: InkWell(
            onTap: isEnabled ? widget.onPressed : null,
            onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
            onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
            onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            splashColor: widget.isPrimary ? Colors.white.withOpacity(0.2) : effectiveColor.withOpacity(0.15),
            highlightColor: widget.isPrimary ? Colors.white.withOpacity(0.1) : effectiveColor.withOpacity(0.08),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 18),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: widget.isPrimary ? Colors.white : effectiveColor,
                          strokeWidth: 2.2,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: 18,
                              color: iconColor,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              widget.label,
                              style: widget.textStyle ??
                                  GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    letterSpacing: 0.2,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted Glass Rounded Icon Button
class GlassIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = 40,
    this.iconSize = 20,
    this.tooltip,
  });

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null;
    final effIconColor = widget.iconColor ?? (isDark ? Colors.white : AppColors.primary);

    Widget button = AnimatedScale(
      scale: _isPressed && isEnabled ? 0.92 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.backgroundColor ??
              (isDark
                  ? const Color(0xFF0F172A).withOpacity(0.65)
                  : Colors.white.withOpacity(0.75)),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.18) : Colors.white.withOpacity(0.9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: isEnabled ? widget.onPressed : null,
            onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
            onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
            onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
            splashColor: effIconColor.withOpacity(0.18),
            highlightColor: effIconColor.withOpacity(0.08),
            child: Center(
              child: Icon(
                widget.icon,
                size: widget.iconSize,
                color: isEnabled ? effIconColor : effIconColor.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

/// Frosted Glass Badge / Chip
class GlassBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool showGlowDot;

  const GlassBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.showGlowDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.40), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showGlowDot) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ] else if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
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

/// Frosted Glass Search & Input Field
class GlassTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final AutovalidateMode? autovalidateMode;

  const GlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A).withOpacity(0.55) : Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.85),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            onChanged: onChanged,
            validator: validator,
            autovalidateMode: autovalidateMode ?? (validator != null ? AutovalidateMode.onUserInteraction : null),
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              labelText: labelText,
              filled: false,
              isDense: true,
              prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 38),
              suffixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 38),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              errorStyle: GoogleFonts.inter(
                color: AppColors.error,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primary, size: 20) : null,
              suffixIcon: suffixIcon,
              hintStyle: GoogleFonts.inter(
                color: AppColors.textMutedLight,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted Glass Overflow-Safe Dropdown
class GlassDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final FormFieldValidator<T>? validator;
  final double borderRadius;

  const GlassDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.validator,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A).withOpacity(0.55) : Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.85),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              validator: validator,
              isExpanded: true,
              isDense: true,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary, size: 24),
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                labelText: labelText,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primary, size: 20) : null,
                errorStyle: GoogleFonts.inter(
                  color: AppColors.error,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
