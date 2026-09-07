import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app_state.dart';

import 'screens/checklist_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/document_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/recap_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(
    'id_ID',
    null,
  );

  await appStore.load();

  runApp(
    const AiizCheckApp(),
  );
}

// ============================================================
// APLIKASI UTAMA
// ============================================================

class AiizCheckApp extends StatelessWidget {
  const AiizCheckApp({
    super.key,
  });

  // ============================================================
  // LIGHT MODE
  // ============================================================

  ThemeData _lightTheme() {
    const navy = Color(
      0xFF092A5B,
    );

    final colorScheme =
        ColorScheme.fromSeed(
      seedColor: navy,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.light,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: const Color(
        0xFFF5F8FC,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(
          0xFFF5F8FC,
        ),
        foregroundColor: Color(
          0xFF151A22,
        ),
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),

      navigationBarTheme:
          const NavigationBarThemeData(
        backgroundColor: Color(
          0xFFF1F3FA,
        ),
        indicatorColor: Color(
          0xFFDCE6FF,
        ),
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
          side: const BorderSide(
            color: Color(
              0xFFE4EAF1,
            ),
          ),
        ),
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,

        fillColor: Colors.white,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            14,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            14,
          ),
          borderSide: const BorderSide(
            color: Color(
              0xFFD7DFEA,
            ),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            14,
          ),
          borderSide: const BorderSide(
            color: Color(
              0xFF315A9D,
            ),
            width: 1.5,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(
          0xFFE4E9F0,
        ),
      ),

      filledButtonTheme:
          FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(
            0xFF315A9D,
          ),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              14,
            ),
          ),
        ),
      ),

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              14,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DARK MODE
  // ============================================================

  ThemeData _darkTheme() {
    const background = Color(
      0xFF08111F,
    );

    const surface = Color(
      0xFF111B2E,
    );

    final colorScheme =
        ColorScheme.fromSeed(
      seedColor: const Color(
        0xFF8CB7FF,
      ),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(
        0xFF8CB7FF,
      ),
      secondary: const Color(
        0xFF36D483,
      ),
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.dark,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: background,

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(
          0xFF0B1525,
        ),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),

      navigationBarTheme:
          const NavigationBarThemeData(
        backgroundColor: Color(
          0xFF0D1727,
        ),
        indicatorColor: Color(
          0xFF203B65,
        ),
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
          side: const BorderSide(
            color: Color(
              0xFF24324A,
            ),
          ),
        ),
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,

        fillColor: const Color(
          0xFF111B2E,
        ),

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            14,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            14,
          ),
          borderSide: const BorderSide(
            color: Color(
              0xFF334158,
            ),
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            14,
          ),
          borderSide: const BorderSide(
            color: Color(
              0xFF8CB7FF,
            ),
            width: 1.5,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(
          0xFF29364A,
        ),
      ),

      filledButtonTheme:
          FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(
            0xFF315A9D,
          ),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              14,
            ),
          ),
        ),
      ),

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              14,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    // MaterialApp hanya rebuild kalau DARK MODE berubah.
    // Tambah/edit checklist tidak membongkar MaterialApp.
    return ValueListenableBuilder<bool>(
      valueListenable:
          appStore.darkModeNotifier,

      builder: (
        context,
        darkMode,
        child,
      ) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'aiiz.__ Check',

          locale: const Locale(
            'id',
            'ID',
          ),

          supportedLocales: const [
            Locale(
              'id',
              'ID',
            ),
            Locale(
              'en',
              'US',
            ),
          ],

          localizationsDelegates: const [
            GlobalMaterialLocalizations
                .delegate,
            GlobalWidgetsLocalizations
                .delegate,
            GlobalCupertinoLocalizations
                .delegate,
          ],

          theme: _lightTheme(),

          darkTheme: _darkTheme(),

          themeMode: darkMode
              ? ThemeMode.dark
              : ThemeMode.light,

          home: const RootRouter(),
        );
      },
    );
  }
}

// ============================================================
// ROOT ROUTER
// ============================================================

class RootRouter extends StatefulWidget {
  const RootRouter({
    super.key,
  });

  @override
  State<RootRouter> createState() {
    return _RootRouterState();
  }
}

class _RootRouterState
    extends State<RootRouter> {
  bool loading = true;

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(
        milliseconds: 900,
      ),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          loading = false;
        });
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (loading) {
      return const SplashView();
    }

    // Hanya login/logout yang mengganti
    // LoginScreen <-> MainShell.
    return ValueListenableBuilder<bool>(
      valueListenable:
          appStore.authNotifier,

      builder: (
        context,
        loggedIn,
        child,
      ) {
        if (loggedIn) {
          return const MainShell();
        }

        return const LoginScreen();
      },
    );
  }
}

// ============================================================
// SPLASH SCREEN
// ============================================================

class SplashView extends StatelessWidget {
  const SplashView({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(
                0xFF061F49,
              ),
              Color(
                0xFF0E57B8,
              ),
            ],
          ),
        ),

        child: Center(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              Container(
                padding: const EdgeInsets.all(
                  14,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(
                    28,
                  ),
                ),

                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 105,
                  height: 105,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              const Text(
                'aiiz.__ Check',

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              const Text(
                'Checklist • PDF • Excel • Print',

                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              const SizedBox(
                width: 26,
                height: 26,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MAIN SHELL
// ============================================================

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
  });

  @override
  State<MainShell> createState() {
    return _MainShellState();
  }
}

class _MainShellState
    extends State<MainShell> {
  int index = 0;

  // ============================================================
  // PINDAH TAB
  // Dipakai dari card Dashboard
  // ============================================================

  void openTab(
    int newIndex,
  ) {
    if (newIndex < 0 ||
        newIndex > 4) {
      return;
    }

    if (index == newIndex) {
      return;
    }

    setState(() {
      index = newIndex;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final pages = <Widget>[
      DashboardScreen(
        onOpenTab: openTab,
      ),

      const ChecklistScreen(),

      const DocumentScreen(),

      const RecapScreen(),

      const ProfileScreen(),
    ];

    const titles = [
      'Dashboard',
      'Checklist',
      'Dokumen',
      'Rekap',
      'Profil',
    ];

    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        title: Text(
          titles[index],

          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          // ====================================================
          // DARK MODE
          // ====================================================

          ValueListenableBuilder<bool>(
            valueListenable:
                appStore.darkModeNotifier,

            builder: (
              context,
              darkMode,
              child,
            ) {
              return IconButton(
                tooltip: darkMode
                    ? 'Mode terang'
                    : 'Mode gelap',

                onPressed: () {
                  appStore.setDarkMode(
                    !darkMode,
                  );
                },

                icon: Icon(
                  darkMode
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
              );
            },
          ),

          const SizedBox(
            width: 4,
          ),

          Padding(
            padding: const EdgeInsets.only(
              right: 12,
            ),

            child: Image.asset(
              'assets/images/app_icon.png',
              width: 38,
              height: 38,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: IndexedStack(
        index: index,
        children: pages,
      ),

      // ========================================================
      // NAVIGATION BOTTOM
      // ========================================================

      bottomNavigationBar:
          NavigationBar(
        selectedIndex: index,

        onDestinationSelected:
            (value) {
          openTab(value);
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Beranda',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.checklist_outlined,
            ),
            selectedIcon: Icon(
              Icons.checklist,
            ),
            label: 'Checklist',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.description_outlined,
            ),
            selectedIcon: Icon(
              Icons.description,
            ),
            label: 'Dokumen',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.bar_chart_outlined,
            ),
            selectedIcon: Icon(
              Icons.bar_chart,
            ),
            label: 'Rekap',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}