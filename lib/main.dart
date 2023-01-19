import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pinterest_clone/home_screen.dart';
import 'package:pinterest_clone/log_in/login_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';



Future<void> main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
          builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Center(
                    child: Text('Welcome to the ArtCloud'),
                  ),
                ),
              ),
            );
            }else if (snapshot.hasError){
            return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: Center(
                      child: Center(
                        child: Text('An error has occurred, please wait'),
                      ),
                  ),
                ),
            );
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ArtCloud',
            theme: ThemeData(
              scaffoldBackgroundColor: Color(0xFFEDE7DC),
              primarySwatch: Colors.blue,
            ),
            home: FirebaseAuth.instance.currentUser == null ? LoginScreen() : HomeScreen(),
          );

          },
    );


  }
}
