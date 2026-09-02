import 'package:flutter/material.dart';

class QRTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const QRTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  static const List<Map<String, dynamic>> types = [
    {
      'name': 'Text',
      'icon': Icons.text_fields,
    },
    {
      'name': 'URL',
      'icon': Icons.link,
    },
    {
      'name': 'Email',
      'icon': Icons.email_outlined,
    },
    {
      'name': 'Phone',
      'icon': Icons.phone_outlined,
    },
    {
      'name': 'Wi-Fi',
      'icon': Icons.wifi,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: types.map((type) {
        final name = type['name'] as String;
        final icon = type['icon'] as IconData;

        final selected = selectedType == name;

        return ChoiceChip(
          selected: selected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
              ),
              const SizedBox(width: 7),
              Text(name),
            ],
          ),
          onSelected: (_) {
            onChanged(name);
          },
        );
      }).toList(),
    );
  }
}