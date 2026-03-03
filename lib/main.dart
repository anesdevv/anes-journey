import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// Core Modules
import 'modules/calendar/calendar_screen.dart';
import 'modules/todo/todo_screen.dart';
import 'modules/goals/goals_screen.dart';
import 'modules/habits/habits_screen.dart';
// Specialized Modules
import 'modules/prayers/prayers_screen.dart';
import 'modules/language/language_screen.dart';
import 'modules/journal/journal_screen.dart';
import 'modules/dashboard/dashboard_screen.dart';
import 'modules/settings/about_screen.dart';

// Services
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'services/export_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCtM07Zxal--d9AQfwA6lq5WHaBhwaf3h8",
        authDomain: "lihlih-app-mvp-2026.firebaseapp.com",
        projectId: "lihlih-app-mvp-2026",
        storageBucket: "lihlih-app-mvp-2026.firebasestorage.app",
        messagingSenderId: "169404052932",
        appId: "1:169404052932:web:3b440e5fc3e9f6abe56091",
      ),
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Initialize Custom Services
  try {
    await NotificationService().init();
    await SyncService().init();
  } catch (e) {
    debugPrint('Services init error: $e');
  }

  runApp(const AnesJourneyApp());
}

class AnesJourneyApp extends StatelessWidget {
  const AnesJourneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anes Journey',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE53935), // Red 600
          surface: Color(0xFF111111),
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111111),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF111111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF111111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF111111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF111111),
          selectedItemColor: Color(0xFFE53935),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const CalendarScreen(),
    const TodoScreen(),
    const TrackerTabsScreen(),
    const MoreMenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showQuickAddModal(context),
              backgroundColor: const Color(0xFFE53935),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'To-Do'),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  void _showQuickAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Quick Add',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFFE53935),
                ),
                title: const Text(
                  'Add To-Do',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 2); // To-Do tab
                },
              ),
              ListTile(
                leading: const Icon(Icons.mosque, color: Color(0xFFE53935)),
                title: const Text(
                  'Log Prayer',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 3); // Tracker tab
                },
              ),
              ListTile(
                leading: const Icon(Icons.loop, color: Color(0xFFE53935)),
                title: const Text(
                  'Update Habit',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 3); // Tracker tab
                },
              ),
              ListTile(
                leading: const Icon(Icons.language, color: Color(0xFFE53935)),
                title: const Text(
                  'Log Study Session',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 4); // More menu -> Language
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.book, color: Color(0xFFE53935)),
                title: const Text(
                  'Write Journal',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 4); // More menu -> Journal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JournalScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// Sub-navigation for Tracker Tab (Prayers + Goals + Habits)
class TrackerTabsScreen extends StatelessWidget {
  const TrackerTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trackers'),
          bottom: const TabBar(
            indicatorColor: Color(0xFFE53935),
            labelColor: Color(0xFFE53935),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Prayers'),
              Tab(text: 'Goals'),
              Tab(text: 'Habits'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PrayersScreen(), // Milestone 3 Integration
            GoalsScreen(),
            HabitsScreen(),
          ],
        ),
      ),
    );
  }
}

// Menu screen for navigating to independent feature screens like Language and Journal
class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More Tools')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFFE53935)),
            title: const Text('German Ausbildung'),
            subtitle: const Text('Track study sessions and topics'),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguageScreen()),
              );
            },
          ),
          const Divider(color: Color(0xFF333333)),
          ListTile(
            leading: const Icon(Icons.book, color: Color(0xFFE53935)),
            title: const Text('Journal'),
            subtitle: const Text('Daily entries and mood tracking'),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JournalScreen()),
              );
            },
          ),
          const Divider(color: Color(0xFF333333)),
          ListTile(
            leading: const Icon(Icons.file_download, color: Color(0xFFE53935)),
            title: const Text(
              'Export Data',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Export all local data to JSON',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onTap: () async {
              try {
                final exportService = ExportService();
                await exportService.exportDataToJson();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Data exported to console/mock file successfully.',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          const Divider(color: Color(0xFF333333)),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFFE53935)),
            title: const Text(
              'About App',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'App details and creator info',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
