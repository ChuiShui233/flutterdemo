import 'package:flutter/material.dart';

// 系统修改页
class SystemSettingsPage extends StatelessWidget {
  const SystemSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('系统修改'),
      ),
      body: ListView(
        children: const [
          SystemSettingTile(
            title: '开发者选项',
            subtitle: '启用或禁用开发者专用设置',
          ),
          SystemSettingTile(
            title: 'USB 调试',
            subtitle: '允许通过 USB 连接进行调试',
          ),
          SystemSettingTile(
            title: 'Root 权限',
            subtitle: '管理设备的 Root 访问权限',
          ),
          // 可以添加更多的系统修改选项
        ],
      ),
    );
  }
}

class SystemSettingTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const SystemSettingTile({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      // 可以添加点击事件或其他交互
      onTap: () {
        // 处理点击事件
        print('点击了：$title');
      },
    );
  }
}