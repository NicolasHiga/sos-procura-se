import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/extension/slide_route.dart';
import 'package:sos_app/core/services/post/post_service.dart';
import 'package:sos_app/core/services/user/user_store.dart';
import 'package:sos_app/core/ui/helpers/messages.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/core/ui/styles/text_styles.dart';
import 'package:sos_app/models/post_form_data.dart';
import 'package:sos_app/pages/auth/register_page/controllers/register_form_controller.dart';
import 'package:sos_app/pages/homePage/components/show_dialogs.dart';
import 'package:sos_app/pages/maps/google_map_select.dart';
import 'package:sos_app/pages/homePage/components/multi_image_picker.dart';
import 'package:sos_app/pages/maps/utils/location_util.dart';
import 'package:validatorless/validatorless.dart';

class MissingPost extends StatefulWidget {
  const MissingPost({super.key});

  @override
  State<MissingPost> createState() => _MissingPostState();
}

class _MissingPostState extends State<MissingPost> {
  late UserStore sessionUser;
  final _formkey = GlobalKey<FormState>();
  final _formEC = RegisterFormController();
  final TextEditingController _controller = TextEditingController();
  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  final _formData = PostFormData();

  bool _hasImages = false;
  bool _isFormSubmitted = false;
  bool _isLoading = false;
  int _formType = 1;

  // ignore: prefer_final_fields
  TextEditingController _dateController = TextEditingController();

  void _handleImagesPick(List<File> images) {
    setState(() {
      _hasImages = images.isNotEmpty;
    });
    _formData.images = images;
  }

