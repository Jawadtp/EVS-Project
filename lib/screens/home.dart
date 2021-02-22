import 'package:evs_project/screens/create_quiz.dart';
import 'package:evs_project/screens/login.dart';
import 'package:evs_project/screens/quizplay.dart';
import 'package:evs_project/screens/quizresult.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:evs_project/screens/firebase_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:evs_project/screens/create_quiz.dart';


class Home extends StatefulWidget
{
  Home({this.user});
  User user;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
{


  Methods meth= new Methods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    meth.getCurrentUser().then((value)
    {
      if(widget.user==null)
        setState(() {
          widget.user=value;

        });
      meth.uploadLastLoginTime(value);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(floatingActionButton: (widget.user==null)?Container():StreamBuilder(stream: meth.isAdmin2(widget.user), builder: (context, snapshot)
    {
      if (snapshot.data == null) {
        return CircularProgressIndicator();
      }
      else {
        return snapshot.data.docs[0].get('admin') ? FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(
                builder: (BuildContext context) => CreateQuiz()));
          }, child: Icon(Icons.add),) : Container(child: Text("Not admin"),);
      }
    },),
      appBar: AppBar(centerTitle:true,title: Text("EnviroQuiz",style: TextStyle(color: Colors.lightBlue),), elevation: 0.0, backgroundColor: Colors.transparent,actions:
      [
        IconButton(icon: Icon(Icons.logout, color: Colors.red,), onPressed: ()
        {
          meth.signOut().then((value)
          {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (BuildContext context) => Login()));
          });

        }),
      ],),body: Center(child: StreamBuilder(stream: meth.getQuizzes(), builder: (context, snapshot)
      {
        return !snapshot.hasData?Container():ListView.builder(itemCount: snapshot.data.docs.length, itemBuilder: (context, index)
        {

          return QuizTile(title: snapshot.data.docs[index].get('title'), description: snapshot.data.docs[index].get('description'), author: snapshot.data.docs[index].get('author'), questioncount: snapshot.data.docs[index].get('questioncount'), url: snapshot.data.docs[index].get('url'),);
        });
      },)),);
  }
}


class QuizTile extends StatelessWidget
{
  Methods meth= new Methods();

  String author, description, title, url;
  int questioncount;
  QuizTile({this.description, this.title, this.author, this.questioncount, this.url});
  @override
  Widget build(BuildContext context)
  {
    return InkWell(
      onTap: ()
      {
        meth.getCurrentUser().then((value)
        {
            meth.hasUserAttempted(value.displayName, title).then((val)
            {
              if(val) Navigator.push(
                  context, MaterialPageRoute(
                  builder: (BuildContext context) => QuizResult(quizid: title, user: value,)));
              else  Navigator.push(
                  context, MaterialPageRoute(
                  builder: (BuildContext context) => QuizPlay(quizid: title)));
            });
        });

      },
      child: Container(height: 200,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Stack(children: [
          ClipRRect(borderRadius: BorderRadius.circular(15),
              child: Image.network(url, fit: BoxFit.cover, width: MediaQuery
                  .of(context)
                  .size
                  .width)),
          Center(
            child: ClipRRect(borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                color: Colors.black54,
                child: Column(children: [
                  Spacer(),
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white),),
                  SizedBox(height: 8),
                  Text(description, textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: Colors.white),),
                  Spacer(),
                  Row(children: [
                    Text(questioncount.toString()+((questioncount>1)?" questions":" question"), style: TextStyle(fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.white),),
                    Spacer(),
                    Text("By "+author, style: TextStyle(fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.white),),
                  ],)
                ],),
              ),
            ),
          )
        ],),),
    );
  }
}
