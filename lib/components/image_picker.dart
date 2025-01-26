import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerWidget extends StatelessWidget {
  final File? selectedImage;
  final Function(ImageSource) onImagePicked;

  const ImagePickerWidget({
    Key? key,
    required this.selectedImage,
    required this.onImagePicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 325,
      width: 325,
      child: DottedBorder(
        padding: const EdgeInsets.all(6),
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        color: Colors.teal,
        strokeWidth: 3,
        dashPattern: const [5, 5],
        child: SizedBox.expand(
          child: FittedBox(
            child: selectedImage != null
                ? Image.file(
                    selectedImage!,
                    fit: BoxFit.cover,
                    width: 300,
                    height: 300,
                  )
                : const Icon(
                    Icons.image_outlined,
                    color: Colors.teal,
                  ),
          ),
        ),
      ),
    );
  }
}