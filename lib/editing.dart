import 'package:flutter/material.dart';
import 'google_sheet.dart'; // fetchSpreadsheetDataForUser() をインポート

class EditingPage extends StatefulWidget {
  @override
  _EditingPageState createState() => _EditingPageState();
}

class _EditingPageState extends State<EditingPage> {
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
        title: Text('編集'),
      ),
      body: Container(
        child: FutureBuilder<List<List<Object?>>>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('エラー: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('データがありません'));
            } else {
              final data = snapshot.data!;
              return LayoutBuilder(
                builder: (context, constraints) {
                  // 幅が600ピクセルより小さい場合はリストビュー、それ以上はグリッドビュー
                  if (constraints.maxWidth < 600) {
                    // モバイル用の縦型リストビュー
                    return Container(
                      padding: EdgeInsets.only(bottom: 10),
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: ListView(
                        children: data.map<Widget>((row) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            child: ListTile(
                              title: Text(
                                '${row[0]?.toString()}', // 日付
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '開始/終了時間: ${row[1]?.toString()}', // 開始/終了時間
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 190, 15, 15),
                                ),
                              ),
                              leading: Icon(
                                Icons.calendar_today,
                                color: Colors.blue,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    // タブレットやデスクトップ用のグリッドビュー
                    return GridView.builder(
                      padding: EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3列で表示
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 3, // カードの比率
                      ),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        var row = data[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              '${row[0]?.toString()}', // 日付
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '開始/終了時間: ${row[1]?.toString()}', // 開始/終了時間
                              style: TextStyle(
                                fontSize: 15,
                                color: const Color.fromARGB(255, 190, 15, 15),
                              ),
                            ),
                            leading: Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
