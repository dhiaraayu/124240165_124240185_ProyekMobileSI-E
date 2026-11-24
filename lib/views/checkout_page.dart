import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ticket_package.dart';
import '../controllers/order_controller.dart';
import '../controllers/currency_controller.dart';
import '../controllers/auth_controller.dart';
import '../theme.dart';
import '../widgets/app_button.dart';
import '../widgets/currency_selector.dart';
import 'root_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late TicketPackage _ticket;
  late String _selectedAttendance;
  int _quantity = 1;
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final authCtrl = Get.find<AuthController>();
    _nameController.text = authCtrl.currentUserName.value;

    final arg = Get.arguments;
    if (arg is TicketPackage) {
      _ticket = arg;
    } else {
      _ticket = TicketPackage(
        id: 'super-pit',
        category: 'grandstand',
        name: 'Super Pit Grandstand',
        zoneAccess: '1, 2, 3, 4',
        gates: '1, 2',
        location: 'Pit Straight',
        price3Day: 2608,
        overview: [],
        description: '',
        imageAsset: '',
      );
    }

    _selectedAttendance = _ticket.availableDays.isNotEmpty
        ? _ticket.availableDays.first
        : '3-Day';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  double get _unitPriceSGD {
    return _ticket.getPriceForDay(_selectedAttendance) ?? _ticket.price3Day;
  }

  double get _totalPriceSGD {
    return _unitPriceSGD * _quantity;
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final orderCtrl = Get.find<OrderController>();
    final order = await orderCtrl.checkout(
      ticket: _ticket,
      attendance: _selectedAttendance,
      quantity: _quantity,
      attendeeName: _nameController.text.trim(),
      totalPriceSGD: _totalPriceSGD,
    );

    if (order != null && mounted) {
      // 06 Pesanan Berhasil Modal Dialog
      _showOrderSuccessDialog();
    }
  }

  void _showOrderSuccessDialog() {
    final currencyCtrl = Get.find<CurrencyController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.success, width: 2),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.success,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '06 Pesanan Berhasil!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Your Formula 1 Singapore GP 2027 booking is confirmed.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ticket:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        Text(_ticket.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Session:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        Text(_selectedAttendance, style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quantity:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        Text('$_quantity Tickets', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Paid:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        Text(
                          currencyCtrl.formatPrice(_totalPriceSGD),
                          style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Connects to "07 Tiketku"
              AppButton(
                text: 'View My Tickets (07 Tiketku)',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Get.offAll(() => const RootPage(initialIndex: 1));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyCtrl = Get.find<CurrencyController>();
    final orderCtrl = Get.find<OrderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('05 Checkout'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CurrencySelector(isCompact: true),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ticket Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.confirmation_number_outlined, color: AppTheme.f1Red),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _ticket.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_ticket.location} • Zone ${_ticket.zoneAccess}',
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Day Selection (Attendance)
              const Text(
                'Select Pass / Day',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _ticket.availableDays.map((day) {
                  final isSelected = _selectedAttendance == day;
                  final dayPrice = _ticket.getPriceForDay(day);

                  return ChoiceChip(
                    label: Text('$day (${currencyCtrl.formatPrice(dayPrice)})'),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedAttendance = day;
                        });
                      }
                    },
                    selectedColor: AppTheme.f1Red,
                    backgroundColor: AppTheme.cardBg,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textMuted,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.f1Red : AppTheme.cardBorder,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    showCheckmark: false,
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Quantity Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ticket Quantity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(height: 2),
                      Text('Max 10 per transaction', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                        ),
                        Text('$_quantity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: _quantity < 10 ? () => setState(() => _quantity++) : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Attendee Name
              const Text(
                'Ticket Holder Name',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter legal name matching passport / ID',
                  prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.textMuted),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter ticket holder name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Total Calculation Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Unit Price:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                        Text(currencyCtrl.formatPrice(_unitPriceSGD), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quantity:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                        Text('$_quantity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Processing Fee:', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                        const Text('FREE', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(color: AppTheme.cardBorder, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyCtrl.formatPrice(_totalPriceSGD),
                              style: const TextStyle(color: AppTheme.f1Red, fontWeight: FontWeight.w900, fontSize: 18),
                            ),
                            Text(
                              currencyCtrl.formatSgdEquivalent(_totalPriceSGD),
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Pay Button
              Obx(() => AppButton(
                    text: 'Pay & Confirm Order (${currencyCtrl.formatPrice(_totalPriceSGD)})',
                    isLoading: orderCtrl.isLoading.value,
                    onPressed: _submitPayment,
                  )),

              const SizedBox(height: 12),
              const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, size: 14, color: AppTheme.textMuted),
                    SizedBox(width: 6),
                    Text(
                      'Simulated Checkout • Instant Confirmation',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
