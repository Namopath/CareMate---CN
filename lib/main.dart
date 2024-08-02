import 'package:caremate/services/ble_container.dart';
import 'package:caremate/services/connected_or_notconneced.dart';
import 'package:caremate/services/navigation.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:caremate/services/language_config.dart';
import 'package:caremate/services/language_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AwesomeNotifications().initialize(null,
    [
      NotificationChannel(channelKey: 'Event 1', channelName: 'Take meds 1' , channelDescription: 'For the pills page'),
      NotificationChannel(channelKey: 'Event 2', channelName: 'Take meds 2' , channelDescription: 'For the pills page'),
      NotificationChannel(channelKey: 'Event 3', channelName: 'Take meds 3' , channelDescription: 'For the pills page'),
      NotificationChannel(channelKey: 'Fall detected', channelName: 'Fall detected', channelDescription: 'In case fall is detected'),
      NotificationChannel(channelKey: 'Emergency', channelName:'Emergency',channelDescription:  "Emergency button pressed"),
      NotificationChannel(channelKey: 'Meds', channelName:'Meds',channelDescription:  "Haven't taken medication"),
      NotificationChannel(channelKey: 'HandCMD', channelName:'HandCMD',channelDescription:  "Hand commands"),
    ],
  );
  bool noti_perm = await AwesomeNotifications().isNotificationAllowed();
  // await Workmanager().initialize(callbackDispatcher);

  if(!noti_perm){
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  Get.put(LanguageConfig());

  runApp(const MyApp());
}

// void ListenForCalls(BuildContext context){
//   final documentRef = FirebaseFirestore.instance.collection("cam")
//       .doc("cam_status").snapshots();
//   documentRef.listen((snapshot) {
//     print("Listening...");
//     if(snapshot.exists){
//
//       var fieldVal = snapshot.get('isCall');
//       if(fieldVal == 'true'){
//         print('Incoming call detected!');
//         Get.to(VideoCall());
//       }
//       if(fieldVal == 'false'){
//         Get.back();
//       }
//     }
//     // else{
//     //
//     // }
//   });
//
// }


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool initEM = false;
  String medState = 'null';
  String prevMedState = 'null';
  bool hasMed = false;
  LanguageConfig languageConfig = Get.find<LanguageConfig>();
  Locale _appLocale = Locale('en');
  String langCode = LanguageConfig().code;

  @override
  void initState() {
    super.initState();
    // ListenForCalls(context);
    // listenMed();
    // checkMedState();
    getLanguage();
  }

  void getLanguage() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var code = prefs.get('language');
    setState(() {
      langCode = code.toString();
      _appLocale = Locale(langCode);
    });
    print(langCode);
  }



  // void listenMed(){
  //   final doc = FirebaseFirestore.instance.collection('cam').doc('Med').snapshots();
  //   doc.listen((snapshot){
  //     var fieldVal = snapshot.get('isMed');
  //     if(snapshot.exists){
  //       if(hasMed == false){
  //         print('Setting med state: $fieldVal');
  //         setState(() {
  //           prevMedState = fieldVal;
  //         });
  //         if(fieldVal == 'true'){
  //           hasMed = true;
  //         }
  //       }
  //     }
  //   });
  // }
  //
  // void checkMedState(){
  //   Timer.periodic(Duration(minutes: 1), (Timer timer){
  //     checkMedHour();
  //   });
  // }
  //
  // void checkMedHour() async {
  //   DocumentSnapshot doc = await FirebaseFirestore.instance.collection('cam').doc('Med').get();
  //   var fieldVal = doc['isMed'];
  //   print('Hourly check value: $fieldVal');
  //   if(fieldVal == 'true'){
  //     setState(() {
  //       medState == 'true';
  //     });
  //       await AwesomeNotifications().createNotification(content:
  //       NotificationContent(id: 0, channelKey: "Meds",
  //           title: "Did you forget to take your medications?",
  //           body: "Don't forget to take your medications!"
  //       )
  //       );
  //
  //   }else{
  //     setState(() {
  //       hasMed == false;
  //       medState == 'false';
  //     });
  //   }
  //
  // }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => BleContainer())],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: _appLocale,
        // onGenerateRoute:  CustomRouter.generateRoute,
        debugShowCheckedModeBanner: false,
        home: ConnectedOrNotConnected(), //TODO: This is important
        navigatorKey: Get.key,
      ),
    );
  }
}
