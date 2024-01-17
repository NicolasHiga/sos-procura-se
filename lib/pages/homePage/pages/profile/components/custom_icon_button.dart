import 'package:flutter/material.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/core/ui/styles/text_styles.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final String text;
  // final BuildContext ctx;
  final Widget page;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.text,
    required this.page,
    // required this.ctx,
  });

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
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
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
