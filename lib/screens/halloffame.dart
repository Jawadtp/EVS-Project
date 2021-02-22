import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'firebase_methods.dart';

class HallOfFame extends StatefulWidget
{
  String quizid;
  int totalqs;
  HallOfFame({this.quizid, this.totalqs});
  @override
  _HallOfFameState createState() => _HallOfFameState();
}

class _HallOfFameState extends State<HallOfFame>
{
  Methods meth= new Methods();
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,appBar: AppBar(leading: BackButton(color: Colors.orange,),centerTitle: true,actions: [], title: Text("Hall of Fame",style: TextStyle(color: Colors.orange,fontSize: 25),),elevation: 0, backgroundColor: Colors.transparent,),
      body: StreamBuilder(stream: meth.getBestPerformers(widget.quizid), builder: (context, snapshot)
      {
        return !snapshot.hasData?Container():ListView.builder(itemCount: snapshot.data.docs.length,itemBuilder: (context, index)
        {
          return WinnerTile(name: snapshot.data.docs[index].id, photourl: snapshot.data.docs[index].data()['photourl'], score: snapshot.data.docs[index].data()['correct'],totalqs: widget.totalqs,index: index,);
        });
      },)
      ,);
  }
}

class WinnerTile extends StatefulWidget
{
  String name, photourl;
  int score, totalqs, index;
  WinnerTile({this.name, this.photourl, this.score, this.totalqs, this.index});
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
      Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.name,style: TextStyle(fontSize: 17),),
          Text("Score: "+ widget.score.toString()+"/"+widget.totalqs.toString())
        ],
      ),
      Spacer(),
      Container(padding:EdgeInsets.symmetric(horizontal: 10, vertical: 10),child: Text((widget.score*100/widget.totalqs).toStringAsPrecision(4)+"%"), decoration: BoxDecoration(color: Colors.greenAccent,borderRadius: BorderRadius.circular(10)),),
    ],),);
  }
}
