import 'package:caremate/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:caremate/services/config.dart';
import 'package:provider/provider.dart';
import 'package:caremate/services/ble_container.dart';

class VideoCall extends StatefulWidget{
  final bool connectionState;
  VideoCall({super.key, required this.connectionState});

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  RtcEngine engine = createAgoraRtcEngine();
  int remoteUid = 0;
  late bool userJoined;

  @override
  void initState() {
    super.initState();
    // isCall();
    initAgora();
  }

  void ListenVC() async{
    if (widget.connectionState) {
      final bleContainer = Provider.of<BleContainer>(context, listen: false);
      if (bleContainer.notifyCharacteristic != null) {
        await bleContainer.writeCharacteristic!.onValueReceived.listen((value){
          if(value == "NVC"){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage(connectionState: widget.connectionState)),
            );
          }
        });
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
              print('User joined');
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
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    // await engine.disableAudio();


    // await Future.delayed(Duration(seconds: 5));
    await engine.joinChannel(
      token: tkn,
      channelId: chan,
      uid: 5143,
      options: const ChannelMediaOptions(),
    );
    // await engine.disableVideo();
    engine.startPreview();
  }

  @override
  void dispose(){
    disposeAgora();
    super.dispose();
  }


  void disposeAgora() async{
    await engine.leaveChannel();
    await engine.release();
  }

  @override
  Widget build(BuildContext context){
    return Center(
      child: GestureDetector(
        onTap: (){
          Navigator.pop(context);
        },
        child: Container(
          width: 360,
          height: 800,
          child: remoteUid != 0 ?
          ClipRect(
            child: AgoraVideoView(controller: VideoViewController.remote(
              rtcEngine: engine,
              canvas: VideoCanvas(uid: remoteUid),
              connection: RtcConnection(channelId: chan),
            )),
          ) : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}