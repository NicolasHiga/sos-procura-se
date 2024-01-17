import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:sos_app/core/config/env.dart';

class LocationUtil {
  static final _apiKey = Env.instance['MAPS_APIKEY'] ?? '';

  static String generateLocationPreviewImage(
      {double? latitude, double? longitude}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=19&size=600x300&maptype=roadmap&markers=color:red%7Clabel:%7C$latitude,$longitude&key=$_apiKey';
  }

  static Future<Map<String, String>> getAddressFromCoordinates(
      double latitude, double longitude) async {
    // final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';
    log("Acessando o Geocoding");
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$_apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      log('Chamando Geocoding API');
      final data = jsonDecode(response.body);
      String? address, cep, uf, city;
      // Extrai o endereço completo
      address = data['results'][0]['formatted_address'];
      log(address!);
      // Extrair CEP, UF e cidade dos componentes de endereço
      for (var component in data['results'][0]['address_components']) {
        List<String> types = List<String>.from(component['types']);

        if (types.contains('postal_code')) {
          // Verificar se o valor do CEP não contém letras
          String potentialCep = component['short_name'];
          if (!containsLetters(potentialCep)) {
            cep = potentialCep;
            log(cep);
          } else {
            log('CEP contém letras, ignorando.');
          }
        } else if (types.contains('administrative_area_level_1')) {
          uf = component['short_name'];
          log(uf!);
        } else if (types.contains('administrative_area_level_2')) {
          city = component['long_name'];
          log(city!);
        }
      }
      return {
        'cep': cep ?? '00000-000',
        'uf': uf ?? '??',
        'city': city ?? 'Desconhecido',
        'address': address,
      };
    } else {
      throw Exception('Erro na solicitação de geocodificação reversa');
    }
  }

  static bool containsLetters(String s) {
    return s.codeUnits.any(
        (char) => (char >= 65 && char <= 90) || (char >= 97 && char <= 122));
  }
}
