import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/user/user_store.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/core/ui/styles/text_styles.dart';
import 'package:sos_app/models/pet_data.dart';
import 'package:sos_app/pages/homePage/components/confirm_encounter.dart';
import 'package:sos_app/pages/homePage/components/image_slider.dart';
import 'package:sos_app/pages/homePage/components/options_cards.dart';
import 'package:sos_app/pages/homePage/components/contact_ways.dart';
import 'package:sos_app/pages/maps/utils/location_util.dart';

class ShowPetData extends StatelessWidget {
  final PetData pet;
  final bool isMissing;
  const ShowPetData({super.key, required this.pet, required this.isMissing});

  @override
  Widget build(BuildContext context) {
    final sessionUser = Provider.of<UserStore>(context, listen: false);

    String datePost = DateFormat('dd/MM/yyyy').format(
        DateTime.fromMillisecondsSinceEpoch(
            pet.datePost.millisecondsSinceEpoch));

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
                postData: pet,
                collectionName: isMissing ? 'missingPets' : 'lostPets',
                onItemDeleted: () => Navigator.pop(context)),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 320,
                child: ImageSlider(images: pet.images),
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
                        pet.name.isNotEmpty
                            ? Text(pet.name)
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
                            Text(pet.age.isEmpty ? 'Não informado' : pet.age),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Gênero: ',
                                style: TextStyles.instance.textBold),
                            Text(pet.gender.isEmpty
                                ? 'Não informado'
                                : pet.gender),
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
                            Text('Espécie: ',
                                style: TextStyles.instance.textBold),
                            Text(pet.specie.isEmpty
                                ? 'Não informado'
                                : pet.specie),
                          ],
                        ),
                        Row(
                          children: [
                            Text('Tamanho: ',
                                style: TextStyles.instance.textBold),
                            Text(pet.size.isEmpty ? 'Não informado' : pet.size),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text('Raça: ', style: TextStyles.instance.textBold),
                      Text(pet.breed.isEmpty ? 'Não informado' : pet.breed)
                    ]),
                    if (isMissing) const SizedBox(height: 8),
                    if (isMissing)
                      Row(children: [
                        Text('Recompensa: ',
                            style: TextStyles.instance.textBold),
                        Text(pet.reward.isNotEmpty
                            ? pet.reward
                            : 'Sem recompensa.')
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
                        Text(pet.date)
                      ]),
                    if (isMissing) const SizedBox(height: 8),
                    isMissing
                        ? Text('Úlitmo local visto: ',
                            style: TextStyles.instance.textBold)
                        : Text('Local em que foi encontrado: ',
                            style: TextStyles.instance.textBold),
                    Text(pet.address.isEmpty ? 'Não informado' : pet.address),
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
                            latitude: pet.lat,
                            longitude: pet.long,
                          ),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Descrição: ', style: TextStyles.instance.textBold),
                    Text(pet.description.isEmpty
                        ? 'Não informado'
                        : pet.description),
                    const SizedBox(height: 16),
                    Text(
                      'Publicado em: $datePost',
                      style: TextStyles.instance.textBold.copyWith(
                          color: ColorsApp.instance.previewText, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    if (pet.userId != sessionUser.currentUser!.id)
                      ContactWays(userId: pet.userId),
                    if (pet.userId == sessionUser.currentUser!.id &&
                        pet.status == 'W')
                      ConfirmEncounter(isMissing: isMissing, data: pet),
                    if (pet.userId == sessionUser.currentUser!.id &&
                        pet.status == 'F')
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
