import 'package:flutter/services.dart';

class WindowChannel {
  static const _channel = MethodChannel('window_control_channel');

  static Future<void> maximize() async {
    await _channel.invokeMethod('maximize');
  }

  static Future<void> unmaximize() async {
    await _channel.invokeMethod('unmaximize');
  }

  static Future<bool> isMaximized() async {
    return await _channel.invokeMethod('isMaximized') ?? false;
  }
}
