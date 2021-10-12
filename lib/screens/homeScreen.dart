import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:podokma_ecom/providers/auth_provider.dart';
import 'package:podokma_ecom/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String id = 'home-screen';
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Center(
        // ignore: deprecated_member_use
        child: RaisedButton(
          onPressed: (){
            auth.error = '';
            FirebaseAuth.instance.signOut().then((value){
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => WelcomeScreen(),
              ),);
            });
          },
          child: Text('Sign Out'),
        ),
      ),
    );
  }
}