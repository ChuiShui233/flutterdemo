part of 'main.dart'; // 声明这是 main.dart 的一部分

// 功能页
class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 16.0,
            runSpacing: 16.0,
            children: _buildFeatureCards(context),
          ),
        ),
      ),
    );
  }


  List<Widget> _buildFeatureCards(BuildContext context) {
    final cardData = [
      {
        'icon': Icons.all_inclusive,
        'title': 'DSU安装',
        'description': '快速安装，下载镜像',
      },
      {
        'icon': Icons.settings,
        'title': '系统设置',
        'description': '更改系统设置',
      },
      {
        'icon': Icons.storage,
        'title': '存储管理',
        'description': '管理存储空间',
      },
      {
        'icon': Icons.security,
        'title': '安全',
        'description': '保护您的设备',
      },
       {
        'icon': Icons.adb,
        'title': 'ADB',
        'description': '高级调试工具',
      },
      {
        'icon': Icons.network_cell,
        'title': '网络',
        'description': '配置网络连接',
      },
      {
        'icon': Icons.update,
        'title': '系统更新',
        'description': '检查系统更新',
      },
      {
        'icon': Icons.phonelink_setup,
        'title': '设备管理',
        'description': '管理您的设备',
      },
      {
        'icon': Icons.developer_mode,
        'title': '开发者选项',
        'description': '访问开发者选项',
      },
       {
        'icon': Icons.brush,
        'title': '主题',
        'description': '自定义界面主题',
      },
      {
        'icon': Icons.notifications,
        'title': '通知管理',
        'description': '管理通知',
      },
      {
        'icon': Icons.accessibility,
        'title': '辅助功能',
        'description': '设置辅助功能选项',
      },
    ];


    return cardData.asMap().entries.map((entry) {
      int index = entry.key;
      var data = entry.value;
      return _buildAnimatedCard(context, data, index);
    }).toList();
  }

  Widget _buildAnimatedCard(BuildContext context, Map<String, Object> data, int index) {
    return AnimatedOpacity(
      opacity: 1.0, // 始终保持不透明
      duration: const Duration(milliseconds: 500),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeOut,
        )),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 24,
          child: GestureDetector(
            onTap: () {
              if (data['title'] == 'DSU安装') {
                  Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => const DSUInstallationScreen()),
                );
              }
            },
            child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(data['icon'] as IconData, size: 30),
                      const SizedBox(height: 8),
                      Text(
                        data['title'] as String,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                         maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['description'] as String,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                         maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }
}