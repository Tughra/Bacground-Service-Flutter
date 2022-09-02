import 'dart:math';

import 'package:flutter/material.dart';

class PageOne extends StatefulWidget {
  const PageOne({Key? key}) : super(key: key);

  @override
  State<PageOne> createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {


  List<Widget> func(){
    int radius=120;
    int numPieces = 12;
    List<Widget> widgets=[];
    double ang=0;
    for (int i = 0; i < numPieces; i++) {

      final xPos = (radius-20) * cos(2 * pi * (i / numPieces));
      final yPos = (radius-20) * sin(2 * pi * (i / numPieces));
      ang=sin(i*pi/180)*360;
       widgets.add(Transform.translate(offset: Offset(xPos,yPos),child: Transform.rotate(angle:0,child: Container(decoration: BoxDecoration(color: Colors.orangeAccent,shape: BoxShape.circle),width: 30,height: 30,child: FittedBox(child: Text(i.toString())),alignment: Alignment.center,)),));
    }
    return widgets;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: (){},child:const Icon(Icons.add),),
      appBar: AppBar(title: const Text("Page One"),),
      body: Center(
        child: Stack(alignment: Alignment.center, children: [


          SizedBox(width: 300,height: 300,
            child: ColoredBox(
              color: Colors.purpleAccent,
              child: Stack(alignment: Alignment.center,
                children: [
                  ...func(),
                //  Align(alignment: Alignment.topRight,child: Transform.rotate(angle:0.8,child: Container(color: Colors.orangeAccent,width: 40,height: 40,))),
                  Container(width: 150,height: 150,decoration: BoxDecoration(color: Colors.transparent,border: Border.all(),shape: BoxShape.circle),),
                ],
              ),
            ),
          ),
        ],),
      ),
    );
  }
}
