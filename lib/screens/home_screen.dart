import 'package:flutter/material.dart';

import '../models/qr_history.dart';
import '../services/storage_service.dart';
import 'create_qr_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'qr_preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<QRHistory> recentQrs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final data = await StorageService.getHistory();

    if (!mounted) return;

    setState(() {
      recentQrs = data.take(4).toList();
      isLoading = false;
    });
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  void openCreateQR() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateQRScreen(),
      ),
    ).then((_) {
      loadHistory();
    });
  }

  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HistoryScreen(),
      ),
    ).then((_) {
      loadHistory();
    });
  }

  void openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  IconData getTypeIcon(String type) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadHistory,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B5FEF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.qr_code_2,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getGreeting(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Text(
                          'QR Studio',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: openSettings,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    icon: const Icon(
                      Icons.settings_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // HERO CARD
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF5B5FEF),
                      Color(0xFF7667F5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create QR Codes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Create professional QR codes quickly and easily.',
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 20),

                          FilledButton(
                            onPressed: openCreateQR,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  Color(0xFF5B5FEF),
                            ),
                            child: const Text(
                              'Create QR',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Icon(
                      Icons.qr_code_2,
                      color: Colors.white,
                      size: 90,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // QUICK ACTIONS
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.add_circle_outline,
                      title: 'Create QR',
                      subtitle: 'Generate',
                      onTap: openCreateQR,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _ActionCard(
                      icon: Icons.history,
                      title: 'History',
                      subtitle: 'View saved',
                      onTap: openHistory,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // RECENT HEADER
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent QR Codes',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextButton(
                    onPressed: openHistory,
                    child: const Text('View all'),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (recentQrs.isEmpty)
                _EmptyState(
                  onCreate: openCreateQR,
                )
              else
                ...recentQrs.map(
                  (qr) => Padding(
                    padding:
                        const EdgeInsets.only(bottom: 10),
                    child: _RecentQRCard(
                      qr: qr,
                      icon: getTypeIcon(qr.type),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QRPreviewScreen(
                              data: qr.data,
                              type: qr.type,
                              existingHistory: qr,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF5B5FEF),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentQRCard extends StatelessWidget {
  final QRHistory qr;
  final IconData icon;
  final VoidCallback onTap;

  const _RecentQRCard({
    required this.qr,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF5B5FEF),
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      qr.displayTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      qr.data,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyState({
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.qr_code_2,
            size: 60,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 14),

          const Text(
            'No QR codes yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Create your first QR code and it will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 18),

          OutlinedButton(
            onPressed: onCreate,
            child: const Text('Create QR'),
          ),
        ],
      ),
    );
  }
}