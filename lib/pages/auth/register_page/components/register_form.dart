import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:sos_app/models/auth_form_data.dart';
import 'package:sos_app/pages/auth/register_page/components/user_image_picker.dart';
import 'package:sos_app/pages/auth/register_page/controllers/register_form_controller.dart';
import 'package:validatorless/validatorless.dart';

import '../../../../core/ui/styles/text_styles.dart';
import '../../../maps/controllers/location_controller.dart';

// ignore: must_be_immutable
class RegisterForm extends StatefulWidget {
  final void Function(AuthFormData) onSubmit;

  const RegisterForm({super.key, required this.onSubmit});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formkey = GlobalKey<FormState>();
  final locationEC = LocationController();
  final _formEC = RegisterFormController();

  final _cpfFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  TextEditingController cepEC = TextEditingController();
  TextEditingController ufEC = TextEditingController();
  TextEditingController cityEC = TextEditingController();
  TextEditingController passwordEC = TextEditingController();

  final _formData = AuthFormData();
  bool _termsChecked = false;
  bool _termsNotChecked = false;

  @override
  void initState() {
    super.initState();

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
    ufEC.dispose();
    cityEC.dispose();
    passwordEC.dispose();
    _cpfFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _handleImagePick(File image) {
    _formData.image = image;
  }

  void _submit() {
    final isValid = _formkey.currentState?.validate() ?? false;
    if (!isValid) return;
    if (!_termsChecked) {
      setState(() => _termsNotChecked = true);
      return;
    }

    try {
      _formData.cep = _formEC.cepEC.text;
      _formData.uf = ufEC.text;
      _formData.city = cityEC.text;

      widget.onSubmit(_formData);
    } catch (e) {
      throw Exception(e);
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserImagePicker(
                onImagePick: _handleImagePick,
                isEditable: true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                style: TextStyles.instance.textInput,
                decoration: const InputDecoration(labelText: 'Nome completo'),
                validator: Validatorless.multiple([
                  Validatorless.required('Nome completo obrigatório'),
                  Validatorless.min(5, 'Insira o nome completo'),
                  Validatorless.max(100, 'No máximo 100 caracteres'),
                  (value) {
                    if (value!.contains(' ')) {
                      return null; // O nome contém um espaço em branco, é válido
                    } else {
                      return 'Insira o nome completo'; // Não contém espaço em branco, é inválido
                    }
                  },
                ]),
                onChanged: (name) => _formData.name = name,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_cpfFocus),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _formEC.cpfEC,
                keyboardType: TextInputType.number,
                style: TextStyles.instance.textInput,
                decoration: const InputDecoration(
                    labelText: 'CPF', hintText: '000.000.000-00'),
                validator: Validatorless.multiple([
                  Validatorless.required('CPF obrigatório'),
                  Validatorless.cpf('CPF inválido'),
                ]),
                onChanged: (_) => _formData.cpf = _formEC.cpfEC.text,
                focusNode: _cpfFocus,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_phoneFocus),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _formEC.phoneEC,
                keyboardType: TextInputType.number,
                style: TextStyles.instance.textInput,
                decoration: const InputDecoration(
                    labelText: 'Celular', hintText: '(00)00000-0000'),
                validator: Validatorless.multiple([
                  Validatorless.required('Celular obrigatório'),
                  Validatorless.min(11, 'Celular no mínimo 11 caracteres')
                ]),
                onChanged: (_) => _formData.phone = '55'.toString() +
                    _formEC.phoneEC.text.replaceAll(RegExp(r'\D'), ''),
                focusNode: _phoneFocus,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_emailFocus),
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
                          ? const Text('Localização não informada!')
                          : //const Text('Imagem do Mapa!')
                          Image.network(
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
                    onPressed: () {
                      locationEC.getPosition();
                    },
                    icon: Visibility(
                        visible: !locationEC.isLoading,
                        child: const Icon(
                          Icons.location_on,
                        )),
                    label: locationEC.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
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
              const SizedBox(height: 8),
              Text(
                '* Sua localização é utilizada apenas para informá-lo do que ocorre em sua região.',
                style: TextStyle(
                    fontSize: 12, color: ColorsApp.instance.previewText),
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: false,
                controller: _formEC.cepEC,
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
                      controller: ufEC,
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
                      controller: cityEC,
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
              const SizedBox(height: 12),
              TextFormField(
                style: TextStyles.instance.textInput,
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: Validatorless.multiple([
                  Validatorless.required('E-mail obrigatório'),
                  Validatorless.email('E-mail inválido'),
                  Validatorless.max(100, 'No máximo 100 caracteres'),
                ]),
                onChanged: (email) => _formData.email = email,
                focusNode: _emailFocus,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
              ),
              const SizedBox(height: 12),
              TextFormField(
                style: TextStyles.instance.textInput,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                controller: passwordEC,
                validator: Validatorless.multiple([
                  Validatorless.required('Senha obrigatória'),
                  Validatorless.min(8, 'Senha no mínimo 8 caracteres'),
                  Validatorless.max(20, 'Senha no máximo 20 caracteres'),
                ]),
                onChanged: (_) => _formData.password = passwordEC.text,
                focusNode: _passwordFocus,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_confirmPasswordFocus),
              ),
              const SizedBox(height: 12),
              TextFormField(
                style: TextStyles.instance.textInput,
                decoration: const InputDecoration(labelText: 'Confirmar senha'),
                obscureText: true,
                validator: Validatorless.multiple([
                  Validatorless.compare(passwordEC, 'Senha inválida'),
                  Validatorless.required('Confirme a senha'),
                ]),
                focusNode: _confirmPasswordFocus,
              ),
              Row(
                children: [
                  Checkbox(
                    activeColor: ColorsApp.instance.primary,
                    value: _termsChecked,
                    onChanged: (value) {
                      setState(() {
                        _termsChecked = value ?? false;
                      });
                    },
                  ),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        const TextSpan(
                          text: 'Li e concordo com os ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Termos de Uso.',
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorsApp.instance.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_termsNotChecked)
                Text("* É obrigatório aceitar os Termos de Uso.", style: TextStyle(color: ColorsApp.instance.primary, fontSize: 12),),
              const SizedBox(height: 15),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text(
                    'Cadastrar',
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
