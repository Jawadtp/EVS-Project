import 'package:flutter/material.dart';
import 'firebase_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:evs_project/screens/home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login>
{
  Methods meth= new Methods();

  authenticateUser(User user)
  {
    meth.authenticateUser(user).then((value)
    {
      if(value) meth.uploadData(user).then((value)
      {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Home()));
      });
      else  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Home()));
    });
  }

  signIn()
  {
    meth.signInWithGoogle().then((value)
    {
      if(value==null) print("Sign in returned NULL");
      else
      {
        authenticateUser(value.user);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(
      child: Container(child: Column(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Enviro",style: TextStyle(fontSize: 22,color: Colors.green),),
              Text("Quiz",style: TextStyle(fontSize: 22,color: Colors.lightGreen),),
            ],
          ),
          TextButton(child: Text("Tap to Sign In",style: TextStyle(fontSize: 20),),onPressed: ()
          {
            signIn();
          },),
        ],
      ),),
    ),);
  }
}

