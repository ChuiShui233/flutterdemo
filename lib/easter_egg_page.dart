// easter_egg_page.dart
import 'package:flutter/material.dart';

class EasterEggPage extends StatelessWidget {
  const EasterEggPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('恭喜你发现了彩蛋!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '🎉🎉🎉',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 20),
                      const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // 返回上一页
              },
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}