import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'main.dart';
import 'package:flutter/gestures.dart';
import 'admin_login.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
                    // prefixIcon: Icon(Icons.email, color: Colors.black),
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
                TextFormField(
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: '名前',
                  ),
                  onChanged: (String value) {
                    setState(() {
                      name = value;
                      print(user?.displayName);  // ここでnameの値を確認
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
                // SizedBox(height: 8),
                SizedBox(
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          const TextSpan(
                          text: 'アカウントが未登録ですか？',
                          style: TextStyle(color: Colors.white)),
                          TextSpan(
                            text: 'アカウントの作成',
                            style: TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // ここにタップ時のアクションを追加します
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => UserRegistrationScreen()),
                                );
                              },
                          ),
                        ]
                      ),
                    ),
                  ),
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
                SizedBox(height: 20),
                SizedBox(
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          const TextSpan(
                          text: '管理者ですか？',
                          style: TextStyle(color: Colors.white)),
                          TextSpan(
                            text: '管理者専用ログイン画面へ',
                            style: TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // ここにタップ時のアクションを追加します
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AdminLoginPage()),
                                );
                              },
                          ),
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
      padding: EdgeInsets.all(24),
      width: 600,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 20),
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
              labelText: '名前',
              ),
              onChanged: (String value) {
                setState(() {
                  name = value;
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
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    const TextSpan(
                    text: 'アカウントが未登録ですか？',
                    style: TextStyle(color: Colors.white)),
                    TextSpan(
                      text: 'アカウントの作成',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // ここにタップ時のアクションを追加します
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserRegistrationScreen()),
                          );
                        },
                    ),
                  ]
                ),
              ),
            ),
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
          SizedBox(height: 5),
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
          SizedBox(height: 20),
          SizedBox(
            child: Center(
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    const TextSpan(
                    text: '管理者ですか？',
                    style: TextStyle(color: Colors.white)),
                    TextSpan(
                      text: '管理者専用ログイン画面へ',
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // ここにタップ時のアクションを追加します
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AdminLoginPage()),
                          );
                        },
                    ),
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

// UserRegistrationScreen
class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
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
        title: Text('ユーザー登録'),
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
                print(user?.displayName);  // ここでnameの値を確認
              });
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelText: '名前',
            ),
            onChanged: (String value) {
              setState(() {
                name= value;
              });
            },
          ),
            
          SizedBox(height: 20),
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
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  // UserCredential を取得
                  UserCredential userCredential = await auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  // Firebaseにユーザーが作成された後、名前を追加
                  User? user = userCredential.user;
                  if (user != null) {
                    await user.updateDisplayName(name);  // 名前をFirebaseに保存
                    await user.reload();  // ユーザー情報をリロード
                    user = auth.currentUser;  // ユーザー情報を更新
                    // 名前やメールアドレス、パスワードをFlutterSecureStorageに保存
                    await storage.write(key: 'name', value: name);
                    await storage.write(key: "email", value: email);
                    await storage.write(key: "password", value: password);
                    // 登録完了後に画面を閉じる
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  setState(() {
                    infoText = '登録に失敗しました: ${e.toString()}';
                  });
                }
              },
              child: Text('登録'),
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
                print(user?.displayName);  // ここでnameの値を確認
              });
            },
          ),
          SizedBox(height: 20),
          TextFormField(
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              labelText: '名前',
            ),
            onChanged: (String value) {
              setState(() {
                name = value;
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
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  // UserCredential を取得
                  UserCredential userCredential = await auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  // Firebaseにユーザーが作成された後、名前を追加
                  User? user = userCredential.user;
                  if (user != null) {
                    await user.updateDisplayName(name);  // 名前をFirebaseに保存
                    await user.reload();  // ユーザー情報をリロード
                    user = auth.currentUser;  // ユーザー情報を更新
                    // 名前やメールアドレス、パスワードをFlutterSecureStorageに保存
                    await storage.write(key: 'name', value: name);
                    await storage.write(key: "email", value: email);
                    await storage.write(key: "password", value: password);
                    // 登録完了後に画面を閉じる
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  setState(() {
                    infoText = '登録に失敗しました: ${e.toString()}';
                  });
                }
              },
              child: Text('登録'),
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