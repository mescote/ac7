import 'package:ac7/Model/RecipeModel.dart';
import 'package:ac7/Views/add.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'RecipeDetailsView.dart';
class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final userLoggedIn = FirebaseAuth.instance.currentUser;
  final _database = FirebaseFirestore.instance;
  late Future<List<RecipeModel>> _futureRecipes;

  @override
  void initState() {
    super.initState();
    _futureRecipes = _getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 0.0, right: 24),
          child: Text("Your Recipes", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
        ),
        backgroundColor: Colors.white,
        centerTitle: false,
        titleSpacing: 24,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddRecipe()),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Recipe List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 24, right: 24, bottom: 24),
              child: FutureBuilder<List<RecipeModel>>(
                future: _getItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 25,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    print('Error fetching recipes: ${snapshot.error}');
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final recipes = snapshot.data;
                    if (recipes != null && recipes.isNotEmpty) {
                      return ListView.builder(
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          return _buildRecipeItem(recipes[index]);
                        },
                      );
                    } else {
                      return const Text('No recipes found.');
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildRecipeItem(RecipeModel recipe) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          recipe.name,
          style: const TextStyle(
            decoration: TextDecoration.none,
          ),
        ),
        subtitle: Text(
          recipe.description,
          style: const TextStyle(
            decoration: TextDecoration.none,
          ),
        ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(recipe.image),
            backgroundColor: Colors.grey,
          ),
          trailing: const Icon(Icons.navigate_next),
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailsView(recipe: recipe),
              ),
            );
          }
      ),
    );
  }

  Future<List<RecipeModel>> _getItems() async {
    setState(() {});
    final snapshot = await _database.collection("Recipes").where("Owner", isEqualTo: userLoggedIn?.email).get();
    final recipes = snapshot.docs.map((e) => RecipeModel.fromSnapshot(e)).toList();
    return recipes;
  }
}
