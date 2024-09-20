import 'package:flutter/material.dart';
import 'google_sheet.dart'; // fetchSpreadsheetDataForUser() をインポート

class SpreadsheetDataPage extends StatefulWidget {
  @override
  _SpreadsheetDataPageState createState() => _SpreadsheetDataPageState();
}

class _SpreadsheetDataPageState extends State<SpreadsheetDataPage> {
  Future<List<List<Object?>>>? _data; // 型を変更

  @override
  void initState() {
    super.initState();
    _data = fetchSpreadsheetDataForUser().then((data) {
      return data.map((row) => row.sublist(0, 2)).toList(); // A列とB列のみを取得
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('履歴'),
      ),
      body: Container(
        child: FutureBuilder<List<List<Object?>>>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No data found.'));
            } else {
              final data = snapshot.data!;
              return Container(
                padding: EdgeInsets.only(bottom: 10),
                margin: EdgeInsets.only(left: 10 , right: 10),
                child: ListView(
                  children: data.map<Widget>((row) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 5), // 上下に5ピクセルの余白
                      child: Chip(
                        label: Text('${row[0]?.toString()}, ${row[1]?.toString()}'),
                      ),
                    );
                  }).toList(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
