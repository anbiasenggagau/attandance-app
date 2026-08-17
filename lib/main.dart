import 'package:attandance/pages/attendance_log.dart';
import 'package:attandance/pages/color_page.dart';
import 'package:attandance/pages/home.dart';
import 'package:attandance/pages/request.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Attandance());
}

class Attandance extends StatelessWidget {
  const Attandance({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Color(0xFF325E6A))),
      home: const HomePage(title: 'Flutter Demo Home Page'),
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
  int selectedIdx = 1;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ColorSchemePreviewPage(),
      Request(),
      Attendance(),
      AttendanceLog(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      body: IndexedStack(index: selectedIdx, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // <--- ADD THIS LINE
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface, // Set the bar's background
        selectedItemColor: Theme.of(
          context,
        ).colorScheme.primary, // Dark navy for selected
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.secondary, // Grey for unselected
        showUnselectedLabels: true,
        currentIndex: selectedIdx,
        onTap: (int idx) {
          setState(() {
            selectedIdx = idx;
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
