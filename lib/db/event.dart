import 'package:hive/hive.dart';

part 'event.g.dart'; // 生成されたファイルをインクルード

@HiveType(typeId: 0) // ユニークなIDを指定
class Event { // 公開クラスにする場合
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String startTime;

  @HiveField(3)
  final String endTime;

  @HiveField(4)
  final String userName;

  Event({ // コンストラクタの修正
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.userName,
  });
}
