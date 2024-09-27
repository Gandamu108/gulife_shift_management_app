import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatefulWidget {
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  DateTime now = DateTime.now(); // 現在の時刻を取得
  final dateformat = DateFormat('yyyy年MM月dd日 EEEE', 'ja_JP'); // 日本語の曜日を表示
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
      appBar: AppBar(title: Text('勤怠管理')),
      body: Container(
        child: Center(
          child: Text('管理者画面です'),
        ),
      ),
    );
  }


}

