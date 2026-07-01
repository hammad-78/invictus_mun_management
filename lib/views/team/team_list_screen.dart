import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/team_member_model.dart';
import '../../viewmodels/team_viewmodel.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_textfield.dart';
import 'add_team_member_screen.dart';

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class TeamListScreen extends TeamMembersScreen {
  const TeamListScreen({super.key});
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TeamViewModel>();

    return Scaffold(
      body: Row(
        children: [
          const SizedBox(
            width: 280,
            child: AppDrawer(selected: 'Team Members'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Team Members',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _openForm(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Member'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 420,
                    child: CustomTextField(
                      controller: _searchController,
                      label: 'Search by name or member ID',
                      icon: Icons.search,
                      onChanged: context.read<TeamViewModel>().setSearchQuery,
                    ),
                  ),
                  if (vm.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      vm.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Expanded(
                    child: Card(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Department')),
                              DataColumn(label: Text('Post')),
                              DataColumn(label: Text('Contact')),
                              DataColumn(label: Text('Email')),
                              DataColumn(label: Text('Created')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: vm.members
                                .map((member) => _row(context, member))
                                .toList(),
                          ),
                        ),
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

  DataRow _row(BuildContext context, TeamMemberModel member) {
    return DataRow(
      cells: [
        DataCell(Text(member.memberId)),
        DataCell(Text(member.name)),
        DataCell(Text(member.department)),
        DataCell(Text(member.post)),
        DataCell(Text(member.contactNumber)),
        DataCell(Text(member.email)),
        DataCell(Text(DateFormat.yMMMd().format(member.createdAt))),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: 'Edit',
                onPressed: () => _openForm(context, member),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, member),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openForm(BuildContext context, [TeamMemberModel? member]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditTeamMemberScreen(member: member),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TeamMemberModel member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete team member'),
        content: Text('Delete ${member.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<TeamViewModel>().deleteMember(member.memberId);
    }
  }
}
