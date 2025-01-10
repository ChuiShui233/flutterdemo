import 'package:flutter/material.dart';

// 主题安装页
class ThemeInstallationPage extends StatelessWidget {
  const ThemeInstallationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题安装'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 24,
              child: const ThemeCard(
                title: '安装主题',
                description: '从本地文件安装 ColorOS 主题',
                icon: Icons.add_to_drive,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 2 - 24,
              child: const ThemeCard(
                title: '备份当前主题',
                description: '备份当前正在使用的主题',
                icon: Icons.backup,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const ThemeCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  // 处理按钮点击事件
                  print('点击了：$title');
                },
                child: const Text('操作'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}