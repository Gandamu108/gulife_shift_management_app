import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AttendanceManagementPage extends StatefulWidget {
  @override
  State<AttendanceManagementPage> createState() => _AttendanceManagementPageState();
}

class _AttendanceManagementPageState extends State<AttendanceManagementPage> {
  DateTime now = DateTime.now(); // 現在の時刻を取得
  final dateformat = DateFormat('yyyy年MM月dd日 (E)', 'ja_JP'); // 日本語の曜日を表示
  final timeformat = DateFormat('HH時mm分ss秒'); // 時間用フォーマット
  late Timer timer; // Timerを使用するための変数
  String status = ''; // 出勤・退勤ステータスを保持
  User? user;
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // 1秒ごとに現在時刻を更新する
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        now = DateTime.now(); // 現在時刻を更新
      });
    });
  }
  
  @override
  void dispose() {
    timer.cancel(); // Timerを停止してメモリリークを防ぐ
    super.dispose();
  }

   // ユーザーデータを取得する非同期メソッド
  Future<void> _loadUserData() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user?.displayName;
        userEmail = user?.email;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final day = dateformat.format(now); // 日付を日本語で表示
    final time = timeformat.format(now); // 時間はそのまま表示
    // フォーマットされた日時を Text ウィジェットでリアルタイム表示
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Container(
        child: Center( // 全体を中央揃えにする
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 垂直方向に中央揃え
            children: [
              Text(
                day, // 日付を表示
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10), // 日付と時間の間にスペースを追加
              Text(
                time, // 時間を表示
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20), // 時間とボタンの間にスペースを追加
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // ボタンを中央揃え
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10), // ボタン間のスペース
                    child: ElevatedButton(
                      onPressed: () {
                        // 出勤ボタンの処理
                        status = '出勤';
                        _saveDate(status); // 日付を保存
                      },
                      child: Text('出勤'),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10), // ボタン間のスペース
                    child: ElevatedButton(
                      onPressed: () {
                        // 退勤ボタンの処理
                        status = '退勤';
                        _saveDate(status); // 日付を保存
                      },
                      child: Text('退勤'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _saveDate(String action) {
    // 日付と時間を取得
    final String dateTime = DateFormat('yyyy/MM/dd HH:mm:ss').format(now);
    // ステータスと日時を表示（または保存処理）
    print('名前: $userName 日付: $dateTime ステータス: $action');
  }

}