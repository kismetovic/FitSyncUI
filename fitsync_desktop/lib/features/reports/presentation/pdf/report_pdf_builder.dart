import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/entities/reservation_report.dart';
import '../../domain/entities/revenue_report.dart';

/// Renders the two required desktop reports as printable, downloadable PDFs.
///
/// Every number printed here comes from the API response; nothing is recalculated
/// locally, so a printed report always agrees with the database.
class ReportPdfBuilder {
  static final _dateFormat = DateFormat('dd.MM.yyyy');
  static final _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

  static const _accent = PdfColor.fromInt(0xFFE8622A);
  static const _dark = PdfColor.fromInt(0xFF152030);
  static const _muted = PdfColor.fromInt(0xFF6B7280);
  static const _stripe = PdfColor.fromInt(0xFFF5F6F8);

  static String _money(double value) => value.toStringAsFixed(2);

  /// The pdf package falls back to Helvetica, whose encoding has no glyphs for
  /// c, c, z, s or d with diacritics - Bosnian names printed as empty boxes.
  /// Roboto is bundled with the app and covers Latin Extended-A.
  static pw.ThemeData? _theme;

  static Future<pw.ThemeData> _loadTheme() async {
    if (_theme != null) return _theme!;
    final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));
    _theme = pw.ThemeData.withFont(base: regular, bold: bold);
    return _theme!;
  }


  // ------------------------------------------------------------------
  // Report 1: reservations in a period
  // ------------------------------------------------------------------

  static Future<Uint8List> buildReservationReport(ReservationReport report) async {
    final document = pw.Document(
      title: 'FitSync - Izvjestaj o rezervacijama',
      author: 'FitSync',
      theme: await _loadTheme(),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => _header(
          context,
          title: 'Izvještaj o rezervacijama',
          subtitle: 'Period: ${_dateFormat.format(report.from)} - ${_dateFormat.format(report.to)}',
          generatedAt: report.generatedAt,
        ),
        footer: _footer,
        build: (context) => [
          _summaryRow([
            _summaryCard('Ukupno rezervacija', '${report.totalReservations}'),
            _summaryCard('Plaćene', '${report.paidReservations}'),
            _summaryCard('Završene', '${report.completedReservations}'),
            _summaryCard('Otkazane', '${report.cancelledReservations}'),
            _summaryCard('Vrijednost', '${_money(report.totalValue)} BAM', highlight: true),
          ]),
          pw.SizedBox(height: 18),

          if (report.statusBreakdown.isNotEmpty) ...[
            _sectionTitle('Pregled po statusu'),
            pw.SizedBox(height: 6),
            pw.Wrap(
              spacing: 8,
              runSpacing: 6,
              children: report.statusBreakdown
                  .map((s) => _chip('${s.status.label}: ${s.count}'))
                  .toList(),
            ),
            pw.SizedBox(height: 18),
          ],

          _sectionTitle('Detaljan pregled'),
          pw.SizedBox(height: 6),

          if (report.rows.isEmpty)
            _emptyNotice('Nema rezervacija u odabranom periodu.')
          else
            _table(
              headers: const ['#', 'Datum i vrijeme', 'Trening', 'Trener', 'Klijent', 'Tip', 'Status', 'Iznos', 'Plaćeno'],
              columnWidths: {
                0: const pw.FixedColumnWidth(28),
                1: const pw.FlexColumnWidth(2.0),
                2: const pw.FlexColumnWidth(2.4),
                3: const pw.FlexColumnWidth(2.0),
                4: const pw.FlexColumnWidth(2.0),
                5: const pw.FlexColumnWidth(1.3),
                6: const pw.FlexColumnWidth(1.5),
                7: const pw.FlexColumnWidth(1.2),
                8: const pw.FlexColumnWidth(1.0),
              },
              rows: report.rows
                  .map((r) => [
                        '${r.reservationId}',
                        _dateTimeFormat.format(r.reservationDate),
                        r.trainingName,
                        r.trainerName ?? '-',
                        r.clientName,
                        r.reservationType.label,
                        r.status.label,
                        _money(r.totalPrice),
                        r.isPaid ? 'DA' : 'NE',
                      ])
                  .toList(),
              numericColumns: const {7},
            ),
        ],
      ),
    );

    return document.save();
  }

  // ------------------------------------------------------------------
  // Report 2: revenue per training
  // ------------------------------------------------------------------

  static Future<Uint8List> buildRevenueReport(RevenueReport report) async {
    final document = pw.Document(
      title: 'FitSync - Izvjestaj o prihodima',
      author: 'FitSync',
      theme: await _loadTheme(),
    );

    final maxRevenue = report.rows.isEmpty
        ? 0.0
        : report.rows.map((r) => r.revenue).reduce((a, b) => a > b ? a : b);

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => _header(
          context,
          title: 'Izvještaj o uplatama i prihodima',
          subtitle: 'Period: ${_dateFormat.format(report.from)} - ${_dateFormat.format(report.to)}',
          generatedAt: report.generatedAt,
        ),
        footer: _footer,
        build: (context) => [
          _summaryRow([
            _summaryCard('Ukupan prihod', '${_money(report.totalRevenue)} ${report.currency}', highlight: true),
            _summaryCard('Broj uplata', '${report.totalPayments}'),
            _summaryCard('Treninga sa prihodom', '${report.rows.length}'),
          ]),
          pw.SizedBox(height: 6),
          pw.Text(
            'U prihod se računaju isključivo uspješno naplaćene (captured) uplate.',
            style: const pw.TextStyle(fontSize: 8, color: _muted),
          ),
          pw.SizedBox(height: 18),

          if (report.providerBreakdown.isNotEmpty) ...[
            _sectionTitle('Po nacinu placanja'),
            pw.SizedBox(height: 6),
            _table(
              headers: const ['Nacin placanja', 'Broj uplata', 'Prihod'],
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
              },
              rows: report.providerBreakdown
                  .map((p) => [p.provider.label, '${p.paymentsCount}', _money(p.revenue)])
                  .toList(),
              numericColumns: const {1, 2},
            ),
            pw.SizedBox(height: 18),
          ],

          _sectionTitle('Prihod po treningu'),
          pw.SizedBox(height: 6),

          if (report.rows.isEmpty)
            _emptyNotice('Nema evidentiranih uplata u odabranom periodu.')
          else ...[
            _table(
              headers: const ['Trening', 'Tip', 'Trener', 'Uplata', 'Prosjek', 'Prihod'],
              columnWidths: {
                0: const pw.FlexColumnWidth(2.6),
                1: const pw.FlexColumnWidth(1.3),
                2: const pw.FlexColumnWidth(1.8),
                3: const pw.FlexColumnWidth(1.0),
                4: const pw.FlexColumnWidth(1.1),
                5: const pw.FlexColumnWidth(1.2),
              },
              rows: report.rows
                  .map((r) => [
                        r.trainingName,
                        r.trainingTypeName ?? '-',
                        r.trainerName ?? '-',
                        '${r.paymentsCount}',
                        _money(r.averagePayment),
                        _money(r.revenue),
                      ])
                  .toList(),
              numericColumns: const {3, 4, 5},
              totalRow: ['UKUPNO', '', '', '${report.totalPayments}', '', _money(report.totalRevenue)],
            ),
            pw.SizedBox(height: 20),

            // A simple proportional bar chart, so the report is readable at a glance.
            _sectionTitle('Udio u prihodu'),
            pw.SizedBox(height: 8),
            ...report.rows.take(10).map((r) => _revenueBar(r, maxRevenue, report.currency)),
          ],
        ],
      ),
    );

    return document.save();
  }

  // ------------------------------------------------------------------
  // Shared building blocks
  // ------------------------------------------------------------------

  static pw.Widget _header(
    pw.Context context, {
    required String title,
    required String subtitle,
    required DateTime generatedAt,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _accent, width: 2)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('FitSync',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _accent)),
              pw.SizedBox(height: 2),
              pw.Text(title, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _dark)),
              pw.SizedBox(height: 2),
              pw.Text(subtitle, style: const pw.TextStyle(fontSize: 9, color: _muted)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Generisano', style: const pw.TextStyle(fontSize: 8, color: _muted)),
              pw.Text(_dateTimeFormat.format(generatedAt.toLocal()),
                  style: const pw.TextStyle(fontSize: 9, color: _dark)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _footer(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'FitSync - Stranica ${context.pageNumber} od ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 8, color: _muted),
      ),
    );
  }

  static pw.Widget _sectionTitle(String text) => pw.Text(
        text,
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _dark),
      );

  static pw.Widget _summaryRow(List<pw.Widget> cards) => pw.Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            pw.Expanded(child: cards[i]),
            if (i != cards.length - 1) pw.SizedBox(width: 8),
          ],
        ],
      );

  static pw.Widget _summaryCard(String label, String value, {bool highlight = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: pw.BoxDecoration(
        color: highlight ? _accent : _stripe,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(fontSize: 7.5, color: highlight ? PdfColors.white : _muted)),
          pw.SizedBox(height: 3),
          pw.Text(value,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: highlight ? PdfColors.white : _dark,
              )),
        ],
      ),
    );
  }

  static pw.Widget _chip(String text) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(
          color: _stripe,
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 8.5, color: _dark)),
      );

  static pw.Widget _emptyNotice(String text) => pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(color: _stripe, borderRadius: pw.BorderRadius.circular(5)),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 9.5, color: _muted)),
      );

  static pw.Widget _table({
    required List<String> headers,
    required List<List<String>> rows,
    Map<int, pw.TableColumnWidth>? columnWidths,
    Set<int> numericColumns = const {},
    List<String>? totalRow,
  }) {
    pw.Widget cell(String text, {required bool header, required int column, bool bold = false}) {
      final isNumeric = numericColumns.contains(column);
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4.5),
        child: pw.Text(
          text,
          textAlign: isNumeric ? pw.TextAlign.right : pw.TextAlign.left,
          style: pw.TextStyle(
            fontSize: header ? 8.5 : 8,
            fontWeight: header || bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: header ? PdfColors.white : _dark,
          ),
        ),
      );
    }

    return pw.Table(
      columnWidths: columnWidths,
      border: pw.TableBorder.symmetric(
        inside: const pw.BorderSide(color: PdfColors.grey300, width: 0.4),
      ),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _dark),
          children: [
            for (var i = 0; i < headers.length; i++) cell(headers[i], header: true, column: i),
          ],
        ),
        for (var r = 0; r < rows.length; r++)
          pw.TableRow(
            decoration: pw.BoxDecoration(color: r.isEven ? PdfColors.white : _stripe),
            children: [
              for (var i = 0; i < rows[r].length; i++) cell(rows[r][i], header: false, column: i),
            ],
          ),
        if (totalRow != null)
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            children: [
              for (var i = 0; i < totalRow.length; i++)
                cell(totalRow[i], header: false, column: i, bold: true),
            ],
          ),
      ],
    );
  }

  /// Horizontal proportion bar built from two flex segments, since the pdf package
  /// has no fractional sizing widget.
  static pw.Widget _proportionBar(double fraction) {
    const resolution = 1000;
    final filled = (fraction * resolution).round().clamp(1, resolution);
    final empty = resolution - filled;

    return pw.SizedBox(
      height: 7,
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: filled,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                color: _accent,
                borderRadius: pw.BorderRadius.circular(4),
              ),
            ),
          ),
          if (empty > 0)
            pw.Expanded(
              flex: empty,
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  color: _stripe,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _revenueBar(RevenueReportRow row, double maxRevenue, String currency) {
    final fraction = maxRevenue <= 0 ? 0.0 : (row.revenue / maxRevenue).clamp(0.0, 1.0);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(row.trainingName,
                    maxLines: 1, style: const pw.TextStyle(fontSize: 8.5, color: _dark)),
              ),
              pw.Text('${_money(row.revenue)} $currency',
                  style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _dark)),
            ],
          ),
          pw.SizedBox(height: 2),
          // The pdf package has no FractionallySizedBox, so the bar is drawn as two
          // flex segments whose ratio encodes the proportion.
          _proportionBar(fraction),
        ],
      ),
    );
  }
}
