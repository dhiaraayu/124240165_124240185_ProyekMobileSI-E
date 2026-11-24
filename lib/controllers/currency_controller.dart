import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/local_service.dart';

class CurrencyController extends GetxController {
  final ApiService _apiService = ApiService();

  final selectedCurrency = 'SGD'.obs; // 'SGD' | 'IDR' | 'USD'
  final exchangeRates = ExchangeRates.fallback().obs;
  final isLoadingRates = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedCurrency.value = LocalService.selectedCurrency;
    fetchRates();
  }

  Future<void> fetchRates() async {
    isLoadingRates.value = true;
    try {
      final rates = await _apiService.fetchExchangeRates();
      exchangeRates.value = rates;
    } finally {
      isLoadingRates.value = false;
    }
  }

  void setCurrency(String currency) {
    if (selectedCurrency.value != currency) {
      selectedCurrency.value = currency;
      LocalService.setCurrency(currency);
    }
  }

  double convert(double priceSGD) {
    switch (selectedCurrency.value) {
      case 'IDR':
        return priceSGD * exchangeRates.value.sgdToIdr;
      case 'USD':
        return priceSGD * exchangeRates.value.sgdToUsd;
      case 'SGD':
      default:
        return priceSGD;
    }
  }

  String formatPrice(double? priceSGD, {bool showCurrency = true}) {
    if (priceSGD == null || priceSGD <= 0) return 'Not Available';
    final converted = convert(priceSGD);

    switch (selectedCurrency.value) {
      case 'IDR':
        final formatter = NumberFormat.currency(
          locale: 'id_ID',
          symbol: showCurrency ? 'Rp ' : '',
          decimalDigits: 0,
        );
        return formatter.format(converted);
      case 'USD':
        final formatter = NumberFormat.currency(
          locale: 'en_US',
          symbol: showCurrency ? '\$ ' : '',
          decimalDigits: converted % 1 == 0 ? 0 : 2,
        );
        return formatter.format(converted);
      case 'SGD':
      default:
        final formatter = NumberFormat.currency(
          locale: 'en_SG',
          symbol: showCurrency ? 'S\$ ' : '',
          decimalDigits: 0,
        );
        return formatter.format(converted);
    }
  }

  String formatSgdEquivalent(double priceSGD) {
    if (selectedCurrency.value == 'SGD') return '';
    final formatter = NumberFormat.currency(
      locale: 'en_SG',
      symbol: 'S\$ ',
      decimalDigits: 0,
    );
    return '(${formatter.format(priceSGD)} SGD)';
  }
}
