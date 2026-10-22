import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/user_repository.dart';
import 'features/auth/view_models/login_view_model.dart';
import 'features/auth/views/login_view.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final LoginViewModel _loginViewModel;

  @override
  void initState() {
    super.initState();
    _loginViewModel = LoginViewModel(
      userRepository: context.read<UserRepository>(),
    );
  }

  @override
  void dispose() {
    _loginViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activités',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: LoginView(viewModel: _loginViewModel),
    );
  }
}
