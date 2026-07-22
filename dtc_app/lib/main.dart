import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'config/env.dart';
import 'theme/app_theme.dart';
import 'theme/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Env.isConfigured) {
    await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  }

  runApp(const DtcApp());
}

class DtcApp extends StatelessWidget {
  const DtcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أكواد الأعطال',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Env.isConfigured ? const DtcAppRoot() : const _MissingConfigScreen(),
      ),
    );
  }
}

class _MissingConfigScreen extends StatelessWidget {
  const _MissingConfigScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'أكواد الأعطال\n\n'
              'يجب تشغيل التطبيق مع SUPABASE_ANON_KEY:\n'
              'flutter run --dart-define=SUPABASE_ANON_KEY=xxxx',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700, height: 1.6),
            ),
          ),
        ),
      ),
    );
  }
}
