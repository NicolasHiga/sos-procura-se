import 'package:flutter/material.dart';
import 'package:sos_app/core/config/routes.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/pages/auth/login_page/components/auth_form.dart';

import '../../../core/ui/styles/text_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  Future<void> _handleSubmit(bool isLoading) async {
    setState(() => _isLoading = isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: AuthForm(onSubmit: _handleSubmit),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 15.0,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(Routes.navigatorKey!.currentContext!)
                        .pushNamed('/auth/forgotPassword');
                  },
                  child: Text(
                    'Esqueceu sua senha?',
                    style: TextStyles.instance.textExtraBold.copyWith(
                        color: ColorsApp.instance.secondary, fontSize: 16),
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color.fromRGBO(0, 0, 0, 0.5),
                  child: const Center(child: CircularProgressIndicator.adaptive()),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
