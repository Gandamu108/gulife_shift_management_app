import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';
import 'google_sheet.dart';
import 'calendar.dart';
import 'login.dart';
import 'view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ja_JP', null);

  final user = FirebaseAuth.instance.currentUser;

  runApp(MyApp(initialRoute: user != null ? '/attendance' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'gulifeシフト管理',
      theme: ThemeData(),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => LoginPage(),
        '/attendance': (context) => MyHomePage(title: '', events: {},),
      },
    );
  }
}

class AccountPage extends StatefulWidget {
  final User? user; // ユーザー情報を受け取る

  AccountPage({Key? key, required this.user}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

// アカウント表示
class _AccountPageState extends State<AccountPage> {
  final storage = FlutterSecureStorage();
  String? storedPassword; // パスワードを保存する変数

  @override
  void initState() {
    super.initState();
    _loadStoredCredentials(); // 初期化時にストレージからパスワードを読み込む
  }

  Future<void> _loadStoredCredentials() async {
    storedPassword = await storage.read(key: "password"); // ストレージからパスワードを読み込む
    setState(() {}); // 状態を更新
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('アカウントページ'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Center(
              child: Text('アカウント情報'),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Center(
              child: Text("メールアドレス: ${widget.user?.email ?? '未ログイン'}"),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Center(
              child: Text("パスワード: ${storedPassword ?? '非表示'}"), // パスワードを表示
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SpreadsheetDataPage()),
                  );
                },
                child: Text('履歴'),
              ),
            ),
          ),
          Container(
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) {
                    return LoginPage();
                  }),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min, // ボタンのサイズをテキストに合わせる
                children: [
                  Text('ログアウト'),
                  SizedBox(width: 8), // テキストとアイコンの間にスペースを追加
                  Icon(Icons.logout),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}