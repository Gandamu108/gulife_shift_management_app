import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gulife_shift_management_app/editing.dart';
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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'Attendance_management.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db/event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ja_JP', null);
  await Hive.initFlutter();
  Hive.registerAdapter(EventAdapter());

  final user = FirebaseAuth.instance.currentUser;

  // ストレージからパスワードを読み込む
  await _loadStoredCredentials();

  runApp(MyApp(initialRoute: user != null ? '/attendance' : '/login'));
}

Future<void> _loadStoredCredentials() async {
  final box = await Hive.openBox('userData');
  String? storedPassword = await box.get('password'); // ストレージからパスワードを読み込む
  // 必要に応じて、ここで状態を更新する処理を追加
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
        '/attendance': (context) => AttendanceSettingsPage(),
      },
    );
  }
}

class AttendanceSettingsPage extends StatefulWidget {
  @override
  _AttendanceSettingsPageState createState() => _AttendanceSettingsPageState();
}

class _AttendanceSettingsPageState extends State<AttendanceSettingsPage> {
  List<String> weekdays = ['月', '火', '水', '木', '金', '土', '日'];
  Map<String, TextEditingController> _startTimeControllers = {};
  Map<String, TextEditingController> _endTimeControllers = {};
  Map<DateTime, List<String>> events = {};
  User? _user;
  String? storedPassword;
  String? userName;
  String? userEmail;
  bool isMobile = !kIsWeb;
  late Box<Event> box; // ボックスの変数を追加
    
  @override
  void initState() {
    _openBox();
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    weekdays.forEach((day) {
      _startTimeControllers[day] = TextEditingController();
      _endTimeControllers[day] = TextEditingController();
    });
    _loadStoredCredentials(); // 初期化時にストレージから読み込む
  }
  
  Future<void> _loadStoredCredentials() async {
    final box = await Hive.openBox('userData');
    storedPassword = await box.get('password'); // ストレージからパスワードを読み込む
    userName = await box.get('name'); // ユーザー名を読み込む
    userEmail = await box.get('email'); // ユーザーのメールアドレスを読み込む
    setState(() {}); // 状態を更新
  }

  Future<void> _saveUserData() async {
  final box = await Hive.openBox('userData');
  await box.put('name', _user?.displayName);
  await box.put('email', _user?.email);
  await box.put('password', storedPassword);
  }

