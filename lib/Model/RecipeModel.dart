

import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeModel{
  final String name;
  final String? owner;
  final String description;
  final String image;

  RecipeModel({
    required this.name,
    required this.owner,
    required this.description,
    required this.image,
  });

  toJson(){
    return{"Name": name, "Owner": owner, "Description": description, "Image": image};
  }

  factory RecipeModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document){
    final data = document.data();
    return RecipeModel(
        name: data?["Name"],
        owner: data?["Owner"],
        description: data?["Description"],
        image: data?["Image"]
    );
  }
}