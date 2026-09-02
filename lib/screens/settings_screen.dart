import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/qr_appearance_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool autoSave = true;
  bool hapticFeedback = true;
  bool showRecent = true;
  QrAppearance appearance = const QrAppearance();

  @override
  void initState() {
    super.initState();
    _loadAppearance();
  }

  Future<void> _loadAppearance() async {
    final savedAppearance = await QrAppearanceService.load();
    if (mounted) setState(() => appearance = savedAppearance);
  }

  Future<void> _editAppearance() async {
    final updatedAppearance = await showModalBottomSheet<QrAppearance>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _QrAppearanceSheet(initialAppearance: appearance),
    );
    if (updatedAppearance == null) return;

    await QrAppearanceService.save(updatedAppearance);
    if (!mounted) return;
    setState(() => appearance = updatedAppearance);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('QR appearance saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          // APP SECTION
          const _SectionTitle(title: 'Application'),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.save_outlined,
                title: 'Auto Save',
                subtitle: 'Automatically save generated QR codes',
                trailing: Switch(
                  value: autoSave,
                  onChanged: (value) {
                    setState(() {
                      autoSave = value;
                    });
                  },
                ),
              ),

              const Divider(height: 1),

              _SettingsTile(
                icon: Icons.vibration,
                title: 'Haptic Feedback',
                subtitle: 'Vibrate when performing actions',
                trailing: Switch(
                  value: hapticFeedback,
                  onChanged: (value) {
                    setState(() {
                      hapticFeedback = value;
                    });
                  },
                ),
              ),

              const Divider(height: 1),

              _SettingsTile(
                icon: Icons.history,
                title: 'Recent QR Codes',
                subtitle: 'Show recent codes on home screen',
                trailing: Switch(
                  value: showRecent,
                  onChanged: (value) {
                    setState(() {
                      showRecent = value;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // QR SECTION
          const _SectionTitle(title: 'QR Code'),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: 'QR Appearance',
                subtitle: 'Customize QR code style',
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  _editAppearance();
                },
              ),

              const Divider(height: 1),

              _SettingsTile(
                icon: Icons.image_outlined,
                title: 'Save Images',
                subtitle: 'Manage QR image saving options',
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Image settings will be available soon.'),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ABOUT
          const _SectionTitle(title: 'About'),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'About QR Studio',
                subtitle: 'Version 1.0.0',
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'QR Studio',
                    applicationVersion: '1.0.0',
                    applicationIcon: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B5FEF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.qr_code_2, color: Colors.white),
                    ),
                    children: const [
                      Text(
                        'A professional QR code creation and management application.',
                      ),
                    ],
                  );
                },
              ),

              const Divider(height: 1),

              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy',
                subtitle: 'Your locally saved QR data',
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: const Text('Privacy'),
                        content: const Text(
                          'Saved QR history is stored locally on this device.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 30),

          Center(
            child: Text(
              'QR Studio • Version 1.0.0',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      onTap: onTap,
      leading: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF5B5FEF)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ),
      trailing: trailing,
    );
  }
}

class _QrAppearanceSheet extends StatefulWidget {
  final QrAppearance initialAppearance;

  const _QrAppearanceSheet({required this.initialAppearance});

  @override
  State<_QrAppearanceSheet> createState() => _QrAppearanceSheetState();
}

class _QrAppearanceSheetState extends State<_QrAppearanceSheet> {
  static const _foregroundColors = <Color>[
    Colors.black,
    Color(0xFF1E3A8A),
    Color(0xFF5B21B6),
    Color(0xFF9F1239),
    Color(0xFF166534),
  ];
  static const _backgroundColors = <Color>[
    Colors.white,
    Color(0xFFEFF6FF),
    Color(0xFFF5F3FF),
    Color(0xFFFFF1F2),
    Color(0xFFF0FDF4),
  ];

  late QrAppearance appearance;

  @override
  void initState() {
    super.initState();
    appearance = widget.initialAppearance;
  }

