import 'package:flutter/material.dart';
import 'package:sos_app/core/services/auth/auth_service.dart';
import 'package:sos_app/core/ui/helpers/messages.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';

class ShowDialogs {
  static void showAlertPost(BuildContext context, bool isMissingPerson) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Postagem realizada com sucesso!'),
        content: !isMissingPerson
            ? const Text(
                'Mantenha sua publicação sempre atualizada. Lembre-se de finalizá-lo quando tudo der certo! Boa sorte!')
            : const Text(
                'Não se esqueça de realizar um Boletim de Ocorrência (BO) para ter ajuda das autoridades. Mantenha sua publicação sempre atualizada. Lembre-se de finalizá-lo quando tudo der certo! Boa sorte!'),
        actions: [
          TextButton(
            child: Text(
              'Ok',
              style: TextStyle(color: ColorsApp.instance.primary),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  static void showDeleteDialog(BuildContext context, String userId) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Deletar conta?'),
        content: const Text(
            'Tem certeza que deseja deletar a sua conta? Todos os dados serão apagados.'),
        actions: [
          TextButton(
            child: Text(
              'Cancelar',
              style: TextStyle(color: ColorsApp.instance.primary),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(
              'Deletar',
              style: TextStyle(color: ColorsApp.instance.primary),
            ),
            onPressed: () async {
              try {
                Navigator.pop(context); // fecha o dialog
                Navigator.pop(context); // fecha a página de edição
                await AuthService().deleteAccount(userId);
              } catch (e) {
                // ignore: use_build_context_synchronously
                Messages.showError(
                    context, 'Erro ao deletar conta. Tente novamente.');
              }              
            },
          ),
        ],
      ),
    );
  }
}
