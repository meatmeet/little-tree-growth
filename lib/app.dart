import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/assessment_screen.dart';
import 'screens/growth_screen.dart';
import 'screens/courses_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';

class LittleTreeApp extends StatelessWidget {
  const LittleTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '小树成长',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const _AppGate(),
    );
  }
}

/// Auth gate: shows login or main shell based on auth state.
class _AppGate extends StatefulWidget {
  const _AppGate();

  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return auth.isLoggedIn ? const MainShell() : const LoginScreen();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  MainShellState createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  /// Called by child screens to switch tabs programmatically.
  void switchToTab(int index) {
    if (index >= 0 && index < 5) {
      setState(() => _currentIndex = index);
    }
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    AssessmentScreen(),
    GrowthScreen(),
    CoursesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      ('🌱', '首页'),
      ('📋', '评测'),
      ('📈', '成长'),
      ('📚', '课程'),
      ('👤', '我的'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: List.generate(items.length, (i) {
              final isActive = i == _currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActive)
                        Container(
                          width: 20,
                          height: 3,
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      else
                        const SizedBox(height: 7),
                      Text(
                        items[i].$1,
                        style: TextStyle(
                          fontSize: 22,
                          color: isActive ? AppTheme.primary : AppTheme.textTertiary,
                        ),
                      ),
                      Text(
                        items[i].$2,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? AppTheme.primary : AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
