import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gulife_shift_management_app/adminPage.dart';
import 'main.dart';
import 'calendar.dart';
import 'package:flutter/gestures.dart';
import 'Attendance_management.dart';

class AdminLoginPage extends StatefulWidget {
  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final storage = FlutterSecureStorage();
  String infoText = '';
  String email = '';
  String password = '';
  String name = '';
  bool _isObscure = true;
  User? user;
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadStoredCredentials();
  }

  Future<void> _loadStoredCredentials() async {
    email = await storage.read(key: "email") ?? '';
    setState(() {});
  }

  Future<void> _sendPasswordResetEmail() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      await auth.sendPasswordResetEmail(email: email);
      setState(() {
        infoText = 'パスワードリセットメールを送信しました。';
      });
    } catch (e) {
      setState(() {
        infoText = 'メールの送信に失敗しました: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('管理者用ログイン'),
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/images/richard-horvath-RAZU_R66vUc-unsplash.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth < 600) {
                  return narrowLayout();
                } else {
                  return wideLayout();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget narrowLayout() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: <Widget>[
                // メールアドレスのUI
                TextFormField(
                  decoration: InputDecoration(
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
                SizedBox(height: 10),
                // パスワードのUI
                TextFormField(
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: 'パスワード',
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                  obscureText: _isObscure,
                  onChanged: (String value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,  // ログインボタンを親コンテナに合わせる
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final FirebaseAuth auth = FirebaseAuth.instance;
                        // UserCredentialを取得
                        UserCredential userCredential = await auth.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        // ここでuserCredentialを使用してUserを取得
                        // User? user = userCredential.user;
                        // if (user != null) {
                        //   await user.updateDisplayName(name);  // 名前をFirebaseに保存
                        //   await user.reload();  // ユーザー情報をリロード
                        //   user = auth.currentUser;  // ユーザー情報を更新
                        // }

                        // await storage.write(key: "name", value: name);
                        await storage.write(key: "email", value: email);
                        await storage.write(key: "password", value: password);
                        await Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                            return AttendanceManagementPage();  // 管理画面に遷移
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
                SizedBox(height: 10),
                Text(infoText, style: TextStyle(color: Colors.red)),
                SizedBox(
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'パスワードを忘れた場合',
                            style: TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // タップした時の処理
                                _sendPasswordResetEmail();
                              }
                          )
                        ]
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget wideLayout() {
    return Container(
      width: 600,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
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
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: 'パスワード',
              suffixIcon: IconButton(
                icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
            ),
            obscureText: _isObscure,
            onChanged: (String value) {
              setState(() {
                password = value;
              });
            },
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,  // ログインボタンを親コンテナに合わせる
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  // UserCredentialを取得
                  UserCredential userCredential = await auth.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  // ここでuserCredentialを使用してUserを取得
                  User? user = userCredential.user;
                  if (user != null) {
                    await user.updateDisplayName(name);  // 名前をFirebaseに保存
                    await user.reload();  // ユーザー情報をリロード
                    user = auth.currentUser;  // ユーザー情報を更新
                  }

                  await storage.write(key: "name", value: name);
                  await storage.write(key: "email", value: email);
                  await storage.write(key: "password", value: password);
                  await Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) {
                      return AdminPage();  // 管理画面に遷移
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
          SizedBox(height: 10),
          Text(infoText, style: TextStyle(color: Colors.red)),
          SizedBox(
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'パスワードを忘れた場合',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // タップした時の処理
                          _sendPasswordResetEmail();
                        }
                    )
                  ]
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

