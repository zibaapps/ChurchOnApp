import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import '../../common/providers/auth_providers.dart';
import '../../common/providers/tenant_providers.dart';
import '../../common/widgets/app_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  bool _isRegister = false;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('saved_email');
    if (email != null && email.isNotEmpty) {
      _emailController.text = email;
    }
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid email and 6+ char password')));
      return;
    }
    setState(() => _loading = true);
    try {
      final auth = ref.read(authServiceProvider);
      final user = _isRegister
          ? await auth.registerWithEmail(email, password)
          : await auth.signInWithEmail(email, password);
      if (!mounted) return;
      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('saved_email', email);
      }
      // Set active church if available and navigate
      if (user.churchId != null) {
        ref.read(activeChurchIdProvider.notifier).state = user.churchId;
        context.go('/home');
      } else {
        context.go('/onboarding/church');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auth error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const AppLogo(size: 96),
            const SizedBox(height: 24),
            SwitchListTile.adaptive(
              title: Text(_isRegister ? 'Register' : 'Login'),
              value: _isRegister,
              onChanged: (v) => setState(() => _isRegister = v),
            ),
            TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _rememberMe,
              onChanged: (v) => setState(() => _rememberMe = v ?? true),
              title: const Text('Remember me'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  TextButton(onPressed: () => context.push('/support'), child: const Text('Terms & Conditions')),
                  TextButton(onPressed: () => context.push('/support'), child: const Text('Privacy Policy')),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : _handleSubmit,
              child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_isRegister ? 'Create account' : 'Continue'),
            ),
          ],
        ),
      ),
    );
  }
}