import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/user/user_store.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/core/ui/styles/text_styles.dart';
import 'package:sos_app/models/person_data.dart';
import 'package:sos_app/pages/homePage/components/confirm_encounter.dart';
import 'package:sos_app/pages/homePage/components/image_slider.dart';
import 'package:sos_app/pages/homePage/components/options_cards.dart';
import 'package:sos_app/pages/homePage/components/contact_ways.dart';
import 'package:sos_app/pages/maps/utils/location_util.dart';

class ShowPersonData extends StatelessWidget {
  final PersonData person;
  final bool isMissing;
  const ShowPersonData(
      {super.key, required this.person, required this.isMissing});

  @override
  Widget build(BuildContext context) {
    final sessionUser = Provider.of<UserStore>(context, listen: false);

    String datePost = DateFormat('dd/MM/yyyy').format(
        DateTime.fromMillisecondsSinceEpoch(
            person.datePost.millisecondsSinceEpoch));

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white, // Altere para a cor desejada
            ),
            onPressed: () {
              // Adicione aqui a ação ao pressionar a seta de voltar
              Navigator.of(context).pop();
            },
          ),
          actions: [
            OptionsCards(
                postData: person,
                collectionName: isMissing ? 'missingPeople' : 'lostPeople',
                onItemDeleted: () => Navigator.pop(context)),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 320,
                child: ImageSlider(images: person.images),
              ),
              Container(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informações',
                        style: TextStyles.instance.textBold.copyWith(
                            fontSize: 24, color: ColorsApp.instance.primary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text('Nome: ', style: TextStyles.instance.textBold),
                        person.name.isNotEmpty
                            ? Text(person.name)
                            : const Text('Não informado.')
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('Idade: ',
                                style: TextStyles.instance.textBold),
                            Text(person.age.isEmpty
                                ? 'Não informado'
                                : person.age),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Gênero: ',
                                style: TextStyles.instance.textBold),
                            Text(person.gender.isEmpty
                                ? 'Não informado'
                                : person.gender),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('Etnia: ',
                                style: TextStyles.instance.textBold),
                            Text(person.color.isEmpty
                                ? 'Não informado'
                                : person.color),
                          ],
                        ),
                        Row(
                          children: [
                            isMissing
                                ? Text('Altura: ',
                                    style: TextStyles.instance.textBold)
                                : Text('Altura aprox.: ',
                                    style: TextStyles.instance.textBold),
                            Text(person.height.isEmpty
                                ? 'Não informado'
                                : person.height),
                          ],
                        )
                      ],
                    ),
                    if (isMissing) const SizedBox(height: 8),
                    if (isMissing)
                      Row(children: [
                        Text('Cabelo: ', style: TextStyles.instance.textBold),
                        Text(person.hairStyle.isEmpty
                            ? 'Não informado'
                            : person.hairStyle)
                      ]),
                    if (isMissing) const SizedBox(height: 8),
                    if (isMissing)
                      Row(children: [
                        Text('Cor do Cabelo: ',
                            style: TextStyles.instance.textBold),
                        Text(person.hairColor.isEmpty
                            ? 'Não informado'
                            : person.hairColor)
                      ]),
                    if (isMissing) const SizedBox(height: 8),
                    if (isMissing)
                      Row(children: [
                        Text('Cor dos olhos: ',
                            style: TextStyles.instance.textBold),
                        Text(person.eyeColor.isEmpty
                            ? 'Não informado'
                            : person.eyeColor)
                      ]),
                    const SizedBox(height: 12),
                    isMissing
                        ? Text('Desaparecimento',
                            style: TextStyles.instance.textBold.copyWith(
                                fontSize: 24,
                                color: ColorsApp.instance.primary))
                        : Text('Perdido',
                            style: TextStyles.instance.textBold.copyWith(
                                fontSize: 24,
                                color: ColorsApp.instance.primary)),
                    const SizedBox(height: 12),
                    if (isMissing)
                      Row(children: [
                        Text('Data: ', style: TextStyles.instance.textBold),
                        Text(person.date)
                      ]),
                    if (isMissing) const SizedBox(height: 8),
                    isMissing
                        ? Text('Úlitmo local visto: ',
                            style: TextStyles.instance.textBold)
                        : Text('Local em que foi encontrado: ',
                            style: TextStyles.instance.textBold),
                    Text(person.address.isEmpty
                        ? 'Não informado'
                        : person.address),
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
                        child: Image.network(
                          LocationUtil.generateLocationPreviewImage(
                            latitude: person.lat,
                            longitude: person.long,
                          ),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Descrição: ', style: TextStyles.instance.textBold),
                    Text(person.description.isEmpty
                        ? 'Não informado'
                        : person.description),
                    const SizedBox(height: 16),
                    Text(
                      'Publicado em: $datePost',
                      style: TextStyles.instance.textBold.copyWith(
                          color: ColorsApp.instance.previewText, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    if (person.userId != sessionUser.currentUser!.id)
                      ContactWays(userId: person.userId),
                    if (person.userId == sessionUser.currentUser!.id &&
                        person.status == 'W')
                      ConfirmEncounter(isMissing: isMissing, data: person),
                    if (person.userId == sessionUser.currentUser!.id &&
                        person.status == 'F')
                      Container(
                        padding: const EdgeInsets.all(15),
                        child: Center(
                          child: Text('Publicação Finalizada',
                              style: TextStyles.instance.textBold
                                  .copyWith(color: Colors.green, fontSize: 16)),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
