import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../constants/theme.dart';

class LangSwitcher extends StatelessWidget {
  const LangSwitcher({super.key});

  static const _langs = [
    {'code': 'en', 'label': 'EN'},
    {'code': 'hi', 'label': 'हि'},
    {'code': 'mr', 'label': 'म'},
    {'code': 'ta', 'label': 'த'},
  ];

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final current = localeProvider.currentLocale.languageCode;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _langs.map((lang) {
        final isActive = lang['code'] == current;
        return GestureDetector(
          onTap: () => localeProvider.setLocale(lang['code']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              gradient: isActive ? AppTheme.gradientMain : null,
              color: isActive ? null : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isActive ? Colors.transparent : Colors.white.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Text(
              lang['label']!,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: isActive
                    ? []
                    : [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 2,
                        ),
                      ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
