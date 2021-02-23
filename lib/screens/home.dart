import 'package:evs_project/screens/adminpanel.dart';
import 'package:evs_project/screens/create_quiz.dart';
import 'package:evs_project/screens/login.dart';
import 'package:evs_project/screens/quizplay.dart';
import 'package:evs_project/screens/quizresult.dart';
import 'package:evs_project/screens/surveyresult.dart';
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
          }, child: Icon(Icons.add),) : Container();
      }
    },),
      appBar: AppBar(centerTitle:true,title: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder(stream: meth.isAdmin2(widget.user), builder:(context, snapshot){
            return !snapshot.hasData?Container():snapshot.data.docs[0].get('admin')?IconButton(icon: Icon(Icons.admin_panel_settings_outlined,color: Colors.lightBlue, size: 30,),onPressed: (){
              meth.addToLog(widget.user.displayName+ " has accessed the admin panel");
              Navigator.push(
            context, MaterialPageRoute(builder: (BuildContext context) => AdminPanel()));
              },):Container();
          }),
          Spacer(),
          Text("Enviro",style: TextStyle(color: Colors.green),),
          Text("Quiz",style: TextStyle(color: Colors.brown),),
          SizedBox(width: 14,),
          Spacer(),
        ],
      ), elevation: 0.0, backgroundColor: Colors.transparent,actions:
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

          return QuizTile(title: snapshot.data.docs[index].get('title'), description: snapshot.data.docs[index].get('description'), author: snapshot.data.docs[index].get('author'), questioncount: snapshot.data.docs[index].get('questioncount'), url: snapshot.data.docs[index].get('url'),type: snapshot.data.docs[index].get('type'),);
        });
      },)),);
  }
}


class QuizTile extends StatelessWidget
{
  Methods meth= new Methods();

  String author, description, title, url, type;
  int questioncount;
  QuizTile({this.description, this.title, this.author, this.questioncount, this.url, this.type});
  @override
  Widget build(BuildContext context)
  {
    return InkWell(
      onTap: ()
      {
        meth.getCurrentUser().then((value)
        {
          if(type=="Survey")
            {
              meth.checkIfUserAttemptedSurvey(title, value).then((val)
              {
                if(val) {
                  meth.addToLog(value.displayName + " is viewing '"+title+"' survey's result");
                  Navigator.push(
                      context, MaterialPageRoute(
                      builder: (BuildContext context) =>
                          SurveyResult(quizid: title,)));
                  }
                  else
                    {
                      meth.addToLog(value.displayName + " is filling the survey '"+title+"' now");
                      Navigator.push(
                          context, MaterialPageRoute(
                          builder: (BuildContext context) =>
                              QuizPlay(quizid: title, type: type,)));
                    }
              });
            }
          else {
            meth.hasUserAttempted(value.displayName, title).then((val) {
              if (val) {
                meth.addToLog(value.displayName+" is checking the result of the quiz "+title);
                Navigator.push(
                    context, MaterialPageRoute(
                    builder: (BuildContext context) =>
                        QuizResult(quizid: title, user: value,)));
              }
              else {
                meth.addToLog(value.displayName+" has started attemping the quiz "+title);
                Navigator.push(
                    context, MaterialPageRoute(
                    builder: (BuildContext context) =>
                        QuizPlay(quizid: title, type: type,)));
              }
            });
          }
        });

      },
      child: Container(height: 200,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), margin: EdgeInsets.symmetric(horizontal: 4),


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
                    Container(padding: EdgeInsets.only(bottom: 5),
                      child: Column(
                        children: [
                          Container(padding: EdgeInsets.symmetric(horizontal: 2,vertical: 2), margin: EdgeInsets.only(bottom: 2),child: Text(type,style: TextStyle(color: Colors.white, fontSize: 11,fontWeight: FontWeight.bold),),decoration: BoxDecoration(border: Border.all(width: 0.5,color: Colors.white),borderRadius: BorderRadius.circular(4)),),
                          Text(questioncount.toString()+((questioncount>1)?" questions":" question"), style: TextStyle(fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Colors.white),),
                        ],
                      ),
                    ),
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
