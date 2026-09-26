import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();

  final _repository = AuthRepository();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isLogin) {
        await _repository.signIn(
          email: _email.text,
          password: _password.text,
        );
      } else {
        await _repository.signUp(
          fullName: _name.text,
          email: _email.text,
          password: _password.text,
          phone: _phone.text,
        );
      }

      if (!mounted) return;

      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        setState(() {
          _loading = false;
          _error = 'Compte créé. Vérifie ton adresse e-mail pour activer le compte, puis connecte-toi.';
        });
        return;
      }

      final hasBusiness = await _repository.hasBusiness();
      if (!mounted) return;
      context.go(hasBusiness ? '/dashboard' : '/onboarding');
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Une erreur est survenue. Vérifie ta connexion et réessaie.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isLogin ? 'Connexion' : 'Créer mon compte';

    return Scaffold(
      appBar: AppBar(title: const Text('APNBF')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin
                          ? 'Accède à ton activité APNBF.'
                          : 'Crée le compte du responsable de l’activité.',
                    ),
                    const SizedBox(height: 28),
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _name,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Nom complet'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Nom requis' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Téléphone'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Téléphone requis' : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                      validator: (v) => v == null || !v.contains('@') ? 'E-mail invalide' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      validator: (v) => v == null || v.length < 6 ? '6 caractères minimum' : null,
                    ),
                    const SizedBox(height: 18),
                    if (_error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_error!),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _loading ? null : _submit,
                        child: Text(_loading ? 'Patiente...' : title),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: _loading
                            ? null
                            : () => setState(() {
                                  _isLogin = !_isLogin;
                                  _error = null;
                                }),
                        child: Text(
                          _isLogin
                              ? 'Je n’ai pas encore de compte'
                              : 'J’ai déjà un compte',
                        ),
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
}
