import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/auth/auth_service.dart';
import 'package:sos_app/core/services/user/user_store.dart';
import 'package:sos_app/core/ui/helpers/messages.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/core/ui/styles/text_styles.dart';
import 'package:sos_app/models/auth_form_data.dart';
import 'package:sos_app/pages/homePage/pages/profile/components/edit_form.dart';
import 'package:validatorless/validatorless.dart';

class EditPage extends StatefulWidget {
  final ImageProvider userImage;

  const EditPage({super.key, required this.userImage});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formPassword = GlobalKey<FormState>();

  bool edit = false;
  bool _isLoading = false;
  bool isPasswordRight = true;
  late String currentPassword;
  late UserStore sessionUser;

  @override
  void initState() {
    super.initState();
    sessionUser = Provider.of<UserStore>(context, listen: false);
  }

  void _handleSubmit(AuthFormData formdata, String userId) async {
    try {
      setState(() => _isLoading = true);

      await AuthService().update(
        userId,
        formdata.name,
        formdata.email,
        formdata.password,
        formdata.lat,
        formdata.long,
        formdata.cep,
        formdata.uf,
        formdata.city,
        formdata.phone,
        formdata.image,
      );

      // ignore: use_build_context_synchronously
      await sessionUser.fetchUserData(userId, context);

      // ignore: use_build_context_synchronously
      Messages.showSuccess(context, 'Dados atualizados com sucesso!');
      setState(() => edit = false);

      // ignore: use_build_context_synchronously
    } catch (e) {
      // ignore: use_build_context_synchronously
      Messages.showError(context, 'Erro ao atualizar dados. Tente novamente.');
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
            title: const Text('Dados pessoais'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home/profile');
              },
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    edit = !edit;
                  });
                },
                icon: Icon(
                  Icons.edit,
                  color: edit ? null : ColorsApp.instance.primary,
                ),
              ),
              IconButton(
                onPressed: () {
                  showDeleteDialog(sessionUser.currentUser!.id);
                },
                icon: Icon(
                  Icons.delete,
                  color: ColorsApp.instance.primary,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: EditForm(
              isEditable: edit,
              onSubmit: _handleSubmit,
              userImage: widget.userImage,
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

  void showDeleteDialog(String userId) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Deletar conta?'),
        content: const Text(
            'Tem certeza que deseja deletar a sua conta? Todos os dados serão apagados.'),
        actions: [
          TextButton(
            child: Text(
              'Cancelar',
              style: TextStyle(color: ColorsApp.instance.primary),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(
              'Deletar',
              style: TextStyle(color: ColorsApp.instance.primary),
            ),
            onPressed: () {
              Navigator.pop(context); // fecha o dialog
              _showPasswordConfirmation();
            },
          ),
        ],
      ),
    );
  }

  void _showPasswordConfirmation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0), // Raio de curvatura superior esquerdo
          topRight: Radius.circular(20.0), // Raio de curvatura superior direito
        ),
      ),
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 210,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  "Confirme sua senha:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formPassword,
                  child: TextFormField(
                    style: TextStyles.instance.textInput,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                    ),
                    validator: (value) {
                      if (!isPasswordRight) {
                        return 'Senha incorreta';
                      }
                      return Validatorless.multiple([
                        Validatorless.required('Senha obrigatória'),
                        Validatorless.min(8, 'Senha no mínimo 8 caracteres'),
                        Validatorless.max(20, 'Senha no máximo 20 caracteres'),
                      ])(value);
                    },
                    onChanged: (value) => currentPassword = value,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isPasswordRight = true;
                      });
                      var isValid =
                          _formPassword.currentState?.validate() ?? false;
                      if (!isValid) return;

                      final resultCheck =
                          await AuthService().checkPassword(currentPassword);
                      if (resultCheck == 'check') {
                        setState(() {
                          isPasswordRight = true;
                        });
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        _deleteAccount();
                      } else if (resultCheck == 'wrong') {
                        setState(() {
                          isPasswordRight = false;
                        });
                        _formPassword.currentState?.validate();
                      } else {
                        // ignore: use_build_context_synchronously
                        Messages.showError(context, 'Erro ao checar senha');
                      }
                    },
                    child: const Text(
                      'Confirmar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteAccount() async {
    try {
      await AuthService().deleteAccount(sessionUser.currentUser!.id);
      // ignore: use_build_context_synchronously
      Messages.showSuccess(context, 'Conta deletada com sucesso!');
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // fecha a página de edição
    } catch (e) {
      // ignore: use_build_context_synchronously
      Messages.showError(context, 'Erro ao deletar conta. Tente novamente.');
    }
  }
}
