import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http; // httpパッケージをインポート
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
// イベントデータをスプレッドシートに送信する関数
Future<void> sendEventToSheet(Map<DateTime, List<String>> events, String userName) async {
  final credentials = await rootBundle.loadString('assets/gulife-432605-83b7d2b64fd3.json');
  final spreadsheetId = '1b3FHCRutgJEzoS6NAvGiJ6iPeBCUlVEnDfX4EbX8v7w';
  final range = 'シート1!A1';

  final jsonCredentials = json.decode(credentials);
  final serviceAccountCredentials = ServiceAccountCredentials.fromJson(jsonCredentials);
  final scopes = [
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive',
  ];

  final client = await clientViaServiceAccount(serviceAccountCredentials, scopes);
  final sheetsApi = SheetsApi(client);

  final List<List<String>> rows = [];
  events.forEach((date, eventList) {
    final dateString = DateFormat('yyyy-MM-dd-EEE', 'ja_JP').format(date);
    final eventsString = eventList.join(', ');
    rows.add([dateString, eventsString, userName]);
  });

  final valueRange = ValueRange.fromJson({
    'values': rows,
  });

  try {
    // ユーザーの既存データを削除
    await deleteUserEntries(spreadsheetId, userName);
    print('データが削除されました');

    // 新しいデータを保存する
    final response = await sheetsApi.spreadsheets.values.append(
      valueRange,
      spreadsheetId,
      range,
      valueInputOption: 'RAW',
    );

    print("新しいデータが保存されました");

    // // 古いデータを削除する処理を呼び出す
    // await deleteOldEntries(spreadsheetId, range);

    print('Update response: ${response.updates?.updatedCells}');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
// データ取得
Future<List<List<Object?>>> fetchSpreadsheetDataForUser() async {
  final credentials = await rootBundle.loadString('assets/gulife-432605-83b7d2b64fd3.json');
  final spreadsheetId = '1b3FHCRutgJEzoS6NAvGiJ6iPeBCUlVEnDfX4EbX8v7w';
  final range = 'シート1!A1:Z';

  final jsonCredentials = json.decode(credentials);
  final serviceAccountCredentials = ServiceAccountCredentials.fromJson(jsonCredentials);
  final scopes = [
    'https://www.googleapis.com/auth/spreadsheets.readonly',
  ];

  final client = await clientViaServiceAccount(serviceAccountCredentials, scopes);
  final sheetsApi = SheetsApi(client);

  User? user = FirebaseAuth.instance.currentUser;
  if (user == null || user.displayName == null) {
    print('User not logged in or email not available.');
    return [];
  }
  final userEmail = user.email!;
  final userName = user.displayName;

  try {
    final response = await sheetsApi.spreadsheets.values.get(spreadsheetId, range);
    final values = response.values ?? [];

    // ユーザーのメールアドレスに基づいてフィルタリング
    final filteredValues = values.where((row) => row.length > 2 && row[2] == userName).toList();

    return filteredValues;
  } catch (e) {
    print('Error: $e');
    return [];
  } finally {
    client.close();
  }
}

Future<void> deleteOldEntries(String spreadsheetId, String range) async {
  final credentials = await rootBundle.loadString('assets/gulife-432605-83b7d2b64fd3.json');
  final jsonCredentials = json.decode(credentials);
  final serviceAccountCredentials = ServiceAccountCredentials.fromJson(jsonCredentials);
  final scopes = ['https://www.googleapis.com/auth/spreadsheets'];

  final client = await clientViaServiceAccount(serviceAccountCredentials, scopes);
  final sheetsApi = SheetsApi(client);

  try {
    final response = await sheetsApi.spreadsheets.values.get(spreadsheetId, range);
    final values = response.values ?? [];

    // 今日の日付を取得
    final now = DateTime.now();

    // 古いデータの削除
    List<int> rowsToDelete = [];
    for (int i = 0; i < values.length; i++) {
      if (values[i].isNotEmpty) {
        // Object? を String にキャスト
        final rowDateString = values[i][0] as String; // キャストを追加
        final rowDate = DateFormat('yyyy-MM-dd').parse(rowDateString);
        // 日付が1ヶ月以上前の場合
        if (now.difference(rowDate).inDays > 30) {
          rowsToDelete.add(i);
        }
      }
    }
    // 行を削除するためのリクエストを作成
    for (var rowIndex in rowsToDelete.reversed) {
      final deleteRequest = {
        "requests": [
          {
            "deleteDimension": {
              "range": {
                "sheetId": 0,
                "dimension": "ROWS",
                "startIndex": rowIndex,
                "endIndex": rowIndex + 1
              }
            }
          }
        ]
      };
      final batchUpdateRequest = BatchUpdateSpreadsheetRequest.fromJson(deleteRequest);
      await sheetsApi.spreadsheets.batchUpdate(batchUpdateRequest, spreadsheetId);
    }

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}

Future<void> deleteUserEntries(String spreadsheetId, String userName) async {
  final credentials = await rootBundle.loadString('assets/gulife-432605-83b7d2b64fd3.json');
  final jsonCredentials = json.decode(credentials);
  final serviceAccountCredentials = ServiceAccountCredentials.fromJson(jsonCredentials);
  final scopes = ['https://www.googleapis.com/auth/spreadsheets'];

  final client = await clientViaServiceAccount(serviceAccountCredentials, scopes);
  final sheetsApi = SheetsApi(client);

  try {
    final response = await sheetsApi.spreadsheets.values.get(spreadsheetId, 'シート1!A1:Z');
    final values = response.values ?? [];

    // ユーザーのデータを削除
    List<int> rowsToDelete = [];
    for (int i = 0; i < values.length; i++) {
      if (values[i].length > 2 && values[i][2] == userName) {
        rowsToDelete.add(i);
      }
    }

    // 行を削除するためのリクエストを作成
    for (var rowIndex in rowsToDelete.reversed) {
      final deleteRequest = {
        "requests": [
          {
            "deleteDimension": {
              "range": {
                "sheetId": 0,
                "dimension": "ROWS",
                "startIndex": rowIndex,
                "endIndex": rowIndex + 1
              }
            }
          }
        ]
      };
      final batchUpdateRequest = BatchUpdateSpreadsheetRequest.fromJson(deleteRequest);
      await sheetsApi.spreadsheets.batchUpdate(batchUpdateRequest, spreadsheetId);
    }

  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
