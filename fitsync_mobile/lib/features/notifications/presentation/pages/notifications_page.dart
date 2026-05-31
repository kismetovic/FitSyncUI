import 'package:flutter/material.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notifications_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Consumer<NotificationsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0F1923),
          appBar: AppBar(
            backgroundColor: const Color(0xFF152030),
            foregroundColor: Colors.white,
            title: Text(l.notifications),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
                onPressed: provider.loadNotifications,
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8622A)))
              : provider.error != null
                  ? _ErrorView(error: provider.error!, onRetry: provider.loadNotifications, l: l)
                  : provider.notifications.isEmpty
                      ? _EmptyView(l: l)
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.notifications.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) => _NotificationCard(
                            notification: provider.notifications[index],
                            onTap: () => provider.markRead(provider.notifications[index].id),
                          ),
                        ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, yyyy HH:mm');
    final isUnread = !notification.isRead;
    return GestureDetector(
      onTap: isUnread ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFE8622A).withValues(alpha: 0.08) : const Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread ? const Color(0xFFE8622A).withValues(alpha: 0.4) : Colors.white10,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isUnread ? const Color(0xFFE8622A) : Colors.grey).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isUnread ? Icons.notifications_active : Icons.notifications_none,
                color: isUnread ? const Color(0xFFE8622A) : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(notification.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          )),
                    ),
                    if (isUnread)
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: Color(0xFFE8622A), shape: BoxShape.circle),
                      ),
                  ]),
                  const SizedBox(height: 4),
                  Text(notification.message, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(fmt.format(notification.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final AppLocalizations l;
  const _ErrorView({required this.error, required this.onRetry, required this.l});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error_outline, color: Colors.red[300], size: 48),
      const SizedBox(height: 12),
      Text(error, style: TextStyle(color: Colors.grey[400]), textAlign: TextAlign.center),
      const SizedBox(height: 16),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE8622A)),
        onPressed: onRetry,
        child: Text(l.retry, style: const TextStyle(color: Colors.white)),
      ),
    ]),
  );
}

class _EmptyView extends StatelessWidget {
  final AppLocalizations l;
  const _EmptyView({required this.l});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.notifications_none, color: Colors.grey[700], size: 64),
      const SizedBox(height: 16),
      Text(l.noNotificationsYet, style: TextStyle(color: Colors.grey[500], fontSize: 16)),
    ]),
  );
}
