import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'firebase_methods.dart';
import 'package:evs_project/models/global.dart';
import 'package:pie_chart/pie_chart.dart';

class QuizStats extends StatefulWidget
{
  String quizid;
  QuizStats({this.quizid});
  @override
  _QuizStatsState createState() => _QuizStatsState();
}

class _QuizStatsState extends State<QuizStats>
{
  GlobalConstants glob = GlobalConstants();
  Methods meth = new Methods();
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(backgroundColor: Color(0xFF875FC0), appBar: AppBar(centerTitle: true, elevation: 0, backgroundColor: Colors.transparent,title: Text(widget.quizid+ " Quiz stats"),), body: StreamBuilder(stream: meth.getQuestionStats(widget.quizid), builder: (context, snapshot)
    {
      return !snapshot.hasData?Container():ListView.builder(itemCount: snapshot.data.docs.length, itemBuilder: (context, index)
      {
        return DisplayQuestionStats(question: snapshot.data.docs[index].data()['question'], attempts: snapshot.data.docs[index].data()['attempts'], correct: snapshot.data.docs[index].data()['correct'],correctanswer: snapshot.data.docs[index].data()['correctanswer'],index: index);
      },);
    },),);
  }
}

class DisplayQuestionStats extends StatefulWidget
{
  String question, correctanswer;
  int attempts, correct, index;
  DisplayQuestionStats({this.question, this.attempts, this.correct, this.correctanswer, this.index});
  @override
  _DisplayQuestionStatsState createState() => _DisplayQuestionStatsState();
}

class _DisplayQuestionStatsState extends State<DisplayQuestionStats>
{
  @override
  Widget build(BuildContext context)
  {
    Map<String, double> m=
    {
      'Correct': widget.correct.toDouble(),
      'Wrong':(widget.attempts-widget.correct).toDouble(),
    };
    List<Color> cl = [Colors.green, Colors.red];
    return Container(margin: EdgeInsets.symmetric(vertical: 15, horizontal: 25), padding: EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(padding: EdgeInsets.symmetric(vertical: 5, horizontal: 7),child: Text("Question "+(widget.index+1).toString(),style: TextStyle(color: Colors.white,fontSize: 18),),decoration: BoxDecoration(color: Color(0xFFFBAF00),borderRadius: BorderRadius.circular(8)),),
          SizedBox(height: 8,),
          Text(widget.question,style: TextStyle(color: Colors.black, fontSize: 20), textAlign: TextAlign.center,),
          SizedBox(height: 8,),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Answer is: "),
              Text(widget.correctanswer,style: TextStyle(fontWeight: FontWeight.bold),)
            ],
          ),
          SizedBox(height: 10,),
          Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PieChart(dataMap: m, colorList: cl, chartLegendSpacing: 18,animationDuration: Duration(milliseconds: 800),chartRadius: 110, legendOptions: LegendOptions(showLegendsInRow: true, legendPosition: LegendPosition.bottom, legendTextStyle: TextStyle(fontSize: 15)),
              ),
             // Spacer(),
              Column(
                children: [
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Text(widget.correct.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                      Text(" out of ",style: TextStyle(fontSize: 20),),
                      Text(widget.attempts.toString(),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                      Text(" people",style: TextStyle(fontSize: 20),),
                    ],
                  ),
                  SizedBox(height: 3,),
                  Row(
                    children: [
                      Text("have got this right",style: TextStyle(fontSize: 18),)
                    ],),
                  SizedBox(height: 20,),
                  Container(padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Text("Success rate" ,style: TextStyle(fontSize: 18,color: Colors.black),),
                        Text(((widget.correct/widget.attempts)*100).toStringAsPrecision(4)+" %",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 17),),
                      ],
                    ),
                  ),

                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
