import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sos_app/core/services/post/post_firebase_service.dart';
import 'package:sos_app/core/services/user/user_store.dart';
import 'package:sos_app/core/ui/helpers/messages.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/pages/homePage/components/report.dart';
import 'package:sos_app/pages/homePage/pages/edit/edit_lost_post.dart';
import 'package:sos_app/pages/homePage/pages/edit/edit_missing_post.dart';

class OptionsCards extends StatelessWidget {
  final dynamic postData;
  final String collectionName;
  final Function() onItemDeleted;
  const OptionsCards(
      {super.key,
      required this.postData,
      required this.collectionName,
      required this.onItemDeleted});

  @override
  Widget build(BuildContext context) {
    final sessionUser = Provider.of<UserStore>(context, listen: false);
    return PopupMenuButton(
        color: Colors.white,
        onSelected: (value) {
          if (value == 1) {
            // Ação para a opção "Denunciar"
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => Report(
                          userId: sessionUser.currentUser!.id,
                          postId: postData.docId,
                          collectionPost: collectionName,
                        )));
          } else if (value == 2) {
            // Ação para a opção "Editar"
            if (collectionName == 'missingPeople' ||
                collectionName == 'missingPets') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditMissingPost(data: postData)));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditLostPost(data: postData)));
            }
          } else if (value == 3) {
            // Ação para a opção "Excluir"
            showAdaptiveDialog(
              context: context,
              builder: (context) => AlertDialog.adaptive(
                title: const Text('Confirmar'),
                content: const Text('Deseja excluir essa publicação?'),
                actions: [
                  TextButton(
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: ColorsApp.instance.previewText),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: const Text('Excluir'),
                    onPressed: () {
                      try {
                        PostFirebaseService().deleteFromFirebase(
                            collectionName, postData.docId, postData.images);
                        Navigator.pop(context);
                        onItemDeleted();
                        Messages.showSuccess(
                            context, 'Publicação excluida com sucesso!');
                      } catch (e) {
                        Messages.showError(context,
                            'Erro ao deletar publicação. Tente novamente.');
                        throw 'Erro ao executar exclusão de publicação: $e';
                      }
                    },
                  ),
                ],
              ),
            );
          }
        },
        itemBuilder: (context) => [
              if (postData.userId != sessionUser.currentUser!.id)
                PopupMenuItem(
                    value: 1,
                    child: Row(children: [
                      Icon(Icons.report,
                          color: ColorsApp
                              .instance.primary), // Ícone para "Denunciar"
                      const SizedBox(
                          width: 8), // Espaço entre o ícone e o texto
                      const Text('Denunciar')
                    ])),
              if (postData.userId == sessionUser.currentUser!.id)
                PopupMenuItem(
                    value: 2,
                    child: Row(children: [
                      Icon(Icons.edit,
                          color: ColorsApp
                              .instance.primary), // Ícone para "Editar"
                      const SizedBox(
                          width: 8), // Espaço entre o ícone e o texto
                      const Text('Editar')
                    ])),
              if (postData.userId == sessionUser.currentUser!.id)
                PopupMenuItem(
                    value: 3,
                    child: Row(children: [
                      Icon(Icons.delete,
                          color: ColorsApp
                              .instance.primary), // Ícone para "Excluir"
                      const SizedBox(
                          width: 8), // Espaço entre o ícone e o texto
                      const Text('Excluir')
                    ])),
            ]);
  }
}
