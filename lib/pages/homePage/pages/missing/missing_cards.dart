// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/models/person_data.dart';
import 'package:sos_app/models/pet_data.dart';
import 'package:sos_app/pages/homePage/pages/missing/show_person_data.dart';
import 'package:sos_app/pages/homePage/pages/lost/show_pet_data.dart';

class MissingCards extends StatelessWidget {
  final dynamic data;

  const MissingCards({
    Key? key,
    required this.data,
  }) : super(key: key);

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
                          isMissing: true,
                        )))
            : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ShowPetData(
                          pet: data,
                          isMissing: true,
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
            Stack(
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
                if (data is PetData &&
                    data.reward.isNotEmpty &&
                    data.reward != 'R\$ 0,00')
                  Positioned(
                    bottom: 5.0, // Define a distância do container inferior
                    right: 5.0, // Define a distância do container direito
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.green, // Cor de fundo do container
                        borderRadius:
                            BorderRadius.circular(5.0), // Borda circular
                      ), // Cor de fundo do segundo container
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recompensa',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14),
                          ),
                          Text(
                            data.reward,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${data.name}, ',
                          style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
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
                  if (data.status == 'F') const SizedBox(height: 8.0),
                  if (data.status == 'F')
                    Container(
                      padding: const EdgeInsets.all(5),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.green),
                      child: const Center(
                          child: Text(
                        'Resolvido',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
