import 'dart:async';

import '../services/api_service.dart';

import 'package:flutter/material.dart';

import '../services/qr_service.dart';
import 'qr_preview_screen.dart';

class CreateQRScreen extends StatefulWidget {
  const CreateQRScreen({super.key});

  @override
  State<CreateQRScreen> createState() => _CreateQRScreenState();
}

class _CreateQRScreenState extends State<CreateQRScreen> {
  String selectedType = 'Text';

  final textController = TextEditingController();
  final urlController = TextEditingController();
  final emailController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  final phoneController = TextEditingController();
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();

  String security = 'WPA';
  bool hiddenNetwork = false;

  @override
  void dispose() {
    textController.dispose();
    urlController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    phoneController.dispose();
    ssidController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  String? generateData() {
    switch (selectedType) {
      case 'URL':
        if (!QRService.isValidUrl(urlController.text)) {
          return null;
        }

        return QRService.buildURL(urlController.text);

      case 'Email':
        if (!QRService.isValidEmail(emailController.text)) {
          return null;
        }

        return QRService.buildEmail(
          email: emailController.text,
          subject: subjectController.text,
          body: messageController.text,
        );

      case 'Phone':
        if (phoneController.text.trim().isEmpty) {
          return null;
        }

        return QRService.buildPhone(phoneController.text);

      case 'Wi-Fi':
        if (ssidController.text.trim().isEmpty) {
          return null;
        }

        return QRService.buildWifi(
          ssid: ssidController.text,
          password: passwordController.text,
          security: security,
          hidden: hiddenNetwork,
        );

      default:
        if (textController.text.trim().isEmpty) {
          return null;
        }

        return QRService.buildText(textController.text);
    }
  }

  Future<void> createQR() async {
    final data = generateData();

    // Check whether the entered data is valid
    if (data == null) {
      String message;

      if (selectedType == 'URL') {
        message = 'Enter a valid URL such as https://example.com';
      } else if (selectedType == 'Email') {
        message = 'Enter a valid email address.';
      } else {
        message = 'Please fill in the required fields.';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    // QR rendering is entirely local. Never block it on an API/database error.
    unawaited(_saveToBackend(type: selectedType, content: data));

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QRPreviewScreen(data: data, type: selectedType),
      ),
    );
  }

  Future<void> _saveToBackend({
    required String type,
    required String content,
  }) async {
    try {
      await ApiService.createQr(type: type, content: content);
    } catch (error) {
      debugPrint(
        'QR was generated locally but was not saved to the backend: $error',
      );
    }
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget buildInputForm() {
    switch (selectedType) {
      case 'URL':
        return inputField(
          controller: urlController,
          label: 'Website URL',
          hint: 'https://example.com',
          icon: Icons.link,
          keyboardType: TextInputType.url,
        );

      case 'Email':
        return Column(
          children: [
            inputField(
              controller: emailController,
              label: 'Email Address',
              hint: 'example@gmail.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 14),

            inputField(
              controller: subjectController,
              label: 'Subject',
              hint: 'Email subject',
              icon: Icons.subject,
            ),

            const SizedBox(height: 14),

            inputField(
              controller: messageController,
              label: 'Message',
              hint: 'Email message',
              icon: Icons.message_outlined,
              maxLines: 5,
            ),
          ],
        );

      case 'Phone':
        return inputField(
          controller: phoneController,
          label: 'Phone Number',
          hint: '+91 9876543210',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        );

      case 'Wi-Fi':
        return Column(
          children: [
            inputField(
              controller: ssidController,
              label: 'Wi-Fi Name',
              hint: 'My Wi-Fi',
              icon: Icons.wifi,
            ),

            const SizedBox(height: 14),

            inputField(
              controller: passwordController,
              label: 'Password',
              hint: 'Wi-Fi password',
              icon: Icons.lock_outline,
              keyboardType: TextInputType.visiblePassword,
            ),

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: security,
              decoration: const InputDecoration(
                labelText: 'Security',
                prefixIcon: Icon(Icons.security_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'WPA', child: Text('WPA / WPA2')),
                DropdownMenuItem(value: 'WEP', child: Text('WEP')),
                DropdownMenuItem(value: 'nopass', child: Text('No Password')),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  security = value;
                });
              },
            ),

            const SizedBox(height: 5),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hidden network'),
              value: hiddenNetwork,
              onChanged: (value) {
                setState(() {
                  hiddenNetwork = value;
                });
              },
            ),
          ],
        );

      default:
        return inputField(
          controller: textController,
          label: 'Text',
          hint: 'Enter text to encode',
          icon: Icons.text_fields,
          maxLines: 6,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final types = [
      {'name': 'Text', 'icon': Icons.text_fields},
      {'name': 'URL', 'icon': Icons.link},
      {'name': 'Email', 'icon': Icons.email_outlined},
      {'name': 'Phone', 'icon': Icons.phone_outlined},
      {'name': 'Wi-Fi', 'icon': Icons.wifi},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text(
          'Create QR',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          const Text(
            'Choose QR Type',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 6),

          Text(
            'Select what you want to store inside the QR code.',
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 18),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: types.map((type) {
              final name = type['name'] as String;
              final icon = type['icon'] as IconData;
              final selected = selectedType == name;

              return ChoiceChip(
                selected: selected,
                avatar: Icon(icon, size: 18),
                label: Text(name),
                onSelected: (_) {
                  setState(() {
                    selectedType = name;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 25),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$selectedType Details',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                buildInputForm(),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 55,
            child: FilledButton.icon(
              onPressed: createQR,
              icon: const Icon(Icons.qr_code_2),
              label: const Text(
                'Generate QR Code',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
