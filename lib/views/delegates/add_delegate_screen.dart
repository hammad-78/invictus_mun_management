import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../models/delegate_model.dart';
import '../../viewmodels/delegate_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AddEditDelegateScreen extends StatefulWidget {
  final DelegateModel? delegate;

  const AddEditDelegateScreen({
    super.key,
    this.delegate,
  });

  @override
  State<AddEditDelegateScreen> createState() => _AddEditDelegateScreenState();
}

class AddDelegateScreen extends AddEditDelegateScreen {
  const AddDelegateScreen({super.key});
}

class _AddEditDelegateScreenState extends State<AddEditDelegateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _delegateId = TextEditingController();
  final _cnic = TextEditingController();
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _dob = TextEditingController();
  final _committee = TextEditingController();
  final _amountPaid = TextEditingController();
  final _remarks = TextEditingController();

  String _registrationType = AppConstants.registrationTypes.first;
  String _paymentMethod = AppConstants.paymentMethods.first;
  String _paymentStatus = AppConstants.paymentStatuses.last;
  DateTime _dateOfBirth = DateTime(2000);

  bool get _isEditing => widget.delegate != null;

  @override
  void initState() {
    super.initState();
    final delegate = widget.delegate;
    if (delegate != null) {
      _delegateId.text = delegate.delegateId;
      _cnic.text = delegate.cnic;
      _name.text = delegate.name;
      _contact.text = delegate.contactNumber;
      _dateOfBirth = delegate.dateOfBirth;
      _dob.text = DateFormat.yMMMd().format(_dateOfBirth);
      _committee.text = delegate.committee;
      _registrationType = delegate.registrationType;
      _paymentMethod = delegate.paymentMethod;
      _paymentStatus = delegate.paymentStatus;
      _amountPaid.text = delegate.amountPaid.toStringAsFixed(0);
      _remarks.text = delegate.remarks;
    }
  }

  @override
  void dispose() {
    _delegateId.dispose();
    _cnic.dispose();
    _name.dispose();
    _contact.dispose();
    _dob.dispose();
    _committee.dispose();
    _amountPaid.dispose();
    _remarks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DelegateViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Delegate' : 'Add Delegate'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Wrap(
                      runSpacing: 16,
                      spacing: 16,
                      children: [
                        _field(
                          _delegateId,
                          'Delegate ID',
                          enabled: !_isEditing,
                          maxLength: 3,
                          uppercase: true,
                          validator: _userIdValidator('Delegate ID'),
                        ),
                        _field(
                          _cnic,
                          'CNIC',
                          keyboardType: TextInputType.number,
                          maxLength: 13,
                          digitsOnly: true,
                          validator: _exactDigitsValidator('CNIC', 13),
                        ),
                        _field(_name, 'Name'),
                        _field(
                          _contact,
                          'Contact Number',
                          keyboardType: TextInputType.number,
                          maxLength: 11,
                          digitsOnly: true,
                          validator: _exactDigitsValidator(
                            'Contact number',
                            11,
                          ),
                        ),
                        _dateField(context),
                        _field(_committee, 'Committee'),
                        _dropdown(
                          label: 'Registration Type',
                          value: _registrationType,
                          items: AppConstants.registrationTypes,
                          onChanged: (value) =>
                              setState(() => _registrationType = value!),
                        ),
                        _dropdown(
                          label: 'Payment Method',
                          value: _paymentMethod,
                          items: AppConstants.paymentMethods,
                          onChanged: (value) =>
                              setState(() => _paymentMethod = value!),
                        ),
                        _dropdown(
                          label: 'Payment Status',
                          value: _paymentStatus,
                          items: AppConstants.paymentStatuses,
                          onChanged: (value) =>
                              setState(() => _paymentStatus = value!),
                        ),
                        _field(
                          _amountPaid,
                          'Amount Paid',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _remarks,
                      label: 'Remarks',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomButton(
                        label: _isEditing ? 'Update Delegate' : 'Save Delegate',
                        icon: Icons.save_outlined,
                        isLoading: vm.isLoading,
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool enabled = true,
    TextInputType? keyboardType,
    int? maxLength,
    bool digitsOnly = false,
    bool uppercase = false,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 280,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        maxLength: maxLength,
        textCapitalization:
            uppercase ? TextCapitalization.characters : TextCapitalization.none,
        inputFormatters: [
          if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
          if (uppercase)
            TextInputFormatter.withFunction(
              (oldValue, newValue) =>
                  newValue.copyWith(text: newValue.text.toUpperCase()),
            ),
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ],
        decoration: InputDecoration(
          labelText: label,
          counterText: maxLength == null ? null : '',
        ),
        validator: validator ??
            (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  String? Function(String?) _exactDigitsValidator(String label, int length) {
    return (value) {
      final text = value?.trim() ?? '';
      if (text.isEmpty) return 'Required';
      if (!RegExp('^\\d{$length}\$').hasMatch(text)) {
        return '$label must be exactly $length digits';
      }
      return null;
    };
  }

  String? Function(String?) _userIdValidator(String label) {
    return (value) {
      final text = value?.trim().toUpperCase() ?? '';
      if (text.isEmpty) return 'Required';
      if (!RegExp(r'^[A-Z][0-9]{2}$').hasMatch(text)) {
        return '$label must use format A01';
      }
      return null;
    };
  }

  Widget _dateField(BuildContext context) {
    return SizedBox(
      width: 280,
      child: TextFormField(
        controller: _dob,
        readOnly: true,
        decoration: const InputDecoration(labelText: 'Date of Birth'),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Required' : null,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(1970),
            lastDate: DateTime.now(),
            initialDate: _dateOfBirth,
          );
          if (picked != null) {
            setState(() {
              _dateOfBirth = picked;
              _dob.text = DateFormat.yMMMd().format(picked);
            });
          }
        },
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      width: 280,
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final delegate = DelegateModel(
      delegateId: _delegateId.text.trim().toUpperCase(),
      cnic: _cnic.text.trim(),
      name: _name.text.trim(),
      contactNumber: _contact.text.trim(),
      dateOfBirth: _dateOfBirth,
      committee: _committee.text.trim(),
      registrationType: _registrationType,
      paymentMethod: _paymentMethod,
      paymentStatus: _paymentStatus,
      amountPaid: double.tryParse(_amountPaid.text.trim()) ?? 0,
      remarks: _remarks.text.trim(),
      createdAt: widget.delegate?.createdAt ?? DateTime.now(),
    );

    try {
      if (_isEditing) {
        await context.read<DelegateViewModel>().updateDelegate(delegate);
      } else {
        await context.read<DelegateViewModel>().addDelegate(delegate);
      }
      if (mounted) {
        SnackbarUtils.showSuccess(context, 'Delegate saved');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, e.toString());
    }
  }
}
