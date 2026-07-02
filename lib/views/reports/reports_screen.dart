import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/pdf_service.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../viewmodels/attendance_viewmodel.dart';
import '../../viewmodels/delegate_viewmodel.dart';
import '../../viewmodels/team_viewmodel.dart';
import '../../widgets/app_drawer.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final delegates = context.watch<DelegateViewModel>().delegates;
    final members = context.watch<TeamViewModel>().members;
    final attendance = context.watch<AttendanceViewModel>().attendance;

    final reports = [
      _ReportAction(
        title: 'Delegate Master Report',
        subtitle: 'Delegate ID, name, CNIC, committee, contact, and payment.',
        filename: 'delegate_master_report.pdf',
        builder: () => PDFService().generateDelegateMasterReport(delegates),
      ),
      _ReportAction(
        title: 'Committee Wise Report',
        subtitle: 'Committee totals with paid and pending delegate counts.',
        filename: 'committee_wise_report.pdf',
        builder: () => PDFService().generateCommitteeWiseReport(delegates),
      ),
      _ReportAction(
        title: 'Payment Report',
        subtitle: 'Amount paid, method, status, and total collection.',
        filename: 'payment_report.pdf',
        builder: () => PDFService().generatePaymentReport(delegates),
      ),
      _ReportAction(
        title: 'Delegate Attendance Report',
        subtitle: 'Delegate attendance dates across Day 1, Day 2, and Day 3.',
        filename: 'delegate_attendance_report.pdf',
        builder: () => PDFService().generateDelegateAttendanceReport(
          delegates: delegates,
          attendance: attendance,
        ),
      ),
      _ReportAction(
        title: 'Team Attendance Report',
        subtitle: 'Team attendance dates across Day 1, Day 2, and Day 3.',
        filename: 'team_attendance_report.pdf',
        builder: () => PDFService().generateTeamAttendanceReport(
          members: members,
          attendance: attendance,
        ),
      ),
      _ReportAction(
        title: 'Department Wise Team Report',
        subtitle: 'Department totals and attendance summary.',
        filename: 'department_wise_team_report.pdf',
        builder: () => PDFService().generateDepartmentWiseTeamReport(
          members: members,
          attendance: attendance,
        ),
      ),
    ];

    return Scaffold(
      body: Row(
        children: [
          const SizedBox(
            width: 280,
            child: AppDrawer(selected: 'Reports'),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reports',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.separated(
                      itemCount: reports.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _ReportTile(report: reports[index]),
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

class _ReportAction {
  final String title;
  final String subtitle;
  final String filename;
  final Future<Uint8List> Function() builder;

  const _ReportAction({
    required this.title,
    required this.subtitle,
    required this.filename,
    required this.builder,
  });
}

class _ReportTile extends StatefulWidget {
  final _ReportAction report;

  const _ReportTile({required this.report});

  @override
  State<_ReportTile> createState() => _ReportTileState();
}

class _ReportTileState extends State<_ReportTile> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        leading: const Icon(Icons.picture_as_pdf_outlined),
        title: Text(widget.report.title),
        subtitle: Text(widget.report.subtitle),
        trailing: Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _loading ? null : () => _export(print: false),
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export PDF'),
            ),
            FilledButton.icon(
              onPressed: _loading ? null : () => _export(print: true),
              icon: const Icon(Icons.print_outlined),
              label: const Text('Print'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _export({required bool print}) async {
    setState(() => _loading = true);
    try {
      final bytes = await widget.report.builder();
      final service = PDFService();
      if (print) {
        await service.printPdf(bytes, name: widget.report.filename);
      } else {
        await service.savePdf(bytes, name: widget.report.filename);
      }
      if (mounted) {
        SnackbarUtils.showSuccess(context, 'Report generated');
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
