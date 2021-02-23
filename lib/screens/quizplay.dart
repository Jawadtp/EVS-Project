import 'package:evs_project/screens/quizresult.dart';
import 'package:evs_project/screens/surveyresult.dart';
import 'package:flutter/material.dart';
import 'package:evs_project/models/global.dart';
import 'firebase_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizPlay extends StatefulWidget
{
  String quizid;
  String type;
  QuizPlay({this.quizid, this.type});
  @override
  _QuizPlayState createState() => _QuizPlayState();
}

class _QuizPlayState extends State<QuizPlay>
{
  GlobalConstants glob= new GlobalConstants();
  bool HasUserAttempted=false;
  User user;
  Methods meth = new Methods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    meth.getCurrentUser().then((value)
    {
      meth.hasUserAttempted(value.displayName, widget.quizid).then((val)
      {
        setState(() {
          HasUserAttempted=val;
        });

      });
      setState(() {
        user=value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: glob.customAppBar(context),body: StreamBuilder(stream: meth.getQuestions(widget.quizid), builder: (context, snapshot)
    {
      return !snapshot.hasData?Container():ListView.builder(itemCount: snapshot.data.docs.length, cacheExtent: snapshot.data.docs.length*500.toDouble(), itemBuilder: (context, index)
      {
        List<String> options = [snapshot.data.docs[index].data()['option1'], snapshot.data.docs[index].data()['option2'], snapshot.data.docs[index].data()['option3'], snapshot.data.docs[index].data()['option4'],];
        options.shuffle();
        return QuestionTile(question: snapshot.data.docs[index].data()['question'], correctanswer: snapshot.data.docs[index].data()['option1'], options: options, index: index, isLast: (snapshot.data.docs.length-1==index),user: user, quizid: widget.quizid, type: widget.type,);
      },);
    },),);
  }
}

class QuestionTile extends StatefulWidget
{
  List<String> options;
  String question, correctanswer, quizid, type;
  int index; bool isLast;
  User user;
  QuestionTile({this.question, this.correctanswer, this.options, this.index, this.isLast, this.user, this.quizid, this.type});
  @override
  _QuestionTileState createState() => _QuestionTileState();
}

class _QuestionTileState extends State<QuestionTile> {
  double optionDistance=10;
  String selected;
  bool isButtonDisabled=false;
  Methods meth = new Methods();


  updateUserChoice(int qno) {
    if (widget.type != "Survey") {
      Map<String, dynamic> m =
      {
        'question': widget.question,
        'selected': widget.options[qno - 1],
        'correct': widget.correctanswer,
        'option1': widget.options[0],
        'option2': widget.options[1],
        'option3': widget.options[2],
        'option4': widget.options[3]
      };

      meth.uploadUserAttempt(m, widget.quizid, widget.user, widget.index + 1);
    }
    else
      {
        meth.setSurveySelectedOption(widget.quizid, widget.question, widget.options[qno - 1]);
        setState(() {
          isButtonDisabled=true;
        });
      }
  }




  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.symmetric(horizontal: 15), margin: EdgeInsets.symmetric(vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children:
          [
            Text("Q"+(widget.index+1).toString()+" "+widget.question,softWrap: true,style: TextStyle(fontSize: 20),),
            SizedBox(height: 20,),

            InkWell(onTap: isButtonDisabled?null:(){setState(() {selected="A";updateUserChoice(1);});},child: OptionTile(desc: widget.options[0], option: "A", isSelected: selected=="A",)),
            SizedBox(height: optionDistance),

            InkWell(onTap: isButtonDisabled?null:(){setState(() {selected="B";updateUserChoice(2);});},child: OptionTile(desc: widget.options[1], option: "B", isSelected: selected=="B",)),
            SizedBox(height: optionDistance),

            InkWell( onTap: isButtonDisabled?null:(){setState(() {selected="C";updateUserChoice(3);});},child: OptionTile(desc: widget.options[2], option: "C", isSelected: selected=="C",)),
            SizedBox(height: optionDistance),

            InkWell(onTap: isButtonDisabled?null:(){setState(() {selected="D";updateUserChoice(4);});},child: OptionTile(desc: widget.options[3], option: "D", isSelected: selected=="D",)),

            SizedBox(height: optionDistance + ((widget.isLast)?20:0)),
            !widget.isLast?Container():Center(child: ElevatedButton(onPressed: ()
            {
              if(widget.type!="Survey")
                  setState(()
                {

                  meth.addToLog(widget.user.displayName + " has finished attempting " + widget.quizid);
                  meth.uploadQuestionStatistic(widget.quizid, widget.user.displayName);
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(
                      builder: (BuildContext context) => QuizResult(quizid: widget.quizid, user: widget.user,)));
                });
              else
                {
                  meth.addUserAttemptForSurvey(widget.quizid, widget.user);
                  meth.addToLog(widget.user.displayName + " has filled out the survey " + widget.quizid);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(title: Text("Thank you!"), content: Text("Your responses have been stored in our database."), actions:
                        [
                          TextButton(child: Text("Continue"), onPressed: (){
                            Navigator.pop(context);
                            Navigator.push(
                              context, MaterialPageRoute(
                              builder: (BuildContext context) => SurveyResult(quizid: widget.quizid,)));},),
                        ],);
                      });


                  /*
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(
                      builder: (BuildContext context) => SurveyResult(quizid: widget.quizid,)));   */
                }
            }, child: Text("Finish Attempt"),))
          ],));
  }
}

class OptionTile extends StatefulWidget {
  String desc, option;
  bool isSelected;
  OptionTile({this.desc,this.option, this.isSelected});
  @override
  _OptionTileState createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> {

  @override
  Widget build(BuildContext context) {
    return Container(padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: widget.isSelected?Color(0xFFc16bfa):Color(0xFFdae3e1)),
      child: Row(children: [
        Container(alignment:Alignment.center, width:30,height:30, padding: EdgeInsets.all(5),decoration: BoxDecoration(color: Colors.white, borderRadius:BorderRadius.circular(60),),child:
        Text(widget.option,style: TextStyle(fontSize: 18,color: Colors.black),),),
        SizedBox(width: 10,),
        Expanded(child: Text(widget.desc,style: TextStyle(fontSize: 16,color: Colors.black),softWrap: true,)),
      ],),);
  }
}
