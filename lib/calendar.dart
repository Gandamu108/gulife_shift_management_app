import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';
import 'google_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'editing.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_picker_spinner_pop_up/time_picker_spinner_pop_up.dart';
import 'google_sheet.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; 
import 'view.dart';
import 'main.dart';



class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title, required this.events}) : super(key: key);

  final String title;
  final Map<DateTime, List<String>> events;
  
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User? _user;
  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser; // ユーザーを取得
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
      backgroundColor: Colors.transparent,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              // <a href="https://unsplash.com/ja/%E5%86%99%E7%9C%9F/%E8%B5%A4%E9%BB%84%E3%83%94%E3%83%B3%E3%82%AF%E3%81%AE%E6%8A%BD%E8%B1%A1%E7%94%BB-RAZU_R66vUc?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Unsplash</a>の<a href="https://unsplash.com/ja/@ricvath?utm_content=creditCopyText&utm_medium=referral&utm_source=unsplash">Richard Horvath</a>が撮影した写真
              'assets/images/richard-horvath-RAZU_R66vUc-unsplash.jpg',
              fit: BoxFit.cover,
            ),
          ),
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
                              // 選択した日のイベントがあれば、開始・終了時刻を設定
                              if (_selectedEvents.isNotEmpty) { // リストが空でないことを確認
                                _startTimeController.text = _selectedEvents[0].split(', ')[0]; // 開始時刻を取得
                                _endTimeController.text = _selectedEvents[1].split(', ')[0]; // 終了時刻を取得
                                print(_startTimeController.text);
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
                      
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _selectedEvents.length,
                        itemBuilder: (context, index) {
                          final event = _selectedEvents[index];
                          return Card(
                            child: ListTile(
                              title: Text(event),
                            ),
                          );
                        },
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            child: Text(
            "${_formattedDateList.toString()}",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold
              ),     
          ),
          ),
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
            child: ElevatedButton(
              onPressed: () {
                _saveData();
              },
              child: Text("申請"),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(90, 40),
                textStyle: TextStyle(fontSize: 20),
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

  void formatSelectedDays() {
    _formattedDateList.clear();
    for (DateTime day in selectedDays) {
      _formattedDateList.add(dateFormat.format(day));
    }
  }

  void _saveData() async {
    String startTime = _startTimeController.text;
    String endTime = _endTimeController.text;

    // 選択された日付にイベントを追加
    for (var date in selectedDays) {
      DateTime eventDate = DateTime(date.year, date.month, date.day);
      widget.events[eventDate] = [startTime, endTime]; // 選択された日付にイベントを追加
    }

    // スプレッドシートに送信
    String userEmail = _user?.email ?? '';
    await sendEventToSheet(startTime, endTime, _formattedDateList, userEmail);
    
    // UIのリセット
    _startTimeController.clear();
    _endTimeController.clear();
    selectedDays.clear();
    _formattedDateList.clear();
    setState(() {
      _selectedEvents.clear();
    });
  }
}