import 'package:flutter/material.dart';
import 'package:news_app/utils/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.surfaceAlt,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : AppColors.textSecondary),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          fontSize: 12,
        ),
        avatar: isSelected
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
        side: BorderSide(
          color: isSelected
              ? AppColors.primary
              : (isDark ? Colors.transparent : AppColors.divider),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
