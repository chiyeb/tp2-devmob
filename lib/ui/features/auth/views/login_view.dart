import 'package:flutter/material.dart';

import '../../../core/themes/dimens.dart';
import '../../home/views/home_view.dart';
import '../view_models/login_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final success = await widget.viewModel.login(
      _loginController.text.trim(),
      _passwordController.text,
    );
    if (!success || !mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HomeView(userId: widget.viewModel.user!.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Activités')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimens.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Dimens.contentMaxWidth,
              ),
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(Dimens.lg),
                        ),
                        child: Icon(
                          Icons.hiking_rounded,
                          size: 36,
                          color: scheme.onPrimaryContainer,
                          semanticLabel: 'Activités',
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimens.lg),
                    Text(
                      'Bon retour !',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: Dimens.sm),
                    Text(
                      'Connectez-vous pour réserver vos activités.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Dimens.xl),
                    TextField(
                      controller: _loginController,
                      autofillHints: const [AutofillHints.username],
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: (_) => widget.viewModel.clearError(),
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Login',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: Dimens.md),
                    TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => widget.viewModel.clearError(),
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Afficher le mot de passe'
                              : 'Masquer le mot de passe',
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    ListenableBuilder(
                      listenable: widget.viewModel,
                      builder: (context, _) {
                        final error = widget.viewModel.error;
                        final isLoading = widget.viewModel.isLoading;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              alignment: Alignment.topCenter,
                              child: error == null
                                  ? const SizedBox(width: double.infinity)
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                        top: Dimens.md,
                                      ),
                                      child: _ErrorBanner(
                                        message: _messageFor(error),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: Dimens.lg),
                            FilledButton(
                              onPressed: isLoading ? null : _submit,
                              child: isLoading
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        semanticsLabel: 'Connexion en cours',
                                        color: scheme.onSurface.withValues(
                                          alpha: 0.38,
                                        ),
                                      ),
                                    )
                                  : const Text('Se connecter'),
                            ),
                          ],
                        );
                      },
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

  static String _messageFor(LoginError error) => switch (error) {
    LoginError.missingFields => 'Renseignez votre login et votre mot de passe.',
    LoginError.invalidCredentials => 'Login ou mot de passe incorrect.',
    LoginError.unavailable =>
      'Connexion impossible. Vérifiez votre réseau et réessayez.',
  };
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(Dimens.md),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(Dimens.radiusField),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
            const SizedBox(width: Dimens.sm + Dimens.xs),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
