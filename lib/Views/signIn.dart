import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'signUp.dart';
import 'list.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInPage();
}

class _SignInPage extends State<SignIn> {
  final myControllerEmail = TextEditingController();
  final myControllerPassword = TextEditingController();

  final RegExp emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tap outside text field
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // ================================
              // Header
              // ================================
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 72.0, left: 24),
                  child: Text(
                    "Sign In",
                    style: TextStyle(fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),

              // ================================
              // Text Fields
              // ================================
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 24, horizontal: 24),
                child: Column(
                  children: [
                    TextField(
                      controller: myControllerEmail,
                      decoration: const InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: CupertinoColors
                              .darkBackgroundGray),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: myControllerPassword,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: CupertinoColors
                                .darkBackgroundGray)
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),

              // ================================
              // Sign In Button
              // ================================
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: ElevatedButton(
                  onPressed: () {
                    // Check fields
                    if (!emailRegex.hasMatch(myControllerEmail.text)) {
                      setState(() {
                        errorMessage = 'Please provide a valid email';
                      });
                    } else {
                      // Reset errors when the email is entered properly
                      setState(() {
                        errorMessage = null;
                      });
                    }
                    // All fields are valid
                    _signInUser(
                        myControllerEmail, myControllerPassword, context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: CupertinoColors.systemGrey,
                  ),
                  child: const Text('Sign In'),
                ),
              ),

              // ================================
              // Sign Up text
              // ================================
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUp(),
                                ),
                              );
                            },
                            child: const Text("Sign Up", style: TextStyle(
                                color: CupertinoColors.black,
                                fontWeight: FontWeight.bold),)
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _signInUser(TextEditingController myControllerEmail,
      TextEditingController myControllerPassword, context) async {
    final String email = myControllerEmail.text.trim();
    final String password = myControllerPassword.text.trim();
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ListPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        setState(() {
          errorMessage = 'Invalid password';
        });
      } else if (e.code == 'user-not-found') {
        setState(() {
          errorMessage = 'No user found with that email';
        });
      } else if (e.code == 'too-many-requests') {
        setState(() {
          errorMessage = 'Too many login attempts. Please try again later.';
        });
      } else {
        setState(() {
          errorMessage = 'An error occurred: $e';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An unexpected error occurred: $e';
      });
    }
  }
}
