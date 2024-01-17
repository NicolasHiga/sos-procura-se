
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class RegisterFormController {
  final cpfEC = MaskedTextController(mask: '000.000.000-00');
  final cepEC = MaskedTextController(mask: '00000-000');
  final phoneEC = MaskedTextController(mask: '(00)00000-0000');
  var heightEC = MaskedTextController(mask: '0,00');
}