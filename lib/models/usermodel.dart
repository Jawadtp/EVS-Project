import 'package:firebase_auth/firebase_auth.dart';

class UserModel
{
  String name, photoURL, email, uid;
  bool admin;
  UserModel({this.name, this.photoURL, this.email, this.uid, this.admin});

  Map<String, dynamic> getMapfromUser()
  {
    Map<String, dynamic> m =
    {
      'name':this.name,
      'email':this.email,
      'uid':this.uid,
      'photoURL':this.photoURL,
      'admin':this.admin,
    };
    return m;
  }
}