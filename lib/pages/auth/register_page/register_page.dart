import 'package:flutter/material.dart';
import 'package:sos_app/core/services/auth/auth_service.dart';
import 'package:sos_app/core/ui/helpers/messages.dart';
import 'package:sos_app/models/auth_form_data.dart';
import 'package:sos_app/pages/auth/register_page/components/register_form.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;

  void _closePage() {
    Navigator.pop(context);
  }

  Future<void> _handleSubmit(AuthFormData formData) async {
    try {
      setState(() => _isLoading = true);

      await AuthService().signup(
          formData.name,
          formData.lat,
          formData.long,
          formData.cpf,
          formData.cep,
          formData.uf,
          formData.city,
          formData.phone,
          formData.email,
          formData.password,
          formData.image,
          context);

      // ignore: use_build_context_synchronously
      _closePage();
    } catch (e) {
      // ignore: use_build_context_synchronously
      Messages.showError(context, 'Erro ao criar conta. Tente novamente.');
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
            title: const Text(
              'Cadastro',
            ),            
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: RegisterForm(onSubmit: _handleSubmit),
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
    );
  }
}
