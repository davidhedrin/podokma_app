import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:podokma_ecom/providers/auth_provider.dart';
import 'package:podokma_ecom/providers/location_provider.dart';
import 'package:podokma_ecom/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const String id = 'home-screen';
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final locationData = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: Container(),
        title: FlatButton(
          onPressed: (){},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Delivery Address', style: TextStyle(color: Colors.white),),
              Icon(Icons.edit_outlined, color: Colors.white,),
            ],
          ),
        ),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.account_circle_outlined, color: Colors.white,),),
        ],
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search, color: Colors.grey,),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ignore: deprecated_member_use
            RaisedButton(
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
            // ignore: deprecated_member_use
            RaisedButton(
              onPressed: (){
                Navigator.pushNamed(context, WelcomeScreen.id);
              },
              child: Text('Home Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
