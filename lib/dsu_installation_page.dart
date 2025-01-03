import 'package:flutter/material.dart';

class DSUInstallationPage extends StatelessWidget {
  const DSUInstallationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DSU安装')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.system_update_alt, size: 80, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'DSU 安装向导',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '请按照以下步骤安装 DSU。',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text(
                '1. 下载 GSI 镜像文件。\n2. 选择安装位置。\n3. 开始安装。',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}