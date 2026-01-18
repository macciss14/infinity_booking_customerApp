// lib/utils/theme_utils.dart - CORRECTED VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeUtils {
  // Simple helper method to get themed icon
  static Icon themedIcon({
    required BuildContext context,
    required IconData icon,
    double? size,
    Color? color,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Icon(
      icon,
      size: size,
      color: color ?? themeProvider.textColor,
    );
  }

  // Simple helper method to get themed card
  static Card themedCard({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    double? elevation,
    BorderRadiusGeometry? borderRadius,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Card(
      color: color ?? themeProvider.surfaceColor,
      elevation: elevation ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  // Simple helper method to get themed elevated button
  static ElevatedButton themedElevatedButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required Widget child,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    bool? enabled,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return ElevatedButton(
      onPressed: enabled == false ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: minimumSize,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: child,
    );
  }

  // Simple helper method to get themed outlined button
  static OutlinedButton themedOutlinedButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required Widget child,
    Color? borderColor,
    Color? textColor,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? themeProvider.primaryColor,
        side: BorderSide(color: borderColor ?? themeProvider.primaryColor),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: minimumSize,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: child,
    );
  }

  // Simple helper method to get themed text button
  static TextButton themedTextButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required Widget child,
    Color? textColor,
    EdgeInsetsGeometry? padding,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? themeProvider.primaryColor,
        padding: padding,
      ),
      child: child,
    );
  }

  // Helper to get text style with theme color
  static TextStyle textStyle(BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? themeProvider.textColor,
    );
  }

  // Helper to get secondary text style
  static TextStyle secondaryTextStyle(BuildContext context, {
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: themeProvider.secondaryTextColor,
    );
  }

  // Helper to get themed container
  static Container themedContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    BorderRadiusGeometry? borderRadius,
    BoxBorder? border,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? themeProvider.surfaceColor,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: border ?? Border.all(color: themeProvider.borderColor),
      ),
      child: child,
    );
  }

  // Helper to get themed divider
  static Divider themedDivider({
    required BuildContext context,
    double? thickness,
    Color? color,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Divider(
      thickness: thickness ?? 1,
      color: color ?? themeProvider.borderColor,
    );
  }

  // Simple themed Chip (without selected parameter)
  static Chip themedChip({
    required BuildContext context,
    required String label,
    Color? backgroundColor,
    Color? labelColor,
    Widget? avatar,
    VoidCallback? onDeleted,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: labelColor ?? themeProvider.textColor),
      ),
      backgroundColor: backgroundColor ?? themeProvider.surfaceColor,
      avatar: avatar,
      deleteIcon: onDeleted != null ? const Icon(Icons.close) : null,
      onDeleted: onDeleted,
    );
  }

  // Helper for FilterChip (if you need selected state)
  static FilterChip themedFilterChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    Color? selectedColor,
    Color? labelColor,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(color: labelColor ?? themeProvider.textColor),
      ),
      selected: selected,
      onSelected: onSelected,
      selectedColor: selectedColor ?? themeProvider.primaryColor.withOpacity(0.2),
      checkmarkColor: themeProvider.primaryColor,
      backgroundColor: themeProvider.surfaceColor,
    );
  }
}