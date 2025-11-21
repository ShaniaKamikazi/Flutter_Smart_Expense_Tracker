import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;
  final Color? gradientStartColor; // New: for colorful tint
  final Color? gradientEndColor; // New: for colorful tint

  const GlassmorphismCard({
    Key? key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 10,
    this.opacity = 0.95,
    this.padding,
    this.margin,
    this.borderColor,
    this.backgroundColor,
    this.width,
    this.height,
    this.boxShadow,
    this.gradientStartColor,
    this.gradientEndColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = isDark 
        ? Theme.of(context).colorScheme.surface
        : Colors.white;
    final bgColor = backgroundColor ?? defaultBgColor;

    // Determine gradient colors with colorful tint
    final gradientStart = gradientStartColor ?? (isDark ? Colors.white : bgColor);
    final gradientEnd = gradientEndColor ?? (isDark ? Colors.white : bgColor);

    if (isDark) {
      // Dark mode: Enhanced glassmorphism with colorful tint
      return Container(
        width: width,
        height: height,
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur * 1.5, sigmaY: blur * 1.5),
            child: Container(
              padding: padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientStartColor != null
                      ? [
                          gradientStart.withOpacity(0.15),
                          gradientEnd.withOpacity(0.08),
                        ]
                      : [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.04),
                        ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderColor ?? 
                      (gradientStartColor != null 
                          ? gradientStart.withOpacity(0.3) 
                          : Colors.white.withOpacity(0.15)),
                  width: 1.5,
                ),
                boxShadow: boxShadow ?? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: -5,
                    offset: const Offset(0, 10),
                  ),
                  if (gradientStartColor != null)
                    BoxShadow(
                      color: gradientStart.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: -2,
                      offset: const Offset(0, -5),
                    )
                  else
                    BoxShadow(
                      color: Colors.white.withOpacity(0.03),
                      blurRadius: 15,
                      spreadRadius: -2,
                      offset: const Offset(0, -5),
                    ),
                ],
              ),
              child: child,
            ),
          ),
        ),
      );
    } else {
      // Light mode: Colorful glassmorphism card with tint
      return Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: boxShadow ?? [
            BoxShadow(
              color: (gradientStartColor ?? Colors.black).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: (gradientStartColor ?? Colors.black).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              padding: padding ?? const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderColor ?? 
                      (gradientStartColor != null 
                          ? gradientStart.withOpacity(0.3) 
                          : Colors.white.withOpacity(0.3)),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientStartColor != null
                      ? [
                          gradientStart.withOpacity(0.2),
                          gradientEnd.withOpacity(0.1),
                        ]
                      : [
                          bgColor.withOpacity(opacity),
                          bgColor.withOpacity(opacity * 0.8),
                        ],
                ),
              ),
              child: child,
            ),
          ),
        ),
      );
    }
  }
}
