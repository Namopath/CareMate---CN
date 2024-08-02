import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HealthPage extends StatefulWidget{
  HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  DateTime today = DateTime.now();
  String? postureData = '-';
  String? colorGameData = '-';
  String? gripData = '-';
  bool hasPlayed = false;

  void initState(){
    super.initState();
    // fetchData();
  }

  // void fetchData()async{
  //   String todayFormat = DateFormat('dd-MM-yyyy').format(today);
  //   try{
  //     var ref = FirebaseFirestore.instance.collection("games");
  //     var posture = await ref.doc("Posture game").get();
  //     var color_game = await ref.doc("color_game").get();
  //     var grip = await ref.doc("Squeeze game").get();
  //     if(posture.data()!.containsKey(todayFormat) && posture.data() != null){
  //       setState(() {
  //         postureData = posture.data()![todayFormat];
  //         hasPlayed = true;
  //       });
  //       print(postureData);
  //
  //     } else{
  //       print("Pose is null");
  //     }
  //     if(grip.data()!.containsKey(todayFormat) && grip.data() != null){
  //       setState(() {
  //         gripData = grip.data()![todayFormat];
  //         hasPlayed = true;
  //       });
  //       print(gripData);
  //
  //     } else{
  //       print("Grip is null");
  //     }
  //     if(color_game.data()!.containsKey(todayFormat)&& color_game.data() != null){
  //       setState(() {
  //         colorGameData = color_game.data()![todayFormat];
  //         print(colorGameData);
  //         hasPlayed = true;
  //       });
  //       print(color_game);
  //
  //     } else{
  //       print('color is null');
  //     }
  //
  //   }catch(e){
  //
  //   }
  // }

  void dispose(){
    super.dispose();
  }

  @override

  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 70 ),
                child: Container(
                  width: 300 ,
                  height: 200 ,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12 ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20 ),
                        child: Icon(Icons.medical_information,
                          size: 60 ,),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left:20),
                        child: Text("You have 3 \nbatches of pills\nscheduled today",
                          style: TextStyle(
                            fontSize: 14 ,
                            fontFamily: "Montserrat_bold",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30 ),
              child: Container(
                width: 300 ,
                height: 200 ,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12 ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20 ),
                      child: Icon(Icons.videogame_asset_rounded,
                        size: 60 ,),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left:20),
                      child: hasPlayed?
                          Text(
                            'Exercise game score: $postureData\nColor catcher score: $colorGameData\nMighty grip score: $gripData',
                            style: TextStyle(
                              fontFamily: "Montserrat_bold",
                              fontSize: 14,
                            ),
                          ) :
                      Text("You have yet to\nplay any of our\ngames today",
                        style: TextStyle(
                          fontSize: 14 ,
                          fontFamily: "Montserrat_bold",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30 ),
              child: Container(
                width: 300 ,
                height: 200 ,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12 ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20 ),
                      child: Icon(Icons.info,
                        size: 60 ,),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left:20),
                      child: Text("Click here to\nnavigate to a\ntutorial page",
                        style: TextStyle(
                          fontSize: 14 ,
                          fontFamily: "Montserrat_bold",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}