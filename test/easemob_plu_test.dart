import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easemob_plu/easemob_plu.dart';

void main() {
  const MethodChannel channel = MethodChannel('easemob_plu');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

}
