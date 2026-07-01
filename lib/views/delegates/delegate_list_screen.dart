import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/delegate_model.dart';
import '../../viewmodels/delegate_viewmodel.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_textfield.dart';
import 'add_delegate_screen.dart';

class DelegatesScreen extends StatefulWidget {
  const DelegatesScreen({super.key});

  @override
  State<DelegatesScreen> createState() => _DelegatesScreenState();
}

class DelegateListScreen extends DelegatesScreen {
  const DelegateListScreen({super.key});
}

class _DelegatesScreenState extends State<DelegatesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DelegateViewModel>();

    return Scaffold(
      body: Row(
        children: [
          const SizedBox(
            width: 280,
            child: AppDrawer(selected: 'Delegates'),
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
                          'Delegates',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _openForm(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Delegate'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 460,
                    child: CustomTextField(
                      controller: _searchController,
                      label: 'Search by name, CNIC, or delegate ID',
                      icon: Icons.search,
                      onChanged: context.read<DelegateViewModel>().setSearchQuery,
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
                              DataColumn(label: Text('CNIC')),
                              DataColumn(label: Text('Committee')),
                              DataColumn(label: Text('Payment')),
                              DataColumn(label: Text('Amount')),
                              DataColumn(label: Text('Created')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: vm.delegates
                                .map((delegate) => _row(context, delegate))
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

  DataRow _row(BuildContext context, DelegateModel delegate) {
    return DataRow(
      cells: [
        DataCell(Text(delegate.delegateId)),
        DataCell(Text(delegate.name)),
        DataCell(Text(delegate.cnic)),
        DataCell(Text(delegate.committee)),
        DataCell(Text('${delegate.paymentMethod} / ${delegate.paymentStatus}')),
        DataCell(Text(delegate.amountPaid.toStringAsFixed(0))),
        DataCell(Text(DateFormat.yMMMd().format(delegate.createdAt))),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: 'Edit',
                onPressed: () => _openForm(context, delegate),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, delegate),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openForm(BuildContext context, [DelegateModel? delegate]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditDelegateScreen(delegate: delegate),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DelegateModel delegate,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete delegate'),
        content: Text('Delete ${delegate.name}?'),
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
      await context.read<DelegateViewModel>().deleteDelegate(delegate.delegateId);
    }
  }
}
