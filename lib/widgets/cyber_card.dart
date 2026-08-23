import 'package:flutter/material.dart';
import '../theme/cyber_theme.dart';

class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool glow;

  const CyberCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = 12.0,
    this.onTap,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = borderColor ?? (glow ? CyberTheme.cyan : CyberTheme.cardBorder);
    final effectiveBg = backgroundColor ?? CyberTheme.cardDark;

    Widget card = Container(
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: effectiveBorder, width: glow ? 1.5 : 1),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: CyberTheme.cyan.withOpacity(0.18),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: card,
      );
    }
    return card;
  }
}
