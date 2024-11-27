import 'package:hive/hive.dart';

part 'container.g.dart';

@HiveType(typeId: 0)
class ContainerData extends HiveObject {
  @HiveField(0)
  String key1;

  @HiveField(1)
  String value1;

  @HiveField(2)
  String key2;

  @HiveField(3)
  String value2;

  @HiveField(4)
  String key3;

  @HiveField(5)
  String value3;

  @HiveField(6)
  DateTime date;

  @HiveField(7)
  String formattedDate;

  ContainerData({
    required this.key1,
    required this.value1,
    required this.key2,
    required this.value2,
    required this.key3,
    required this.value3,
    required this.date,
    required this.formattedDate,
  });

  // Add operator overloading for map-like access
  dynamic operator [](String key) {
    switch (key) {
      case 'value1':
        return value1;
      case 'value2':
        return value2;
      case 'value3':
        return value3;
      case 'date':
        return date;
      case 'formattedDate':
        return formattedDate;
      default:
        return null;
    }
  }
}
