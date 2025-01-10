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
        'icon': Icons.download_rounded,
        'title': 'DSU安装',
        'description': '快速安装，下载镜像',
      },
      {
        'icon': Icons.settings,
        'title': '系统修改',
        'description': '更改定制系统设置',
      },
      {
        'icon': Icons.palette,
        'title': '主题安装',
        'description': '用于ColorOS主题强制安装',
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
              } else if (data['title'] == '系统修改') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SystemSettingsPage()),
                );
              } else if (data['title'] == '主题安装') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThemeInstallationPage()),
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