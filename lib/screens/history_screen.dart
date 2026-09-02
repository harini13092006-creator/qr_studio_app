import 'package:flutter/material.dart';

import '../models/qr_history.dart';
import '../services/storage_service.dart';
import 'qr_preview_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<QRHistory> history = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() {
      loading = true;
    });

    final data = await StorageService.getHistory();

    if (!mounted) return;

    setState(() {
      history = data;
      loading = false;
    });
  }

  Future<void> deleteQR(QRHistory qr) async {
    await StorageService.deleteQR(qr.id);

    if (!mounted) return;

    setState(() {
      history.removeWhere(
        (item) => item.id == qr.id,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR code deleted.'),
      ),
    );
  }

  Future<void> clearHistory() async {
    if (history.isEmpty) return;

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Clear History?',
          ),
          content: const Text(
            'This will permanently delete all saved QR codes.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await StorageService.clearHistory();

    if (!mounted) return;

    setState(() {
      history.clear();
    });
  }

  IconData getIcon(String type) {
    switch (type) {
      case 'URL':
        return Icons.link;
      case 'Email':
        return Icons.email_outlined;
      case 'Phone':
        return Icons.phone_outlined;
      case 'Wi-Fi':
        return Icons.wifi;
      default:
        return Icons.text_fields;
    }
  }

  String formatDate(DateTime date) {
    final d = date.toLocal();

    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              onPressed: clearHistory,
              icon: const Icon(
                Icons.delete_sweep_outlined,
              ),
            ),
        ],
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : history.isEmpty
              ? _EmptyHistory(
                  onCreate: () {
                    Navigator.pop(context);
                  },
                )
              : RefreshIndicator(
                  onRefresh: loadHistory,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: history.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final qr = history[index];

                      return _HistoryCard(
                        qr: qr,
                        icon: getIcon(qr.type),
                        date: formatDate(
                          qr.createdAt,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  QRPreviewScreen(
                                data: qr.data,
                                type: qr.type,
                                existingHistory: qr,
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          deleteQR(qr);
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final QRHistory qr;
  final IconData icon;
  final String date;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.qr,
    required this.icon,
    required this.date,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0FF),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF5B5FEF),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      qr.displayTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      qr.data,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (_) {
                  return const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyHistory({
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            const Text(
              'No QR History',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'QR codes that you save will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 22),

            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create QR'),
            ),
          ],
        ),
      ),
    );
  }
}
