import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../views/attendance/attendance_screen.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/delegates/delegate_list_screen.dart';
import '../views/reports/reports_screen.dart';
import '../views/team/team_list_screen.dart';

class AppDrawer extends StatelessWidget {
  final String selected;

  const AppDrawer({
    super.key,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: _indexFor(selected),
      onDestinationSelected: (index) => _navigate(context, index),
      children: const [
        Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 16, 12),
          child: Text(
            'MUN Management System',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.dashboard_outlined,),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.badge_outlined, color: Colors.black,),
          selectedIcon: Icon(Icons.badge),
          label: Text('Delegates'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.groups_outlined, color: Colors.blue,),
          selectedIcon: Icon(Icons.groups),
          label: Text('Team Members'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.fact_check_outlined, color: Colors.green,),
          selectedIcon: Icon(Icons.fact_check),
          label: Text('Attendance'),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.picture_as_pdf_outlined, color: Colors.red,),
          selectedIcon: Icon(Icons.picture_as_pdf),
          label: Text('Reports'),
        ),
        Divider(),
        NavigationDrawerDestination(
          icon: Icon(Icons.logout, color: Colors.red,),
          label: Text('Logout'),
        ),
      ],
    );
  }

  int _indexFor(String value) {
    return switch (value) {
      'Dashboard' => 0,
      'Delegates' => 1,
      'Team Members' => 2,
      'Attendance' => 3,
      'Reports' => 4,
      _ => 0,
    };
  }

  void _navigate(BuildContext context, int index) async {
    if (index == _indexFor(selected)) return;

    Widget? screen;
    switch (index) {
      case 0:
        screen = const DashboardScreen();
      case 1:
        screen = const DelegatesScreen();
      case 2:
        screen = const TeamMembersScreen();
      case 3:
        screen = const AttendanceScreen();
      case 4:
        screen = const ReportsScreen();
      case 5:
        await context.read<AuthViewModel>().logout();
        if (context.mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        return;
    }

    if (screen == null || !context.mounted) return;
    final route = MaterialPageRoute(builder: (_) => screen!);
    if (ModalRoute.of(context)?.isFirst ?? false) {
      Navigator.of(context).push(route);
    } else {
      Navigator.of(context).pushReplacement(route);
    }
  }
}
