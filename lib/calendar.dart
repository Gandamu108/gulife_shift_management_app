import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'google_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; 
import 'main.dart';
import 'db/event.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.events}) : super(key: key);

  final String title;
  final Map<DateTime, List<String>> events;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User? user;
  late Box<Event> box; // ボックスの変数を追加
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser; // ユーザーを取得
    _openBox().then((_) => _loadEvents()); // ボックスを開いた後にイベントを読み込む
  }
  Future<void> _openBox() async {
  box = await Hive.openBox<Event>('events'); // 'events'という名前のボックスを開く
}

Future<void> _loadEvents() async {
  final allEvents = box.toMap(); // すべてのイベントを取得
  allEvents.forEach((key, value) {
    if (value is Event) {
      DateTime eventDate = value.date;
      widget.events[eventDate] = [value.startTime, value.endTime]; // イベントをマップに追加
    }
  });
}

  String _startTime = '';
  String _endTime = '';
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd-EEE', 'ja_JP');
  final List<DateTime> selectedDays = [];
  String _formattedDate = '';
  List<String> _formattedDateList = [];
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  bool _isChecked = false;
  List<String> _selectedEvents = [];
  bool isMobile = !kIsWeb;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String? userName;
  String? userEmail;
  bool isLoading = false; // ローディング状態の管理


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('シフト申請カレンダー'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle), // アカウントアイコン
            onPressed: () {
              User? user = FirebaseAuth.instance.currentUser;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountPage(user: user)),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          
          // Positioned.fill(
          //   child: Image.asset(
          //     // <a href="https://unsplash.com/ja/%E5%86%99%E7%9C%9F/%E8%B5%A4%E9%BB%84%E3%83%94%E3%83%B3%E3%82%AF%E3%81%AE%E6%8A%BD%E8%B1%A1%E7%94%BB-RAZU_R66vUc?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a>の<a href="https://unsplash.com/ja/@ricvath?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Richard Horvath</a>が撮影した写真
          //     'assets/images/richard-horvath-RAZU_R66vUc-unsplash.jpg',
          //     fit: BoxFit.cover,
          //   ),
          // ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: Colors.white.withOpacity(1.0),
                        // カレンダー表示
                        child: TableCalendar(
                           // カレンダーの上の部分のスタイルを変えるためのやつ
                          headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true, 
                          ),
                          locale: 'ja_JP',
                          firstDay: DateTime.utc(2000, 1, 1),
                          lastDay: DateTime.utc(3000, 12, 31),
                          focusedDay: _focused,
                          eventLoader: (date) {
                            final keyDate = DateTime(date.year, date.month, date.day);
                            return widget.events[keyDate] ?? [];
                          },
                          selectedDayPredicate: (day) {
                            return selectedDays.any((selectedDay) => DateTime(selectedDay.year, selectedDay.month, selectedDay.day) == DateTime(day.year, day.month, day.day));
                          },
                          onDaySelected: (selected, focused) {
                            setState(() {
                              _selected = selected;
                              _focused = focused;
                              _selectedEvents = widget.events[DateTime(selected.year, selected.month, selected.day)] ?? [];
                              _startTimeController.text = ''; // 初期化
                              _endTimeController.text = ''; // 初期化
                              // 選択した日のイベントがあれば、開始終了時刻を設定
                              if (_selectedEvents.isNotEmpty) { // リストが空でないことを確認
                                _startTimeController.text = _selectedEvents[0].split(', ')[0]; // 開始時刻を取得
                                _endTimeController.text = _selectedEvents[1].split(', ')[0]; // 終了時刻を取得
                                print(_selectedEvents);
                              } else {
                                print("選択されたイベントがありません。");
                              }
                            });
                            // 選択した日付を管理
                            if (selectedDays.any((selectedDay) => DateTime(selectedDay.year, selectedDay.month, selectedDay.day) == DateTime(selected.year, selected.month, selected.day))) {
                              selectedDays.remove(selected);
                            } else {
                              selectedDays.add(selected);
                            }
                            formatSelectedDays();
                            print(_formattedDateList);
                          },
                        ),
                      ),
                      
                      if (selectedDays.isNotEmpty) _buildNoteInput(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoteInput() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: Colors.white,
                  child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9:]')
                          ),
                        ],
                        controller: _startTimeController,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          icon: Icon(
                            Icons.access_time,
                            size: 40,
                          ),
                          labelText: '開始希望時刻 *',
                        ),
                        readOnly: !kIsWeb,
                        onTap: () {
                          _showTimePicker(context, _startTimeController);
                        },
                      ),
                    ),
                  ],
                ),
                ),
                Container(
                  color: Colors.white,
                  child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z0-9:]'),
                    ),
                  ],
                  controller: _endTimeController,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    icon: Icon(
                      Icons.access_time_filled_rounded,
                      size: 40,
                    ),
                    labelText: '終了希望時刻 *',
                  ),
                  readOnly: !kIsWeb,
                  onTap: () {
                    _showTimePicker(context, _endTimeController);
                  },
                ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _startTimeController.clear();
                      _endTimeController.clear();
                      selectedDays.clear();
                      _formattedDateList.clear();
                      setState(() {
                        _selectedEvents.clear();
                      });
                    },
                    child: Text('キャンセル'),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                      child: ElevatedButton(
                        onPressed:  () async {
                          await _loadData();
                          await _saveData();
                          await _showDialog(context);
                      },
                    child: const Text("追加"),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(100, 90),
                      textStyle: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ),
            ],
          ),
      )
    ),
      ],
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 背景タップで閉じないようにする
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("読み込み中...", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('申請されました'),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                // OKボタンの処理
                Navigator.of(context).pop();
                setState(() {
                  isLoading = false; // ローディング終了
                });

              },
            ),
          ],
        );
      }
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              // height: 150,
              width: 300,
              child: TimePickerSpinnerPopUp(
                mode: CupertinoDatePickerMode.time,
                initTime: DateTime.now(),
                onChange: (dateTime) {
                  setState(() {
                    controller.text = dateTime.toString().substring(11, 16);
                  });
                  Navigator.of(context).pop(); // ダイアログを閉じる
                },
              ),
            ),
          );
        },
      );
    }
  }

  void formatSelectedDays() {
    _formattedDateList.clear();
    for (DateTime day in selectedDays) {
      _formattedDateList.add(dateFormat.format(day));
    }
  }

  Future<void> _saveData() async {
    String startTime = _startTimeController.text;
    String endTime = _endTimeController.text;

    // 選択された日付にイベントを追加
    for (var date in selectedDays) {
      DateTime eventDate = DateTime(date.year, date.month, date.day);
      widget.events[eventDate] = [startTime, endTime]; // 選択された日付にイベントを追加
      String eventId = '${eventDate.toIso8601String()}_$startTime'; // 一意のIDを生成

    Event event = Event(
      id: eventId,
      date: eventDate,
      startTime: startTime,
      endTime: endTime,
      userName: user?.displayName ?? '匿名',
    );
    // すでに存在するイベントを削除
    if (await box.containsKey(eventId)) {
      await box.delete(eventId); // IDを指定して削除
      print('データが削除されました: $eventId');
    }

    await box.put(eventId, event); // イベントを保存
    print('Event ID: ${event.id}, Date: ${event.date}, Start Time: ${event.startTime}, End Time: ${event.endTime}, User Name: ${event.userName}');
    }

    // スプレッドシートに送信
    String userEmail = user?.email ?? '';
    String userNmae = user?.displayName ?? '';
    await sendEventToSheet(widget.events, userNmae); // widget.eventsを送信
    
    // UIのリセット
    _startTimeController.clear();
    _endTimeController.clear();
    selectedDays.clear();
    _formattedDateList.clear();
    setState(() {
      _selectedEvents.clear();
    });

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
  // 非同期処理
  Future<void> _loadData() async {
    setState(() {
      isLoading = true; // ローディング開始
    });
    showLoadingDialog(context);
    // 2秒待つ（ここに非同期の処理を入れる）
    await _saveData();
    Navigator.of(context, rootNavigator: true).pop();
    setState(() {
      isLoading = false; // ローディング終了
    });


  }
}

