import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'main.dart';
import 'calendar.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final storage = FlutterSecureStorage();
  String infoText = '';
  String email = '';
  String password = '';
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _loadStoredCredentials();
  }

  Future<void> _loadStoredCredentials() async {
    email = await storage.read(key: "email") ?? '';
    setState(() {});
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
                    prefixIcon: Icon(Icons.email, color: Colors.black),
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
                Text(infoText),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,  // 新規登録ボタンを親コンテナに合わせる
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserRegistrationScreen()),
                      );
                    },
                    child: Text('新規登録はこちら'),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,  // ログインボタンを親コンテナに合わせる
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
                            return MyHomePage(title: "", events: {},);
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
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,  // 新規登録ボタンを親コンテナに合わせる
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserRegistrationScreen()),
                );
              },
              child: Text('新規登録はこちら'),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,  // ログインボタンを親コンテナに合わせる
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
                      return MyHomePage(title: "", events: {},);
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
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _loadStoredCredentials();
  }

  Future<void> _loadStoredCredentials() async {
    email = await storage.read(key: "email") ?? '';
    setState(() {});
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
                  await auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  await storage.write(key: "email", value: email);
                  await storage.write(key: "password", value: password);
                  Navigator.of(context).pop();
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
        ],
      ),
    );
  }

  Widget wideLayout() {
    return Padding(
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
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final FirebaseAuth auth = FirebaseAuth.instance;
                  await auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  await storage.write(key: "email", value: email);
                  await storage.write(key: "password", value: password);
                  Navigator.of(context).pop();
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
        ],
      ),
    );
  }
}
