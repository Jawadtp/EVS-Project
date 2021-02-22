import 'package:flutter/material.dart';
import 'package:evs_project/models/global.dart';
import 'firebase_methods.dart';

class AddQuestion extends StatefulWidget
{
  String quizid;
  AddQuestion({this.quizid});
  @override
  _AddQuestionState createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion>
{
  Methods meth= new Methods();

  GlobalConstants _glob=new GlobalConstants();
  double textfieldspacing=10;
  String question="", option1="", option2="", option3="", option4="";
  final _formKey= GlobalKey<FormState>();

  addQuestion(int x) async
  {
    Map<String, dynamic> m =
    {
      'question':question,
      'option1':option1,
      'option2':option2,
      'option3':option3,
      'option4':option4,
    };
    meth.initialiseQuizStatistic(widget.quizid, question, option1);
    meth.uploadQuestion(m,widget.quizid).then((value)
    {
      _formKey.currentState.reset();
      if(x==1) Navigator.pop(context);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _glob.customAppBar(context), resizeToAvoidBottomInset:false,body:
      Form(key: _formKey,
        child: Container(padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child: Column(children:
          [
            TextFormField(decoration: InputDecoration(hintText: "Enter question"),onChanged: (val){question=val;},validator: (val)
            {
              if(val.isEmpty) return "Please enter a question";
            },),
            SizedBox(height: textfieldspacing,),

            TextFormField(decoration: InputDecoration(hintText: "Enter option 1 (correct answer)"),onChanged: (val){option1=val;},validator: (val)
            {
              if(val.isEmpty) return "Please enter a choice";
            },),
            SizedBox(height: textfieldspacing,),

            TextFormField(decoration: InputDecoration(hintText: "Enter option 2"),onChanged: (val){option2=val;},validator: (val)
            {
              if(val.isEmpty) return "Please enter a choice";
            },),
            SizedBox(height: textfieldspacing,),

            TextFormField(decoration: InputDecoration(hintText: "Enter option 3"),onChanged: (val){option3=val;},validator: (val)
            {
              if(val.isEmpty) return "Please enter a choice";
            },),
            SizedBox(height: textfieldspacing,),

            TextFormField(decoration: InputDecoration(hintText: "Enter option 4"),onChanged: (val){option4=val;},validator: (val)
            {
              if(val.isEmpty) return "Please enter a choice";
            },),
            Spacer(),
            Container(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(50),child:ElevatedButton(onPressed: ()
                  {
                    if(_formKey.currentState.validate()) addQuestion(0);
                  }, child: Container(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),child: Text("Add Question",style: TextStyle(fontSize: 15),))),),
                  Spacer(),
                  ClipRRect(borderRadius: BorderRadius.circular(50),child:ElevatedButton(onPressed: () async
                  {
                    if(_formKey.currentState.validate()) {
                      addQuestion(1);
                    }
                    else Navigator.pop(context);
                  }, child: Container(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),child: Text("Submit Quiz",style: TextStyle(fontSize: 15),))),),
                ],
              ),
            )
          ],),
        ),
      ),);
  }
}
