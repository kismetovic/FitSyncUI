import 'package:flutter/material.dart';
import 'package:fitsync_mobile/l10n/app_localizations.dart';
import '../../../../../core/error/api_error_messages.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.registerTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(l.createAccount, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                if (authProvider.error != null)
                  Text(apiErrorText(context, authProvider.errorCode, authProvider.error), style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: l.firstName),
                  validator: (v) => v!.isEmpty ? l.required : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: l.lastName),
                  validator: (v) => v!.isEmpty ? l.required : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: l.email),
                  validator: (v) => v!.isEmpty ? l.required : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: l.phoneNumber),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l.password),
                  validator: (v) => v!.isEmpty ? l.required : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l.confirmPassword),
                  validator: (v) {
                    if (v!.isEmpty) return l.required;
                    if (v != _passwordController.text) return l.passwordsDoNotMatch;
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final navigator = Navigator.of(context);
                              final success = await authProvider.register(
                                firstName: _firstNameController.text,
                                lastName: _lastNameController.text,
                                email: _emailController.text,
                                phone: _phoneController.text,
                                password: _passwordController.text,
                                confirmPassword: _confirmPasswordController.text,
                              );
                              if (success && mounted) navigator.pop();
                            }
                          },
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : Text(l.registerTitle),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
