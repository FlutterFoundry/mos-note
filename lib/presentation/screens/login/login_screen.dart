import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscureToken = true;
  bool _obscurePassword = true;
  bool _loading = false;
  bool _useCredentials = true;
  String? _error;

  @override
  void dispose() {
    _tokenController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_useCredentials) {
        await ref.read(authStateProvider.notifier).signIn(
              _usernameController.text.trim(),
              _passwordController.text,
            );
      } else {
        await ref.read(authStateProvider.notifier).signInWithToken(
              _tokenController.text.trim(),
            );
      }
      if (mounted) context.go('/home');
    } catch (e) {
      final raw = e.toString();
      final message = raw.contains('Exception:')
          ? raw.replaceFirst('Exception: ', '')
          : 'Authentication failed. Please try again.';
      setState(() {
        _error = message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/instance-setup'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                loc.welcomeBack,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _useCredentials
                    ? loc.signInWithCredentials
                    : loc.signInWithToken,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),

              // Login method toggle
              Center(
                child: SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: true, label: Text(loc.credentials)),
                    ButtonSegment(value: false, label: Text(loc.token)),
                  ],
                  selected: {_useCredentials},
                  onSelectionChanged: (v) => setState(() {
                    _useCredentials = v.first;
                    _error = null;
                  }),
                ),
              ),
              const SizedBox(height: 24),

              Form(
                key: _formKey,
                child: _useCredentials
                    ? _buildCredentialsForm(loc)
                    : _buildTokenForm(loc),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _signIn,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(loc.signIn),
              ),

              if (!_useCredentials) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    loc.tokenHelp,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialsForm(AppLocalizations loc) {
    return Column(
      children: [
        TextFormField(
          controller: _usernameController,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: loc.username,
            prefixIcon: const Icon(Icons.person_outline),
          ),
          validator: (v) =>
              v == null || v.trim().isEmpty ? loc.enterUsername : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          autocorrect: false,
          textInputAction: TextInputAction.go,
          onFieldSubmitted: (_) => _signIn(),
          decoration: InputDecoration(
            labelText: loc.password,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) => v == null || v.isEmpty ? loc.enterPassword : null,
        ),
      ],
    );
  }

  Widget _buildTokenForm(AppLocalizations loc) {
    return TextFormField(
      controller: _tokenController,
      obscureText: _obscureToken,
      autocorrect: false,
      textInputAction: TextInputAction.go,
      onFieldSubmitted: (_) => _signIn(),
      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      decoration: InputDecoration(
        labelText: loc.personalAccessToken,
        hintText: loc.pasteTokenHere,
        prefixIcon: const Icon(Icons.key_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureToken
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () => setState(() => _obscureToken = !_obscureToken),
        ),
      ),
      validator: (v) =>
          v == null || v.trim().isEmpty ? loc.enterAccessToken : null,
    );
  }
}
