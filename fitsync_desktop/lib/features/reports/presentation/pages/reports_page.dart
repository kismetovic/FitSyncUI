import 'package:flutter/material.dart';
import '../../../../core/error/api_error_messages.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import '../providers/reports_provider.dart';

/// The two PDF reports required for the desktop application:
/// reservations over a period, and revenue per training. Both can be previewed,
/// printed and downloaded, and both are built from API data only.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  static final _dateFormat = DateFormat('dd.MM.yyyy');

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F1923),
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Izvještaji',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Podaci se u cijelosti dohvaćaju iz FitSync API-ja i mogu se preuzeti ili odštampati.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                const SizedBox(height: 20),

                _ControlsCard(provider: provider, dateFormat: _dateFormat),
                const SizedBox(height: 16),

                if (provider.error != null) ...[
                  _ErrorBanner(message: apiErrorText(context, provider.errorCode, provider.error)),
                  const SizedBox(height: 12),
                ],

                Expanded(child: _PreviewArea(provider: provider)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ControlsCard extends StatelessWidget {
  final ReportsProvider provider;
  final DateFormat dateFormat;

  const _ControlsCard({required this.provider, required this.dateFormat});

  Future<void> _pickDate(BuildContext context, {required bool isFrom}) async {
    final initial = isFrom ? provider.from : provider.to;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE8622A),
            surface: Color(0xFF1E2A3A),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    provider.setPeriod(from: isFrom ? picked : null, to: isFrom ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _ReportKindChip(
                label: 'Rezervacije po periodu',
                icon: Icons.event_note,
                selected: provider.kind == ReportKind.reservations,
                onTap: () => provider.setKind(ReportKind.reservations),
              ),
              _ReportKindChip(
                label: 'Uplate i prihodi po treningu',
                icon: Icons.payments,
                selected: provider.kind == ReportKind.revenue,
                onTap: () => provider.setKind(ReportKind.revenue),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _DateField(
                label: 'Od',
                value: dateFormat.format(provider.from),
                onTap: () => _pickDate(context, isFrom: true),
              ),
              _DateField(
                label: 'Do',
                value: dateFormat.format(provider.to),
                onTap: () => _pickDate(context, isFrom: false),
              ),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading ? null : provider.generate,
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.assessment, size: 18),
                  label: const Text('Generiši izvještaj'),
                ),
              ),
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: provider.hasReport ? provider.downloadReport : null,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Preuzmi PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: provider.hasReport ? provider.printReport : null,
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text('Štampaj'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewArea extends StatelessWidget {
  final ReportsProvider provider;

  const _PreviewArea({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFE8622A)));
    }

    final bytes = provider.pdfBytes;
    if (bytes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf_outlined, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              'Odaberite izvještaj i period, zatim kliknite "Generiši izvještaj".',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: PdfPreview(
        build: (_) => bytes,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName: '${provider.kind.fileNamePrefix}.pdf',
        loadingWidget: const CircularProgressIndicator(color: Color(0xFFE8622A)),
      ),
    );
  }
}

class _ReportKindChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ReportKindChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE8622A);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.15) : const Color(0xFF243347),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? accent : Colors.white12, width: selected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: selected ? accent : Colors.grey[400]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey[400],
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF243347),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$label: ', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today, size: 15, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red, fontSize: 13))),
        ],
      ),
    );
  }
}
