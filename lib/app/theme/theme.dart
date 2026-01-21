import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tailor/app/theme/theme_data.dart';
import 'package:tailor/main.dart';

class themecont extends GetxController {
  final RxBool _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;

  @override
  void onInit() {
    super.onInit();
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    _loadTheme();
  }

  void _loadTheme() {
    // تحميل الحالة من SharedPreferences
    _isDarkMode.value = shared.getBool('isDarkMode') ?? false;
    _updateTheme();
  }

  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    await shared.setBool('isDarkMode', _isDarkMode.value);
    _updateTheme();
  }

  Future<void> setTheme(bool isDark) async {
    _isDarkMode.value = isDark;
    await shared.setBool('isDarkMode', isDark);
    _updateTheme();
  }

  void _updateTheme() {
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    Get.changeTheme(_getThemeData());
  }

  ThemeData _getThemeData() {
    final colorScheme = _isDarkMode.value ? AppColors.darkScheme : AppColors.lightScheme;

    return ThemeData(
      fontFamily: 'cairo',
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),


      buttonTheme: ButtonThemeData(
        buttonColor: colorScheme.primary,
        textTheme: ButtonTextTheme.primary,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          side: BorderSide(color: colorScheme.secondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.surfaceVariant,
        thickness: 1,
        space: 1,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}