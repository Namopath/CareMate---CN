import 'control_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hexcolor/hexcolor.dart';
import "home_page.dart";
import 'voice_assistant_page.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:caremate/services/ble_container.dart';
import 'dart:convert';

class Pills_page extends StatefulWidget{
  final bool connectionState;
  const Pills_page({super.key, required this.connectionState});

  @override
  State<Pills_page> createState() => _Pills_pageState();
}

class _Pills_pageState extends State<Pills_page> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  TextEditingController eventName = TextEditingController();
  TextEditingController hour = TextEditingController();
  TextEditingController minute = TextEditingController();
  OverlayEntry? entry;
  String today = DateFormat('MMMM d, yyyy').format(DateTime.now());
  String _focusedDay_format = '';
  String eventNameText = '';
  int hourValue = 0;
  int minuteValue = 0;
  String time_data = '';
  // CollectionReference eventsCollection = FirebaseFirestore.instance.collection('pill_dispensing');
  String event1 = '';
  String event2 = '';
  String event3 = '';
  String? timeZone_str = '';
  int id = 0;
  String med1 = "S-1";
  String med2 = "S-2";
  String med3 = "S-3";

  void initState() {
    super.initState();
    sendTodayMed();

    _onDaySelected(_focusedDay, _focusedDay);
  }

  Future<void> scheduleNotification(int day, int month, int year, int hour, int minute, int id, String channel, String event_name) async {
    await AwesomeNotifications().createNotification(
      schedule: NotificationCalendar(
        day: day,
        month: month,
        year: year,
        hour: hour,
        minute: minute,
        timeZone: DateTime.now().timeZoneName,
        repeats: false, // Set repeats to false for a one-time notification
        preciseAlarm: true,
      ),
      content: NotificationContent(
        id: 0, // Notification ID
        channelKey: channel, // Channel key defined in your app
        title: "Time to take your medication!",
        body: 'Time to take  $event_name',
      ),
    );
  }

  void dayOfYear(DateTime date) {
    final beginningOfYear = DateTime(date.year);
    final difference = date.difference(beginningOfYear);
    id = difference.inDays + 1; // Add 1 since the count starts from 0
  }

  void sendTodayMed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key1 = DateFormat('dd-MM-yyyy').format(DateTime.now()) + ' ' + 'event1';
    String key2 = DateFormat('dd-MM-yyyy').format(DateTime.now()) + ' ' + 'event2';
    String key3 = DateFormat('dd-MM-yyyy').format(DateTime.now()) + ' ' + 'event3';

    if(prefs.containsKey(key1)){
      String? eventData1 = prefs.getString(key1);
      int hour = int.parse(eventData1!.split(" ")[3].split(":")[0]);
      int min = int.parse(eventData1!.split(" ")[3].split(":")[1]);
      DateTime now = DateTime.now();
      DateTime event1_time = DateTime(now.year, now.month,now.day, hour, min);
      Duration event1_diff = event1_time.difference(now);
      print("Time difference: $event1_diff");
      if(!event1_diff.isNegative){
        await Future.delayed(event1_diff);
        print("Time to send BLE 1");
        if (widget.connectionState) {
          final bleContainer = Provider.of<BleContainer>(context, listen: false);
          if (bleContainer.writeCharacteristic != null) {
            await bleContainer.writeCharacteristic!.write(utf8.encode(med1));
            print("BLE message event 1 sent");
          } else {
            print("BLE write characteristic is not available");
          }
        } else {
          print("BLE connection is not established");
        }
      }

    }
    if(prefs.containsKey(key2)){
      String? eventData2 = prefs.getString(key2);
      int hour = int.parse(eventData2!.split(" ")[3].split(":")[0]);
      int min = int.parse(eventData2!.split(" ")[3].split(":")[1]);
      DateTime now = DateTime.now();
      DateTime event2_time = DateTime(now.year, now.month,now.day, hour, min);
      Duration event2_diff = event2_time.difference(now);
      print("Time difference: $event2_diff");
      if(!event2_diff.isNegative){
        await Future.delayed(event2_diff);
        if (widget.connectionState) {
          final bleContainer = Provider.of<BleContainer>(context, listen: false);
          if (bleContainer.writeCharacteristic != null) {
            await bleContainer.writeCharacteristic!.write(utf8.encode(med2));
            print("BLE message event 2 sent");
          } else {
            print("BLE write characteristic is not available");
          }
        } else {
          print("BLE connection is not established");
        }
      }
    }
    if(prefs.containsKey(key3)){
      String? eventData3 = prefs.getString(key3);
      int hour = int.parse(eventData3!.split(" ")[3].split(":")[0]);
      int min = int.parse(eventData3!.split(" ")[3].split(":")[1]);
      DateTime now = DateTime.now();
      DateTime event3_time = DateTime(now.year, now.month,now.day, hour, min);
      Duration event3_diff = event3_time.difference(now);
      print("Time difference: $event3_diff");
      if(!event3_diff.isNegative){
        if (widget.connectionState) {
          final bleContainer = Provider.of<BleContainer>(context, listen: false);
          if (bleContainer.writeCharacteristic != null) {
            await bleContainer.writeCharacteristic!.write(utf8.encode(med3));
            print("BLE message event 3 sent");
          } else {
            print("BLE write characteristic is not available");
          }
        } else {
          print("BLE connection is not established");
        }
      }
    }
  }

  void _onDaySelected(DateTime day, DateTime focused_day) async {
    setState(() {
      _focusedDay = day;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String key1 = DateFormat('dd-MM-yyyy').format(_focusedDay) + ' ' + 'event1';
    String key2 = DateFormat('dd-MM-yyyy').format(_focusedDay) + ' ' + 'event2';
    String key3 = DateFormat('dd-MM-yyyy').format(_focusedDay) + ' ' + 'event3';
    String? eventData1 = prefs.getString(key1);
    String? eventData2 = prefs.getString(key2);
    String? eventData3 = prefs.getString(key3);

    if (eventData1 != null){
      setState(() {
        event1 = eventData1;
      });
      print(eventData1);
    } else {
      print('No events yet');
      setState(() {
        event1 = 'No events yet';
      });
    }

    if (eventData2 != null){
      setState(() {
        event2 = eventData2;
      });
      print(eventData2);
    } else {
      print('No events yet');
      setState(() {
        event2 = 'No events yet';
      });
    }

    if (eventData3 != null){
      setState(() {
        event3 = eventData3;
      });
      print(eventData3);
    } else {
      print('No events yet');
      setState(() {
        event3 = 'No events yet';
      });
    }

    print('Selected day:'+ _focusedDay.toString().split(" ")[0]);
  }

  void ShowSetEvent1(){
    final overlay = Overlay.of(context);

    entry = OverlayEntry(builder: (context) =>
        SetEvent1()
    );
    overlay.insert(entry!);
  }

  Widget SetEvent1() => Material(
    color: Colors.black.withOpacity(0.25),
    child: Center(
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20 ),
              border: Border.all(
                  width: 2,
                  color: Colors.black
              )
          ),
          width: 200 ,
          height: 300  ,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 12  ),
                child: Text(AppLocalizations.of(context)!.set_info,
                  style: TextStyle(
                      fontFamily: 'Montserrat_bold',
                      fontSize: 14 ,
                      color: Colors.black
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 15  , 80 , 0),
                child: Text(AppLocalizations.of(context)!.event_name,
                  style: TextStyle(
                    fontSize: 14 ,
                    fontFamily: 'Montserrat_bold',
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 15  , 30 , 0),
                child: Container(
                  width: 150 ,
                  height: 30  ,
                  child: SingleChildScrollView(
                    child: Container(
                      width: 150 ,
                      height: 30  ,
                      child: TextField(
                        controller: eventName,
                        key: ValueKey('event_name'),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          labelText: 'Enter event name',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                            borderRadius: BorderRadius.circular(10 ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 15  , 85 , 0),
                child: Text(AppLocalizations.of(context)!.enter_time,
                  style: TextStyle(
                    fontSize: 14 ,
                    fontFamily: 'Montserrat_bold',
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(padding: EdgeInsets.fromLTRB(10 , 15  , 0, 0),
                    child: Container(
                      width: 30 ,
                      height: 30  ,
                      child: SingleChildScrollView(
                        child: Container(
                          width: 30 ,
                          height: 30  ,
                          child: TextField(
                            controller: hour,
                            key: ValueKey('event_name'),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                                borderRadius: BorderRadius.circular(10 ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10 , 10  , 0, 0),
                    child: Text(":",
                      style: TextStyle(
                          fontFamily: 'Montserrat_bold',
                          fontSize: 14 ,
                          color: Colors.black
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10 , 15  , 0, 0),
                    child: Container(
                      width: 30 ,
                      height: 30  ,
                      child: SingleChildScrollView(
                        child: Container(
                          width: 30 ,
                          height: 30  ,
                          child: TextField(
                            controller: minute,
                            key: ValueKey('event_name'),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                                borderRadius: BorderRadius.circular(10 ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 25  ),
                child: GestureDetector(
                  onTap: () async {
                    eventNameText = eventName.text;
                    hourValue = int.tryParse(hour.text) ?? 0;
                    minuteValue = int.tryParse(minute.text) ?? 0;

                    // Convert hour and minute to DateTime
                    DateTime eventDateTime = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day, hourValue, minuteValue);

                    // Add event to the Table Calendar
                    // Assuming `_focusedDay_format` is the desired format for the event
                    // Replace this with the desired logic to add events to the Table Calendar
                    print('Event Name: $eventNameText, Time: ${DateFormat('HH:mm').format(eventDateTime)}');
                    print(_focusedDay);
                    time_data = DateFormat('HH:mm').format(eventDateTime);
                    _focusedDay_format = DateFormat('dd-MM-yyyy').format(_focusedDay);
                    print(_focusedDay_format);
                    print(time_data);

                    // DocumentSnapshot docSnapshot = await eventsCollection.doc(_focusedDay_format).get();

                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String key = _focusedDay_format + ' ' + 'event1';
                    String eventData = eventNameText + ' ' + 'at' + ' ' + time_data;
                    await prefs.setString(key, eventData);

                    // if (docSnapshot.exists){
                    //   await eventsCollection.doc(_focusedDay_format).update(
                    //       {'Event 1': time_data}
                    //   );
                    //   print("Document updated for Event 1");
                    // } else{
                    //   await eventsCollection.doc(_focusedDay_format).set(
                    //       {'Event 1': time_data}
                    //   );
                    //   print('Document created for Event 1');
                    // // }

                    setState(() {
                      event1 = eventData;
                    });

                    dayOfYear(_focusedDay);

                    scheduleNotification(int.parse(DateFormat('dd').format(_focusedDay)),
                      int.parse(DateFormat('MM').format(_focusedDay)),
                      int.parse(DateFormat('yyyy').format(_focusedDay)),
                      int.parse(DateFormat('HH').format(eventDateTime)),
                      int.parse(DateFormat('mm').format(eventDateTime)), id,
                      'Event 1',
                      eventNameText,
                    );
                    // final pillsRef = db.child("Pills/${_focusedDay_format}");
                    //
                    // await pillsRef.push().set(time_data);

                    // await scheduleTask1(eventDateTime, _focusedDay_format);
                    entry!.remove();

                  },
                  child: Container(
                    width: 150 ,
                    height: 40  ,
                    decoration: BoxDecoration(
                      color: HexColor('#CFE8EB'),
                      borderRadius: BorderRadius.circular(10 ),
                    ),
                    child: Center(
                      child: Text(AppLocalizations.of(context)!.save,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14 ,
                            fontFamily: 'Montserrat_bold'
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
      ),
    ),
  );

  void ShowSetEvent2(){
    final overlay = Overlay.of(context);

    entry = OverlayEntry(builder: (context) =>
        SetEvent2()
    );
    overlay.insert(entry!);
  }

  Widget SetEvent2() => Material(
    color: Colors.black.withOpacity(0.25),
    child: Center(
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20 ),
              border: Border.all(
                  width: 2,
                  color: Colors.black
              )
          ),
          width: 200 ,
          height: 300  ,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 12  ),
                child: Text(AppLocalizations.of(context)!.set_info,
                  style: TextStyle(
                      fontFamily: 'Montserrat_bold',
                      fontSize: 14 ,
                      color: Colors.black
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 15  , 80 , 0),
                child: Text(AppLocalizations.of(context)!.event_name,
                  style: TextStyle(
                    fontSize: 14 ,
                    fontFamily: 'Montserrat_bold',
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 15  , 30 , 0),
                child: Container(
                  width: 150 ,
                  height: 30  ,
                  child: SingleChildScrollView(
                    child: Container(
                      width: 150 ,
                      height: 30  ,
                      child: TextField(
                        controller: eventName,
                        key: ValueKey('event_name'),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          labelText: 'Enter event name',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                            borderRadius: BorderRadius.circular(10 ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 15  , 85 , 0),
                child: Text(AppLocalizations.of(context)!.enter_time,
                  style: TextStyle(
                    fontSize: 14 ,
                    fontFamily: 'Montserrat_bold',
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(padding: EdgeInsets.fromLTRB(10 , 15  , 0, 0),
                    child: Container(
                      width: 30 ,
                      height: 30  ,
                      child: SingleChildScrollView(
                        child: Container(
                          width: 30 ,
                          height: 30  ,
                          child: TextField(
                            controller: hour,
                            key: ValueKey('event_name'),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                                borderRadius: BorderRadius.circular(10 ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10 , 10  , 0, 0),
                    child: Text(":",
                      style: TextStyle(
                          fontFamily: 'Montserrat_bold',
                          fontSize: 14 ,
                          color: Colors.black
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10 , 15  , 0, 0),
                    child: Container(
                      width: 30 ,
                      height: 30  ,
                      child: SingleChildScrollView(
                        child: Container(
                          width: 30 ,
                          height: 30  ,
                          child: TextField(
                            controller: minute,
                            key: ValueKey('event_name'),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                                borderRadius: BorderRadius.circular(10 ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 25  ),
                child: GestureDetector(
                  onTap: () async {
                    eventNameText = eventName.text;
                    hourValue = int.tryParse(hour.text) ?? 0;
                    minuteValue = int.tryParse(minute.text) ?? 0;

                    // Convert hour and minute to DateTime
                    DateTime eventDateTime = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day, hourValue, minuteValue);

                    // Add event to the Table Calendar
                    // Assuming `_focusedDay_format` is the desired format for the event
                    // Replace this with the desired logic to add events to the Table Calendar
                    print('Event Name: $eventNameText, Time: ${DateFormat('HH:mm').format(eventDateTime)}');
                    print(_focusedDay);
                    time_data = DateFormat('HH:mm').format(eventDateTime);
                    _focusedDay_format = DateFormat('dd-MM-yyyy').format(_focusedDay);
                    print(_focusedDay_format);
                    print(time_data);

                    // DocumentSnapshot docSnapshot = await eventsCollection.doc(_focusedDay_format).get();

                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String key = _focusedDay_format + ' ' + 'event2';
                    String eventData = eventNameText + ' ' + 'at' + ' ' + time_data;
                    await prefs.setString(key, eventData);


                    // if (docSnapshot.exists){
                    //   await eventsCollection.doc(_focusedDay_format).update(
                    //       {'Event 2': time_data}
                    //   );
                    //   print("Document updated for Event 2");
                    // } else{
                    //   await eventsCollection.doc(_focusedDay_format).set(
                    //       {'Event 2': time_data}
                    //   );
                    //   print('Document created for Event 2');
                    // }

                    setState(() {
                      event2 = eventData;
                    });

                    dayOfYear(_focusedDay);

                    scheduleNotification(int.parse(DateFormat('dd').format(_focusedDay)),
                      int.parse(DateFormat('MM').format(_focusedDay)),
                      int.parse(DateFormat('yyyy').format(_focusedDay)),
                      int.parse(DateFormat('HH').format(eventDateTime)),
                      int.parse(DateFormat('mm').format(eventDateTime)), id,
                      'Event 2',
                      eventNameText,
                    );

                    // await scheduleTask2(eventDateTime, _focusedDay_format);
                    entry!.remove();

                  },
                  child: Container(
                    width: 150 ,
                    height: 40  ,
                    decoration: BoxDecoration(
                      color: HexColor('#CFE8EB'),
                      borderRadius: BorderRadius.circular(10 ),
                    ),
                    child: Center(
                      child: Text(AppLocalizations.of(context)!.save,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14 ,
                            fontFamily: 'Montserrat_bold'
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
      ),
    ),
  );

  void ShowSetEvent3(){
    final overlay = Overlay.of(context);

    entry = OverlayEntry(builder: (context) =>
        SetEvent3()
    );
    overlay.insert(entry!);
  }

  Widget SetEvent3() => Material(
    color: Colors.black.withOpacity(0.25),
    child: Center(
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20 ),
              border: Border.all(
                  width: 2,
                  color: Colors.black
              )
          ),
          width: 200 ,
          height: 300  ,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 12  ),
                child: Text(AppLocalizations.of(context)!.set_info,
                  style: TextStyle(
                      fontFamily: 'Montserrat_bold',
                      fontSize: 14 ,
                      color: Colors.black
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 15  , 80 , 0),
                child: Text(AppLocalizations.of(context)!.event_name,
                  style: TextStyle(
                    fontSize: 14 ,
                    fontFamily: 'Montserrat_bold',
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 15  , 30 , 0),
                child: Container(
                  width: 150 ,
                  height: 30  ,
                  child: SingleChildScrollView(
                    child: Container(
                      width: 150 ,
                      height: 30  ,
                      child: TextField(
                        controller: eventName,
                        key: ValueKey('event_name'),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          labelText: 'Enter event name',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                            borderRadius: BorderRadius.circular(10 ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 15  , 85 , 0),
                child: Text(AppLocalizations.of(context)!.enter_time,
                  style: TextStyle(
                    fontSize: 14 ,
                    fontFamily: 'Montserrat_bold',
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(padding: EdgeInsets.fromLTRB(10 , 15  , 0, 0),
                    child: Container(
                      width: 30 ,
                      height: 30  ,
                      child: SingleChildScrollView(
                        child: Container(
                          width: 30 ,
                          height: 30  ,
                          child: TextField(
                            controller: hour,
                            key: ValueKey('event_name'),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                                borderRadius: BorderRadius.circular(10 ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10 , 10  , 0, 0),
                    child: Text(":",
                      style: TextStyle(
                          fontFamily: 'Montserrat_bold',
                          fontSize: 14 ,
                          color: Colors.black
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(10 , 15  , 0, 0),
                    child: Container(
                      width: 30 ,
                      height: 30  ,
                      child: SingleChildScrollView(
                        child: Container(
                          width: 30 ,
                          height: 30  ,
                          child: TextField(
                            controller: minute,
                            key: ValueKey('event_name'),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(),
                                borderRadius: BorderRadius.circular(10 ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 25  ),
                child: GestureDetector(
                  onTap: () async {
                    eventNameText = eventName.text;
                    hourValue = int.tryParse(hour.text) ?? 0;
                    minuteValue = int.tryParse(minute.text) ?? 0;

                    // Convert hour and minute to DateTime
                    DateTime eventDateTime = DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day, hourValue, minuteValue);

                    // Add event to the Table Calendar
                    // Assuming `_focusedDay_format` is the desired format for the event
                    // Replace this with the desired logic to add events to the Table Calendar
                    print('Event Name: $eventNameText, Time: ${DateFormat('HH:mm').format(eventDateTime)}');
                    print(_focusedDay);
                    time_data = DateFormat('HH:mm').format(eventDateTime);
                    _focusedDay_format = DateFormat('dd-MM-yyyy').format(_focusedDay);
                    print(_focusedDay_format);
                    print(time_data);

                    // DocumentSnapshot docSnapshot = await eventsCollection.doc(_focusedDay_format).get();

                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String key = _focusedDay_format + ' ' + 'event3';
                    String eventData = eventNameText + ' ' + 'at' + ' ' + time_data;
                    await prefs.setString(key, eventData);

                    // if (docSnapshot.exists){
                    //   await eventsCollection.doc(_focusedDay_format).update(
                    //       {'Event 3': time_data}
                    //   );
                    //   print("Document updated for Event 3");
                    // } else{
                    //   await eventsCollection.doc(_focusedDay_format).set(
                    //       {'Event 3': time_data}
                    //   );
                    //   print('Document created for Event 3');
                    // }

                    setState(() {
                      event3 = eventData;
                    });

                    dayOfYear(_focusedDay);

                    scheduleNotification(int.parse(DateFormat('dd').format(_focusedDay)),
                      int.parse(DateFormat('MM').format(_focusedDay)),
                      int.parse(DateFormat('yyyy').format(_focusedDay)),
                      int.parse(DateFormat('HH').format(eventDateTime)),
                      int.parse(DateFormat('mm').format(eventDateTime)), id,
                      'Event 3',
                      eventNameText,
                    );

                    // await scheduleTask3(eventDateTime, _focusedDay_format);
                    entry!.remove();

                  },
                  child: Container(
                    width: 150 ,
                    height: 40  ,
                    decoration: BoxDecoration(
                      color: HexColor('#CFE8EB'),
                      borderRadius: BorderRadius.circular(10 ),
                    ),
                    child: Center(
                      child: Text(AppLocalizations.of(context)!.save,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14 ,
                            fontFamily: 'Montserrat_bold'
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
      ),
    ),
  );

  Widget build(BuildContext context){
    return ScreenUtilInit(
      designSize: Size(360,800),
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover
            )
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 44  , 0, 0),
                    child: Text(AppLocalizations.of(context)!.med,
                      style: TextStyle(
                          fontFamily: 'Montserrat-bold',
                          fontSize: 24 ,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 40  ),
                  child: Container(
                    width: 335 ,
                    height: 290  ,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12 ),
                        color: Colors.white
                    ),
                    child: TableCalendar(
                      headerStyle: HeaderStyle(
                        titleTextStyle: TextStyle(
                          fontSize: 14 ,
                        ),
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      shouldFillViewport: true,
                      firstDay: DateTime.utc(2000,01,01),
                      lastDay: DateTime.utc(2030, 12,31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      calendarStyle: CalendarStyle(
                        defaultTextStyle: TextStyle(),
                      ),
                      onDaySelected: _onDaySelected,
                      availableGestures: AvailableGestures.all,
                      selectedDayPredicate: (day) {
                        return isSameDay(day, _focusedDay);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Container(
                    width: 335,
                    height: 280,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12 ),
                        color: Colors.white
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: GestureDetector(
                            onTap: (){
                              ShowSetEvent1();
                            },
                            child: Container(
                              width: 315 ,
                              height: 60  ,
                              decoration: BoxDecoration(
                                  color: HexColor("#5490FE"),
                                  borderRadius: BorderRadius.circular(20 )
                              ),
                              child: Center(
                                child: Builder(
                                    builder: (BuildContext context) {
                                      return Text(
                                        "$event1",
                                        style: TextStyle(
                                            fontSize: 14 ,
                                            fontFamily: 'Montserrat_bold',
                                            color: Colors.white
                                        ),
                                        textAlign: TextAlign.center,
                                      );
                                    }
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8  ),
                          child: GestureDetector(
                            onTap: (){
                              ShowSetEvent2();
                            },
                            child: Container(
                              width: 315 ,
                              height: 60  ,
                              decoration: BoxDecoration(
                                  color: HexColor("#5490FE"),
                                  borderRadius: BorderRadius.circular(20 )
                              ),
                              child: Center(
                                child: Builder(
                                    builder: (BuildContext context) {
                                      return Text(
                                        "$event2",
                                        style: TextStyle(
                                            fontSize: 14 ,
                                            fontFamily: 'Montserrat_bold',
                                            color: Colors.white
                                        ),
                                        textAlign: TextAlign.center,
                                      );
                                    }
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8  ),
                          child: GestureDetector(
                            onTap: (){
                              ShowSetEvent3();
                            },
                            child: Container(
                              width: 315 ,
                              height: 60  ,
                              decoration: BoxDecoration(
                                  color: HexColor("#5490FE"),
                                  borderRadius: BorderRadius.circular(20 )
                              ),
                              child: Center(
                                child: Builder(
                                    builder: (BuildContext context) {
                                      return Text(
                                        "$event3",
                                        style: TextStyle(
                                            fontSize: 14 ,
                                            fontFamily: 'Montserrat_bold',
                                            color: Colors.white
                                        ),
                                        textAlign: TextAlign.center,
                                      );
                                    }
                                ),
                              ),
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
        ),
      ),
    );
  }
}