import 'package:get/get.dart';
import 'package:hive/hive.dart';

class MeetingCounter extends GetxController {
  var counter = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    try {
      var settingsBox = await Hive.openBox('settings');
      counter.value = settingsBox.get('counter', defaultValue: 0);
    } catch (e) {
      print('Error loading counter: $e');
    }
  }

  void increment() {
    counter++;
    _saveCounter();
  }

  void decrement() {
    if (counter > 0) {
      counter--;
      _saveCounter();
    }
  }

  void _saveCounter() async {
    try {
      await Hive.box('settings').put('counter', counter.value);
    } catch (e) {
      print('Error saving counter: $e');
    }
  }
}