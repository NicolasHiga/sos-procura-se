import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/user/user_store.dart';
import 'package:sos_app/pages/maps/controllers/location_controller.dart';
import 'package:sos_app/pages/maps/utils/location_util.dart';

class CurrentLocation {
  static Future<void> getLocation(BuildContext context) async {
    final sessionUser = Provider.of<UserStore>(context, listen: false);
    LocationController locationEC = LocationController();
    final previousLat = sessionUser.currentUser!.lat;
    final previousLong = sessionUser.currentUser!.long;
    late double newLat;
    late double newLong;
    log("Location antiga: $previousLat $previousLong");

    await locationEC.getLocationPost().then((latLong) {
      newLat = latLong['lat']!;
      newLong = latLong['long']!;
      log('Nova location: $newLat $newLong');
    });
    // Verifica se o usuário se moveu
    if ((newLat == previousLat) && (newLong == previousLong)) {
      log('A localização não mudou');
      return;
    }

    // Calcula a distancia percorrida
    double distanceInMeters = Geolocator.distanceBetween(
      previousLat,
      previousLong,
      newLat,
      newLong,
    );
    log(distanceInMeters.toString());

    // Atualiza os dados se a distância percorrida for maior que 300 metros
    if (distanceInMeters >= 400) {
      log('Usuário andou mais de 400m. Atualizando dados.');
      // Pega o endereço atual
      Map<String, String> addressData =
          await LocationUtil.getAddressFromCoordinates(newLat, newLong);
      final String cep = addressData['cep']!;
      final String uf = addressData['uf']!;
      final String city = addressData['city']!;
      // Salva o id do usuário atual
      final String userId = sessionUser.currentUser!.id;

      // Acesse o Firestore e atualize os campos necessários
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'lat': newLat,
        'long': newLong,
        'cep': cep,
        'city': city,
        'uf': uf,
      }).then((value) {
        log("Dados de localização atualizados");
        // Puxa os dados atualizados
        sessionUser.fetchUserData(userId, context);
      }).catchError((error) {
        log('Erro ao atualizar dados do usuário: $error');
        throw Exception(error);
      });
    } else {
      log("O usuário não andou menos de 400m.");
    }
  }
}
