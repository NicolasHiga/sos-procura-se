import 'package:flutter/material.dart';
import 'package:sos_app/core/services/contact_utils.dart';
import 'package:sos_app/core/ui/helpers/messages.dart';
import 'package:sos_app/core/ui/styles/text_styles.dart';

class ContactWays extends StatelessWidget {
  final String userId;

  const ContactWays({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: () {
                try {
                  ContactUtils.openWhatsApp(userId);
                } catch (e) {
                  Messages.showError(
                      context, 'Erro de conexão. Tente novamente mais tarde');
                  throw Exception(e);
                }
              },
              icon: const Icon(
                Icons.message,
                size: 22,
              ),
              label: Text('WhatsApp',
                  style: TextStyles.instance.textRegular
                      .copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  )),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 1,
          child: SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: () {
                try {
                  ContactUtils.callAuthorPost(userId);
                } catch (e) {
                  Messages.showError(
                      context, 'Erro de conexão. Tente novamente mais tarde');
                  throw Exception(e);
                }
              },
              icon: const Icon(
                Icons.phone,
                size: 22,
              ),
              label: Text('Contato',
                  style: TextStyles.instance.textRegular
                      .copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 5, 155, 142),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  )),
            ),
          ),
        ),
      ],
    );
  }
}
