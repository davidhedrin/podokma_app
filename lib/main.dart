import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:podokma_ecom/providers/auth_provider.dart';
import 'package:podokma_ecom/providers/location_provider.dart';
import 'package:podokma_ecom/screens/homeScreen.dart';
import 'package:podokma_ecom/screens/login_screen.dart';
import 'package:podokma_ecom/screens/map_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        fontFamily: 'Lato',
      ),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id : (context) => SplashScreen(),
        HomeScreen.id : (context) => HomeScreen(),
        WelcomeScreen.id : (context) => WelcomeScreen(),
        MapScreen.id : (context) => MapScreen(),
        LoginScreen.id : (context) => LoginScreen(),
      },
    );
  }
}