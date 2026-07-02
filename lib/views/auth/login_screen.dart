import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController =
  TextEditingController();

  final passwordController =
  TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 420,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Admin Login",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 24),

                        CustomTextField(
                          controller: emailController,
                          label: "Email",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Email is required'
                              : null,
                        ),

                        const SizedBox(height: 14),

                        CustomTextField(
                          controller:
                          passwordController,
                          label: "Password",
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Password is required'
                              : null,
                        ),

                        if (vm.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            vm.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            label: "Login",
                            icon: Icons.login,
                            isLoading: vm.isLoading,
                            onPressed: () async {
                              if (!_formKey.currentState!.validate()) return;
                              await vm.login(
                                emailController.text,
                                passwordController.text,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Developed by Hammad Ali Khan & Muhammad Majid Nawaz',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}