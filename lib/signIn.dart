import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'signUp.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInPage();
}

class _SignInPage extends State<SignIn> {
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
                  padding: const EdgeInsets.only(top: 96.0, left: 24),
                  child: _header(context),
                ),
              ),

              // ================================
              // Text Fields
              // ================================
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                child: _inputField(context),
              ),

              // ================================
              // Sign In Button
              // ================================
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _signin(context),
              ),

              // ================================
              // Sign Up text
              // ================================
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _signup(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

_header(context) {
  return const Column(
    children: [
      Text(
        "Sign In",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    ],
  );
}

_inputField(context) {
  return const Column(
    children: [
      TextField(
        //autofocus: true,
        decoration: InputDecoration(
          hintText: "Username",
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: CupertinoColors.darkBackgroundGray),
          ),
        ),
      ),
      SizedBox(height: 12),

      TextField(
        //autofocus: true,
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Password",
          hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: CupertinoColors.darkBackgroundGray)
          ),
        ),
      ),
      SizedBox(height: 12),
    ],
  );
}


_signin(context) {
  return ElevatedButton(
    onPressed: _saveRecipe,
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, backgroundColor: CupertinoColors.systemGrey,
      minimumSize: Size(84, 32),
    ),
    child: Text('Sign In'),
  );
}

_signup(context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Don't have an account? "),
      TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignUp(),
              ),
            );
          },
          child: const Text("Sign Up", style: TextStyle(color: CupertinoColors.black, fontWeight: FontWeight.bold),)
      )
    ],
  );
}


_saveRecipe() {

}