  Future<void> _openBox() async {
    box = await Hive.openBox<Event>('events'); // 'events'という名前のボックスを開く
  }

  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text('gulife シフト表申請ページ'),
        actions: <Widget>[
          if (_user != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: IconButton(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccountPage(user: _user)),
                      );
                    },
                    icon: Icon(Icons.account_circle),
                  ),
                ),
              ),
          ],
        ],
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/images/richard-horvath-RAZU_R66vUc-unsplash.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
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
      child: Column(
        children: <Widget>[
          Column(
            children: weekdays.map((day) {
              return Container(
                margin: EdgeInsets.only(top: 20, bottom: 0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 0, left: 20, right: 0, bottom: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold,
                              // backgroundColor: Colors.white.withOpacity(0.5),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9:]')
                          ),
                        ],
                        controller: _startTimeControllers[day],
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: '開始希望時刻を入力してください',
                          labelText: '開始希望時刻',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () {
                          _showTimePicker(context, _startTimeControllers[day]!);
                        },
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9:]')
                          ),
                        ],
                        controller: _endTimeControllers[day],
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: '終了希望時刻を入力してください',
                          labelText: '終了希望時刻',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () {
                          _showTimePicker(context, _endTimeControllers[day]!);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Container(
            padding: EdgeInsets.only(top: 30, bottom: 50),
            child: ElevatedButton(
              onPressed: () {
                _saveData();
                String userEmail = _user?.email ?? '';
                sendEventToSheet(events, userEmail);
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(100, double.infinity),
              ),
              child: Text(
                '申請',
                style: TextStyle(
                  fontSize: 25,
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
      padding: EdgeInsets.only(left: 300, right: 300),
      child: Column(
        children: <Widget>[
          Column(
            children: weekdays.map((day) {
              return Container(
                margin: EdgeInsets.only(top: 20, bottom: 0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 0, left: 20, right: 0, bottom: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold,
                              // backgroundColor: Colors.white.withOpacity(0.5),
                              color: Colors.white
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9:]')
                          ),
                        ],
                        controller: _startTimeControllers[day],
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: '開始希望時刻を入力してください',
                          labelText: '開始希望時刻',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () {
                          _showTimePicker(context, _startTimeControllers[day]!);
                        },
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9:]')
                          ),
                        ],
                        controller: _endTimeControllers[day],
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: '終了希望時刻を入力してください',
                          labelText: '終了希望時刻',
                          border: OutlineInputBorder(),
                        ),
                        onTap: () {
                          _showTimePicker(context, _endTimeControllers[day]!);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Container(
            padding: EdgeInsets.only(top: 30, bottom: 50),
            child: ElevatedButton(
              onPressed: () {
                _saveData();
                // String userEmail = _user?.email ?? '';
                // sendEventToSheet(events, userEmail);
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(100, 90),
              ),
              child: Text(
                '申請',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(BuildContext context, TextEditingController controller) async {
    if (kIsWeb) {
      TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext ddcontext, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
      );
      if (picked != null) {
        setState(() {
          controller.text = picked.format(context);
        });
      }
    } else {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).size.height / 10,
            width: double.infinity,
            child: TimePickerSpinnerPopUp(
              mode: CupertinoDatePickerMode.time,
              initTime: DateTime.now(),
              onChange: (dateTime) {
                setState(() {
                  controller.text = dateTime.toString().substring(11, 16);
                });
              },
            ),
          );
        },
      );
    }
  }

  void _saveData() async {
    Map<DateTime, List<String>> newEvents = {};
    final int maxEventsPerDay = 1;

    Map<int, String> weekdayNames = {
      DateTime.monday: '月',
      DateTime.tuesday: '火',
      DateTime.wednesday: '水',
      DateTime.thursday: '木',
      DateTime.friday: '金',
      DateTime.saturday: '土',
      DateTime.sunday: '日',
    };

    DateTime now = DateTime.now();
    DateTime nextMonthFirstDay = (now.month == 12)
      ? DateTime(now.year + 1, 1, 1)
      : DateTime(now.year, now.month + 1, 1);

    for (var weekday in weekdayNames.keys) {
      String dayName = weekdayNames[weekday]!;

      if (_startTimeControllers[dayName] != null && _endTimeControllers[dayName] != null) {
        String startTime = _startTimeControllers[dayName]!.text;
        String endTime = _endTimeControllers[dayName]!.text;
        DateTime nextWeekday = _getNextWeekday(nextMonthFirstDay, weekday);

        while (nextWeekday.month == nextMonthFirstDay.month) {
          if (!newEvents.containsKey(nextWeekday)) {
            newEvents[nextWeekday] = [];
          }
          if (startTime.isNotEmpty) {
            newEvents[nextWeekday]!.add('開始希望時間: $startTime');
          }
          if (endTime.isNotEmpty) {
            newEvents[nextWeekday]!.add('終了希望時間: $endTime');
          }
          nextWeekday = nextWeekday.add(Duration(days: 7));
        }
      }
    }

    final sortedKeys = newEvents.keys.toList()..sort();
    for (var key in sortedKeys) {
      if (events.containsKey(key)) {
        if (events[key]!.length < maxEventsPerDay) {
          events[key]!.addAll(newEvents[key]!);
        }
      } else {
        events[key] = newEvents[key]!;
      }
      
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(title: 'gulife', events: events),
      ),
    );
  }

  DateTime _getNextWeekday(DateTime referenceDate, int weekday) {
    int daysToNextWeekday = (weekday - referenceDate.weekday + 7) % 7;
    if (daysToNextWeekday == 0) daysToNextWeekday = 7;
    return referenceDate.add(Duration(days: daysToNextWeekday));
  }
}

class AccountPage extends StatefulWidget {
  final User? user;
  // final Box<Event> box;


  AccountPage({required this.user, });

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final storage = FlutterSecureStorage();
  String? storedPassword; // パスワードを保存する変数
  User? user;
  String? userName;
  String? userEmail;
  bool _isObscure = true;
  final String spreadsheetId = '1b3FHCRutgJEzoS6NAvGiJ6iPeBCUlVEnDfX4EbX8v7w'; // スプレッドシートのIDを指定

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 初期化時にユーザー情報を読み込む
    _loadStoredCredentials(); // 初期化時にストレージからパスワードを読み込む
  }

  // ユーザーデータを取得する非同期メソッド
  Future<void> _loadUserData() async {
  user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    setState(() {
      userName = user?.displayName;
      userEmail = user?.email;
    });
    await _saveUserData(); // ユーザーデータを保存
  }
}

    Future<void> _saveUserData() async {
  final box = await Hive.openBox('userData');
  await box.put('name', user?.displayName);
  await box.put('email', user?.email);
  await box.put('password', storedPassword);
}

  Future<void> _loadStoredCredentials() async {
  final box = await Hive.openBox('userData');
  storedPassword = await box.get('password'); // ストレージからパスワードを読み込む
  setState(() {}); // 状態を更新
}

  Future<void> _deleteUserData() async {
    // ボックスを開いて、全てのデータを削除
    Box<Event> box = await Hive.openBox<Event>('events'); // 'events'という名前のボックスを開く
    await box.clear(); // ボックス内の全てのデータを削除
    if (userName != null) { // userNameがnullでないことを確認
      await deleteUserEntries(spreadsheetId, userName!); // userNameを非nullのStringとして渡す
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'アカウントページ',
          style: TextStyle(fontSize: 30),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Center(
              child: Text(
                'アカウント情報',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Center(
              child: Text(
                'メールアドレス: $userEmail',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              '名前: $userName',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 10),
            child: Center(
              child: Text(
                "パスワード: ${storedPassword ?? '非表示'}",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            child: ElevatedButton(
              onPressed: () async {
                // 確認ダイアログを表示
                bool? confirmDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('データ削除確認'),
                      content: Text('全てのデータを削除しますか？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('削除'),
                        ),
                      ],
                    );
                  },
                );

                // 確認された場合、データを削除
                if (confirmDelete == true) {
                  await _deleteUserData(); // データ削除メソッドを呼び出す
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('全てのデータが削除されました')),
                  );
                }
              },
              child: Text('全データ削除'),
            ),
          ),
          SizedBox(height: 10),
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

