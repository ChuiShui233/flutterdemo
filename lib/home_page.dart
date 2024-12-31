part of 'main.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isLargeScreen = screenWidth > 600; // 可自定义阈值

          return SingleChildScrollView(
            child: isLargeScreen
                ? _buildLargeScreenLayout(context, constraints)
                : _buildSmallScreenLayout(context, constraints),
          );
        },
      ),
    );
  }

    Widget _buildLargeScreenLayout(BuildContext context, BoxConstraints constraints) {
    return Row(
      children: [
         Expanded(
            flex: 1, //图片卡片占比
          child: _buildSizedCard(context, constraints),
        ),
          const SizedBox(width: 16), // 卡片之间添加间距
         Expanded(
             flex: 1, //信息卡片占比
          child: _buildSizedInfoCard(context, constraints),
        )
      ],
    );
  }


    Widget _buildSmallScreenLayout(BuildContext context, BoxConstraints constraints) {
      return Column(
          children: [
              _buildSizedCard(context, constraints),
              const SizedBox(height: 16), // 卡片之间添加间距
              _buildSizedInfoCard(context, constraints),
          ],
        );
  }


   Widget _buildSizedCard(BuildContext context, BoxConstraints constraints) {
    return  AspectRatio(
      aspectRatio: 16/9, // 设置统一的长宽比
       child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand, // 设置 Stack 充满整个卡片
            children: [
              Image.asset(
                'assets/images/home.png',
                fit: BoxFit.cover, // 图片铺满
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                       decoration: BoxDecoration(
                         color: Colors.black.withOpacity(0.6), // 黑色半透明背景
                        ),
                      child:  Text(
                          'v1.0.0',
                          style: TextStyle(fontSize: 14,color: Colors.white), //白色文本
                        )
                    ),
                  ),
                )
              ],
          ),
        ),
    );
  }


  Widget _buildSizedInfoCard(BuildContext context, BoxConstraints constraints) {
      return AspectRatio(
        aspectRatio: 16/9, // 设置统一的长宽比
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '构建信息',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                 const SizedBox(height: 8),
                 Text(
                  'Flutter: 3.16.7',
                   style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                 const SizedBox(height: 8),
                 Text(
                  '构建平台: Flutter',
                  style: TextStyle(fontSize: 16,color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                 const SizedBox(height: 8),
                Text(
                  '开发语言: Dart',
                   style: TextStyle(fontSize: 16,color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
               const SizedBox(height: 8),
                Text(
                  '编译时间： ${DateTime.now()}',
                  style: TextStyle(fontSize: 16,color: Theme.of(context).colorScheme.onSurfaceVariant),
                )
              ],
            ),
          ),
        ),
      );
    }
}