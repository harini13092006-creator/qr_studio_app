import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';

class QrAppearance {
  final Color foregroundColor;
  final Color backgroundColor;
  final int errorCorrectionLevel;
  final bool circularModules;
  final bool circularEyes;
  final String? logoPath;

  const QrAppearance({
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.errorCorrectionLevel = 2,
    this.circularModules = false,
    this.circularEyes = false,
    this.logoPath,
  });

  QrAppearance copyWith({
    Color? foregroundColor,
    Color? backgroundColor,
    int? errorCorrectionLevel,
    bool? circularModules,
    bool? circularEyes,
    String? logoPath,
    bool removeLogo = false,
  }) => QrAppearance(
    foregroundColor: foregroundColor ?? this.foregroundColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    errorCorrectionLevel: errorCorrectionLevel ?? this.errorCorrectionLevel,
    circularModules: circularModules ?? this.circularModules,
    circularEyes: circularEyes ?? this.circularEyes,
    logoPath: removeLogo ? null : logoPath ?? this.logoPath,
  );
}

class QrAppearanceService {
  static const _foregroundKey = 'qr_foreground_color';
  static const _backgroundKey = 'qr_background_color';
  static const _errorCorrectionKey = 'qr_error_correction';
  static const _circularModulesKey = 'qr_circular_modules';
  static const _circularEyesKey = 'qr_circular_eyes';
  static const _logoPathKey = 'qr_logo_path';

  static Future<QrAppearance> load() async {
    final preferences = await SharedPreferences.getInstance();
    return QrAppearance(
      foregroundColor: Color(
        preferences.getInt(_foregroundKey) ?? Colors.black.toARGB32(),
      ),
      backgroundColor: Color(
        preferences.getInt(_backgroundKey) ?? Colors.white.toARGB32(),
      ),
      errorCorrectionLevel: preferences.getInt(_errorCorrectionKey) ?? 2,
      circularModules: preferences.getBool(_circularModulesKey) ?? false,
      circularEyes: preferences.getBool(_circularEyesKey) ?? false,
      logoPath: preferences.getString(_logoPathKey),
    );
  }

  static Future<void> save(QrAppearance appearance) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(
      _foregroundKey,
      appearance.foregroundColor.toARGB32(),
    );
    await preferences.setInt(
      _backgroundKey,
      appearance.backgroundColor.toARGB32(),
    );
    await preferences.setInt(
      _errorCorrectionKey,
      appearance.errorCorrectionLevel,
    );
    await preferences.setBool(_circularModulesKey, appearance.circularModules);
    await preferences.setBool(_circularEyesKey, appearance.circularEyes);
    if (appearance.logoPath == null) {
      await preferences.remove(_logoPathKey);
    } else {
      await preferences.setString(_logoPathKey, appearance.logoPath!);
    }
  }

  static Future<String?> pickAndStoreLogo() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 90,
    );
    if (image == null) return null;

    final appDirectory = await getApplicationDocumentsDirectory();
    final extension = image.name.contains('.')
        ? image.name.substring(image.name.lastIndexOf('.'))
        : '.png';
    final destination = File(
      '${appDirectory.path}${Platform.pathSeparator}qr_brand_logo$extension',
    );
    await File(image.path).copy(destination.path);
    return destination.path;
  }
}
