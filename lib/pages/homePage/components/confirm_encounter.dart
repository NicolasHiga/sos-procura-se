import 'package:flutter/material.dart';
import 'package:sos_app/core/services/post/post_firebase_service.dart';
import 'package:sos_app/core/ui/helpers/messages.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/core/ui/styles/text_styles.dart';
import 'package:sos_app/models/person_data.dart';

class ConfirmEncounter extends StatelessWidget {
  final bool isMissing;
  final dynamic data;
  const ConfirmEncounter({super.key, required this.isMissing, this.data});

  Future<void> _showConfirmationCheck(BuildContext context) {
    return showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Confirmar'),
        content: const Text('Deseja finalizar essa publicação?'),
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
            child: const Text('Confirmar'),
            onPressed: () {
              try {
                PostFirebaseService().setStatus(
                    data is PersonData
                        ? isMissing
                            ? 'missingPeople'
                            : 'lostPeople'
                        : isMissing
                            ? 'missingPets'
                            : 'lostPets',
                    data.docId);
                Navigator.pop(context);
                Messages.showSuccess(context,
                    'Finalizado com sucesso! Ficamos felizes pelo final feliz!');
              } catch (e) {
                Messages.showError(
                    context, 'Erro ao finalizar publicação. Tente novamente.');
                throw 'Erro ao finalizar publicação: $e';
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          try {
            _showConfirmationCheck(context);
          } catch (e) {
            Messages.showError(
                context, 'Erro ao confimar. Tente novamente mais tarde');
            throw Exception(e);
          }
        },
        icon: const Icon(
          Icons.check,
        ),
        label: Text(isMissing ? 'Confirmar Encontro' : 'Resolvido',
            style: TextStyles.instance.textRegular
                .copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            )),
      ),
    );
  }
}
