import 'package:flutter/material.dart';
import 'package:sos_app/core/extension/slide_route.dart';
import 'package:sos_app/core/services/auth/auth_service.dart';
import 'package:sos_app/core/ui/helpers/messages.dart';
import 'package:sos_app/core/ui/styles/text_styles.dart';
import 'package:sos_app/pages/auth/register_page/register_page.dart';
import 'package:validatorless/validatorless.dart';

// ignore: must_be_immutable
class AuthForm extends StatefulWidget {
  final void Function(bool) onSubmit;

  const AuthForm({super.key, required this.onSubmit});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formkey = GlobalKey<FormState>();

  final _passwordFocus = FocusNode();

  TextEditingController emailEC = TextEditingController();

  TextEditingController passwordEC = TextEditingController();

  bool _loginError = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailEC.dispose();
    passwordEC.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() async {
    final isValid = _formkey.currentState?.validate() ?? false;
    if (!isValid) return;

    try {
      widget.onSubmit(true);
      final login = await AuthService().login(emailEC.text, passwordEC.text);
      if (!login) {
        setState(() {
          _loginError = true;
        });
        _submit();
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Messages.showError(
          context, 'Ocorreu um problema ao tentar logar. Tente novamente.');
    } finally {
      widget.onSubmit(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: SizedBox(
                  height: 140,
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
              TextFormField(
                style: TextStyles.instance.textInput,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                ),
                controller: emailEC,
                validator: (value) {
                  if (Validatorless.required('E-mail obrigatório')
                          .call(value) !=
                      null) {
                    return 'E-mail obrigatório';
                  } else if (Validatorless.email('E-mail inválido')
                          .call(value) !=
                      null) {
                    return 'E-mail inválido';
                  } else if (_loginError) {
                    return 'E-mail ou senha incorretos.';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {
                  _loginError = false;
                }),
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
              ),
              const SizedBox(height: 12),
              TextFormField(
                style: TextStyles.instance.textInput,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                obscureText: _obscurePassword,
                controller: passwordEC,
                validator: (value) {
                  if (Validatorless.required('Senha obrigatória').call(value) !=
                      null) {
                    return 'Senha obrigatória';
                  } else if (Validatorless.min(8, 'Senha inválida')
                              .call(value) !=
                          null &&
                      Validatorless.max(20, 'Senha inválida').call(value) !=
                          null) {
                    return 'Senha inválida';
                  } else if (_loginError) {
                    return 'E-mail ou senha incorretos.';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {
                  _loginError = false;
                }),
                focusNode: _passwordFocus,
                onFieldSubmitted: (_) =>
                    _submit
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text(
                    'Entrar',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Não tem conta? '),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        SlideRoute(page: const RegisterPage()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, //remove espaçamento interno
                      tapTargetSize: MaterialTapTargetSize
                          .shrinkWrap, //remove espaçamento externo
                    ),
                    child: Text(
                      'Cadastre-se',
                      style: TextStyles.instance.textSemiBold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
