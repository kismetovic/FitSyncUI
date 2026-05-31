import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/trainings/domain/entities/training.dart';
import '../../../payments/presentation/providers/payments_provider.dart';

class ReservationPaymentPage extends StatefulWidget {
  final Training training;
  final int reservationId;
  final double totalAmount;

  ReservationPaymentPage({
    super.key,
    required this.training,
    required this.reservationId,
    double? totalAmount,
  }) : totalAmount = totalAmount ?? training.price;

  @override
  State<ReservationPaymentPage> createState() => _ReservationPaymentPageState();
}

class _ReservationPaymentPageState extends State<ReservationPaymentPage> {
  int _selectedPayment = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F1923),
          appBar: AppBar(
            backgroundColor: const Color(0xFF152030),
            foregroundColor: Colors.white,
            title: const Text('Placanje'),
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Odaberite nacin placanja',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Iznos: \$${widget.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Color(0xFFE8622A), fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                _PaymentOption(
                  index: 0,
                  selected: _selectedPayment,
                  icon: Icons.store,
                  title: 'Plati pri dolasku',
                  subtitle: 'Plati gotovinom ili karticom kada dodes',
                  color: const Color(0xFF4A90D9),
                  onTap: () => setState(() => _selectedPayment = 0),
                ),
                const SizedBox(height: 12),
                _PaymentOption(
                  index: 1,
                  selected: _selectedPayment,
                  icon: Icons.account_balance_wallet,
                  title: 'PayPal',
                  subtitle: 'Plati sigurno putem PayPal-a',
                  color: const Color(0xFF003087),
                  onTap: () => setState(() => _selectedPayment = 1),
                ),
                if (provider.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(provider.error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (_selectedPayment == 1)
                  _PayPalForm(
                    amount: widget.totalAmount,
                    trainingName: widget.training.name,
                    loading: provider.isLoading,
                    onPay: (email) => _handlePayPal(context, provider),
                  ),
                if (_selectedPayment == 0)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: provider.isLoading ? null : () => _handleCash(context, provider),
                      child: provider.isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Potvrdi rezervaciju', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCash(BuildContext context, PaymentsProvider provider) async {
    final payment = await provider.payCash(
      amount: widget.totalAmount,
      reservationId: widget.reservationId,
    );
    if (!mounted) return;
    if (payment != null) _showSuccess(context, paypal: false);
  }

  Future<void> _handlePayPal(BuildContext context, PaymentsProvider provider) async {
    final order = await provider.initiatePayPal(
      amount: widget.totalAmount,
      reservationId: widget.reservationId,
    );
    if (!mounted || order == null) return;

    final orderId = order['orderId'] ?? 'PAYPAL-${DateTime.now().millisecondsSinceEpoch}';
    final payment = await provider.finishPayPal(
      amount: widget.totalAmount,
      transactionId: orderId,
      reservationId: widget.reservationId,
    );
    if (!mounted) return;
    if (payment != null) _showSuccess(context, paypal: true);
  }

  void _showSuccess(BuildContext context, {required bool paypal}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF27AE60), size: 64),
            const SizedBox(height: 16),
            const Text(
              'Rezervacija potvrdena!',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              paypal
                  ? 'Uplata putem PayPal-a uspjesna.\nVasa rezervacija za "${widget.training.name}" je potvrdena.'
                  : 'Vasa rezervacija za "${widget.training.name}" je kreirana.\nPlatite pri dolasku.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60)),
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Zavrsi', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final int index, selected;
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.index, required this.selected,
    required this.icon, required this.title, required this.subtitle,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selected;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.white12, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? color : Colors.grey[600], size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PayPalForm extends StatefulWidget {
  final double amount;
  final String trainingName;
  final bool loading;
  final void Function(String email) onPay;

  const _PayPalForm({
    required this.amount,
    required this.trainingName,
    required this.loading,
    required this.onPay,
  });

  @override
  State<_PayPalForm> createState() => _PayPalFormState();
}

class _PayPalFormState extends State<_PayPalForm> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF003087).withValues(alpha: 0.4)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF003087), borderRadius: BorderRadius.circular(6)),
                  child: const Row(children: [
                    Text('Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Pal', style: TextStyle(color: Color(0xFF009CDE), fontWeight: FontWeight.bold, fontSize: 14)),
                  ]),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text('Checkout', style: TextStyle(color: Colors.grey[300], fontSize: 14, fontWeight: FontWeight.w500))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(children: [
                    Icon(Icons.lock, color: Color(0xFF27AE60), size: 12),
                    SizedBox(width: 4),
                    Text('Sigurno', style: TextStyle(color: Color(0xFF27AE60), fontSize: 11)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF0F1923), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.fitness_center, color: Color(0xFF4A90D9), size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(widget.trainingName, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                  Text('\$${widget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('PayPal Email', Icons.email_outlined),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Unesite PayPal email';
                if (!v.contains('@')) return 'Unesite ispravnu email adresu';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('PayPal Lozinka', Icons.lock_outline).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey[500], size: 18),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Unesite PayPal lozinku';
                if (v.length < 6) return 'Lozinka mora imati najmanje 6 znakova';
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009CDE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: widget.loading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          widget.onPay(_emailCtrl.text);
                        }
                      },
                child: widget.loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Plati \$${widget.amount.toStringAsFixed(2)} putem PayPal-a',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.security, color: Colors.grey[600], size: 12),
                  const SizedBox(width: 4),
                  Text('Zasticeno od strane PayPal-a — 256-bit SSL enkripcija',
                      style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 18),
      filled: true,
      fillColor: const Color(0xFF243347),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF009CDE)),
      ),
    );
  }
}
