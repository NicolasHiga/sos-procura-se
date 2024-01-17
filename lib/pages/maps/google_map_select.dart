import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/user/user_store.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/pages/maps/controllers/location_controller.dart';

class GoogleMapSelect extends StatefulWidget {
  final bool isReadOnly;
  final void Function(LatLng) onSubmit;

  const GoogleMapSelect(
      {super.key,
      this.isReadOnly = false,
      required this.onSubmit});

  @override
  State<GoogleMapSelect> createState() => _GoogleMapSelectState();
}

class _GoogleMapSelectState extends State<GoogleMapSelect> {
  final _locationEC = LocationController();
  double lat = 0.0;
  double long = 0.0;
  LatLng? _pickedPosition;
  bool isLoading = true;
  late UserStore sessionUser;

  @override
  void initState() {
    super.initState();
    sessionUser = Provider.of<UserStore>(context, listen: false);
    _locationEC.getLocationPost().then((latLong) {
      lat = latLong['lat']!;
      long = latLong['long']!;
    });

    // Caso dê erro ou a localização esteja desabilitada, os dados do cadastros serão pegos
    if (lat == 0.0 && long == 0.0) {
      lat = sessionUser.currentUser!.lat;
      long = sessionUser.currentUser!.long;
    }

    setState(() {
      isLoading = false;
    });
  }

  void _selectPosition(LatLng position) {
    setState(() {
      _pickedPosition = position;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione...'),
        titleSpacing: 0,
        actions: [
          if (!widget.isReadOnly)
            IconButton(
              onPressed: _pickedPosition == null
                  ? null
                  : () {
                      widget.onSubmit(_pickedPosition!);
                      Navigator.of(context).pop();
                    },
              icon: Icon(
                Icons.check,
                color: ColorsApp.instance.primary,
              ),
            )
        ],
        backgroundColor: Colors.white,
      ),
      body: !isLoading
          ? SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat, long),
                  zoom: 18,
                ),
                onTap: widget.isReadOnly ? null : _selectPosition,
                markers: _pickedPosition == null
                    ? {}
                    : {
                        Marker(
                          markerId: const MarkerId('p1'),
                          position: _pickedPosition!,
                        ),
                      },
              ),
            )
          : const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
