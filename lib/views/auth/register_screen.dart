import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final error = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Conta criada com sucesso!',
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 70,
                  color: Colors.blue,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Crie sua conta no PedeAi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                CustomTextField(
                  controller: _nameController,
                  label: 'Nome',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Digite seu nome';
                    }

                    if (value.trim().length < 3) {
                      return 'Digite um nome válido';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  label: 'E-mail',
                  prefixIcon: Icons.email_outlined,
                  keyboardType:
                      TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Digite seu e-mail';
                    }

                    if (!value.contains('@')) {
                      return 'Digite um e-mail válido';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  controller: _passwordController,
                  label: 'Senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword =
                            !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Digite uma senha';
                    }

                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }

                    if (!RegExp(
                      r'[A-Z]',
                    ).hasMatch(value)) {
                      return 'A senha precisa ter uma letra maiúscula';
                    }

                    if (!RegExp(
                      r'[0-9]',
                    ).hasMatch(value)) {
                      return 'A senha precisa ter um número';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  controller:
                      _confirmPasswordController,
                  label: 'Confirmar senha',
                  prefixIcon: Icons.lock_reset_outlined,
                  obscureText:
                      _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                      });
                    },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Confirme sua senha';
                    }

                    if (value !=
                        _passwordController.text) {
                      return 'As senhas não coincidem';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 25),

                CustomButton(
                  text: 'CRIAR CONTA',
                  isLoading: authProvider.isLoading,
                  onPressed: _register,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}