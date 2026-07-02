import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/attendance_model.dart';
import '../../models/delegate_model.dart';
import '../../models/team_member_model.dart';
import '../../viewmodels/attendance_viewmodel.dart';
import '../../viewmodels/delegate_viewmodel.dart';
import '../../viewmodels/team_viewmodel.dart';
import '../../widgets/app_drawer.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _personType = 'delegate';
  int _day = 1;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceViewModel>();
    final delegates = context.watch<DelegateViewModel>().delegates;
    final members = context.watch<TeamViewModel>().members;

    return Scaffold(
      body: Row(
        children: [
          const SizedBox(
            width: 280,
            child: AppDrawer(selected: 'Attendance'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'delegate',
                            icon: Icon(Icons.badge_outlined),
                            label: Text('Delegates'),
                          ),
                          ButtonSegment(
                            value: 'team',
                            icon: Icon(Icons.groups_outlined),
                            label: Text('Team'),
                          ),
                        ],
                        selected: {_personType},
                        onSelectionChanged: (value) {
                          setState(() {
                            _personType = value.first;
                            _day = 1;
                          });
                        },
                      ),
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 1, label: Text('Day 1')),
                          ButtonSegment(value: 2, label: Text('Day 2')),
                          ButtonSegment(value: 3, label: Text('Day 3')),
                        ],
                        selected: {_day},
                        onSelectionChanged: (value) {
                          setState(() => _day = value.first);
                        },
                      ),
                      SizedBox(
                        width: 360,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search by ID or name',
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) => setState(() => _query = value),
                        ),
                      ),
                    ],
                  ),
                  if (attendance.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      attendance.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Expanded(
                    child: _personType == 'delegate'
                        ? _DelegateAttendanceTable(
                            delegates: _filterDelegates(delegates),
                            day: _day,
                          )
                        : _TeamAttendanceTable(
                            members: _filterMembers(members),
                            day: _day,
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

  List<DelegateModel> _filterDelegates(List<DelegateModel> delegates) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return delegates;
    return delegates
        .where(
          (delegate) =>
              delegate.name.toLowerCase().contains(query) ||
              delegate.delegateId.toLowerCase().contains(query),
        )
        .toList();
  }

  List<TeamMemberModel> _filterMembers(List<TeamMemberModel> members) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return members;
    return members
        .where(
          (member) =>
              member.name.toLowerCase().contains(query) ||
              member.memberId.toLowerCase().contains(query),
        )
        .toList();
  }
}

class _DelegateAttendanceTable extends StatelessWidget {
  final List<DelegateModel> delegates;
  final int day;

  const _DelegateAttendanceTable({
    required this.delegates,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AttendanceViewModel>();

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            dataRowMinHeight: 64,
            dataRowMaxHeight: 72,
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('Delegate ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Committee')),
              DataColumn(label: Text('Day')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Action')),
            ],
            rows: delegates.map((delegate) {
              final record = vm.recordFor(delegate.delegateId, 'delegate', day);
              final status = record == null
                  ? 'Not marked'
                  : record.present
                      ? 'Present'
                      : 'Absent';
              return DataRow(
                key: ValueKey('delegate-${delegate.delegateId}-day$day'),
                cells: [
                  DataCell(Text(delegate.delegateId)),
                  DataCell(Text(delegate.name)),
                  DataCell(Text(delegate.committee)),
                  DataCell(Text('Day $day')),
                  DataCell(Text(status)),
                  DataCell(_AttendanceActions(
                    key: ValueKey(
                      'delegate-actions-${delegate.delegateId}-day$day',
                    ),
                    personId: delegate.delegateId,
                    personType: 'delegate',
                    day: day,
                    record: record,
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _TeamAttendanceTable extends StatelessWidget {
  final List<TeamMemberModel> members;
  final int day;

  const _TeamAttendanceTable({
    required this.members,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AttendanceViewModel>();

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            dataRowMinHeight: 64,
            dataRowMaxHeight: 72,
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('Member ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Department')),
              DataColumn(label: Text('Day')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Action')),
            ],
            rows: members.map((member) {
              final record = vm.recordFor(member.memberId, 'team', day);
              final status = record == null
                  ? 'Not marked'
                  : record.present
                      ? 'Present'
                      : 'Absent';
              return DataRow(
                key: ValueKey('team-${member.memberId}-day$day'),
                cells: [
                  DataCell(Text(member.memberId)),
                  DataCell(Text(member.name)),
                  DataCell(Text(member.department)),
                  DataCell(Text('Day $day')),
                  DataCell(Text(status)),
                  DataCell(_AttendanceActions(
                    key: ValueKey('team-actions-${member.memberId}-day$day'),
                    personId: member.memberId,
                    personType: 'team',
                    day: day,
                    record: record,
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _AttendanceActions extends StatelessWidget {
  final String personId;
  final String personType;
  final int day;
  final AttendanceModel? record;

  const _AttendanceActions({
    super.key,
    required this.personId,
    required this.personType,
    required this.day,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AttendanceViewModel>();
    final isPresent = record?.present;

    return SizedBox(
      width: 152,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AttendanceActionButton(
            key: ValueKey('$personType-$personId-day$day-present'),
            tooltip: 'Mark present',
            icon: Icons.check,
            selected: isPresent == true,
            onPressed: () => vm.setAttendance(
              personId: personId,
              personType: personType,
              day: day,
              present: true,
            ),
          ),
          const SizedBox(width: 6),
          _AttendanceActionButton(
            key: ValueKey('$personType-$personId-day$day-absent'),
            tooltip: 'Mark absent',
            icon: Icons.close,
            selected: isPresent == false,
            onPressed: () => vm.setAttendance(
              personId: personId,
              personType: personType,
              day: day,
              present: false,
            ),
          ),
          const SizedBox(width: 6),
          IconButton.filledTonal(
            key: ValueKey('$personType-$personId-day$day-clear'),
            tooltip: 'Clear attendance',
            visualDensity: VisualDensity.compact,
            onPressed: record == null
                ? null
                : () => vm.clearAttendance(
                      personId: personId,
                      personType: personType,
                      day: day,
                    ),
            icon: const Icon(Icons.backspace_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}

class _AttendanceActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  const _AttendanceActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor:
            selected ? colorScheme.primaryContainer : colorScheme.surface,
        foregroundColor:
            selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
        side: BorderSide(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
    );
  }
}
