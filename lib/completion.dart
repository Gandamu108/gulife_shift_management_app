import 'package:flutter/material.dart';

class CompletionPage extends StatefulWidget {
  const CompletionPage({super.key});

  @override
  State<CompletionPage> createState() => _CompletionPageState();
}

class _CompletionPageState extends State<CompletionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('シフト申請カレンダー'),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'シフト申請完了！',
              style: TextStyle(
                fontSize: 50
              ),
            ),
          )
        ],
      ),
    );
  }
}