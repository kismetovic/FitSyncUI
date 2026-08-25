import 'package:flutter/material.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';
import '../../../../../core/error/api_error_messages.dart';
import 'package:provider/provider.dart';
import '../../../payments/presentation/providers/payments_provider.dart';
import '../../../../core/utils/money.dart';

/// Payment step of the booking flow.
///
/// PayPal is handled through the official approval URL: the backend opens an order,
/// the user approves it on PayPal's own page in the browser, and the backend then
/// captures and verifies it. The app deliberately never asks for a PayPal password.
class ReservationPaymentPage extends StatefulWidget {
  /// Only the name is needed here, and taking a string rather than the whole
  /// entity lets the screen be opened from the bookings list too, where the
  /// reservation carries the name but not a Training object.
  final String trainingName;
  final int reservationId;
  final double totalAmount;

  const ReservationPaymentPage({
    super.key,
    required this.trainingName,
    required this.reservationId,
    required this.totalAmount,
  });

  @override
  State<ReservationPaymentPage> createState() => _ReservationPaymentPageState();
}

class _ReservationPaymentPageState extends State<ReservationPaymentPage>
    with WidgetsBindingObserver {
  static const _cashOption = 0;
  static const _payPalOption = 1;

  int _selectedPayment = _cashOption;

  /// Guards against two verification runs overlapping if the app is resumed twice.
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // The screen may be opened for a booking whose PayPal order was started
    // earlier and never settled - the app was killed in the background, or the
    // client simply never came back. Ask the server to finish it before showing
    // payment options for something that may already be paid at PayPal.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<PaymentsProvider>();
      final settled = await provider.resumePendingPayPal(widget.reservationId);
      if (!settled || !mounted) return;

      final capture = provider.lastCapture;
      _showResultDialog(
        title: 'Uplata evidentirana',
        message: 'Ranije započeto plaćanje na PayPal-u je dovršeno i provjereno: '
            '${formatMoney(capture?.amount ?? 0, currency: capture?.currency ?? "EUR")}.'
            '\n\nRezervacija za "${widget.trainingName}" je potvrđena.',
        icon: Icons.check_circle,
        color: const Color(0xFF27AE60),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The user approves on PayPal's own page, in the browser, which means this app is
  /// backgrounded. Coming back to the foreground is the signal that they are done —
  /// so the check starts by itself instead of asking the user to declare it.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    final provider = context.read<PaymentsProvider>();
    if (provider.stage == PayPalStage.awaitingApproval) {
      _verifyPayPal(provider);
    }
  }

  Future<void> _verifyPayPal(PaymentsProvider provider) async {
    if (_verifying) return;
    _verifying = true;

    // Every attempt is the server capturing and verifying with PayPal; the app is
    // only choosing when to ask.
    final ok = await provider.verifyPayPalPayment();
    _verifying = false;
    if (!mounted || !ok) return;

    final capture = provider.lastCapture;
    _showResultDialog(
      title: 'Uplata evidentirana',
      message: 'Server je potvrdio uplatu od '
          '${formatMoney(capture?.amount ?? 0, currency: capture?.currency ?? 'EUR')}.'
          '\n\nRezervacija za "${widget.trainingName}" je potvrđena.',
      icon: Icons.check_circle,
      color: const Color(0xFF27AE60),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Belt and braces. The confirmation screen already skips this page when a package
    // covers the booking, but nothing should ever offer to charge 0.00 BAM - and the
    // server would refuse such an order with NOTHING_TO_PAY.
    if (widget.totalAmount <= 0) return _NothingToPay(training: widget.trainingName);

    return Consumer<PaymentsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F1923),
          appBar: AppBar(
            backgroundColor: const Color(0xFF152030),
            foregroundColor: Colors.white,
            title: const Text('Plaćanje'),
            elevation: 0,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Odaberite način plaćanja',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _AmountSummary(training: widget.trainingName, amount: widget.totalAmount),
                const SizedBox(height: 24),

                _PaymentOption(
                  index: _cashOption,
                  selected: _selectedPayment,
                  icon: Icons.store,
                  title: 'Plati pri dolasku',
                  subtitle: 'Uplatu evidentira osoblje teretane na recepciji',
                  color: const Color(0xFF4A90D9),
                  onTap: provider.isLoading ? null : () => setState(() => _selectedPayment = _cashOption),
                ),
                const SizedBox(height: 12),
                _PaymentOption(
                  index: _payPalOption,
                  selected: _selectedPayment,
                  icon: Icons.account_balance_wallet,
                  title: 'PayPal',
                  subtitle: 'Plaćanje se obavlja na zvaničnoj PayPal stranici',
                  color: const Color(0xFF003087),
                  onTap: provider.isLoading ? null : () => setState(() => _selectedPayment = _payPalOption),
                ),

                if (provider.error != null) ...[
                  const SizedBox(height: 16),
                  _ErrorBanner(message: apiErrorText(context, provider.errorCode, provider.error), onDismiss: provider.clearError),
                ],

                const SizedBox(height: 20),

                if (_selectedPayment == _payPalOption)
                  _PayPalCheckout(
                    amount: widget.totalAmount,
                    provider: provider,
                    onStart: () => _startPayPal(provider),
                    onConfirm: () => _completePayPal(provider),
                  ),

                if (_selectedPayment == _cashOption) _buildCashSection(provider),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCashSection(PaymentsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2A3A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF4A90D9), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Rezervacija ostaje neplaćena dok osoblje teretane ne evidentira uplatu '
                  'prilikom Vašeg dolaska.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: provider.isLoading ? null : () => _chooseCash(provider),
            child: provider.isLoading
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Potvrdi plaćanje pri dolasku',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Future<void> _chooseCash(PaymentsProvider provider) async {
    final payment = await provider.chooseCashOnArrival(widget.reservationId);
    if (!mounted || payment == null) return;
    _showResultDialog(
      title: 'Rezervacija zabilježena',
      message: 'Vaša rezervacija za "${widget.trainingName}" je kreirana.\n\n'
          'Uplatu izvršite pri dolasku. Rezervacija će biti potvrđena kada osoblje '
          'evidentira uplatu.',
      icon: Icons.event_available,
      color: const Color(0xFF4A90D9),
    );
  }

  Future<void> _startPayPal(PaymentsProvider provider) async {
    final started = await provider.startPayPalCheckout(widget.reservationId);
    if (!mounted || !started) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dovršite plaćanje na PayPal stranici, zatim se vratite u aplikaciju.'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  /// Manual re-check, for the case where the automatic one ran before the user had
  /// finished at PayPal. It runs exactly the same server-side verification.
  Future<void> _completePayPal(PaymentsProvider provider) => _verifyPayPal(provider);

  void _showResultDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 64),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], height: 1.4)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: color),
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Završi', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountSummary extends StatelessWidget {
  final String training;
  final double amount;

  const _AmountSummary({required this.training, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, color: Color(0xFF4A90D9), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(training, style: const TextStyle(color: Colors.white70, fontSize: 14))),
          Text(
            formatMoney(amount),
            style: const TextStyle(color: Color(0xFFE8622A), fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// The real PayPal flow, in the two steps it actually has: send the user to PayPal,
/// then ask the backend to capture once they come back.
class _PayPalCheckout extends StatelessWidget {
  final double amount;
  final PaymentsProvider provider;
  final VoidCallback onStart;
  final VoidCallback onConfirm;

  const _PayPalCheckout({
    required this.amount,
    required this.provider,
    required this.onStart,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final awaitingApproval = provider.stage == PayPalStage.awaitingApproval ||
        provider.stage == PayPalStage.capturing;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF003087).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF003087),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(children: [
                  Text('Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Pal', style: TextStyle(color: Color(0xFF009CDE), fontWeight: FontWeight.bold, fontSize: 14)),
                ]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Checkout',
                    style: TextStyle(color: Colors.grey[300], fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _Step(
            number: 1,
            title: 'Otvorite PayPal',
            description: 'Bit ćete preusmjereni na zvaničnu PayPal stranicu gdje se '
                'prijavljujete svojim PayPal nalogom. PayPal ne prima KM, pa se '
                'naplaćuje protuvrijednost u eurima.',
            active: !awaitingApproval,
            done: awaitingApproval,
          ),
          const SizedBox(height: 12),
          _Step(
            number: 2,
            title: 'Vratite se u aplikaciju',
            description: 'Čim se vratite, FitSync server sam provjerava kod PayPal-a '
                'da li je uplata prošla, te potvrđuje iznos, valutu i rezervaciju. '
                'Vi ništa ne potvrđujete.',
            active: awaitingApproval,
            done: provider.stage == PayPalStage.completed,
          ),

          const SizedBox(height: 18),

          if (!awaitingApproval)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF009CDE),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: provider.isLoading ? null : onStart,
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.open_in_new, size: 18),
                label: Text(
                  // Once the order exists the server has told us the euro figure PayPal
                  // will actually take, so show it rather than let the PayPal page
                  // present a number the user has not seen before.
                  provider.order == null
                      ? 'Plati ${formatMoney(amount)} putem PayPal-a'
                      : 'Plati ${formatMoney(amount)} '
                          '(≈ ${formatMoney(provider.order!.chargedAmount, currency: provider.order!.chargedCurrency)})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),

          // No "I have paid" button: the client never declares a payment successful.
          // The app checks with the server on its own as soon as the user returns
          // from PayPal, and only reports what the server found.
          if (awaitingApproval) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2A3A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(children: [
                if (provider.isLoading)
                  const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(color: Color(0xFFE8622A), strokeWidth: 2))
                else
                  Icon(
                    provider.notApprovedYet ? Icons.hourglass_empty : Icons.sync,
                    color: const Color(0xFFE8622A), size: 18,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    provider.isLoading
                        ? 'Provjeravamo uplatu kod PayPal-a...'
                        : provider.notApprovedYet
                            ? 'Plaćanje još nije odobreno. Dovršite ga na PayPal-u — '
                                'provjera kreće sama čim se vratite.'
                            : 'Čekamo Vaš povratak sa PayPal-a.',
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: provider.isLoading ? null : onStart,
                  icon: const Icon(Icons.open_in_new, size: 16, color: Colors.white54),
                  label: const Text('Ponovo otvori PayPal',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  // A re-check, not a declaration: it asks the server to look again.
                  onPressed: provider.isLoading ? null : onConfirm,
                  icon: const Icon(Icons.refresh, size: 16, color: Colors.white54),
                  label: const Text('Provjeri ponovo',
                      style: TextStyle(color: Colors.white54, fontSize: 13)),
                ),
              ),
            ]),
          ],

          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.security, color: Colors.grey[600], size: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'FitSync nikada ne traži i ne pohranjuje Vašu PayPal lozinku.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final bool active;
  final bool done;

  const _Step({
    required this.number,
    required this.title,
    required this.description,
    required this.active,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final color = done
        ? const Color(0xFF27AE60)
        : active
            ? const Color(0xFF009CDE)
            : Colors.grey.shade700;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.18), shape: BoxShape.circle),
          child: Center(
            child: done
                ? Icon(Icons.check, size: 15, color: color)
                : Text('$number', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    color: active || done ? Colors.white : Colors.white54,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  )),
              const SizedBox(height: 2),
              Text(description, style: TextStyle(color: Colors.grey[500], fontSize: 12, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 13))),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close, color: Colors.red, size: 16),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final int index;
  final int selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _PaymentOption({
    required this.index,
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
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
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.w600,
                      )),
                  Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? color : Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when a reservation costs nothing because a monthly package covers it.
class _NothingToPay extends StatelessWidget {
  final String training;

  const _NothingToPay({required this.training});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        backgroundColor: const Color(0xFF152030),
        foregroundColor: Colors.white,
        title: Text(l.nothingToPayTitle),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_membership, color: Color(0xFF2E7D32), size: 72),
            const SizedBox(height: 20),
            Text(l.reservationConfirmed,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(l.coveredByPackageBody(training),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.5)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                child: Text(l.finish,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
