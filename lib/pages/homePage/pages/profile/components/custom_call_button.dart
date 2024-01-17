import 'package:flutter/material.dart';
import 'package:sos_app/core/ui/helpers/messages.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/core/ui/styles/text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomCallButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final String phoneNumber;
  final BuildContext ctx;

  const CustomCallButton(
      {super.key,
      required this.icon,
      required this.text,
      required this.phoneNumber,
      required this.ctx});

  Future<void> _makePhoneCall() async {
    try {
      final Uri url = Uri(scheme: 'tel', path: phoneNumber);
      await launchUrl(url);
    } catch (e) {
      // ignore: use_build_context_synchronously
      Messages.showError(
          ctx, 'Não foi possível fazer a chamada para $phoneNumber');
      throw 'Não foi possível fazer a chamada para $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorsApp.instance.secondary,
        ),
      ),
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          color: ColorsApp.instance.primary,
          size: 30,
        ),
        onPressed: () {
          showAdaptiveDialog(
            context: context,
            builder: (context) => AlertDialog.adaptive(
              title: const Text('Confirmar'),
              content: Text('Deseja ligar para o número $phoneNumber?'),
                actions: [
                  TextButton(
                    child: Text('Cancelar', style: TextStyle(color: ColorsApp.instance.previewText),),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: const Text('Ligar'),
                    onPressed: () {
                      _makePhoneCall();
                      Navigator.pop(context);
                    },
                  ),
                ],
            ),
          );        
        },
        label: Text(
          text,
          style: TextStyles.instance.textMedium
              .copyWith(color: Colors.black, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft, backgroundColor: Colors.white),
      ),
    );
  }
}
