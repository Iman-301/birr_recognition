import '../components/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

class PredictionWidget extends StatelessWidget {
  final Size size;
  final String predicted;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final int currentLanguage;
  final void Function(int?)? onToggle;

  const PredictionWidget({
    Key? key,
    required this.size,
    required this.predicted,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.currentLanguage,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * 0.415 - 45,
      decoration: BoxDecoration(
        color: Color(0xaeC4DFDF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        border: Border.all(
          color: Color(0xffC4DFDF),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 34),
          predicted == "Predicting..."
              ? const CircularProgressIndicator(
                  color: Colors.orange,
                )
              : Text(
                  "Predicted: $predicted",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
          const SizedBox(height: 45),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                size: size,
                color: Colors.purple[300]!,
                icon: Icons.camera_alt,
                text: 'Camera',
                onTap: onCameraTap,
              ),
              CustomButton(
                size: size,
                color: Colors.teal[300]!,
                icon: Icons.photo_library,
                text: 'Gallery',
                onTap: onGalleryTap,
              ),
            ],
          ),
          SizedBox(height: 40),
          ToggleSwitch(
            minWidth: 95.0,
            initialLabelIndex: currentLanguage,
            totalSwitches: 3,
            labels: ['Eng', 'Amh 1', 'Amh 2'],
            customTextStyles: [
              TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ],
            activeFgColor: Colors.white,
            inactiveBgColor: Color(0xFFb2d8d8),
            inactiveFgColor: Colors.grey[900],
            activeBgColor: [Colors.purple],
            onToggle: onToggle,
          ),
        ],
      ),
    );
  }
}