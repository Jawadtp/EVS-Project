import 'package:evs_project/screens/surveycontributors.dart';
import 'package:flutter/material.dart';
import 'firebase_methods.dart';
import 'package:pie_chart/pie_chart.dart';
import 'home.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SurveyResult extends StatefulWidget {
  String quizid;
  SurveyResult({this.quizid});
  @override
  _SurveyResultState createState() => _SurveyResultState();
}

class _SurveyResultState extends State<SurveyResult>
{
  Methods meth= new Methods();
  User user;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    meth.getCurrentUser().then((value)
    {
      setState(() {
        user=value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Color(0xFF875FC0),appBar:

    AppBar(automaticallyImplyLeading: false, actions: [IconButton(icon: Icon(Icons.add),onPressed: (){meth.addToLog(user.displayName+" is now viewing the list of respondents of the survey '"+widget.quizid+"'");
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        SurveyContributors(quizid: widget.quizid,)), (Route<dynamic> route) => false);},)],
      title: Row(
      children:
      [
        IconButton(icon: Icon(Icons.arrow_back), onPressed: (){Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
            Home()), (Route<dynamic> route) => false);},),
       SizedBox(width: MediaQuery.of(context).size.width/15,),
       Expanded(child: Text(widget.quizid+ " survey statistics",)),
      ],
    ),elevation: 0, backgroundColor: Colors.transparent,),

        body:
    StreamBuilder(stream: meth.getSurveyQuestionResult(widget.quizid), builder: (context, snapshot)
    {
      return !snapshot.hasData?Container():ListView.builder(itemCount: snapshot.data.docs.length, itemBuilder: (context, index)
      {
        return SurveyResultTile(quizid: widget.quizid, question: snapshot.data.docs[index].data()['question'], chartlabel:snapshot.data.docs[index].data()['chartlabel'],index: index,);
      },);
    },)
      );
  }
}

class SurveyResultTile extends StatefulWidget
{
  String quizid, question, chartlabel;
  int index;
  SurveyResultTile({this.quizid, this.question, this.index, this.chartlabel});
  @override
  _SurveyResultTileState createState() => _SurveyResultTileState();
}

class _SurveyResultTileState extends State<SurveyResultTile>
{
  Methods meth = new Methods();
  @override
  Widget build(BuildContext context) {

    return Column(

      children: [
        StreamBuilder(stream: meth.getSurveyOptionResult(widget.quizid, widget.question), builder: (context, snapshot)
        {
          if(!snapshot.hasData) return Container();

          String option1 = snapshot.data.docs[0].data()['option'], option2 = snapshot.data.docs[1].data()['option'], option3 =  snapshot.data.docs[2].data()['option'], option4=snapshot.data.docs[3].data()['option'];
          int c1 =  snapshot.data.docs[0].data()['count'], c2 = snapshot.data.docs[1].data()['count'], c3 = snapshot.data.docs[2].data()['count'], c4 = snapshot.data.docs[3].data()['count'];
          Map<String, double> m =
          {
            option1:c1.toDouble(),
            option2:c2.toDouble(),
            option3:c3.toDouble(),
            option4:c4.toDouble(),
          };
          List<Color> cl = [Colors.yellow, Colors.green, Colors.blue, Colors.red];
          return Container(padding: EdgeInsets.fromLTRB(10, 0, 10, 10), margin: EdgeInsets.symmetric(horizontal: 18, vertical: 15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child:  Column(
              children: [
                Container(padding: EdgeInsets.symmetric(vertical: 5, horizontal: 7),child: Text("Question "+(widget.index+1).toString(),style: TextStyle(color: Colors.white,fontSize: 18),),decoration: BoxDecoration(color: Color(0xFFFBAF00),borderRadius: BorderRadius.circular(8)),),
                SizedBox(height: 18),
                Text(widget.chartlabel,style: TextStyle(color: Colors.black, fontSize: 21), textAlign: TextAlign.center,),
                SizedBox(height: 14),
                PieChart(dataMap: m, colorList: cl, chartLegendSpacing: 15,animationDuration: Duration(milliseconds: 800),chartRadius: 160, legendOptions: LegendOptions(showLegendsInRow: false, legendPosition: LegendPosition.bottom, legendTextStyle: TextStyle(fontSize: 14,)),
          ),

              ],
            ),);

        },),
      ],
    );
  }
}

/*
    child: Column(children:
      [
        Text(snapshot.data.docs[0].data()['option'] + " " + snapshot.data.docs[0].data()['count'].toString()),
        Text(snapshot.data.docs[1].data()['option'] + " " + snapshot.data.docs[1].data()['count'].toString()),
        Text(snapshot.data.docs[2].data()['option'] + " " + snapshot.data.docs[2].data()['count'].toString()),
        Text(snapshot.data.docs[3].data()['option'] + " " + snapshot.data.docs[3].data()['count'].toString()),
      ],),

 */