  Future<void> _selectLogo() async {
    final logoPath = await QrAppearanceService.pickAndStoreLogo();
    if (logoPath != null && mounted) {
      setState(() => appearance = appearance.copyWith(logoPath: logoPath));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'QR Appearance',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Create a scannable QR code that matches your brand.'),
            const SizedBox(height: 16),
            Center(child: _BrandPreview(appearance: appearance)),
            const SizedBox(height: 22),
            _ColorPicker(
              label: 'Code color',
              colors: _foregroundColors,
              selected: appearance.foregroundColor,
              onSelected: (color) => setState(
                () => appearance = appearance.copyWith(foregroundColor: color),
              ),
            ),
            const SizedBox(height: 18),
            _ColorPicker(
              label: 'Background color',
              colors: _backgroundColors,
              selected: appearance.backgroundColor,
              onSelected: (color) => setState(
                () => appearance = appearance.copyWith(backgroundColor: color),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'QR style',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Rounded modules'),
              subtitle: const Text('Use circular QR dots'),
              value: appearance.circularModules,
              onChanged: (value) => setState(
                () => appearance = appearance.copyWith(circularModules: value),
              ),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Rounded finder eyes'),
              subtitle: const Text('Style the three corner markers'),
              value: appearance.circularEyes,
              onChanged: (value) => setState(
                () => appearance = appearance.copyWith(circularEyes: value),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Center logo',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _LogoThumbnail(path: appearance.logoPath),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectLogo,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(
                      appearance.logoPath == null
                          ? 'Choose logo'
                          : 'Replace logo',
                    ),
                  ),
                ),
                if (appearance.logoPath != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Remove logo',
                    onPressed: () => setState(
                      () => appearance = appearance.copyWith(removeLogo: true),
                    ),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<int>(
              initialValue: appearance.errorCorrectionLevel,
              decoration: const InputDecoration(labelText: 'Error correction'),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Low (L)')),
                DropdownMenuItem(value: 0, child: Text('Medium (M)')),
                DropdownMenuItem(value: 3, child: Text('Quartile (Q)')),
                DropdownMenuItem(value: 2, child: Text('High (H)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(
                    () => appearance = appearance.copyWith(
                      errorCorrectionLevel: value,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: () =>
                      setState(() => appearance = const QrAppearance()),
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, appearance),
                    child: const Text('Save appearance'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoThumbnail extends StatelessWidget {
  final String? path;

  const _LogoThumbnail({required this.path});

  @override
  Widget build(BuildContext context) {
    final imageFile = path == null ? null : File(path!);
    final hasImage = imageFile != null && imageFile.existsSync();
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.file(imageFile, fit: BoxFit.cover)
          : const Icon(Icons.image_outlined),
    );
  }
}

class _BrandPreview extends StatelessWidget {
  final QrAppearance appearance;

  const _BrandPreview({required this.appearance});

  @override
  Widget build(BuildContext context) {
    final logoPath = appearance.logoPath;
    final hasLogo = logoPath != null && File(logoPath).existsSync();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appearance.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: QrImageView(
        data: 'QR Studio',
        size: 120,
        backgroundColor: appearance.backgroundColor,
        errorCorrectionLevel: appearance.errorCorrectionLevel,
        eyeStyle: QrEyeStyle(
          color: appearance.foregroundColor,
          eyeShape: appearance.circularEyes
              ? QrEyeShape.circle
              : QrEyeShape.square,
        ),
        dataModuleStyle: QrDataModuleStyle(
          color: appearance.foregroundColor,
          dataModuleShape: appearance.circularModules
              ? QrDataModuleShape.circle
              : QrDataModuleShape.square,
        ),
        embeddedImage: hasLogo ? FileImage(File(logoPath)) : null,
        embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(26, 26)),
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final String label;
  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onSelected;

  const _ColorPicker({
    required this.label,
    required this.colors,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          children: colors.map((color) {
            final isSelected = color.toARGB32() == selected.toARGB32();
            return Semantics(
              label: '$label option',
              selected: isSelected,
              child: InkWell(
                onTap: () => onSelected(color),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF5B5FEF)
                          : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: color.computeLuminance() > .5
                              ? Colors.black
                              : Colors.white,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
