
import 'package:evs_project/screens/home.dart';
import 'package:evs_project/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/firebase_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  Methods meth= new Methods();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "EVS Project", debugShowCheckedModeBanner: false,
       home: FutureBuilder(future: meth.getCurrentUser(), builder: (context, AsyncSnapshot<User> snapshot)
       {
          if(snapshot.hasData)
          {
              return Home(user: snapshot.data,);
           }
          else return Login();
       }
       )
    );
  }
}
