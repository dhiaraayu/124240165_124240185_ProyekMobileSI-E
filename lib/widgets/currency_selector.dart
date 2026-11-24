import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/currency_controller.dart';
import '../theme.dart';

class CurrencySelector extends StatelessWidget {
  final bool isCompact;

  const CurrencySelector({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final currencyCtrl = Get.find<CurrencyController>();

    return Obx(() {
      final current = currencyCtrl.selectedCurrency.value;

      if (isCompact) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.surfaceBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: current,
              icon: const Icon(Icons.arrow_drop_down,
                  color: AppTheme.textWhite, size: 18),
              dropdownColor: AppTheme.surfaceBg,
              isDense: true,
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              items: const [
                DropdownMenuItem(value: 'SGD', child: Text('SGD (S\$)')),
                DropdownMenuItem(value: 'IDR', child: Text('IDR (Rp)')),
                DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
              ],
              onChanged: (val) {
                if (val != null) currencyCtrl.setCurrency(val);
              },
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: ['SGD', 'IDR', 'USD'].map((curr) {
            final isSelected = current == curr;
            return GestureDetector(
              onTap: () => currencyCtrl.setCurrency(curr),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.f1Red : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  curr,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}
