import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'main.dart';

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
      // 背景画像を設定
      body: Stack(
        children: <Widget>[
          // 背景画像
          Positioned.fill(
            child: Image.asset(
              'assets/images/jerome-prax-cr6U8ilcdIc-unsplash.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // コンテンツのレイアウト
          Center(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth < 600) {
                  // 狭い画面用のレイアウト
                  return narrowLayout();
                } else {
                  // 広い画面用のレイアウト
                  return wideLayout();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // 狭い画面用のUI
  Widget narrowLayout() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.account_circle,
            size: 500,
            color: Colors.black,
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    // 背景色を設定
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: 'メールアドレス',
                  ),
                  onChanged: (String value) {
                    setState(() {
                      email = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    // 背景色を設定
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: 'パスワード',
                  ),
                  obscureText: true,
                  onChanged: (String value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                Text(infoText),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final FirebaseAuth auth = FirebaseAuth.instance;
                        await auth.createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        await Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                            return AttendanceSettingsPage();
                          }),
                        );
                      } catch (e) {
                        setState(() {
                          infoText = 'ユーザー登録に失敗しました: ${e.toString()}';
                        });
                      }
                    },
                    child: Text('ユーザー登録'),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final FirebaseAuth auth = FirebaseAuth.instance;
                        await auth.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );
                        await storage.write(key: "email", value: email);
                        await storage.write(key: "password", value: password);
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
        ],
      ),
    );
  }

  // 広い画面用のUI
  Widget wideLayout() {
    return Container(
      padding: EdgeInsets.all(24),
      width: 600,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.account_circle,
            size: 500,
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              // 背景色を設定
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: 'メールアドレス',
            ),
            onChanged: (String value) {
              setState(() {
                email = value;
              });
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              // 背景色を設定
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: 'パスワード',
            ),
            obscureText: true,
            onChanged: (String value) {
              setState(() {
                password = value;
              });
            },
          ),
          SizedBox(height: 10),
          Text(infoText),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  await auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  await Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) {
                      return AttendanceSettingsPage();
                    }),
                  );
                } catch (e) {
                  setState(() {
                    infoText = 'ユーザー登録に失敗しました: ${e.toString()}';
                  });
                }
              },
              child: Text('ユーザー登録'),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  await auth.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  await storage.write(key: "email", value: email);
                  await storage.write(key: "password", value: password);
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
    );
  }
}
