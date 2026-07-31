import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/app_colors.dart';

class LicenseTypeToggle extends StatelessWidget {
  final LicenseType selectedType;
  final ValueChanged<LicenseType> onTypeChanged;

  const LicenseTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface(selectedType, isDark),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _LicenseButton(
              type: LicenseType.a1,
              isSelected: selectedType == LicenseType.a1,
              onTap: () => onTypeChanged(LicenseType.a1),
            ),
          ),
          Expanded(
            child: _LicenseButton(
              type: LicenseType.a2,
              isSelected: selectedType == LicenseType.a2,
              onTap: () => onTypeChanged(LicenseType.a2),
            ),
          ),
        ],
      ),
    );
  }
}

class _LicenseButton extends StatelessWidget {
  final LicenseType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _LicenseButton({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primary(type, isDark);
    final text = AppColors.text(type, isDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(type.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  type.displayName,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : text.withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
