import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/auth/auth_service.dart';
import 'package:sos_app/core/services/user/user_store.dart';
import 'package:sos_app/core/ui/helpers/messages.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:sos_app/models/auth_form_data.dart';
import 'package:sos_app/pages/auth/register_page/components/user_image_picker.dart';
import 'package:sos_app/pages/auth/register_page/controllers/register_form_controller.dart';
import 'package:sos_app/pages/maps/controllers/location_controller.dart';
import 'package:validatorless/validatorless.dart';

import '../../../../../../core/ui/styles/text_styles.dart';

// ignore: must_be_immutable
class EditForm extends StatefulWidget {
  final bool isEditable;
  final void Function(AuthFormData, String) onSubmit;
  final ImageProvider userImage;

  const EditForm({
    super.key,
    required this.onSubmit,
    required this.isEditable,
    required this.userImage,
  });

  @override
  State<EditForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<EditForm> {
  final _formkey = GlobalKey<FormState>();
  final _formPassword = GlobalKey<FormState>();
  final locationEC = LocationController();
  final _formEC = RegisterFormController();
  late UserStore sessionUser;

  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  late String currentPassword;
  bool isPasswordRight = true;

  TextEditingController cepEC = TextEditingController();
  TextEditingController ufEC = TextEditingController();
  TextEditingController cityEC = TextEditingController();
  TextEditingController? phoneEC;

  final _formData = AuthFormData();

  @override
  void initState() {
    super.initState();
    sessionUser = Provider.of<UserStore>(context, listen: false);

    autorun((_) {
      _formEC.cepEC.text = locationEC.cep;      
      ufEC.text = locationEC.uf;
      cityEC.text = locationEC.city;
      _formData.lat = locationEC.lat;
      _formData.long = locationEC.long;
    });
  }

  @override
  void dispose() {
    _formEC.cepEC.dispose();
    cepEC.dispose();
    ufEC.dispose();
    cityEC.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    phoneEC!.dispose();
    super.dispose();
  }

  void _handleImagePick(File image) {
    _formData.image = image;
  }

  void _submit() {
    final isValid = _formkey.currentState?.validate() ?? false;
    if (!isValid) return;
    _showPasswordConfirmation();
  }

  void _saveDatas() {
    try {
      _formData.cep = _formEC.cepEC.text;
      _formData.uf = ufEC.text;
      _formData.city = cityEC.text;

      _formData.password = currentPassword;

      if (_formData.phone.isEmpty) {
        _formData.phone = sessionUser.currentUser!.phone;
      }

      if (_formData.name.isEmpty) {
        _formData.name = sessionUser.currentUser!.name;
      }

      widget.onSubmit(_formData, sessionUser.currentUser!.id);
    } catch (e) {
      throw Exception(e);
    }
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                        _saveDatas();
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    phoneEC = MaskedTextController(
        mask: '(00)00000-0000',
        text: sessionUser.currentUser!.phone.substring(2));

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              UserImagePicker(
                onImagePick: _handleImagePick,
                userImage: widget.userImage,
                isEditable: widget.isEditable,
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: !widget.isEditable,
                initialValue: sessionUser.currentUser!.name,
                style: TextStyles.instance.textInput,
                decoration: InputDecoration(
                  labelText: 'Nome completo',
                  fillColor:
                      !widget.isEditable ? ColorsApp.instance.background : null,
                ),
                validator: Validatorless.multiple([
                  Validatorless.required('Nome completo obrigatório'),
                  Validatorless.min(5, 'Insira o nome completo'),
                  Validatorless.max(100, 'No máximo 100 caracteres'),
                ]),
                onChanged: (name) => _formData.name = name,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_emailFocus),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: sessionUser.currentUser!.cpf,
                readOnly: true,
                style: TextStyles.instance.textInput,
                decoration: InputDecoration(
                    labelText: 'CPF', fillColor: ColorsApp.instance.background),
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: !widget.isEditable,
                initialValue: sessionUser.currentUser!.email,
                style: TextStyles.instance.textInput,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  fillColor:
                      !widget.isEditable ? ColorsApp.instance.background : null,
                ),
                validator: Validatorless.multiple([
                  Validatorless.required('E-mail obrigatório'),
                  Validatorless.email('E-mail inválido'),
                  Validatorless.max(100, 'No máximo 100 caracteres'),
                ]),
                onChanged: (email) => _formData.email = email,
                focusNode: _emailFocus,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_phoneFocus),
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: !widget.isEditable,
                controller: phoneEC,
                keyboardType: TextInputType.number,
                style: TextStyles.instance.textInput,
                decoration: InputDecoration(
                  labelText: 'Celular',
                  hintText: '(00)00000-0000',
                  fillColor:
                      !widget.isEditable ? ColorsApp.instance.background : null,
                ),
                validator: Validatorless.multiple([
                  Validatorless.required('Celular obrigatório'),
                  Validatorless.min(11, 'Celular no mínimo 11 caracteres')
                ]),
                onChanged: (_) => _formData.phone = '55'.toString() +
                    phoneEC!.text.replaceAll(RegExp(r'\D'), ''),
                focusNode: _phoneFocus,
              ),
              const SizedBox(height: 12),
              Observer(
                builder: (_) => Container(
                    height: 140,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorsApp.instance.background,
                      border: Border.all(
                        color: ColorsApp.instance.previewText,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: locationEC.staticMapImageUrl.isEmpty
                          ? const Text('Selecione uma nova localização')
                          : Image.network(
                              locationEC.staticMapImageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                    )),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: Observer(
                  builder: (_) => ElevatedButton.icon(
                    onPressed: widget.isEditable
                        ? () {
                            locationEC.getPosition();
                          }
                        : null,
                    icon: Visibility(
                        visible: !locationEC.isLoading,
                        child: const Icon(
                          Icons.location_on,
                        )),
                    label: locationEC.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                          )
                        : Text('Selecionar Localização',
                            style: TextStyles.instance.textRegular
                                .copyWith(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: ColorsApp.instance.primary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                              color: ColorsApp.instance.primary, width: 1),
                        )),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: false,
                initialValue:
                    widget.isEditable ? null : sessionUser.currentUser!.cep,
                controller: widget.isEditable ? _formEC.cepEC : null,
                style: TextStyles.instance.textInput,
                decoration: InputDecoration(
                  labelText: 'CEP',
                  fillColor: ColorsApp.instance.background,
                ),
                validator:
                    Validatorless.required('Compartilhe a sua localização'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: TextFormField(
                      readOnly: true,
                      initialValue: widget.isEditable
                          ? null
                          : sessionUser.currentUser!.uf,
                      controller: widget.isEditable ? ufEC : null,
                      style: TextStyles.instance.textInput,
                      decoration: InputDecoration(
                        labelText: 'UF',
                        fillColor: ColorsApp.instance.background,
                      ),
                      validator: Validatorless.required('??'),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Flexible(
                    flex: 4,
                    child: TextFormField(
                      readOnly: true,
                      initialValue: widget.isEditable
                          ? null
                          : sessionUser.currentUser!.city,
                      controller: widget.isEditable ? cityEC : null,
                      style: TextStyles.instance.textInput,
                      decoration: InputDecoration(
                        labelText: 'Cidade',
                        fillColor: ColorsApp.instance.background,
                      ),
                      validator: Validatorless.required(
                          'Compartilhe a sua localização'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.isEditable ? _submit : null,
                  child: const Text(
                    'Salvar',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
