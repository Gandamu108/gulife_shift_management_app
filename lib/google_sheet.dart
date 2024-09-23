import 'dart:convert';
import 'dart:io';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

// イベントデータをスプレッドシートに送信する関数
Future<void> sendEventToSheet(
    String startTime, String endTime, List<String> formattedDateList, String userEmail) async {
  
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    // ユーザーがログインしていない場合
    print("User is not logged in.");
    return;
  }

  if (userEmail.isEmpty) {
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

    print('Update response: ${response.updates?.updatedCells}');
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}

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
  if (user == null || user.email == null) {
    print('User not logged in or email not available.');
    return [];
  }
  final userEmail = user.email!;

  try {
    final response = await sheetsApi.spreadsheets.values.get(spreadsheetId, range);
    final values = response.values ?? [];

    // ユーザーのメールアドレスに基づいてフィルタリング
    final filteredValues = values.where((row) => row.length > 2 && row[2] == userEmail).toList();

    return filteredValues;
  } catch (e) {
    print('Error: $e');
    return [];
  } finally {
    client.close();
  }
}
