import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  String _startTime = '';
  String _endTime = '';
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd-EEE', 'ja_JP');
  final List<DateTime> selectedDays = [];
  
  String _formattedDate = '';
  List<String> _formattedDateList = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  bool _isChecked = false;
  List<String> _selectedEvents = [];
  bool isMobile = !kIsWeb;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 背景色を透明に設定
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              'assets/images/jerome-prax-cr6U8ilcdIc-unsplash.jpg',
              fit: BoxFit.cover,
              
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: const Color.fromARGB(255, 206, 206, 206),
                title: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('gulife シフト管理'),
                      Padding(padding: EdgeInsets.only(left: 15)),
                      Icon(
                        Icons.calendar_month,
                        size: 30,
                      ),
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
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: Colors.white.withOpacity(0.5), // 背景色を設定
                        child: TableCalendar(
                            headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            // ヘッダーの背景色を設定
                            titleTextStyle: TextStyle(color: Colors.black, fontSize: 16),
                            leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                            rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                          ),
                          calendarStyle: CalendarStyle(
                            defaultTextStyle: TextStyle(color: Colors.black),
                            weekendTextStyle: TextStyle(color: Colors.red),
                            selectedDecoration: BoxDecoration(
                              color: Colors.blue, // 選択された日付の背景色
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: TextStyle(color: Colors.white),
                              todayDecoration: BoxDecoration(
                                color: Colors.orange, // 今日の日付の背景色
                                shape: BoxShape.circle,
                              ),
                              todayTextStyle: TextStyle(color: Colors.white),
                            ),
                            locale: 'ja_JP',
                            firstDay: DateTime.utc(2000, 1, 1),
                            lastDay: DateTime.utc(3000, 12, 31),
                            focusedDay: _focused,
                            eventLoader: (date) {
                              final keyDate = DateTime(date.year, date.month, date.day); // 時間部分を無視
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
                              });
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
            color: Colors.white.withOpacity(0.8), // 背景色を設定
            child: Text(
            "${_formattedDateList.toString()}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ),
          Container(
            color: Colors.white, // 背景色を設定
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
                    hintText: '開始希望時刻を入力してください',
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
            color: Colors.white, // 背景色を設定
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
              hintText: '終了希望時刻の入力してください',
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
                String userEmail = _user?.email ?? '';
                writeToSpreadsheetAndChangeColor(_startTime, _endTime, _formattedDateList, userEmail);
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
    _startTime = _startTimeController.text;
    _endTime = _endTimeController.text;
    print("$_formattedDateList\n開始時間: $_startTime\n終了時間: $_endTime");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SpreadsheetDataPage()),
    );
  }
}
