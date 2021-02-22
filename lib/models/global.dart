import 'package:flutter/material.dart';

class GlobalConstants {
  Widget customAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      leading: BackButton(color: Colors.black,),
      backgroundColor: Colors.transparent,
      title: Row(mainAxisAlignment: MainAxisAlignment.center,
        children:
        [

          Text('Enviro', style: TextStyle(color: Colors.green),),
          Text('Quiz', style: TextStyle(color: Colors.grey),),
          SizedBox(width: MediaQuery
              .of(context)
              .size
              .width / 6.5,)
        ],),);
  }
}
