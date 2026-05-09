import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../shared/widgets/ruzai_bottom_nav.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/detection/screens/camera_screen.dart';
import '../features/chat/screens/chat_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../features/profile/screens/profile_screen.dart';

class RuzaiApp extends StatelessWidget {
  const RuzaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ruz.ai',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CameraScreen(),
    const ChatScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: RuzaiBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
