import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/qr_history.dart';
import '../services/storage_service.dart';
import '../services/qr_appearance_service.dart';

class QRPreviewScreen extends StatefulWidget {
  final String data;
  final String type;
  final QRHistory? existingHistory;

  const QRPreviewScreen({
    super.key,
    required this.data,
    required this.type,
    this.existingHistory,
  });

  @override
  State<QRPreviewScreen> createState() => _QRPreviewScreenState();
}

class _QRPreviewScreenState extends State<QRPreviewScreen> {
  bool isSaved = false;
  QrAppearance appearance = const QrAppearance();

  @override
  void initState() {
    super.initState();

    isSaved = widget.existingHistory != null;
    _loadAppearance();
  }

  Future<void> _loadAppearance() async {
    final savedAppearance = await QrAppearanceService.load();
    if (mounted) setState(() => appearance = savedAppearance);
  }

  Future<void> saveQRCode() async {
    if (isSaved) return;

    final qr = QRHistory(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: widget.type,
      data: widget.data,
      createdAt: DateTime.now(),
    );

    await StorageService.saveQR(qr);

    if (!mounted) return;

    setState(() {
      isSaved = true;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('QR code saved successfully')));
  }

  Future<void> shareQRCode() async {
    await Share.share(
      widget.data,
      subject: '${getTypeDescription()} from QR Studio',
    );
  }

  IconData getTypeIcon() {
    switch (widget.type) {
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

  String getTypeDescription() {
    switch (widget.type) {
      case 'URL':
        return 'Website QR Code';
      case 'Email':
        return 'Email QR Code';
      case 'Phone':
        return 'Phone QR Code';
      case 'Wi-Fi':
        return 'Wi-Fi QR Code';
      default:
        return 'Text QR Code';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text(
          'QR Preview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: shareQRCode,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(getTypeIcon(), color: const Color(0xFF5B5FEF)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTypeDescription(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Preview your generated QR code',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // QR CODE CARD
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text(
                  'Your QR Code',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: widget.data,
                    version: QrVersions.auto,
                    size: 260,
                    backgroundColor: appearance.backgroundColor,
                    errorCorrectionLevel: appearance.errorCorrectionLevel,
                    dataModuleStyle: QrDataModuleStyle(
                      color: appearance.foregroundColor,
                      dataModuleShape: appearance.circularModules
                          ? QrDataModuleShape.circle
                          : QrDataModuleShape.square,
                    ),
                    eyeStyle: QrEyeStyle(
                      color: appearance.foregroundColor,
                      eyeShape: appearance.circularEyes
                          ? QrEyeShape.circle
                          : QrEyeShape.square,
                    ),
                    embeddedImage: _logoImage,
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(42, 42),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QR Content',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        widget.data,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SAVE BUTTON
          SizedBox(
            height: 55,
            child: FilledButton.icon(
              onPressed: isSaved ? null : saveQRCode,
              icon: Icon(
                isSaved ? Icons.check_circle_outline : Icons.bookmark_outline,
              ),
              label: Text(
                isSaved ? 'Saved to History' : 'Save to History',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // SHARE BUTTON
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: shareQRCode,
              icon: const Icon(Icons.share_outlined),
              label: const Text(
                'Share QR Code',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // CREATE NEW
          SizedBox(
            height: 52,
            child: TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Another QR'),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? get _logoImage {
    final logoPath = appearance.logoPath;
    if (logoPath == null || !File(logoPath).existsSync()) return null;
    return FileImage(File(logoPath));
  }
}
