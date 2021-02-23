import 'package:flutter/material.dart';
import 'package:evs_project/models/global.dart';
import '../models/global.dart';
import 'firebase_methods.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel>
{
  Methods meth= new Methods();
  bool isLocked=true;
  GlobalConstants glob = new GlobalConstants();
  ScrollController controller = new ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(floatingActionButton: IconButton(icon: Icon(!isLocked?Icons.lock_open:Icons.lock), onPressed: (){setState(() {
      isLocked=isLocked?false:true;
    });},),appBar: glob.customAppBar(context), body: StreamBuilder(stream: meth.getAdminLogs(), builder: (context, snapshot)
    {
      return !snapshot.hasData?Container():Container(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Text("User Activity Logs",style: TextStyle(fontSize: 20),),
            SizedBox(height: 15,),
            Expanded(
              child: ListView.builder(itemCount: snapshot.data.docs.length, reverse: true, controller: controller, itemBuilder: (context, index)
              {
                if(isLocked) controller.animateTo(
                    100*snapshot.data.docs.length.toDouble(),
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 300));
                return Container(padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: [
                      SizedBox(width: 60, child: Text(snapshot.data.docs[index].data()['time'].substring(13),style: TextStyle(fontSize: 10))),
                      SizedBox(width: 10,),
                      Expanded(child: Text(snapshot.data.docs[index].data()['activity'],style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),softWrap: true,)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      );
    },),);
  }
}
