import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:alterego/router/app_router.dart';
import 'package:provider/provider.dart';
import 'package:alterego/providers/story_provider.dart';
import 'package:alterego/providers/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alterego/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://imeqyuurqmckmtryondh.supabase.co',
    anonKey: 'sb_publishable_zQQ098-uyS3t9vSO-lsiNA_qryL2ixO',
  );
  // GoogleFonts disabled to avoid runtime fetching issues
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const midnight = Color(0xFF0F111A);
    const neonCyan = Color(0xFF00F5FF);
    final themeDark = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: Colors.white,
        surface: Color(0x0DFFFFFF),
      ),
      scaffoldBackgroundColor: midnight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.06),
        indicatorColor: Colors.white.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, color: Colors.white70)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0x0DFFFFFF),
        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
        labelStyle: TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white54),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: Color(0x22111122)),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: Colors.white),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.white70),
      ),
    );

    final themeLight = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: neonCyan,
        secondary: Colors.black,
        surface: Color(0x0D000000),
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return TextStyle(fontSize: 12, color: active ? const Color(0xFF1C2B4D) : const Color(0xFF8A93A8));
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(color: active ? const Color(0xFF1C2B4D) : const Color(0xFF8A93A8));
        }),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0x0D000000),
        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
        labelStyle: TextStyle(color: Colors.black54),
        hintStyle: TextStyle(color: Colors.black38),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating, backgroundColor: Color(0x22000000)),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: Color(0xFF1C2B4D)),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: Color(0xFF1C2B4D)),
        bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF6D7A92)),
        labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6A5AE0)),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) {
          final lp = LocaleProvider();
          lp.load();
          return lp;
        }),
      ],
      child: Consumer<LocaleProvider>(builder: (context, lp, _) {
        return MaterialApp(
        title: AppLocalizations.of(context)?.appTitle ?? 'AlterEgo',
        theme: themeLight,
        darkTheme: themeDark,
        themeMode: ThemeMode.light,
        locale: lp.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('zh')],
        routes: AppRouter.routes,
        initialRoute: '/',
      );
      }),
    );
  }
}
