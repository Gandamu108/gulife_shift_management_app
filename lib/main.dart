import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';
import 'google_sheet.dart';
import 'calendar.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'; 




void main() async{
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
        '/attendance': (context) => AttendanceSettingsPage(),
        // 他のルートもここに追加できます
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

  // 曜日ごとに開始時間と終了時間を管理するためのコントローラーを作成
  Map<String, TextEditingController> _startTimeControllers = {};
  Map<String, TextEditingController> _endTimeControllers = {};
  // イベントを保存するMap
  Map<DateTime, List<String>> events = {};

  User? _user;
  bool isMobile = !kIsWeb;
    
  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    // 各曜日に対応するコントローラーを初期化
    weekdays.forEach((day) {
      _startTimeControllers[day] = TextEditingController();
      _endTimeControllers[day] = TextEditingController();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 206, 206, 206),
        title: const Text('gulife シフト表申請ページ'),
        actions: <Widget>[
          if (_user != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  'ログインユーザー: ${_user!.email}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ),
          ],
          IconButton(
            onPressed: () async {
              // ログアウト処理
              // 内部で保持しているログイン情報等が初期化される
              await FirebaseAuth.instance.signOut();
              // ログイン画面に遷移＋シフト申請画面を破棄
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return LoginPage();
                }),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          // 背景画像
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
                // 狭い画面用のレイアウト
                return narrowLayout();
              } else {
                // 広い画面用のレイアウト
                return wideLayout();
              }
            },
          ),
        )
      ],
    )  
  );
  }
  // 狭い画面のレイアウト
  Widget narrowLayout() {
  return Container(
    child: Column(
    children: <Widget>[
      // 曜日のリストを縦に並べる
      Column(
        children: weekdays.map((day) {
          return Container(
            margin: EdgeInsets.only(top: 20, bottom: 0), // 上下にスペースを追加
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
                          backgroundColor: Colors.white.withOpacity(0.5), // 50%透明な白色
                          
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10), // テキストと入力フィールドの間にスペースを追加
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
                      // 背景色を設定
                      fillColor: Colors.white,
                      filled: true,
                      hintText: '開始希望時刻を入力してください',
                      labelText: '開始希望時刻',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () {
                      if (isMobile) {
                        // モバイル用の処理（この部分は後で追加するかもしれません）
                      }
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
                       // 背景色を設定
                      fillColor: Colors.white,
                      filled: true,
                      hintText: '終了希望時刻を入力してください',
                      labelText: '終了希望時刻',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () {
                      if (isMobile) {
                        // モバイル用の処理（この部分は後で追加するかもしれません）
                      }
                      _showTimePicker(context, _endTimeControllers[day]!);
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
      // ボタンの配置
      Container(
        padding: EdgeInsets.only(top: 30, bottom: 50),
        child: ElevatedButton(
          onPressed: () {
            _saveData();
            String userEmail = _user?.email ?? ''; // ログインユーザーのメールアドレスを取得
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
// 広い画面のレイアウト
Widget wideLayout() {
  return Container(
    // width: 800,
    padding: EdgeInsets.only(left: 300, right: 300),
    child: Column(
    children: <Widget>[
      // 曜日のリストを縦に並べる
      Column(
        children: weekdays.map((day) {
          return Container(
            margin: EdgeInsets.only(top: 20, bottom: 0), // 上下にスペースを追加
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
                          backgroundColor: Colors.white.withOpacity(0.5), // 50%透明な白色
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10), // テキストと入力フィールドの間にスペースを追加
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
                       // 背景色を設定
                      fillColor: Colors.white,
                      filled: true,
                      hintText: '開始希望時刻を入力してください',
                      labelText: '開始希望時刻',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () {
                      if (isMobile) {
                        // モバイル用の処理（この部分は後で追加するかもしれません）
                      }
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
                       // 背景色を設定
                      fillColor: Colors.white,
                      filled: true,
                      hintText: '終了希望時刻を入力してください',
                      labelText: '終了希望時刻',
                      border: OutlineInputBorder(),
                    ),
                    onTap: () {
                      if (isMobile) {
                        // モバイル用の処理（この部分は後で追加するかもしれません）
                      }
                      _showTimePicker(context, _endTimeControllers[day]!);
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
      // ボタンの配置
      Container(
        padding: EdgeInsets.only(top: 30, bottom: 50),
        child: ElevatedButton(
          onPressed: () {
            _saveData();
            String userEmail = _user?.email ?? ''; // ログインユーザーのメールアドレスを取得
            sendEventToSheet(events, userEmail);
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
      // Webの場合
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
      // モバイルの場合
      showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 10,
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
     
    Map<DateTime, List<String>> newEvents = {}; // 新しいイベントマップ
    final int maxEventsPerDay = 1; // 1日あたりの最大イベント数

    // 曜日ごとのインデックスと日本語名を定義
    Map<int, String> weekdayNames = {
      DateTime.monday: '月',
      DateTime.tuesday: '火',
      DateTime.wednesday: '水',
      DateTime.thursday: '木',
      DateTime.friday: '金',
      DateTime.saturday: '土',
      DateTime.sunday: '日',
    };

    // 現在の日付
    DateTime now = DateTime.now();
    // // 翌月にする
    // DateTime nextMonthFirstDay = (now.month == 12)
    //   ? DateTime(now.year + 1, 1, 1)
    //   : DateTime(now.year, now.weekday + 1, 1);
    // 今月の初日
    DateTime thisMonthFirstDay = DateTime(now.year, now.month, 1);
  //   // 各曜日について処理
  //   for (var weekday in weekdayNames.keys) {
  //     String dayName = weekdayNames[weekday]!;

  //     // コントローラーが null でないことを確認する
  //     if (_startTimeControllers[dayName] != null && _endTimeControllers[dayName] != null) {
  //       String startTime = _startTimeControllers[dayName]!.text;
  //       String endTime = _endTimeControllers[dayName]!.text;

  //       // 次の対応する曜日の日付を計算
  //       DateTime nextWeekday = _getNextWeekday(nextMonthFirstDay, weekday);

  //       // 月ごとのイベントを追加
  //       while (nextWeekday.month == nextMonthFirstDay.month) {
  //         if (newEvents.containsKey(nextWeekday)) {
  //           if (startTime.isNotEmpty) {
  //             newEvents[nextWeekday]!.add('開始希望時間: $startTime');
  //           }
  //           if (endTime.isNotEmpty) {
  //             newEvents[nextWeekday]!.add('終了希望時間: $endTime');
  //           }
  //         } else {
  //           //新しいイベントを追加
  //           newEvents[nextWeekday] = [];
  //           if (startTime.isNotEmpty) {
  //             newEvents[nextWeekday]!.add('開始希望時間: $startTime');
  //           }
  //           if (endTime.isNotEmpty) {
  //             newEvents[nextWeekday]!.add('終了希望時間: $endTime');
  //           }
  //         }
  //         nextWeekday = nextWeekday.add(Duration(days: 7)); // 次の週の同じ曜日
  //       }
  //     }
  //   }

  //   // ソートしてから追加
  //   final sortedKeys = newEvents.keys.toList()..sort();
  //   for (var key in sortedKeys) {
  //     if (events.containsKey(key)) {
  //       if (events[key]!.length < maxEventsPerDay) {
  //         events[key]!.addAll(newEvents[key]!);
  //       }
  //     } else {
  //       events[key] = newEvents[key]!;
  //     }
  //   }

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => MyHomePage(title: 'gulife', events: events),
  //     ),
  //   );
  // }

  // DateTime _getNextWeekday(DateTime referenceDate, int weekday) {
  //   int daysToNextWeekday = (weekday - referenceDate.weekday + 7) % 7;
  //   if (daysToNextWeekday == 0) daysToNextWeekday = 7;
  //   return referenceDate.add(Duration(days: daysToNextWeekday));
  // }
// }
 // 各曜日について処理
  for (var weekday in weekdayNames.keys) {
    String dayName = weekdayNames[weekday]!;

    // コントローラーが null でないことを確認する
    if (_startTimeControllers[dayName] != null && _endTimeControllers[dayName] != null) {
      String startTime = _startTimeControllers[dayName]!.text;
      String endTime = _endTimeControllers[dayName]!.text;

      // 次の対応する曜日の日付を計算
      DateTime nextWeekday = _getNextWeekday(thisMonthFirstDay, weekday);

      // 今月のイベントを追加
      while (nextWeekday.month == thisMonthFirstDay.month) {
        if (newEvents.containsKey(nextWeekday)) {
          if (startTime.isNotEmpty) {
            newEvents[nextWeekday]!.add('開始希望時間: $startTime');
          }
          if (endTime.isNotEmpty) {
            newEvents[nextWeekday]!.add('終了希望時間: $endTime');
          }
        } else {
          // 新しいイベントを追加
          newEvents[nextWeekday] = [];
          if (startTime.isNotEmpty) {
            newEvents[nextWeekday]!.add('開始希望時間: $startTime');
          }
          if (endTime.isNotEmpty) {
            newEvents[nextWeekday]!.add('終了希望時間: $endTime');
          }
        }
        nextWeekday = nextWeekday.add(Duration(days: 7)); // 次の週の同じ曜日
      }
    }
  }

  // ソートしてから追加
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