  void _selectOnMap(LatLng position) async {
    final LatLng selectedPosition = position;
    // ignore: unnecessary_null_comparison
    if (selectedPosition == null) return;

    // Busca o endereço com base na LatLong
    Map<String, String> addressData =
        await LocationUtil.getAddressFromCoordinates(
            selectedPosition.latitude, selectedPosition.longitude);

    _formData.city = addressData['city']!;
    _formData.uf = addressData['uf']!;
    setState(() {
      _formData.latitude = selectedPosition.latitude;
      _formData.longitude = selectedPosition.longitude;
      _formData.address = addressData['address']!;
    });
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        final formattedDate =
            DateFormat.yMd('pt_BR').format(picked); // Formata a data
        _dateController.text = formattedDate;
        log(_dateController.text);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    sessionUser = Provider.of<UserStore>(context, listen: false);
    _formData.postType = 1; // MissingPost
    _formData.type = 1; // Inicia como Pessoa
    _controller.text = '0,00'; // Valor inicial
    _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length));
  }

  @override
  void dispose() {
    _controller.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _submit() async {
    // Valida se todos os campos obrigatórios foram preenchidos
    final isValid = _formkey.currentState?.validate() ?? false;

    setState(() {
      _isFormSubmitted = true;
    });
    // Valida se tem imagens e se todo o restante está correto
    if (!isValid || (!_hasImages && _isFormSubmitted)) return;

    try {
      setState(() => _isLoading = true);
      _formData.date = _dateController.text;
      _formData.userId = sessionUser.currentUser!.id;
      _formData.datePost = DateTime.now();

      await PostService().post(_formData);

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      if (_formData.type == 1) {
        // ignore: use_build_context_synchronously
        ShowDialogs.showAlertPost(context, true);
      } else {
        // ignore: use_build_context_synchronously
        ShowDialogs.showAlertPost(context, false);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Messages.showError(
          context, 'Erro ao salvar publicação. Tente novamente.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Desaparecido'),
            titleSpacing: 0,
          ),
          body: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0)
                  .copyWith(top: 15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: _formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("TIPO"),
                          const SizedBox(height: 12),
                          DropdownButtonFormField(
                            value: 1,
                            items: [
                              DropdownMenuItem(
                                value: 1,
                                child: Row(
                                  children: [
                                    Icon(Icons.person,
                                        color: ColorsApp.instance.primary),
                                    const SizedBox(
                                        width:
                                            8), // Espaço entre o ícone e o texto
                                    const Text('Pessoa'), // Texto do item
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 2,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.pets,
                                      color: ColorsApp.instance.primary,
                                    ),
                                    const SizedBox(
                                        width:
                                            8), // Espaço entre o ícone e o texto
                                    const Text('Animal'), // Texto do item
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _formType = value!;
                              });
                              _formData.type = value!;
                            },
                          ),
                          const SizedBox(height: 20),
                          Text(_formType == 1 ? "DADOS PESSOAIS" : "DADOS"),
                          const SizedBox(height: 12),
                          TextFormField(
                            style: TextStyles.instance.textInput,
                            decoration: InputDecoration(
                                labelText: _formType == 1
                                    ? '*Nome completo'
                                    : '*Nome'),
                            validator: Validatorless.multiple([
                              Validatorless.required('Nome obrigatório'),
                              Validatorless.min(3, 'Insira o nome completo'),
                              Validatorless.max(
                                  100, 'No máximo 100 caracteres'),
                              (value) {
                                if (_formType == 1) {
                                  if (value!.contains(' ')) {
                                    return null; // O nome contém um espaço em branco, é válido
                                  } else {
                                    return 'Insira o nome completo'; // Não contém espaço em branco, é inválido
                                  }
                                }
                                return null;
                              },
                            ]),
                            onChanged: (name) =>
                                _formData.name = name.toUpperCase(),
                          ),
                          const SizedBox(height: 12),
                          _formType == 1
                              ? Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: TextFormField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(
                                              3), //Limite de 3 dígitos
                                        ],
                                        style: TextStyles.instance.textInput,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            labelText: '*Idade'),
                                        validator: Validatorless.multiple([
                                          Validatorless.required(
                                              'Idade obrigatória'),
                                        ]),
                                        onChanged: (age) => _formData.age = age,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: TextFormField(
                                        controller: _formEC.heightEC,
                                        style: TextStyles.instance.textInput,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            labelText: 'Altura',
                                            suffixText: 'm'),
                                        onChanged: (height) =>
                                            _formData.height = '$height m',
                                      ),
                                    ),
                                  ],
                                )
                              : DropdownButtonFormField(
                                  value: '',
                                  items: [
                                    DropdownMenuItem(
                                        value: '',
                                        child: Text('*Sexo',
                                            style: TextStyle(
                                                color: ColorsApp
                                                    .instance.previewText))),
                                    const DropdownMenuItem(
                                        value: 'Macho', child: Text('Macho')),
                                    const DropdownMenuItem(
                                        value: 'Fêmea', child: Text('Fêmea')),
                                  ],
                                  validator: (value) {
                                    if (value == '') {
                                      return 'Selecione um sexo válido'; // Mensagem de erro personalizada
                                    }
                                    return null; // A seleção é válida
                                  },
                                  onChanged: (gender) {
                                    _formData.gender = gender!;
                                  },
                                ),
                          const SizedBox(height: 12),
                          _formType == 1
                              ? DropdownButtonFormField(
                                  value: '',
                                  items: [
                                    DropdownMenuItem(
                                        value: '',
                                        child: Text('*Gênero',
                                            style: TextStyle(
                                                color: ColorsApp
                                                    .instance.previewText))),
                                    const DropdownMenuItem(
                                        value: 'Masculino',
                                        child: Text('Masculino')),
                                    const DropdownMenuItem(
                                        value: 'Feminino',
                                        child: Text('Feminino')),
                                    const DropdownMenuItem(
                                        value: 'Outro', child: Text('Outro')),
                                  ],
                                  validator: (value) {
                                    if (value == '') {
                                      return 'Selecione um gênero válido'; // Mensagem de erro personalizada
                                    }
                                    return null; // A seleção é válida
                                  },
                                  onChanged: (gender) {
                                    _formData.gender = gender!;
                                  },
                                )
                              : DropdownButtonFormField(
                                  value: '',
                                  items: [
                                    DropdownMenuItem(
                                        value: '',
                                        child: Text('*Idade',
                                            style: TextStyle(
                                                color: ColorsApp
                                                    .instance.previewText))),
                                    const DropdownMenuItem(
                                        value: 'Filhote',
                                        child: Text('Filhote')),
                                    const DropdownMenuItem(
                                        value: 'Adulto', child: Text('Adulto')),
                                    const DropdownMenuItem(
                                        value: 'Idoso', child: Text('Idoso')),
                                  ],
                                  validator: (value) {
                                    if (value == '') {
                                      return 'Selecione uma idade válida'; // Mensagem de erro personalizada
                                    }
                                    return null; // A seleção é válida
                                  },
                                  onChanged: (age) {
                                    _formData.age = age!;
                                  },
                                ),
                          const SizedBox(height: 12),
                          _formType == 1
                              ? DropdownButtonFormField(
                                  value: '',
                                  items: [
                                    DropdownMenuItem(
                                        value: '',
                                        child: Text('*Etnia',
                                            style: TextStyle(
                                                color: ColorsApp
                                                    .instance.previewText))),
                                    const DropdownMenuItem(
                                        value: 'Branco', child: Text('Branco')),
                                    const DropdownMenuItem(
                                        value: 'Preto', child: Text('Preto')),
                                    const DropdownMenuItem(
                                        value: 'Pardo', child: Text('Pardo')),
                                    const DropdownMenuItem(
                                        value: 'Amarelo',
                                        child: Text('Amarelo')),
                                    const DropdownMenuItem(
                                        value: 'Indígena',
                                        child: Text('Indígena')),
                                  ],
                                  validator: (value) {
                                    if (value == '') {
                                      return 'Selecione uma etnia válida'; // Mensagem de erro personalizada
                                    }
                                    return null; // A seleção é válida
                                  },
                                  onChanged: (colorOrspecie) {
                                    _formData.colorOrspecie = colorOrspecie!;
                                  },
                                )
                              : DropdownButtonFormField(
                                  value: '',
                                  items: [
                                    DropdownMenuItem(
                                        value: '',
                                        child: Text('*Espécie',
                                            style: TextStyle(
                                                color: ColorsApp
                                                    .instance.previewText))),
                                    const DropdownMenuItem(
                                        value: 'Cachorro',
                                        child: Text('Cachorro')),
                                    const DropdownMenuItem(
                                        value: 'Gato', child: Text('Gato')),
                                    const DropdownMenuItem(
                                        value: 'Pássaro',
                                        child: Text('Pássaro')),
                                    const DropdownMenuItem(
                                        value: 'Outro', child: Text('Outro')),
                                  ],
                                  validator: (value) {
                                    if (value == '') {
                                      return 'Selecione uma espécie válida'; // Mensagem de erro personalizada
                                    }
                                    return null; // A seleção é válida
                                  },
                                  onChanged: (colorOrspecie) {
                                    _formData.colorOrspecie = colorOrspecie!;
                                  },
                                ),
                          if (_formType == 1) const SizedBox(height: 12),
                          if (_formType == 1)
                            DropdownButtonFormField(
                              value: '',
                              items: [
                                DropdownMenuItem(
                                    value: '',
                                    child: Text('Cor do cabelo',
                                        style: TextStyle(
                                            color: ColorsApp
                                                .instance.previewText))),
                                const DropdownMenuItem(
                                    value: 'Preto', child: Text('Preto')),
                                const DropdownMenuItem(
                                    value: 'Castanho', child: Text('Castanho')),
                                const DropdownMenuItem(
                                    value: 'Loiro', child: Text('Loiro')),
                                const DropdownMenuItem(
                                    value: 'Ruivo', child: Text('Ruivo')),
                                const DropdownMenuItem(
                                    value: 'Outro', child: Text('Outro')),
                              ],
                              onChanged: (hairColor) {
                                _formData.hairColor = hairColor!;
                              },
                            ),
                          if (_formType == 1) const SizedBox(height: 12),
                          if (_formType == 1)
                            DropdownButtonFormField(
                              value: '',
                              items: [
                                DropdownMenuItem(
                                    value: '',
                                    child: Text('Cor dos Olhos',
                                        style: TextStyle(
                                            color: ColorsApp
                                                .instance.previewText))),
                                const DropdownMenuItem(
                                    value: 'Castanho', child: Text('Castanho')),
                                const DropdownMenuItem(
                                    value: 'Azul', child: Text('Azul')),
                                const DropdownMenuItem(
                                    value: 'Verde', child: Text('Verde')),
                                const DropdownMenuItem(
                                    value: 'Cinza', child: Text('Cinza')),
                                const DropdownMenuItem(
                                    value: 'Avelã', child: Text('Avelã')),
                                const DropdownMenuItem(
                                    value: 'Outro', child: Text('Outro')),
                              ],
                              onChanged: (eye) {
                                _formData.eyeColor = eye!;
                              },
                            ),
                          if (_formType == 1) const SizedBox(height: 12),
                          if (_formType == 1)
                            DropdownButtonFormField(
                              value: '',
                              items: [
                                DropdownMenuItem(
                                    value: '',
                                    child: Text('Tipo de Cabelo',
                                        style: TextStyle(
                                            color: ColorsApp
                                                .instance.previewText))),
                                const DropdownMenuItem(
                                    value: 'Liso', child: Text('Liso')),
                                const DropdownMenuItem(
                                    value: 'Ondulado', child: Text('Ondulado')),
                                const DropdownMenuItem(
                                    value: 'Cacheado', child: Text('Cacheado')),
                                const DropdownMenuItem(
                                    value: 'Crespo', child: Text('Crespo')),
                                const DropdownMenuItem(
                                    value: 'Careca', child: Text('Careca')),
                                const DropdownMenuItem(
                                    value: 'Outro', child: Text('Outro')),
                              ],
                              onChanged: (hair) {
                                _formData.hairStyle = hair!;
                              },
                            ),
                          if (_formType == 2) const SizedBox(height: 12),
                          if (_formType == 2)
                            DropdownButtonFormField(
                              value: '',
                              items: [
                                DropdownMenuItem(
                                    value: '',
                                    child: Text('*Tamanho',
                                        style: TextStyle(
                                            color: ColorsApp
                                                .instance.previewText))),
                                const DropdownMenuItem(
                                    value: 'Pequeno', child: Text('Pequeno')),
                                const DropdownMenuItem(
                                    value: 'Médio', child: Text('Médio')),
                                const DropdownMenuItem(
                                    value: 'Grande', child: Text('Grande')),
                              ],
                              validator: (value) {
                                if (value == '') {
                                  return 'Selecione um tamanho'; // Mensagem de erro personalizada
                                }
                                return null; // A seleção é válida
                              },
                              onChanged: (size) {
                                _formData.size = size!;
                              },
                            ),
                          if (_formType == 2) const SizedBox(height: 12),
                          if (_formType == 2)
                            TextFormField(
                              style: TextStyles.instance.textInput,
                              decoration:
                                  const InputDecoration(labelText: 'Raça'),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(
                                    r'[a-zA-ZÀ-ÿ ]+')), // Permite apenas letras
                              ],
                              onChanged: (breed) => _formData.breed = breed,
                            ),
                          const SizedBox(height: 20),
                          if (_formType == 2)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('RECOMPENSA'),
                                const SizedBox(height: 5),
                                Text(
                                  'Ofereça uma recompensa para quem encontrar o seu pet',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: ColorsApp.instance.previewText),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _controller,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Valor',
                                  ),
                                  onChanged: (text) {
                                    final cleanText = text.replaceAll(
                                        RegExp('[^0-9]'),
                                        ''); // Remove caracteres não numéricos
                                    final intValue = int.tryParse(cleanText) ??
                                        0; // Converte para um inteiro
                                    final formattedValue =
                                        _currencyFormatter.format(intValue /
                                            100); // Formata como moeda
                                    setState(() {
                                      _controller.value = TextEditingValue(
                                        text: formattedValue,
                                        selection: TextSelection.fromPosition(
                                            TextPosition(
                                                offset: formattedValue.length)),
                                      );
                                    });
                                    _formData.reward = _controller.text;
                                  },
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          const Text("LOCAL VISTO PELA ÚLTIMA VEZ"),
                          const SizedBox(height: 12),
                          Container(
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
                              child: (_formData.latitude == 0.0 &&
                                      _formData.longitude == 0.0)
                                  ? const Text('Localização não informada!')
                                  : Image.network(
                                      LocationUtil.generateLocationPreviewImage(
                                        latitude: _formData.latitude,
                                        longitude: _formData.longitude,
                                      ),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                            ),
                          ),
                          if (_formData.address.isNotEmpty)
                            const SizedBox(height: 12),
                          if (_formData.address.isNotEmpty)
                            TextFormField(
                              style: TextStyles.instance.textInput,
                              decoration:
                                  const InputDecoration(labelText: '*Endereço'),
                              initialValue: _formData.address,
                              validator: Validatorless.multiple([
                                Validatorless.required('Endereço obrigatório'),
                              ]),
                              onChanged: (address) =>
                                  _formData.address = address,
                            ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 42,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(SlideRoute(
                                    page: GoogleMapSelect(
                                        onSubmit: _selectOnMap)));
                              },
                              icon: const Icon(Icons.location_on),
                              label: Text('Selecionar Localização',
                                  style: TextStyles.instance.textRegular
                                      .copyWith(fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: ColorsApp.instance.primary,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                        color: ColorsApp.instance.primary,
                                        width: 1),
                                  )),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text("OUTRAS INFORMAÇÕES"),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _dateController,
                            style: TextStyles.instance.textInput,
                            decoration: InputDecoration(
                                labelText: '*Data do desaparecimento',
                                prefixIcon: Icon(Icons.calendar_today,
                                    color: ColorsApp.instance.primary)),
                            readOnly: true,
                            validator: Validatorless.multiple([
                              Validatorless.required('Data obrigatória'),
                            ]),
                            onTap: _selectDate,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            style: TextStyles.instance.textInput,
                            maxLines: 5,
                            decoration: const InputDecoration(
                                labelText: 'Descrição',
                                alignLabelWithHint: true,
                                hintText:
                                    'Dê mais detalhes sobre características físicas, roupas e informações do ocorrido.'),
                            onChanged: (description) =>
                                _formData.description = description,
                          ),
                          const SizedBox(height: 20),
                          const Text("FOTOS DO DESAPARECIDO"),
                          const SizedBox(height: 12),
                          MultiImagePicker(onImagesPick: _handleImagesPick),
                          SizedBox(
                              height: _isFormSubmitted && !_hasImages ? 10 : 0),
                          Text(
                            _isFormSubmitted && !_hasImages
                                ? '   *Adicione pelo menos uma foto'
                                : '',
                            style: const TextStyle(
                                color: Colors.red, fontSize: 13),
                          ),
                          Text(
                            '* - Define campos obrigatórios',
                            style: TextStyle(
                                fontSize: 12,
                                color: ColorsApp.instance.previewText),
                          ),
                          const SizedBox(height: 12),
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
                          const SizedBox(height: 12),
                        ],
                      ),
                    )
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
            child: const Center(child: CircularProgressIndicator.adaptive()),
          ),
      ],
    );
  }
}
