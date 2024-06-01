import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleContainer extends ChangeNotifier {
  BluetoothDevice? bluetoothDevice;
  BluetoothCharacteristic? writeCharacteristic;
  BluetoothCharacteristic? notifyCharacteristic;

  void changeDevice(BluetoothDevice device) {
    bluetoothDevice = device;
  }

  void changeWriteCharacteristic(BluetoothCharacteristic characteristic) {
    writeCharacteristic = characteristic;
  }

  void changeNotifyCharacteristic(BluetoothCharacteristic characteristic) {
    notifyCharacteristic = characteristic;
  }
}
