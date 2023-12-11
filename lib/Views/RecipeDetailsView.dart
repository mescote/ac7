import 'package:ac7/Views/list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Model/RecipeModel.dart';

class RecipeDetailsView extends StatefulWidget {
  final RecipeModel recipe;
  const RecipeDetailsView({required this.recipe, Key? key}) : super(key: key);

  @override
  State<RecipeDetailsView> createState() => _RecipeDetailsViewPage();
}

class _RecipeDetailsViewPage extends State<RecipeDetailsView> {
  late RecipeModel _recipe;
  final double coverHeight = 280;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 0.0, right: 24),
          child: Text("Recipe Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
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
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Colors.grey,
            child: Image.network(_recipe.image,
              width: double.infinity,
              height: coverHeight,
              fit: BoxFit.cover,
            ),
          ),

          // Text Fields
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0, left: 24),
              child: Text(_recipe.name,
                style: TextStyle(fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 24),
              child: Text(_recipe.description,
                style: TextStyle(fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Check fields
                      /*
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditRecipe(recipe: _recipe),
                        ),
                      );
                      */
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: CupertinoColors.systemGrey,
                    ),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Wrap(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Check fields
                      await _deleteRecipe();
                      setState(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListPage(),
                          ),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
}