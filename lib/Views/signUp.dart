import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'signIn.dart';
import 'list.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUp> {
  final myControllerEmail = TextEditingController();
  final myControllerPassword = TextEditingController();
  final myControllerConfirmation = TextEditingController();

  final RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
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
                    "Sign Up",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),

              // ================================
              // Text Fields
              // ================================
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                child: Column(
                  children: [
                    TextField(
                      controller: myControllerEmail,
                      decoration: const InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: CupertinoColors.darkBackgroundGray),
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
                            borderSide: BorderSide(color: CupertinoColors.darkBackgroundGray)
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: myControllerConfirmation,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: "Confirm Password",
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: CupertinoColors.darkBackgroundGray)
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
              // Sign Un Button
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
                    } else if (myControllerPassword.text != myControllerConfirmation.text) {
                      setState(() {
                        errorMessage = 'Passwords do not match';
                      });
                    } else {
                      setState(() {
                        errorMessage = null;
                      });
                    }
                    // All fields are valid
                    _signUpUser(myControllerEmail, myControllerPassword, myControllerConfirmation, context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: CupertinoColors.systemGrey,
                  ),
                  child: const Text('Sign Up'),
                ),
              ),

              // ================================
              // Sign In text
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
                                  builder: (context) => SignIn(),
                                ),
                              );
                            },
                            child: const Text("Sign In", style: TextStyle(color: CupertinoColors.black, fontWeight: FontWeight.bold),)
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

  _signUpUser(TextEditingController myControllerEmail, TextEditingController myControllerPassword, TextEditingController myControllerConfirmation, context) async {
    final String email = myControllerEmail.text.trim();
    final String password = myControllerPassword.text.trim();

    if (errorMessage == null) {
      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ListPage(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          setState(() {
            errorMessage = 'The password provided is too weak.';
          });
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            errorMessage = 'This account already exists.';
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'An error occurred: $e';
        });
      }
    }
  }
}




