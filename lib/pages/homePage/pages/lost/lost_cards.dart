// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/models/person_data.dart';
import 'package:sos_app/pages/homePage/pages/missing/show_person_data.dart';
import 'package:sos_app/pages/homePage/pages/lost/show_pet_data.dart';

class LostCards extends StatelessWidget {
  final dynamic data;

  const LostCards({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        data is PersonData
            ? Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ShowPersonData(
                          person: data,
                          isMissing: false,
                        )))
            : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ShowPetData(
                          pet: data,
                          isMissing: false,
                        )));
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0),
              ),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: Image.network(
                  data.images[0],
                  fit: BoxFit.cover,
                  height: 200,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        data.name.isNotEmpty
                            ? TextSpan(
                                text: '${data.name}, ',
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              )
                            : TextSpan(
                                text: data is PersonData
                                    ? '${data.age.toString().toUpperCase()} PERDIDO'
                                    : '${data.specie.toString().toUpperCase()} PERDIDO',
                                style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                        if (data.name.isNotEmpty)
                          data is PersonData
                              ? TextSpan(
                                  text: data.age,
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: ColorsApp.instance.previewText),
                                )
                              : WidgetSpan(
                                  child: Icon(
                                    data.gender == 'Macho'
                                        ? Icons.male
                                        : Icons.female,
                                    color: ColorsApp.instance.previewText,
                                    size: 20,
                                  ),
                                ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    data.address,
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
