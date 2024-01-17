import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';

class MultiImagePicker extends StatefulWidget {
  final void Function(List<File> images) onImagesPick;
  const MultiImagePicker({super.key, required this.onImagesPick});

  @override
  State<MultiImagePicker> createState() => _MultiImagePickerState();
}

class _MultiImagePickerState extends State<MultiImagePicker> {
  final controller = MultiImagePickerController(
      maxImages: 3,
      allowedImageTypes: ['png', 'jpg', 'jpeg'],
      withReadStream: true,
      images: <ImageFile>[] // array of pre/default selected images
      );
    
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  
  Future<void> _pickImages() async {
    final List<File> imagesList = [];
    final images = controller.images;

    for(final image in images) {
      if(image.hasPath) {
        imagesList.add(File(image.path!));
      }
    }

    widget.onImagesPick(imagesList); 
  }

  @override
  Widget build(BuildContext context) {
    return MultiImagePickerView(
      controller: controller,
      draggable: true,
      showAddMoreButton: true,
      showInitialContainer: true,
      initialContainerBuilder: (context, pickerCallback) {
        return GestureDetector(
          onTap: pickerCallback,
          child: Container(
            width: 64, // Defina a largura desejada do botão
            height: 64, // Defina a altura desejada do botão
            decoration: BoxDecoration(
              border: Border.all(
                  color: ColorsApp.instance.previewText), // Borda cinza
              color: Colors.white, // Fundo branco
              borderRadius: BorderRadius.circular(8.0), // Borda arredondada
            ),
            child: Center(
              child: Icon(
                Icons.add,
                color: ColorsApp.instance.accent, // Ícone cinza
              ),
            ),
          ),
        );
      },
      addMoreBuilder: (context, pickerCallback) {
        return GestureDetector(
          onTap: pickerCallback,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: ColorsApp.instance.previewText), // Borda cinza
              color: Colors.white, // Fundo branco
              borderRadius: BorderRadius.circular(8.0), // Borda arredondada
            ),
            child: Center(
              child: Icon(
                Icons.add,
                color: ColorsApp.instance.accent, // Ícone cinza
                size: 40,
              ),
            ),
          ),
        );
      },
      onChange: (images) {
        _pickImages();
      },
    );
  }
}
