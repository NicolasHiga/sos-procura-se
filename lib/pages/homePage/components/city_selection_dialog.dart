// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:sos_app/core/ui/styles/colors_app.dart';

class CitySelectionDialog extends StatefulWidget {
  final void Function(String, String) onSubmit;
  final String currentState;
  final String currentCity;

  const CitySelectionDialog({
    Key? key,
    required this.currentState,
    required this.currentCity,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _CitySelectionDialogState createState() => _CitySelectionDialogState();
}

class _CitySelectionDialogState extends State<CitySelectionDialog> {
  late String selectedState; // Inicialize com o estado padrão
  late String selectedCity; // Inicialize com "Cidade" como opção padrão
  List<String> states = [];
  List<String> cities = ['Cidade']; // Adicione "Cidade" à lista de cidades
  bool isLoading = true;

  Future<void> fetchStates() async {
    final response = await http.get(Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        states = List<String>.from(data.map((state) => state['sigla']));
      });
      fetchCities(
          selectedState); // Inicie a busca de cidades assim que os estados forem carregados
    }
  }

  Future<void> fetchCities(String state) async {
    final response = await http.get(Uri.parse(
        'https://servicodados.ibge.gov.br/api/v1/localidades/estados/$state/municipios'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        cities = [
          'Cidade',
          ...List<String>.from(data.map((city) => city['nome']))
        ];
        if (!cities.contains(selectedCity)) {
          selectedCity = 'Cidade';
        }
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedState = widget.currentState;
    selectedCity = widget.currentCity;
    fetchStates();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text('Selecione um lugar'),
      content: SizedBox(
        height: 110,
        child:
            isLoading // Mostra o indicador de carregamento se isLoading for verdadeiro
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      DropdownButtonFormField<String>(
                        value: selectedState,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedState = newValue!;
                            fetchCities(
                                selectedState); // Buscar cidades com base no estado selecionado
                          });
                        },
                        items: states
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12), // Espaço entre os Dropdowns
                      DropdownButtonFormField<String>(
                        value: selectedCity,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCity = newValue!;
                          });
                        },
                        items: cities
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == 'Cidade') {
                            return 'Selecione uma cidade'; // Mensagem de erro personalizada
                          }
                          return null; // A seleção é válida
                        },
                      ),
                    ],
                  ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fechar o diálogo
            },
            child: Text(
              'Cancelar',
              style: TextStyle(color: ColorsApp.instance.previewText),
            )),
        TextButton(
          child: const Text('Salvar'),
          onPressed: () {
            widget.onSubmit(selectedState, selectedCity);
            Navigator.of(context).pop(); //
          },
        ),
      ],
    );
  }
}
