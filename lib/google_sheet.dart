import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'login.dart';
import 'calendar.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';


// セルの色を変更する関数
Future<void> writeToSpreadsheetAndChangeColor(
    String startTime, String endTime, List<String> formattedDateList, String userEmail) async {
  
  User? user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    // ユーザーがログインしていない場合
    print("User is not logged in.");
    return;
  }

  String? userEmail = user.email;

  if (userEmail == null || userEmail.isEmpty) {
    // ユーザーのメールアドレスがnullの場合
    print("User email is null or empty.");
    return;
  }
  final credentials = await rootBundle.loadString('assets/gulife-432605-83b7d2b64fd3.json');
  final spreadsheetId = '1b3FHCRutgJEzoS6NAvGiJ6iPeBCUlVEnDfX4EbX8v7w';
  final range = 'シート1!A1'; // 初期の範囲

  final jsonCredentials = json.decode(credentials);
  final serviceAccountCredentials = ServiceAccountCredentials.fromJson(jsonCredentials);
  final scopes = [
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive',
  ];

  final client = await clientViaServiceAccount(serviceAccountCredentials, scopes);
  final sheetsApi = SheetsApi(client);

  final List<List<Object>> values = formattedDateList.map((date) {
    return [date, '開始希望時間: $startTime, 終了希望時間: $endTime', userEmail];
  }).toList();

  final valueRange = ValueRange.fromJson({'values': values});

  try {
    // データをスプレッドシートに追加
    final response = await sheetsApi.spreadsheets.values.append(
      valueRange,
      spreadsheetId,
      range,
      valueInputOption: 'RAW',
    );

    final updatedRange = response.updates?.updatedRange;

    if (updatedRange != null) {
      final rangeParts = updatedRange.split('!')[1].split(':');
      final startCell = rangeParts[0];
      final endCell = rangeParts[1];

      final startColumnIndex = _getColumnIndex(startCell);
      final startRowIndex = _getRowIndex(startCell);
      final endColumnIndex = _getColumnIndex(endCell);
      final endRowIndex = _getRowIndex(endCell);

      // 色をつけるリクエスト
      final colorRequest = {
        "requests": [
          {
            "repeatCell": {
              "range": {
                "sheetId": 0,
                "startRowIndex": startRowIndex,
                "endRowIndex": endRowIndex + 1,
                "startColumnIndex": startColumnIndex,
                "endColumnIndex": endColumnIndex + 1
              },
              "cell": {
                "userEnteredFormat": {
                  "backgroundColor": {
                    "red": 0.5,
                    "green": 1.0,
                    "blue": 0.5,
                    "alpha": 1.0
                  }
                }
              },
              "fields": "userEnteredFormat.backgroundColor"
            }
          }
        ]
      };

      // 色変更リクエストを送信
      final batchUpdateRequest = BatchUpdateSpreadsheetRequest.fromJson(colorRequest);
      await sheetsApi.spreadsheets.batchUpdate(batchUpdateRequest, spreadsheetId);
    }

    print('Update response: ${response.updates?.updatedCells}');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}

// セルの列インデックスを取得
int _getColumnIndex(String cell) {
  return cell.codeUnitAt(0) - 'A'.codeUnitAt(0);
}

// セルの行インデックスを取得
int _getRowIndex(String cell) {
  return int.parse(cell.substring(1)) - 1;
}


// イベントデータをスプレッドシートに送信する関数
Future<void> sendEventToSheet(Map<DateTime, List<String>> events, String _userEmail) async {
  final _credentials = await rootBundle.loadString('assets/gulife-432605-83b7d2b64fd3.json');
  final _spreadsheetId = '1b3FHCRutgJEzoS6NAvGiJ6iPeBCUlVEnDfX4EbX8v7w';
  final _range = 'シート1!A1'; 

  final jsonCredentials = json.decode(_credentials);
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
    rows.add([dateString, eventsString, _userEmail]);
  });

  final valueRange = ValueRange.fromJson({
    'values': rows,
  });

  try {
    final response = await sheetsApi.spreadsheets.values.append(
      valueRange,
      _spreadsheetId,
      _range,
      valueInputOption: 'RAW',
    );

    print('Update response: ${response.updates?.updatedCells}');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}

