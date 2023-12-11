import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Model/RecipeModel.dart';
import 'package:image_picker/image_picker.dart';
import 'list.dart';


class AddRecipe extends StatefulWidget {
  const AddRecipe({Key? key}) : super(key: key);

  @override
  State<AddRecipe> createState() => _AddRecipePage();
}

class _AddRecipePage extends State<AddRecipe> {
  final _database = FirebaseFirestore.instance;
  final userLoggedIn = FirebaseAuth.instance.currentUser;
  final myControllerRecipeName = TextEditingController();
  final myControllerDescription = TextEditingController();
  String imageUrl='';
  String? errorMessage, successMessage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tap outside text field
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.only(top: 0.0, right: 24),
            child: Text("Add Recipe", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          ),
          backgroundColor: Colors.white,
          centerTitle: false,
          titleSpacing: 24,
          actions: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Text Fields
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 24),
                  child: Column(
                    children: [
                      TextField(
                        controller: myControllerRecipeName,
                        decoration: const InputDecoration(
                          hintText: "Recipe Name",
                          hintStyle: TextStyle(fontSize: 14,
                              color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: CupertinoColors.darkBackgroundGray),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: myControllerDescription,
                        maxLines: 10,
                        maxLength: 100,
                        decoration: const InputDecoration(
                          hintText: "Recipe Description",
                          hintStyle: TextStyle(fontSize: 14,
                              color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: CupertinoColors.darkBackgroundGray),
                          ),
                        ),
                      ),

                      if (errorMessage != null)
                        Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      if (successMessage != null)
                        Text(
                          successMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),

                // Image
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child:
                  ColoredBox(
                    color: Colors.white,
                    child: SizedBox(
                      height: 42,
                      child: IconButton(
                        icon: const Icon(CupertinoIcons.camera),
                        color: Colors.black,
                        onPressed: () {
                          _pickImageFromGallery();
                        },
                      )
                    ),
                  ),
                ),

                // Create Recipe Button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child:
                  ElevatedButton(
                    onPressed: () async {
                      // Check fields
                      if (myControllerRecipeName.text.isEmpty) {
                        setState(() {
                          errorMessage = 'Please provide a name';
                        });
                      } else if (myControllerDescription.text.isEmpty) {
                        setState(() {
                          errorMessage = 'Please provide a description';
                        });
                      } else {
                        setState(() {
                          errorMessage = null;
                        });
                      }
                      if (errorMessage == null) {
                        // All fields are valid
                        await _createRecipe(
                            myControllerRecipeName, myControllerDescription,
                            context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListPage(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: CupertinoColors.systemGrey,
                    ),
                    child: const Text('Add Recipe'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _createRecipe(TextEditingController myControllerRecipeName,
      TextEditingController myControllerDescription, context) async {
    try {
      final String name = myControllerRecipeName.text.trim();
      final String description = myControllerDescription.text.trim();
      bool isRepeated = await _recipeExists(name);
      if (name.isEmpty || description.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe cannot have empty values'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      if(isRepeated){
        // Handle repeated recipes or existing recipe if needed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This recipe already exists!'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if(imageUrl.isEmpty){
        imageUrl = "https://previews.123rf.com/images/dapoomll/dapoomll1307/dapoomll130700007/21260096-seamless-wallpaper-with-fast-food.jpg";
        File returnedImage = File(imageUrl);

        if(returnedImage==null) return;

        String uniqueFileName=DateTime.now().microsecondsSinceEpoch.toString();

        Reference referenceRoot = FirebaseStorage.instance.ref();
        Reference referenceDirImages = referenceRoot.child('images');
        Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

        try{
          await referenceImageToUpload.putFile(File(returnedImage!.path));
          imageUrl = await referenceImageToUpload.getDownloadURL();
        }catch(error){
          //some error
        }
      }
      RecipeModel recipeModel = RecipeModel(name: name, owner: userLoggedIn?.email, description: description, image: imageUrl);
      await _database.collection("Recipes").add(recipeModel.toJson());

      // Clear text fields after successful addition
      myControllerRecipeName.clear();
      myControllerDescription.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe created successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      // Handle errors
      print('Error creating recipe: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error creating recipe'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool> _recipeExists(String name) async {
    final querySnapshot = await _database
        .collection("Recipes")
        .where('Name', isEqualTo: name).where('Owner', isEqualTo: userLoggedIn?.email)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future _pickImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? returnedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    print('${returnedImage?.path}');

    if(returnedImage==null) return;

    String uniqueFileName=DateTime.now().microsecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    try{
      await referenceImageToUpload.putFile(File(returnedImage!.path));
      imageUrl = await referenceImageToUpload.getDownloadURL();
    }catch(error){
      //some error
    }
  }
}