// lib/screens/home_page.dart
import 'package:attandance/widgets/gps_info.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? photoPath;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: ListView(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: screenSize.width * 0.60),
            child: Container(
              margin: EdgeInsets.only(
                top: 20,
                left: screenSize.width * 0.15,
                right: screenSize.width * 0.15,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: photoPath != null
                    ? Image.file(
                        File(photoPath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Center(child: Text("Your photo will be here")),
              ),
            ),
          ),
          GpsInfo(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final ImagePicker imagePicker = ImagePicker();
          final XFile? photo = await imagePicker.pickImage(
            source: ImageSource.camera,
          );

          if (photo != null) {
            setState(() {
              setState(() {
                photoPath = photo.path;
              });
            });
          }
        },
        child: const Icon(Icons.linked_camera),
      ),
    );
  }
}
