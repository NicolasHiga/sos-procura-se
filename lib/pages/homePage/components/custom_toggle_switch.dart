import 'package:flutter/material.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';

class CustomToggleSwitch extends StatefulWidget {
  final bool isPeople;
  final ValueChanged<bool> onChanged;

  const CustomToggleSwitch({
    super.key,
    required this.onChanged, required this.isPeople,
  });

  @override
  State<CustomToggleSwitch> createState() => _CustomToggleSwitchState();
}

class _CustomToggleSwitchState extends State<CustomToggleSwitch> {
  late bool _value = widget.isPeople;

  void _toggle() {
    setState(() {
      _value = !_value;
      widget.onChanged(_value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: double.infinity,
        height: 35, // Altura total do switch
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18), // Metade da altura
            color: ColorsApp.instance.secondary,
            ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: _value ? 0 : MediaQuery.of(context).size.width * 0.455,
              top: 0,
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.47, // Ajuste para a largura total do switch
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18), 
                  color: ColorsApp.instance.primary,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'Pessoas',
                      style: TextStyle(
                        color: _value
                            ? Colors.white
                            : ColorsApp.instance.previewText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Animais',
                      style: TextStyle(
                        color: _value
                            ? ColorsApp.instance.previewText
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
