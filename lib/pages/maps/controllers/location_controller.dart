import 'package:geolocator/geolocator.dart';
import 'package:sos_app/pages/maps/utils/location_util.dart';
import 'package:mobx/mobx.dart';

part 'location_controller.g.dart';

// ignore: library_private_types_in_public_api
class LocationController = _LocationController with _$LocationController;

abstract class _LocationController with Store {
  double lat = 0.0;
  double long = 0.0;
  String? erro;

  @observable
  String staticMapImageUrl = '';

  @observable
  String cep = '';

  @observable
  String city = '';

  @observable
  String uf = '';

  @observable
  bool isLoading = false;

  locationController() {
    getPosition();
  }

  @action
  getPosition() async {
    try {
      isLoading = true;

      Position position = await _currentPosition();
      lat = position.latitude;
      long = position.longitude;

      Map<String, String> addressData =
          await LocationUtil.getAddressFromCoordinates(lat, long);
      cep = addressData['cep']!;
      uf = addressData['uf']!;
      city = addressData['city']!;

      staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
        latitude: lat,
        longitude: long,
      );
    } catch (e) {
      erro = e.toString();
    } finally {
      isLoading = false;
    }
  }

  Future<Map<String, double>> getLocationPost() async {
    Position position = await _currentPosition();

    return {
      'lat' : position.latitude,
      'long' : position.longitude,
    };
  }

  Future<Position> _currentPosition() async {
    LocationPermission permission;

    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return Future.error('Autorize o acesso à localização');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Autorize o  acesso à localização');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Autorize o  acesso à localização');
    }

    return await Geolocator.getCurrentPosition();
  }
}
