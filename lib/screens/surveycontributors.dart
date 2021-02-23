import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'firebase_methods.dart';
import 'home.dart';
class SurveyContributors extends StatefulWidget
{
  String quizid;

  SurveyContributors({this.quizid});
  @override
  _SurveyContributorState createState() => _SurveyContributorState();
}

class _SurveyContributorState extends State<SurveyContributors>
{
  Methods meth= new Methods();
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,appBar: AppBar(leading: BackButton(color: Colors.orange, onPressed: ()
    {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          Home()), (Route<dynamic> route) => false);

    },),centerTitle: true,actions: [], title: Text("Respondents",style: TextStyle(color: Colors.orange,fontSize: 25),),elevation: 0, backgroundColor: Colors.transparent,),
      body: StreamBuilder(stream: meth.getSurveyRespondents(widget.quizid), builder: (context, snapshot)
      {
        return !snapshot.hasData?Container():ListView.builder(itemCount: snapshot.data.docs.length,itemBuilder: (context, index)
        {
          return WinnerTile(name: snapshot.data.docs[index].data()['name'], photourl: snapshot.data.docs[index].data()['photourl'],index: index,);
        });
      },)
      ,);
  }
}

class WinnerTile extends StatefulWidget
{
  String name, photourl;
  int index;
  WinnerTile({this.name, this.photourl, this.index});
  @override
  _WinnerTileState createState() => _WinnerTileState();
}

class _WinnerTileState extends State<WinnerTile>
{
  @override
  Widget build(BuildContext context)
  {
    return Container(padding: EdgeInsets.fromLTRB(10, 15, 10, 15), margin: EdgeInsets.fromLTRB(10, widget.index==0?35:10, 10, 5),decoration: BoxDecoration(color: Color(0xFFd5edec),borderRadius: BorderRadius.circular(10)),
      child: Row(
        children:
        [
          Container(padding: EdgeInsets.all(2),child: Text((widget.index+1).toString(),style: TextStyle(fontSize: 20),),decoration: BoxDecoration(border: Border.all(width: 1.2,color: Colors.green)),),
          SizedBox(width: 12,),
          CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(widget.photourl)
          ),
          SizedBox(width: 10,),
          Expanded(child: Text(widget.name,style: TextStyle(fontSize: 17),)),



        ],),);
  }
}
