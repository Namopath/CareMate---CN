import 'package:caremate/services/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectedOrNotConnected extends StatefulWidget {
  const ConnectedOrNotConnected({super.key});

  @override
  State<ConnectedOrNotConnected> createState() =>
      _ConnectedOrNotConnectedState();
}

class _ConnectedOrNotConnectedState extends State<ConnectedOrNotConnected> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FlutterBluePlus.events.onConnectionStateChanged,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.connectionState ==
                BluetoothConnectionState.connected) {
              return Navigation(connectionState: true);
            } else {
              return Navigation(connectionState: false);
            }
          }
          return Navigation(connectionState: false);
        });
  }
}
