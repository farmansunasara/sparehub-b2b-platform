import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final VoidCallback? onTap;
  final bool elevated;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? shadowColor;
  final Border? border;
  final Widget? header;
  final Widget? footer;
  final CrossAxisAlignment crossAxisAlignment;
  final bool selected;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.elevated = true,
    this.elevation,
    this.borderRadius,
    this.shadowColor,
    this.border,
    this.header,
    this.footer,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) header!,
        Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
        if (footer != null) footer!,
      ],
    );

    final card = Card(
      elevation: elevated ? (elevation ?? 2) : 0,
      color: color ?? (selected ? Theme.of(context).colorScheme.primaryContainer : null),
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        side: border?.top ?? BorderSide.none,
      ),
      child: cardContent,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }

  // Factory constructors for common card styles
  factory CustomCard.outlined({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? color,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    Color? borderColor,
    Widget? header,
    Widget? footer,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    bool selected = false,
  }) {
    return CustomCard(
      child: child,
      padding: padding,
      color: color,
      onTap: onTap,
      elevated: false,
      borderRadius: borderRadius,
      border: Border.all(
        color: borderColor ?? Colors.grey[300]!,
      ),
      header: header,
      footer: footer,
      crossAxisAlignment: crossAxisAlignment,
      selected: selected,
    );
  }

  factory CustomCard.flat({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? color,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    Widget? header,
    Widget? footer,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    bool selected = false,
  }) {
    return CustomCard(
      child: child,
      padding: padding,
      color: color ?? Colors.grey[100],
      onTap: onTap,
      elevated: false,
      borderRadius: borderRadius,
      header: header,
      footer: footer,
      crossAxisAlignment: crossAxisAlignment,
      selected: selected,
    );
  }

  factory CustomCard.gradient({
    required Widget child,
    required List<Color> colors,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    Widget? header,
    Widget? footer,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return CustomCard(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        child: child,
      ),
      padding: padding,
      onTap: onTap,
      elevated: true,
      borderRadius: borderRadius,
      header: header,
      footer: footer,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  factory CustomCard.success({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    Widget? header,
    Widget? footer,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return CustomCard(
      child: child,
      padding: padding,
      color: Colors.green[50],
      onTap: onTap,
      elevated: false,
      borderRadius: borderRadius,
      border: Border.all(color: Colors.green[200]!),
      header: header,
      footer: footer,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  factory CustomCard.warning({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    Widget? header,
    Widget? footer,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return CustomCard(
      child: child,
      padding: padding,
      color: Colors.orange[50],
      onTap: onTap,
      elevated: false,
      borderRadius: borderRadius,
      border: Border.all(color: Colors.orange[200]!),
      header: header,
      footer: footer,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  factory CustomCard.error({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    Widget? header,
    Widget? footer,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return CustomCard(
      child: child,
      padding: padding,
      color: Colors.red[50],
      onTap: onTap,
      elevated: false,
      borderRadius: borderRadius,
      border: Border.all(color: Colors.red[200]!),
      header: header,
      footer: footer,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  factory CustomCard.info({
    required Widget child,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
    BorderRadius? borderRadius,
    Widget? header,
    Widget? footer,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return CustomCard(
      child: child,
      padding: padding,
      color: Colors.blue[50],
      onTap: onTap,
      elevated: false,
      borderRadius: borderRadius,
      border: Border.all(color: Colors.blue[200]!),
      header: header,
      footer: footer,
      crossAxisAlignment: crossAxisAlignment,
    );
  }
}
