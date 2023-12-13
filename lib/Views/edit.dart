import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Model/RecipeModel.dart';
import 'package:image_picker/image_picker.dart';
import 'list.dart';

class EditRecipe extends StatefulWidget {
  final RecipeModel recipe;
  const EditRecipe({required this.recipe, Key? key}) : super(key: key);

  @override
  State<EditRecipe> createState() => _EditRecipePage();
}

class _EditRecipePage extends State<EditRecipe> {
  late RecipeModel _recipe;
  final _database = FirebaseFirestore.instance;
  final userLoggedIn = FirebaseAuth.instance.currentUser;
  final myControllerRecipeName = TextEditingController();
  final myControllerDescription = TextEditingController();
  String imageUrl='';
  String? errorMessage, successMessage;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    myControllerRecipeName.text = _recipe.name;
    myControllerDescription.text = _recipe.description;
    return super.initState();
  }

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
            child: Text("Edit Recipe", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
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
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
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
                          hintStyle: TextStyle(fontSize: 14,
                              color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: CupertinoColors.darkBackgroundGray),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                  ),
                ),

                // Create Recipe Button
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
                      // All fields are valid
                      if(errorMessage==null) {
                        await _editRecipe(
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
                    child: const Text('Edit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _editRecipe(TextEditingController myControllerRecipeName,
      TextEditingController myControllerDescription, context) async {
    try {
      final String name = myControllerRecipeName.text.trim();
      final String description = myControllerDescription.text.trim();
      if (name.isEmpty || description.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe cannot have empty values'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      if (imageUrl.isEmpty){
        print(_recipe.image);
        imageUrl=_recipe.image;
      }

      _deleteRecipe();
      RecipeModel recipeModel = RecipeModel(
          name: name, owner: userLoggedIn?.email, description: description, image: imageUrl);

      await _database.collection("Recipes").add(recipeModel.toJson());

      // Clear text fields after successful addition
      myControllerRecipeName.clear();
      myControllerDescription.clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe edit successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      // Handle errors
      print('Error editing recipe: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error editing recipe'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  _deleteRecipe() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Recipes")
        .where("Name", isEqualTo: _recipe.name)
        .get();

    // Check if there's a document with the given name
    if (querySnapshot.docs.isNotEmpty) {
      // Get the first document in the result (assuming there's only one match)
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      // Delete the document by its ID
      await FirebaseFirestore.instance.collection("Recipes").doc(documentSnapshot.id).delete();

      print('Document successfully deleted!');
    } else {
      print('No document found with the specified name.');
    }
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