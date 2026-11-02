import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Minha conta: um formulário para os dados pessoais
/// e outro para trocar a senha.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _emailController.text = user?.email ?? '';
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showResult(String? error, String successMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? successMessage),
        backgroundColor: error == null ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    final error = await context.read<AuthProvider>().updateProfile(
          _nameController.text.trim(),
          Validators.onlyDigits(_phoneController.text),
        );

    if (!mounted) return;
    _showResult(error, 'Dados atualizados.');
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    final error = await context.read<AuthProvider>().changePassword(
          _currentPasswordController.text,
          _newPasswordController.text,
        );

    if (!mounted) return;
    _showResult(error, 'Senha alterada com sucesso.');

    if (error == null) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Minha conta')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ===== DADOS PESSOAIS =====
            Form(
              key: _profileFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Title('Dados pessoais'),
                  CustomTextField(
                    controller: _emailController,
                    label: 'E-mail',
                    prefixIcon: Icons.email_outlined,
                    enabled: false,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Nome',
                    prefixIcon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                    validator: Validators.name,
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Telefone (com DDD)',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    validator: Validators.phone,
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    text: 'SALVAR DADOS',
                    isLoading: auth.isLoading,
                    onPressed: _saveProfile,
                  ),
                ],
              ),
            ),
            const Divider(height: 48),

            // ===== TROCAR SENHA =====
            Form(
              key: _passwordFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Title('Alterar senha'),
                  CustomTextField(
                    controller: _currentPasswordController,
                    label: 'Senha atual',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) => Validators.requiredField(v, 'a senha atual'),
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _newPasswordController,
                    label: 'Nova senha',
                    prefixIcon: Icons.lock_reset_outlined,
                    obscureText: true,
                    validator: (v) {
                      final error = Validators.password(v);
                      if (error != null) return error;
                      if (v == _currentPasswordController.text) {
                        return 'A nova senha deve ser diferente da atual';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar nova senha',
                    prefixIcon: Icons.lock_reset_outlined,
                    obscureText: true,
                    validator: (v) => v != _newPasswordController.text
                        ? 'As senhas não coincidem'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    text: 'ALTERAR SENHA',
                    isLoading: auth.isLoading,
                    onPressed: _changePassword,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;

  const _Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
