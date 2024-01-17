// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:sos_app/core/services/post/post_firebase_service.dart';
import 'package:sos_app/core/ui/helpers/messages.dart';

import 'package:sos_app/core/ui/styles/colors_app.dart';
import 'package:sos_app/core/ui/styles/text_styles.dart';

class Report extends StatefulWidget {
  final String userId;
  final String postId;
  final String collectionPost;

  const Report({
    Key? key,
    required this.userId,
    required this.postId,
    required this.collectionPost,
  }) : super(key: key);

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  String selectedValue = '';
  String? comment;
  DateTime? dateReport;

  void _submit() async {
    if (widget.userId.isEmpty &&
        widget.postId.isEmpty &&
        widget.collectionPost.isEmpty &&
        selectedValue.isEmpty) return;

    try {
      dateReport = DateTime.now();

      await PostFirebaseService().sendReport(widget.userId, widget.postId,
          widget.collectionPost, selectedValue, comment!, dateReport!);

      // ignore: use_build_context_synchronously
      Messages.showSuccess(
          context, 'Denúncia enviada. Agradecemos pela colaboração!');
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      // ignore: use_build_context_synchronously
      Messages.showError(context, 'Erro ao enviar denúncia. Tente novamente.');
      throw 'Erro ao enviar denúncia: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Denunciar'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selecione uma opção:',
                  style: TextStyle(
                      fontSize: 16,
                      color: ColorsApp.instance.accent,
                      fontWeight: FontWeight.bold)),
              RadioListTile(
                value: 'optionIncorrectInfo',
                groupValue: selectedValue,
                contentPadding: const EdgeInsets.all(0.0),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                  });
                },
                title: const Text('Informações Incorretas',
                    style: TextStyle(fontSize: 14)),
              ),
              RadioListTile(
                value: 'optionSensationalism',
                groupValue: selectedValue,
                contentPadding: const EdgeInsets.all(0.0),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                  });
                },
                title: const Text('Conteúdo Sensacionalista',
                    style: TextStyle(fontSize: 14)),
              ),
              RadioListTile(
                value: 'optionOffensiveContent',
                groupValue: selectedValue,
                contentPadding: const EdgeInsets.all(0.0),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                  });
                },
                title: const Text('Conteúdo Ofensivo ou Inapropriado',
                    style: TextStyle(fontSize: 14)),
              ),
              RadioListTile(
                value: 'optionFraud',
                groupValue: selectedValue,
                contentPadding: const EdgeInsets.all(0.0),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                  });
                },
                title: const Text('Fraude', style: TextStyle(fontSize: 14)),
              ),
              RadioListTile(
                value: 'optionSpam',
                groupValue: selectedValue,
                contentPadding: const EdgeInsets.all(0.0),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                  });
                },
                title: const Text('Spam', style: TextStyle(fontSize: 14)),
              ),
              RadioListTile(
                value: 'optionUnrelatedContent',
                groupValue: selectedValue,
                contentPadding: const EdgeInsets.all(0.0),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                  });
                },
                title: const Text('Conteúdo não Relacionado',
                    style: TextStyle(fontSize: 14)),
              ),
              RadioListTile(
                value: 'optionInappropriateImages',
                groupValue: selectedValue,
                contentPadding: const EdgeInsets.all(0.0),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                  });
                },
                title: const Text('Imagens Inadequadas',
                    style: TextStyle(fontSize: 14)),
              ),
              RadioListTile(
                value: 'optionOther',
                groupValue: selectedValue,
                contentPadding: const EdgeInsets.all(0.0),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value!;
                  });
                },
                title: const Text('Outro ', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 12),
              Text('Comentário (opcional):',
                  style: TextStyle(
                      fontSize: 16,
                      color: ColorsApp.instance.accent,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                style: TextStyles.instance.textInput,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Comentário.'),
                onChanged: (v) => comment = v,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedValue.isNotEmpty
                      ? () {
                          showAdaptiveDialog(
                            context: context,
                            builder: (context) => AlertDialog.adaptive(
                              title: const Text('Confirmar'),
                              content: const Text(
                                  'Deseja enviar esse formulário de denúncia?'),
                              actions: [
                                TextButton(
                                  child: Text(
                                    'Cancelar',
                                    style: TextStyle(
                                        color: ColorsApp.instance.previewText),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: const Text('Enviar'),
                                  onPressed: () {
                                    _submit();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        }
                      : null,
                  child: const Text(
                    'Enviar',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
