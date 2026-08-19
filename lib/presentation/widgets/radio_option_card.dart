import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/glossy.dart';

class RadioOptionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const RadioOptionCard({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: isSelected
            ? BoxDecoration(
                gradient: AppColors.buttonGloss,
                borderRadius: BorderRadius.circular(AppGloss.radiusSm),
                boxShadow: AppGloss.buttonGlow,
              )
            : AppGloss.panel(
                color: AppColors.optionTile,
                r: AppGloss.radiusSm,
              ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.textWhite : Colors.black87,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
