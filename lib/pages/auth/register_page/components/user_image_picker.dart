// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sos_app/core/ui/styles/colors_app.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File image) onImagePick;
  final ImageProvider? userImage;
  final bool isEditable;

  const UserImagePicker({
    Key? key,
    required this.onImagePick,
    this.userImage,
    required this.isEditable,
  }) : super(key: key);

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if(pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      widget.onImagePick(_image!); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: ColorsApp.instance.background,
          // ignore: prefer_if_null_operators
          backgroundImage: _image != null ? FileImage(_image!) : (widget.userImage != null ? widget.userImage : null),
        ),
        TextButton(
          onPressed: widget.isEditable ? _pickImage : null,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image,
              ),
              SizedBox(width: 10),
              Text('Adicionar foto de perfil')
            ],
          ),
        ),
      ],
    );
  }
}
