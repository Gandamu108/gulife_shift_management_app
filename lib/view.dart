import 'package:flutter/material.dart';
import 'google_sheet.dart';  // fetchSpreadsheetDataForUser() をインポート

class SpreadsheetDataPage extends StatefulWidget {
  @override
  _SpreadsheetDataPageState createState() => _SpreadsheetDataPageState();
}

class _SpreadsheetDataPageState extends State<SpreadsheetDataPage> {
  Future<List<List<Object?>>>? _data;  // 型を変更

  @override
  void initState() {
    super.initState();
    _data = fetchSpreadsheetDataForUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('申請されました'),
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
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final row = data[index];
                  return ListTile(
                    title: Text(row.map((item) => item?.toString() ?? '').join(', ')),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
