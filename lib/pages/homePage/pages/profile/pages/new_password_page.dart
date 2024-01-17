import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/auth/auth_service.dart';
import 'package:sos_app/core/services/user/user_store.dart';
import 'package:sos_app/core/ui/helpers/messages.dart';
import 'package:sos_app/core/ui/styles/text_styles.dart';
import 'package:validatorless/validatorless.dart';

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final _formkey = GlobalKey<FormState>();

  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  String? currentPassword;
  late String newPassword;
  bool isPasswordRight = true;
  bool _isLoading = false;
  late UserStore sessionUser;

  TextEditingController currentPasswordEC = TextEditingController();
  TextEditingController passwordEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    sessionUser = Provider.of<UserStore>(context, listen: false);
  }

  @override
  void dispose() {
    currentPasswordEC.dispose();
    passwordEC.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() {
      isPasswordRight = true;
    });
    // Valida o formulário
    final isValid = _formkey.currentState?.validate() ?? false;
    if (!isValid) return;
    // Checa se a senha é válida
    final resultCheck = await AuthService().checkPassword(currentPassword!);
    if (resultCheck == 'check') {
      // Se for verdadeira, atualiza a nova senha
      setState(() {
        isPasswordRight = true;
      });
      _updateData();
    } else if (resultCheck == 'wrong') {
      // Se for falsa, imprime erro
      setState(() {
        isPasswordRight = false;
      });
      _formkey.currentState?.validate();
      return;
    } else {
      // Se ocorrer outro erro, exibe mensagem de erro.
      // ignore: use_build_context_synchronously
      Messages.showError(context, 'Erro ao checar senha');
      return;
    }
  }

  void _updateData() async {
    try {
      setState(() => _isLoading = true);

      await AuthService().updatePassword(
          sessionUser.currentUser!.id, currentPassword!, newPassword);

      // ignore: use_build_context_synchronously
      await sessionUser.fetchUserData(sessionUser.currentUser!.id, context);

      // ignore: use_build_context_synchronously
      Messages.showSuccess(context, 'Senha atualizada com sucesso!');

      // ignore: use_build_context_synchronously
    } catch (e) {
      // ignore: use_build_context_synchronously
      Messages.showError(context, 'Erro ao atualizar Senha. Tente novamente.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text('Alterar senha'),
          ),
          body: Container(
            color: Colors.white,
            margin: const EdgeInsets.all(5),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            style: TextStyles.instance.textInput,
                            decoration:
                                const InputDecoration(labelText: 'Senha atual'),
                            obscureText: true,
                            validator: (value) {
                              if (!isPasswordRight) {
                                return 'Senha incorreta';
                              }
                              return Validatorless.multiple([
                                Validatorless.required('Senha obrigatória'),
                                Validatorless.min(
                                    8, 'Senha no mínimo 8 caracteres'),
                                Validatorless.max(
                                    20, 'Senha no máximo 20 caracteres'),
                              ])(value);
                            },
                            onChanged: (value) => currentPassword = value,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_passwordFocus),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            style: TextStyles.instance.textInput,
                            decoration:
                                const InputDecoration(labelText: 'Nova Senha'),
                            obscureText: true,
                            controller: passwordEC,
                            validator: Validatorless.multiple([
                              Validatorless.required('Senha obrigatória'),
                              Validatorless.min(
                                  8, 'Senha no mínimo 8 caracteres'),
                              Validatorless.max(
                                  20, 'Senha no máximo 20 caracteres'),
                            ]),
                            onChanged: (_) => newPassword = passwordEC.text,
                            focusNode: _passwordFocus,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_confirmPasswordFocus),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            style: TextStyles.instance.textInput,
                            decoration: const InputDecoration(
                                labelText: 'Confirmar nova senha'),
                            obscureText: true,
                            validator: Validatorless.multiple([
                              Validatorless.compare(
                                  passwordEC, 'Senha inválida'),
                              Validatorless.required('Confirme a senha'),
                            ]),
                            focusNode: _confirmPasswordFocus,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: const Text(
                          'Salvar',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
