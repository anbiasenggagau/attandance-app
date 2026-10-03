import 'package:attandance/data/central_api_caller.dart';
import 'package:attandance/pages/attendance_log.dart';
import 'package:attandance/pages/color_page.dart';
import 'package:attandance/pages/home.dart';
import 'package:attandance/pages/login.dart';
import 'package:attandance/pages/request.dart';
import 'package:attandance/pages/request_list.dart';
import 'package:attandance/storage/token.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class DataSyncNotifier extends ValueNotifier<int> {
  DataSyncNotifier() : super(0);

  void notifyDataChanged() {
    value++;
  }
}

final globalDataSync = DataSyncNotifier();

void main() async {
  runApp(const Attandance());
}

class Attandance extends StatelessWidget {
  const Attandance({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Attendance',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Color(0xFF325E6A))),
      home: FutureBuilder<String?>(
        future: CentralApiCaller().setToken(null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final token = snapshot.data;
          if (token == null || token.isEmpty) {
            return const LoginPage();
          }

          return HomePage(title: 'Attendance');
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CentralApiCaller apiCaller = CentralApiCaller();

  int selectedIdx = 2;
  late final Set<int> _visitedIndices = {selectedIdx};

  int outStandingReq = 0;

  @override
  void initState() {
    super.initState();
    globalDataSync.addListener(_onDataSyncChanged);
  }

  @override
  void dispose() {
    globalDataSync.removeListener(_onDataSyncChanged);
    super.dispose();
  }

  void _onDataSyncChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentVersion = globalDataSync.value;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          selectedIdx == 3
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: Badge.count(
                      count: outStandingReq,
                      child: const Icon(Icons.approval),
                    ),
                    tooltip: 'Approval',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RequestList(),
                        ),
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),

      body: IndexedStack(
        index: selectedIdx,
        children: [
          _visitedIndices.contains(0)
              ? const ColorSchemePreviewPage()
              : const SizedBox.shrink(),
          _visitedIndices.contains(1)
              ? AttendanceLog(
                  dataVersion: currentVersion,
                  isActive: selectedIdx == 1,
                )
              : const SizedBox.shrink(),
          _visitedIndices.contains(2)
              ? const Attendance()
              : const SizedBox.shrink(),
          _visitedIndices.contains(3)
              ? Request(
                  onRequestCountChanged: (count) {
                    setState(() {
                      outStandingReq = count;
                    });
                  },
                )
              : const SizedBox.shrink(),
        ],
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        showUnselectedLabels: true,
        currentIndex: selectedIdx,
        onTap: (int idx) {
          setState(() {
            selectedIdx = idx;
            _visitedIndices.add(idx);
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.color_lens), label: "Color"),
          BottomNavigationBarItem(
            icon: Icon(Icons.punch_clock),
            label: "Attendance",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: "Request",
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(radius: 30, child: Icon(Icons.person, size: 35)),
                SizedBox(height: 10),
                Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Account Info'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          Navigator.pop(context);

                          // Clear stored JWT token
                          await TokenStorage.deleteToken();

                          if (!context.mounted) return;

                          // Navigate back to Login Screen and clear stack
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
