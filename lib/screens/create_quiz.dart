import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evs_project/screens/addquestion.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_methods.dart';
import 'dart:io';


class CreateQuiz extends StatefulWidget {
  @override
  _CreateQuizState createState() => _CreateQuizState();
}

class _CreateQuizState extends State<CreateQuiz> {

  bool mode=false;
  final _formKey= GlobalKey<FormState>();
  Methods meth= new Methods();

  String title="", description="";
  User user;
  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  uploadQuiz() async
  {

    final Reference sref = FirebaseStorage.instance.ref()
        .child('QuizImages')
        .child(title);

    final UploadTask storageUploadTask = sref.putFile(
      _image

      );
    await storageUploadTask.whenComplete(() async
    {
      sref.getDownloadURL().then((value)
      {
        Map<String, dynamic> m =
        {
          'title':title,
          'description':description,
          'author':user.displayName,
          'url':value,
          'questioncount': 0,
          'type': mode?"Survey":"Quiz",
          'time': FieldValue.serverTimestamp(),
        };
        meth.uploadQuiz(m).then((value)
        {
          Navigator.pushReplacement(
              context, MaterialPageRoute(
              builder: (BuildContext context) => AddQuestion(quizid: title, mode: mode,)));
        });
      });
    });



  }

  @override
  void initState()
  {

    super.initState();
    meth.getCurrentUser().then((value)
    {
      setState(() {
        user=value;
      });
    });
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(resizeToAvoidBottomInset:false,appBar: AppBar(elevation: 0, centerTitle:true,leading: BackButton(color: Colors.black,),backgroundColor: Colors.transparent, title: Row(mainAxisAlignment: MainAxisAlignment.center,
      children:
      [

        Text('Enviro',style: TextStyle(color: Colors.green),),
        Text('Quiz',style: TextStyle(color: Colors.grey),),
        SizedBox(width: MediaQuery.of(context).size.width/6.5,)
      ],),),body: Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Form(key: _formKey,
          child: Column(children:
    [
          TextFormField(decoration: InputDecoration(hintText: !mode?"Quiz Title":"Survey Title"),onChanged: (val){title=val;},validator: (val)
          {
            if(val.isEmpty) return 'Please enter a title';
          }),
           SizedBox(height: 5),
          TextFormField(decoration: InputDecoration(hintText: !mode?"Describe your quiz in a sentence":"Describe your survey in a sentence"),onChanged: (val){description=val;},validator: (val)
          {
            if(val.isEmpty) return 'Please enter a suitable description';
          },),
          SizedBox(height: 30,),
          OutlinedButton(onPressed: (){getImage();}, child: Text(!mode?"Pick a background image for your quiz":"Pick a background image for your survey")),
          SizedBox(height: 30,),
          _image==null?Container():Container(height: MediaQuery.of(context).size.height/4, width:MediaQuery.of(context).size.width,child: ClipRRect(borderRadius:BorderRadius.circular(20),child: Image.file(_image,fit: BoxFit.fill,))),

         Text(!mode?"Switch to survey mode":"Switch to quiz mode",style: TextStyle(fontSize: 15),),
         Switch(onChanged: (val){setState(() {mode=val;});}, value: mode,),

          Spacer(),

          ClipRRect(borderRadius: BorderRadius.circular(50),child:ElevatedButton(onPressed: ()
          {
            print("Upload quiz");
            if(_formKey.currentState.validate()) uploadQuiz();
          }, child: Container(padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),child: Text(!mode?"Create Quiz":"Create Survey",style: TextStyle(fontSize: 15),))),)
    ],),
        ),
      ) );
  }
}
