import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'firebase_options.dart'; // Import Firebase options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Royal Movie Details Form',
      theme: ThemeData(
        fontFamily: 'Georgia',
        primaryColor: Colors.black,
      ),
      home: MovieDetailsForm(),
    );
  }
}

class CastController extends GetxController {
  var castMembers = <Map<String, dynamic>>[].obs;

  void addCastMember() {
    castMembers.add({'imageBytes': null, 'name': ''});
  }

  Future<void> pickImage(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      // Declare name variable
      String name = '';

      // Open dialog to get name after image selection
      name = await Get.dialog(
        AlertDialog(
          title: Text('Enter Cast Member Name'),
          content: TextField(
            onChanged: (value) {
              name = value;
            },
            decoration: InputDecoration(hintText: "Name"),
          ),
          actions: [
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                if (name.isNotEmpty) {
                  Get.back(
                      result: name); // Close the dialog and return the name
                }
              },
            ),
          ],
        ),
      );

      if (name.isNotEmpty) {
        castMembers[index] = {
          'imageBytes': result.files.single.bytes,
          'name': name,
        };
      }
    }
  }
}

class MovieDetailsForm extends StatelessWidget {
  final CastController _controller = Get.put(CastController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFFFD700), width: 2),
                ),
              ),
              child: Text(
                'Enter Movie Details',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
            ),
            SizedBox(height: 30),
            Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextField('Movie Name', 'Please enter a movie name'),
                  SizedBox(height: 16),
                  buildTextField(
                    'Director Name',
                    'Please enter the director\'s name',
                    validator: (value) {
                      if (value == null || value.length < 3) {
                        return 'Director\'s name must be at least 3 letters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  buildTextField(
                    'Producer Email',
                    'Please enter a valid email address',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final emailRegex =
                          RegExp(r'^[\w-]+@[a-zA-Z]+\.[a-zA-Z]+$');
                      return emailRegex.hasMatch(value ?? '')
                          ? null
                          : 'Enter a valid email address';
                    },
                  ),
                  SizedBox(height: 16),
                  buildTextField(
                    'Producer Phone Number',
                    'Enter a valid 10-digit phone number',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) => (value != null && value.length == 10)
                        ? null
                        : 'Phone number must be exactly 10 digits',
                  ),
                  SizedBox(height: 30),

                  Center(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.black, // Black background
                        border: Border(
                          left: BorderSide(
                              color: Color(0xFFFFD700),
                              width: 4.0), // Yellow left border
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Cast Members',
                            style: TextStyle(
                                color: Color(0xFFFFD700), fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Horizontal list of cast member containers
                  Obx(() => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _controller.castMembers
                              .asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key;
                            var castMember = entry.value;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: GestureDetector(
                                onTap: () => _controller.pickImage(index),
                                child: Stack(
                                  alignment: Alignment
                                      .bottomCenter, // Align at the bottom
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
                                        image: castMember['imageBytes'] != null
                                            ? DecorationImage(
                                                image: MemoryImage(
                                                    castMember['imageBytes']),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: (castMember['imageBytes'] == null)
                                          ? Icon(Icons.add_a_photo,
                                              color: Color(0xFFFFD700))
                                          : Container(),
                                    ),
                                    // Display name at the bottom of the image
                                    if (castMember['name'] != null &&
                                        castMember['name']!.isNotEmpty)
                                      Container(
                                        width:
                                            80, // Use the same width as the circular container
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(
                                              0.7), // Transparent black
                                          borderRadius: BorderRadius.circular(
                                              40), // Rounded corners for circular effect
                                        ),
                                        padding: EdgeInsets.all(
                                            4), // Padding for name
                                        child: Text(
                                          castMember['name'],
                                          style: TextStyle(
                                            color: Colors
                                                .white, // White text for better readability
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )),
                  SizedBox(height: 16),

                  Center(
                    child: ElevatedButton(
                      onPressed: _controller.addCastMember,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Color(0xFFFFD700),
                      ),
                      child: Text('Add Cast Member'),
                    ),
                  ),

                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Color(0xFFFFD700),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                      onPressed: () {
                        // Validation logic for the form can be implemented here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Form Submitted Successfully')),
                        );
                      },
                      child: Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    String errorMessage, {
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator ?? (value) => value!.isEmpty ? errorMessage : null,
      style: TextStyle(color: Color(0xFFFFD700)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFFFFD700), fontSize: 18),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFD700), width: 2),
        ),
      ),
    );
  }
}
