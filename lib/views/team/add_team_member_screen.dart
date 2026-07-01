import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/utils/snackbar_utils.dart';
import '../../models/team_member_model.dart';
import '../../viewmodels/team_viewmodel.dart';
import '../../widgets/custom_button.dart';

class AddEditTeamMemberScreen extends StatefulWidget {
  final TeamMemberModel? member;

  const AddEditTeamMemberScreen({
    super.key,
    this.member,
  });

  @override
  State<AddEditTeamMemberScreen> createState() =>
      _AddEditTeamMemberScreenState();
}

class AddTeamMemberScreen extends AddEditTeamMemberScreen {
  const AddTeamMemberScreen({super.key});
}

class _AddEditTeamMemberScreenState extends State<AddEditTeamMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _memberId = TextEditingController();
  final _name = TextEditingController();
  final _department = TextEditingController();
  final _post = TextEditingController();
  final _contact = TextEditingController();
  final _email = TextEditingController();

  bool get _isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    if (member != null) {
      _memberId.text = member.memberId;
      _name.text = member.name;
      _department.text = member.department;
      _post.text = member.post;
      _contact.text = member.contactNumber;
      _email.text = member.email;
    }
  }

  @override
  void dispose() {
    _memberId.dispose();
    _name.dispose();
    _department.dispose();
    _post.dispose();
    _contact.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TeamViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Team Member' : 'Add Team Member'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
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
                          _memberId,
                          'Member ID',
                          enabled: !_isEditing,
                          maxLength: 3,
                          uppercase: true,
                          validator: _userIdValidator('Member ID'),
                        ),
                        _field(_name, 'Name'),
                        _field(_department, 'Department'),
                        _field(_post, 'Post'),
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
                        _field(
                          _email,
                          'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomButton(
                        label: _isEditing ? 'Update Member' : 'Save Member',
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
      width: 320,
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final member = TeamMemberModel(
      memberId: _memberId.text.trim().toUpperCase(),
      name: _name.text.trim(),
      department: _department.text.trim(),
      post: _post.text.trim(),
      contactNumber: _contact.text.trim(),
      email: _email.text.trim(),
      createdAt: widget.member?.createdAt ?? DateTime.now(),
    );

    try {
      if (_isEditing) {
        await context.read<TeamViewModel>().updateMember(member);
      } else {
        await context.read<TeamViewModel>().addMember(member);
      }
      if (mounted) {
        SnackbarUtils.showSuccess(context, 'Team member saved');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, e.toString());
    }
  }
}
