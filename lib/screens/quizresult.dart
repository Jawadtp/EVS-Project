import 'dart:ffi';
import 'quizstats.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:evs_project/models/global.dart';
import 'firebase_methods.dart';
import 'halloffame.dart';

class QuizResult extends StatefulWidget
{
  String quizid;
  User user;
  QuizResult({this.quizid, this.user});
  @override
  _QuizResultState createState() => _QuizResultState();
}

class _QuizResultState extends State<QuizResult> with AutomaticKeepAliveClientMixin
{
  @override
  bool get wantKeepAlive => true;

  int score=0, totalqs=0, attempted=0;
  GlobalConstants glob= new GlobalConstants();
  Methods meth= new Methods();
  Stream quizStream;
  @override
  void initState() {
    // TODO: implement initState

    quizStream = meth.getQuizResult(widget.quizid, widget.user.displayName);
    meth.getQuizScore(widget.quizid, widget.user.displayName).then((value)
    {
      setState(() {
        score=value[0];
       attempted=value[1];
      });
    });
    meth.getQuestionCount(widget.quizid).then((value)
    {
      setState(() {
        totalqs=value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(appBar: glob.customAppBar(context), floatingActionButton: FloatingActionButton(child: Icon(Icons.close), onPressed: (){Navigator.pop(context);},),
    body: Column(
      children: [
        Container(padding: EdgeInsets.fromLTRB(20, 15, 20, 15), margin: EdgeInsets.fromLTRB(20, 20, 20, 10), decoration: BoxDecoration(color: Colors.lightBlue, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Text("Attempt Summary",style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),),
              SizedBox(height: 10,),
              Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(children:
                [
                  Text("Total questions: ",style: TextStyle(color: Colors.white, fontSize: 20),),
                  Text("Correct answers: ",style: TextStyle(color: Colors.white, fontSize: 20),),
                  Text("Incorrect answers: ",style: TextStyle(color: Colors.white, fontSize: 20),),
                ],),
                Column(children:
                [
                  Text(totalqs.toString(),style: TextStyle(color: Colors.white, fontSize: 20),),
                  Text(score.toString(),style: TextStyle(color: Colors.white, fontSize: 20),),
                  Text((attempted-score).toString(),style: TextStyle(color: Colors.white, fontSize: 20),),
                ],),
                Spacer(),
                Column(
                  children: [
                    Text("Score: "+score.toString()+"/"+totalqs.toString(),style: TextStyle(color: Colors.white, fontSize: 23,fontWeight: FontWeight.bold),),
                    SizedBox(height: 5,),
                    !(score/totalqs>0.4)? Text('☹',style: TextStyle(fontSize: 20),):Text('☺',style: TextStyle(fontSize: 20),),
                  ],
                ),
              ],
        ),
            ],
          ),),

        Container(padding: EdgeInsets.symmetric(horizontal: 50),
          child: Row(
            children: [
              ElevatedButton(onPressed: (){
                meth.addToLog(widget.user.displayName + " accessed stats of " + widget.quizid);
                Navigator.push(
                  context, MaterialPageRoute(
                  builder: (BuildContext context) => QuizStats(quizid: widget.quizid,)));
                }, child: Text("Views stats")),

              Spacer(),
              ElevatedButton(onPressed: (){
                meth.addToLog(widget.user.displayName + " accessed hall of fame of quiz " + widget.quizid);
                Navigator.push(
                  context, MaterialPageRoute(
                  builder: (BuildContext context) => HallOfFame(quizid: widget.quizid, totalqs: totalqs)));}, child: Text("Hall of fame")),
            ],
          ),
        ),

        StreamBuilder(stream: quizStream, builder: (context, snapshot)
        {

          return !snapshot.hasData?Container():Expanded(
            child: ListView.builder(itemCount: snapshot.data.docs.length, shrinkWrap: true, cacheExtent: 999999, addAutomaticKeepAlives: true, scrollDirection: Axis.vertical,itemBuilder: (context, index)
            {

              List<String> options = [snapshot.data.docs[index].data()['option1'], snapshot.data.docs[index].data()['option2'], snapshot.data.docs[index].data()['option3'], snapshot.data.docs[index].data()['option4'],];
              return QuestionTile(question: snapshot.data.docs[index].data()['question'], selected: snapshot.data.docs[index].data()['selected'], options: options, correctanswer: snapshot.data.docs[index].data()['correct'] , index: index, isLast: (index==snapshot.data.docs.length-1),);
            },),
          );
        },),
      ],
    ),);
  }

}

class QuestionTile extends StatefulWidget
{

  List<String> options;
  String question, correctanswer, selected;
  int index;
   bool isLast;
  QuestionTile({this.question, this.correctanswer, this.options, this.selected, this.index, this.isLast});
  @override
  _QuestionTileState createState() => _QuestionTileState();
}

class _QuestionTileState extends State<QuestionTile> with AutomaticKeepAliveClientMixin
{



  @override
  bool get wantKeepAlive => true;

  double optionDistance=10;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(padding: EdgeInsets.symmetric(horizontal: 15), margin: EdgeInsets.symmetric(vertical: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children:
          [
            Text("Q"+(widget.index+1).toString()+" "+widget.question,softWrap: true,style: TextStyle(fontSize: 20),),
            SizedBox(height: 20,),

            InkWell(onTap: (){},child: OptionTile(desc: widget.options[0], option: "A", correct: (widget.selected==widget.options[0] && widget.selected==widget.correctanswer)?1:widget.selected==widget.options[0] && widget.selected!=widget.correctanswer?2:0,)),
            SizedBox(height: optionDistance),

            InkWell(onTap: (){},child: OptionTile(desc: widget.options[1], option: "B", correct: (widget.selected==widget.options[1] && widget.selected==widget.correctanswer)?1:widget.selected==widget.options[1] && widget.selected!=widget.correctanswer?2:0, )),
            SizedBox(height: optionDistance),

            InkWell( onTap: (){},child: OptionTile(desc: widget.options[2], option: "C", correct: (widget.selected==widget.options[2] && widget.selected==widget.correctanswer)?1:widget.selected==widget.options[2] && widget.selected!=widget.correctanswer?2:0, )),
            SizedBox(height: optionDistance),

            InkWell(onTap: (){},child: OptionTile(desc: widget.options[3], option: "D", correct: (widget.selected==widget.options[3] && widget.selected==widget.correctanswer)?1:widget.selected==widget.options[3] && widget.selected!=widget.correctanswer?2:0,)),

            SizedBox(height: optionDistance + ((widget.isLast)?20:0)),

          ],));
      }


}

class OptionTile extends StatefulWidget {
  String desc, option;
  int correct; //1 corr, 2 wrong, 3 not selected
  OptionTile({this.desc,this.option, this.correct});
  @override
  _OptionTileState createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: widget.correct==0?Colors.grey:widget.correct==1?Colors.green:Colors.red),
      child: Row(children: [
        Container(alignment:Alignment.center, width:30,height:30, padding: EdgeInsets.all(5),decoration: BoxDecoration(color: Colors.white, borderRadius:BorderRadius.circular(60),),child:
        Text(widget.option,style: TextStyle(fontSize: 18,color: Colors.black),),),
        SizedBox(width: 10,),
        Expanded(child: Text(widget.desc,style: TextStyle(fontSize: 16,color: Colors.black),)),
      ],),);
  }

}

