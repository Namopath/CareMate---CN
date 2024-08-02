import 'dart:convert';
import 'dart:io';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:caremate/pages/scan_page.dart';
import 'package:caremate/services/ble_container.dart';
import 'package:caremate/services/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caremate/services/config.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ControlPage extends StatefulWidget {
  final bool connectionState;
  const ControlPage({super.key, required this.connectionState});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  RtcEngine engine = createAgoraRtcEngine();
  // CollectionReference cam = FirebaseFirestore.instance.collection('cam');
  int remoteUid = 0;
  late bool userJoined;
  String mode = 'CT';
  String ctrExit = "CTR";
  String modeExit = "O";
  String auto= "LD";
  void initState(){
    super.initState();
    sendMode();
    // isControl();
    initAgora();
  }
  bool isAuto = false;


// To make controls work with BLE just do something with the mode command, eg if receive CT then send CTR

  @override
  void dispose() async {
    // notControl();
    engine.release();
    super.dispose();
  }

  @override
  void deactivate(){
    // notControl();
    sendExit();
    sendOver();
    super.deactivate();
  }

  // void isControl() async{
  //   // DocumentSnapshot docSnapshot = await cam.doc("cam_status").get();
  //   await cam.doc('cam_status').update(
  //       {'isControl': 'true'}
  //   );
  //   print('Control request sent');
  // }
  // void notControl() async{
  //   await cam.doc("cam_status").update({'isControl': 'false'});
  // }

  void sendExit() async{
    if (widget.connectionState) {
      final bleContainer = Provider.of<BleContainer>(context, listen: false);
      if (bleContainer.writeCharacteristic != null) {
        await bleContainer.writeCharacteristic!.write(utf8.encode(ctrExit));
        print("BLE message event 1 sent");
      } else {
        print("BLE write characteristic is not available");
      }
    }
  }

  void sendMode() async{
    if (widget.connectionState) {
      final bleContainer = Provider.of<BleContainer>(context, listen: false);
      if (bleContainer.writeCharacteristic != null) {
        await bleContainer.writeCharacteristic!.write(utf8.encode(mode));
        print("BLE message sent on page load");
      } else {
        print("BLE write characteristic is not available");
      }
    } else {
      print("BLE connection is not established");
    }
  }

  sendOver() async{
    if (widget.connectionState) {
      final bleContainer = Provider.of<BleContainer>(context, listen: false);
      if (bleContainer.writeCharacteristic != null) {
        await bleContainer.writeCharacteristic!.write(utf8.encode(modeExit));
        print("BLE message sent on page exit");
      } else {
        print("BLE write characteristic is not available");
      }
    } else {
      print("BLE connection is not established");
    }
  }

  void sendAuto() async{
    if (widget.connectionState) {
      final bleContainer = Provider.of<BleContainer>(context, listen: false);
      if (bleContainer.writeCharacteristic != null) {
        await bleContainer.writeCharacteristic!.write(utf8.encode(auto));
        print("BLE message sent on auto");
      } else {
        print("BLE write characteristic is not available");
      }
    } else {
      print("BLE connection is not established");
    }
  }

  Future<void> initAgora() async{
    await [Permission.camera].request();
    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
      appId: appid,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
    await engine.enableVideo();
    await engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    engine.registerEventHandler(
        RtcEngineEventHandler(
            onJoinChannelSuccess: (RtcConnection connection, int elapsed){
              print('User ${connection.localUid} joined');
              setState(() {
                userJoined = true;
              });
            },
            onUserJoined: (RtcConnection connection,int uid, int elapsed){
              print('Remote user $uid joined');
              setState(() {
                remoteUid = uid;
              });
            },
            onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
              print('User $uid left channel');
              setState(() {
                remoteUid = 0;
              });
            }
        )
    );
    await engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    // await engine.disableAudio();


    // await Future.delayed(Duration(seconds: 5));
    await engine.joinChannel(
      token: tkn,
      channelId: chan,
      uid: 5140,
      options: const ChannelMediaOptions(),
    );
    // await engine.disableVideo();
    engine.startPreview();
  }

  @override
  Widget build(BuildContext context) {
    return
      widget.connectionState
        ?
    Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              backgroundColor: Colors.transparent,
              title: Text(AppLocalizations.of(context)!.control,
                  style: GoogleFonts.sen(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // video from the robot
                    Container(
                      width: 320,
                      height: 275,
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                    child: remoteUid != 0 ?
                      AgoraVideoView(controller: VideoViewController.remote(
                        rtcEngine: engine,
                        canvas: VideoCanvas(uid: remoteUid),
                        connection: RtcConnection(channelId: chan),
                      )) : const CircularProgressIndicator()
                    ),

                    const SizedBox(height: 15),

                    // control panel
                    Column(
                      children: [
                        // arrow up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 5, 20),
                              child: Switch(value: isAuto, onChanged: (value){
                                if(isAuto == false){
                                  setState(() {
                                    isAuto = true;
                                  });
                                  sendAuto();
                                } else{
                                  setState(() {
                                    isAuto = false;
                                  });
                                  sendOver();
                                }
                              },
                                activeColor: Colors.blueAccent,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 65),
                              child: GestureDetector(
                                onTap: () async {
                                  await context
                                      .read<BleContainer>()
                                      .writeCharacteristic!
                                      .write(utf8.encode("F-1"));
                                },
                                child: Container(
                                  width: 110,
                                  padding: const EdgeInsets.all(15),
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: ColorAsset.primary),
                                  child: const Icon(Icons.keyboard_arrow_up,
                                      size: 44, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 35),

                        // arrow right + arrow left + stop button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // arrow right
                            GestureDetector(
                              onTap: () async {
                                await context
                                    .read<BleContainer>()
                                    .writeCharacteristic!
                                    .write(utf8.encode("TL-1"));
                              },
                              child: Container(
                                width: 110,
                                padding: const EdgeInsets.all(15),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorAsset.primary),
                                child: const Icon(Icons.keyboard_arrow_left,
                                    size: 44, color: Colors.white),
                              ),
                            ),

                            // stop button
                            GestureDetector(
                              onTap: () async {
                                await context
                                    .read<BleContainer>()
                                    .writeCharacteristic!
                                    .write(utf8.encode("S-1"));
                              },
                              child: Container(
                                width: 110,
                                padding: const EdgeInsets.all(15),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorAsset.primary),
                                child: const Icon(Icons.stop,
                                    size: 44, color: Colors.white),
                              ),
                            ),

                            // left arrow
                            GestureDetector(
                              onTap: () async {
                                await context
                                    .read<BleContainer>()
                                    .writeCharacteristic!
                                    .write(utf8.encode("TR-1"));
                              },
                              child: Container(
                                width: 110,
                                padding: const EdgeInsets.all(15),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorAsset.primary),
                                child: const Icon(Icons.keyboard_arrow_right,
                                    size: 44, color: Colors.white),
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 35),

                        // arrow down
                        GestureDetector(
                          onTap: () async {
                            await context
                                .read<BleContainer>()
                                .writeCharacteristic!
                                .write(utf8.encode("B-1"));
                          },
                          child: Container(
                            width: 110,
                            padding: const EdgeInsets.all(15),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorAsset.primary),
                            child: const Icon(Icons.keyboard_arrow_down,
                                size: 44, color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.transparent,
              title: Text(AppLocalizations.of(context)!.control,
                  style: GoogleFonts.sen(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
            body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  width: double.infinity,
                  height: 570,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      // no ble connection logo
                      Image.asset("assets/logoBLE.png", width: 250),

                      // text
                      Text("Bluetooth is Disconnected",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sen(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[300])),

                      const SizedBox(height: 275),

                      // button
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // device status + connect button
                            Column(children: [
                              // connect device
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                               ScanPage()));
                                },
                                child: Container(
                                  width: 300,
                                  height: 40,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      color: ColorAsset.secondary,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // add icon
                                      const Icon(Icons.add_circle_outline,
                                          size: 20, color: Colors.white),

                                      const SizedBox(width: 5),

                                      // text
                                      Text(AppLocalizations.of(context)!.connect_ble,
                                          style: GoogleFonts.sen(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ],
                                  ),
                                ),
                              )
                            ]
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          );
  }
}
