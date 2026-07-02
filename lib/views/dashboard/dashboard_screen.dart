import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/dashboard_viewmodel.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardViewModel>();
    final colorScheme = Theme.of(context).colorScheme;

    final cards = [
      StatCard(
        title: 'Total Delegates',
        value: dashboard.totalDelegates.toString(),
        icon: Icons.badge,
        color: colorScheme.primary,
      ),
      StatCard(
        title: 'Total Team Members',
        value: dashboard.totalTeamMembers.toString(),
        icon: Icons.groups,
        color: Colors.teal,
      ),
      StatCard(
        title: 'Paid Delegates',
        value: dashboard.paidDelegates.toString(),
        icon: Icons.payments,
        color: Colors.green,
      ),
      StatCard(
        title: 'Pending Delegates',
        value: dashboard.pendingDelegates.toString(),
        icon: Icons.pending_actions,
        color: Colors.orange,
      ),
      StatCard(
        title: 'Delegate Attendance',
        value: dashboard.delegateAttendanceCount.toString(),
        icon: Icons.how_to_reg,
        color: Colors.indigo,
      ),
      StatCard(
        title: 'Team Attendance',
        value: dashboard.teamAttendanceCount.toString(),
        icon: Icons.task_alt,
        color: Colors.purple,
      ),
    ];

    return Scaffold(
      body: Row(
        children: [
          const SizedBox(
            width: 280,
            child: AppDrawer(selected: 'Dashboard'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/iv_logo.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Invictus Model United Nations',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Monitor registrations, attendance, and event progress.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (dashboard.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      dashboard.errorMessage!,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 360,
                        mainAxisExtent: 112,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: cards.length,
                      itemBuilder: (context, index) => cards[index],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Developed by Hammad Ali Khan & Muhammad Majid Nawaz',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      
    );
  }
}
