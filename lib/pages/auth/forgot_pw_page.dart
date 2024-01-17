import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sos_app/core/ui/helpers/messages.dart';
import 'package:sos_app/core/ui/styles/text_styles.dart';
import 'package:validatorless/validatorless.dart';

class ForgotPwPage extends StatefulWidget {
  const ForgotPwPage({super.key});

  @override
  State<ForgotPwPage> createState() => _ForgotPwPageState();
}

class _ForgotPwPageState extends State<ForgotPwPage> {
  final _formkey = GlobalKey<FormState>();

  TextEditingController emailEC = TextEditingController();

  @override
  void dispose() {
    emailEC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formkey.currentState?.validate() ?? false;
    if (!isValid) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailEC.text.trim());
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Messages.showSuccess(context, "Enviamos um e-mail para redefinir a senha. Verifique sua caixa de entrada.");
    } on FirebaseAuthException catch(e) {
      if(e.code == 'user-not-found') {
        // ignore: use_build_context_synchronously
        Messages.showError(context, 'Não existe uma conta com este e-mail. Por favor, verifique o endereço digitado.');
      } else {
        // ignore: use_build_context_synchronously
        Messages.showError(context, 'Erro ao enviar e-mail de recuperação. Tente novamente');
      }
      log('Erro ao tentar redefinir senha: $e');
      throw Exception('Erro ao tentar redefinir senha: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esqueci minha senha'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Digite seu e-mail e nós enviaremos um link de redefinição de senha.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Form(
              key: _formkey,
              child: TextFormField(
                style: TextStyles.instance.textInput,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                ),
                controller: emailEC,
                validator: Validatorless.multiple([
                  Validatorless.required('E-mail obrigatório'),
                  Validatorless.email('E-mail inválido'),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text(
                  'Redefinir Senha',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
