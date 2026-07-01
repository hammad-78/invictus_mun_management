import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/attendance_model.dart';
import '../../models/delegate_model.dart';
import '../../models/team_member_model.dart';

class PDFService {
  Future<Uint8List> generateDelegateMasterReport(
    List<DelegateModel> delegates,
  ) async {
    return _buildReport(
      title: 'Delegate Master Report',
      headers: const [
        'Delegate ID',
        'Name',
        'CNIC',
        'Committee',
        'Contact',
        'Payment Method',
        'Payment Status',
      ],
      rows: delegates
          .map(
            (delegate) => [
              delegate.delegateId,
              delegate.name,
              delegate.cnic,
              delegate.committee,
              delegate.contactNumber,
              delegate.paymentMethod,
              delegate.paymentStatus,
            ],
          )
          .toList(),
      summary: 'Total Delegates: ${delegates.length}',
    );
  }

  Future<Uint8List> generateCommitteeWiseReport(
    List<DelegateModel> delegates,
  ) async {
    final committees = <String, List<DelegateModel>>{};
    for (final delegate in delegates) {
      committees.putIfAbsent(delegate.committee, () => []).add(delegate);
    }

    return _buildReport(
      title: 'Committee Wise Report',
      headers: const [
        'Committee',
        'Total Delegates',
        'Paid Delegates',
        'Pending Delegates',
      ],
      rows: committees.entries.map((entry) {
        final paid = entry.value
            .where((item) => item.paymentStatus.toLowerCase() == 'paid')
            .length;
        return [
          entry.key,
          entry.value.length.toString(),
          paid.toString(),
          (entry.value.length - paid).toString(),
        ];
      }).toList(),
      summary: 'Total Committees: ${committees.length}',
    );
  }

  Future<Uint8List> generatePaymentReport(List<DelegateModel> delegates) async {
    final total = delegates.fold<double>(
      0,
      (sum, delegate) => sum + delegate.amountPaid,
    );

    return _buildReport(
      title: 'Payment Report',
      headers: const [
        'Delegate Name',
        'Amount Paid',
        'Payment Method',
        'Payment Status',
      ],
      rows: delegates
          .map(
            (delegate) => [
              delegate.name,
              delegate.amountPaid.toStringAsFixed(0),
              delegate.paymentMethod,
              delegate.paymentStatus,
            ],
          )
          .toList(),
      summary: 'Total Amount Paid: ${total.toStringAsFixed(0)}',
    );
  }

  Future<Uint8List> generateDelegateAttendanceReport({
    required List<DelegateModel> delegates,
    required List<AttendanceModel> attendance,
  }) async {
    return _buildReport(
      title: 'Delegate Attendance Report',
      headers: const ['Delegate Name', 'Delegate ID', 'Present Status'],
      rows: delegates.map((delegate) {
        final marked = attendance.any(
          (item) =>
              item.personType == 'delegate' &&
              item.personId == delegate.delegateId &&
              item.present,
        );
        return [
          delegate.name,
          delegate.delegateId,
          marked ? 'Present' : 'Absent',
        ];
      }).toList(),
      summary: 'Present Delegates: ${attendance.where((item) => item.personType == 'delegate' && item.present).length}',
    );
  }

  Future<Uint8List> generateTeamAttendanceReport({
    required List<TeamMemberModel> members,
    required List<AttendanceModel> attendance,
  }) async {
    return _buildReport(
      title: 'Team Attendance Report',
      headers: const ['Member Name', 'Member ID', 'Attendance Dates'],
      rows: members.map((member) {
        final days = attendance
            .where(
              (item) =>
                  item.personType == 'team' &&
                  item.personId == member.memberId &&
                  item.present,
            )
            .map((item) => 'Day ${item.day}')
            .toSet()
            .join(', ');
        return [member.name, member.memberId, days.isEmpty ? '-' : days];
      }).toList(),
      summary: 'Present Team Marks: ${attendance.where((item) => item.personType == 'team' && item.present).length}',
    );
  }

  Future<Uint8List> generateDepartmentWiseTeamReport({
    required List<TeamMemberModel> members,
    required List<AttendanceModel> attendance,
  }) async {
    final departments = <String, List<TeamMemberModel>>{};
    for (final member in members) {
      departments.putIfAbsent(member.department, () => []).add(member);
    }

    return _buildReport(
      title: 'Department Wise Team Report',
      headers: const ['Department', 'Total Members', 'Attendance Summary'],
      rows: departments.entries.map((entry) {
        final ids = entry.value.map((member) => member.memberId).toSet();
        final marks = attendance
            .where(
              (item) =>
                  item.personType == 'team' &&
                  item.present &&
                  ids.contains(item.personId),
            )
            .length;
        return [entry.key, entry.value.length.toString(), '$marks present marks'];
      }).toList(),
      summary: 'Total Departments: ${departments.length}',
    );
  }

  Future<void> printPdf(Uint8List bytes, {required String name}) {
    return Printing.layoutPdf(
      name: name,
      onLayout: (_) async => bytes,
    );
  }

  Future<void> savePdf(Uint8List bytes, {required String name}) {
    return Printing.sharePdf(bytes: bytes, filename: name);
  }

  Future<Uint8List> _buildReport({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
    required String summary,
  }) async {
    final pdf = pw.Document();
    final generatedAt = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (context) => [
          pw.Text(
            'MUN Management System',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(title, style: const pw.TextStyle(fontSize: 16)),
          pw.Text('Generated: ${generatedAt.toLocal()}'),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue100),
            cellAlignment: pw.Alignment.centerLeft,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 16),
          pw.Text(summary, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );

    return pdf.save();
  }
}
