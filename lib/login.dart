import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'firebase_options.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'main.dart';

// ログイン画面用Widget
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final storage = FlutterSecureStorage();
  String infoText = '';
  String email = '';
  String password = '';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                // メールアドレス入力
               child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelText: 'メールアドレス'
                  ),
                onChanged: (String value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
            ),
            Container(
               // パスワード入力
               padding: EdgeInsets.only(top: 20),
              child: TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelText: 'パスワード'
                  ),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
            ),
              
              Container(
                padding: EdgeInsets.all(8),
                child: Text(infoText),
              ),
              Container(
                width: double.infinity,
                // ユーザー登録ボタン
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // メール/パスワードでユーザー登録
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      await auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      // ユーザー登録に成功した場合
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return AttendanceSettingsPage();
                        }),
                      );
                    } catch (e) {
                      // ユーザー登録に失敗した場合
                      setState(() {
                        infoText = 'ユーザー登録に失敗しました: ${e.toString()}';
                      });
                    }
                  },
                  child: Text('ユーザー登録'),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                // ログインボタン
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // メール/パスワードでログイン
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      await auth.signInWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      // ログイン成功後に保存
                      await storage.write(key: "email", value: email);
                      await storage.write(key: "password", value: password);

                      // 読み取り (非同期)
                      final String storedEmail = await storage.read(key: "email") ?? "";
                      final String storedPassword = await storage.read(key: "password") ?? "";

                      // シフト表申請ページに遷移＋ログイン画面を破棄
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return AttendanceSettingsPage();
                        }),
                      );
                    } catch (e) {
                      setState(() {
                        infoText = 'ログインに失敗しました: ${e.toString()}';
                      });
                    }
                  },
                  child: Text('ログイン'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
