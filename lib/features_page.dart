part of 'main.dart'; // 声明这是 main.dart 的一部分

// 功能页
class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '功能',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Text(
            '这里是功能的示例内容。',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}