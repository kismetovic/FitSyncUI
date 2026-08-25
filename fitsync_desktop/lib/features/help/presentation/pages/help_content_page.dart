import 'package:flutter/material.dart';
import 'package:fitsync_desktop/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/error/api_error_messages.dart';
import '../../domain/entities/faq.dart';
import '../providers/help_content_provider.dart';

/// Where the administrator edits what clients read on the mobile help screen:
/// the FAQ list and the gym's contact details.
class HelpContentPage extends StatefulWidget {
  const HelpContentPage({super.key});

  @override
  State<HelpContentPage> createState() => _HelpContentPageState();
}

class _HelpContentPageState extends State<HelpContentPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HelpContentProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Consumer<HelpContentProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(l.navHelp,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l.addFaq),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8622A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showFaqDialog(context, provider),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  onPressed: provider.load,
                  tooltip: l.refresh,
                ),
              ]),
              const SizedBox(height: 20),
              if (provider.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(apiErrorText(context, provider.errorCode, provider.error),
                          style: const TextStyle(color: Colors.red)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 16),
                      onPressed: provider.clearError,
                    ),
                  ]),
                ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8622A)))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ContactCard(provider: provider),
                            const SizedBox(height: 24),
                            Text(l.faqs,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            if (provider.faqs.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32),
                                child: Center(
                                  child: Text(l.noFaqs,
                                      style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                                ),
                              )
                            else
                              ...provider.faqs.map((faq) => _FaqRow(
                                    faq: faq,
                                    onEdit: () => _showFaqDialog(context, provider, faq: faq),
                                    onDelete: () => _confirmDelete(context, provider, faq),
                                  )),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFaqDialog(BuildContext context, HelpContentProvider provider, {Faq? faq}) {
    final l = AppLocalizations.of(context);
    final questionCtrl = TextEditingController(text: faq?.question ?? '');
    final answerCtrl = TextEditingController(text: faq?.answer ?? '');
    // A new entry goes to the end of the list rather than fighting for position 0.
    final orderCtrl = TextEditingController(
        text: (faq?.sortOrder ?? (provider.faqs.length + 1)).toString());
    var isActive = faq?.isActive ?? true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1A2535),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(faq == null ? l.addFaq : l.editFaq,
              style: const TextStyle(color: Colors.white)),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                _field(l.question, questionCtrl),
                const SizedBox(height: 12),
                _field(l.answer, answerCtrl, maxLines: 6),
                const SizedBox(height: 12),
                _field(l.sortOrder, orderCtrl, keyboardType: TextInputType.number),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: const Color(0xFFE8622A),
                  title: Text(l.visible, style: const TextStyle(color: Colors.white)),
                  value: isActive,
                  onChanged: (v) => setDlgState(() => isActive = v),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancel, style: TextStyle(color: Colors.grey[400])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8622A), foregroundColor: Colors.white),
              onPressed: () async {
                final ok = await provider.saveFaq(
                  id: faq?.id,
                  question: questionCtrl.text.trim(),
                  answer: answerCtrl.text.trim(),
                  sortOrder: int.tryParse(orderCtrl.text.trim()) ?? 0,
                  isActive: isActive,
                );
                if (!ctx.mounted) return;
                if (ok) Navigator.pop(ctx);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? l.saved
                      : apiErrorText(context, provider.errorCode, provider.error)),
                ));
              },
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, HelpContentProvider provider, Faq faq) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2535),
        title: Text(l.deleteFaq, style: const TextStyle(color: Colors.white)),
        content: Text(faq.question, style: TextStyle(color: Colors.grey[300])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel, style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await provider.deleteFaq(faq.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? l.saved
                    : apiErrorText(context, provider.errorCode, provider.error)),
              ));
            },
            child: Text(l.delete),
          ),
        ],
      ),
    );
  }
}

Widget _field(String label, TextEditingController controller,
        {int maxLines = 1, TextInputType? keyboardType}) =>
    TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF243347),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );

class _ContactCard extends StatefulWidget {
  final HelpContentProvider provider;
  const _ContactCard({required this.provider});

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _hours = TextEditingController();
  final _address = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _hours.dispose();
    _address.dispose();
    super.dispose();
  }

  /// Fill the fields once, from the first load. Refilling on every rebuild would
  /// wipe whatever the administrator is in the middle of typing.
  void _fillOnce() {
    final c = widget.provider.contact;
    if (_filled || c == null) return;
    _email.text = c.email;
    _phone.text = c.phoneNumber;
    _hours.text = c.workingHours;
    _address.text = c.address ?? '';
    _filled = true;
  }

  @override
  Widget build(BuildContext context) {
    _fillOnce();
    final l = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.supportContact,
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(l.supportContactHint, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _field(l.email, _email)),
            const SizedBox(width: 12),
            Expanded(child: _field(l.phone, _phone)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _field(l.workingHours, _hours)),
            const SizedBox(width: 12),
            Expanded(child: _field(l.address, _address)),
          ]),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_outlined),
              label: Text(l.save),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8622A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              ),
              onPressed: widget.provider.isSaving
                  ? null
                  : () async {
                      final ok = await widget.provider.saveContact(
                        email: _email.text.trim(),
                        phoneNumber: _phone.text.trim(),
                        workingHours: _hours.text.trim(),
                        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok
                            ? l.saved
                            : apiErrorText(context, widget.provider.errorCode,
                                widget.provider.error)),
                      ));
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqRow extends StatelessWidget {
  final Faq faq;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FaqRow({required this.faq, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ExpansionTile(
        iconColor: Colors.white70,
        collapsedIconColor: Colors.white38,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: CircleAvatar(
          radius: 15,
          backgroundColor: const Color(0xFFE8622A).withValues(alpha: 0.18),
          child: Text('${faq.sortOrder}',
              style: const TextStyle(color: Color(0xFFE8622A), fontSize: 12)),
        ),
        title: Text(faq.question,
            style: TextStyle(
                color: faq.isActive ? Colors.white : Colors.grey[500],
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        subtitle: faq.isActive
            ? null
            : Text(l.visible, style: TextStyle(color: Colors.orange[300], fontSize: 11)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (!faq.isActive)
            const Padding(
              padding: EdgeInsets.only(right: 4),
              child: Icon(Icons.visibility_off_outlined, color: Colors.orange, size: 18),
            ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white54, size: 18),
            onPressed: onEdit,
            tooltip: l.edit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
            onPressed: onDelete,
            tooltip: l.delete,
          ),
        ]),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(faq.answer,
                  style: TextStyle(color: Colors.grey[300], fontSize: 13, height: 1.45)),
            ),
          ),
        ],
      ),
    );
  }
}
