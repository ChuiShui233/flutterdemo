// main.dart
part of 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _demoClickCount = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _incrementDemoClickCount(BuildContext context) {
    setState(() {
      _demoClickCount++;
      _animationController.forward();
      if (_demoClickCount >= 10) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const EasterEggPage()),
        );
        _demoClickCount = 0; // Reset counter after triggering
      }
    });
  }

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

  Widget _buildLargeScreenLayout(
      BuildContext context, BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(
          flex: 1, //图片卡片占比
          child: _buildDemoCard(context, constraints),
        ),
        const SizedBox(width: 16), // 卡片之间添加间距
        Expanded(
          flex: 1, //信息卡片占比
          child: _buildSizedInfoCard(context, constraints),
        )
      ],
    );
  }

  Widget _buildSmallScreenLayout(
      BuildContext context, BoxConstraints constraints) {
    return Column(
      children: [
        _buildDemoCard(context, constraints),
        const SizedBox(height: 16), // 卡片之间添加间距
        _buildSizedInfoCard(context, constraints),
      ],
    );
  }

  Widget _buildDemoCard(BuildContext context, BoxConstraints constraints) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: GestureDetector(
            onTap: () => _incrementDemoClickCount(context),
            child: AspectRatio(
              aspectRatio: 16 / 9, // 设置统一的长宽比
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand, // 设置 Stack 充满整个卡片
                  children: [
                    Image.asset(
                      'assets/images/home.jpg',
                      fit: BoxFit.cover, // 图片铺满
                    ),
                    Positioned.fill(
                      // 添加 Positioned.fill 以覆盖整个卡片
                      child: Center(
                        // 使用 Center 组件进行水平垂直居中
                        child: Text(
                          'Demo',
                          style: TextStyle(
                            fontFamily: 'Customized', // 使用自定义字体
                            color: Colors.white,
                            fontSize: 32, // 可以根据需要调整字体大小
                            fontWeight: FontWeight.bold,
                            shadows: const <Shadow>[
                              Shadow(
                                offset: Offset(2.0, 2.0),
                                blurRadius: 3.0,
                                color: Colors.black87,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8), 
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5), // 黑色半透明背景
                          ),
                          child: const Text(
                            'v1.0.0 开发预览版',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                            //白色文本
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSizedInfoCard(
      BuildContext context, BoxConstraints constraints) {
    // ... (rest of the _buildSizedInfoCard method remains the same)
    final onSurfaceVariantColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final textStyle = TextStyle(color: onSurfaceVariantColor);
    final titleStyle =
        TextStyle(fontWeight: FontWeight.bold, color: onSurfaceVariantColor);

    String dartVersion = Platform.version;
    String environment = '';
    if (kDebugMode) {
      environment = '开发 (Debug)';
    } else if (kProfileMode) {
      environment = '测试 (Profile)';
    } else {
      environment = '发布 (Release)';
    }

    return AspectRatio(
      aspectRatio: 16 / 9, // 设置统一的长宽比
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: Text(
                  '构建信息',
                  style: titleStyle,
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: Text(
                  'Dart: $dartVersion',
                  style: textStyle,
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: Text(
                  '环境： $environment',
                  style: textStyle,
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: Text(
                  kIsWeb ? '平台： Web' : '平台： ${Platform.operatingSystem}',
                  style: textStyle,
                ),
              ),
              if (!kIsWeb) ...[
                const SizedBox(height: 8),
                _buildAndroidInfo(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidInfo() {
    return FutureBuilder<String>(
      future: _getAndroidInfo(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: Text('获取安卓信息中...'),
          );
        } else if (snapshot.hasError) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: Text('获取安卓信息失败: ${snapshot.error}'),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: Text(snapshot.data!),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Future<String> _getAndroidInfo() async {
    try {
      const platform = MethodChannel('com.example.app/info');
      final String version =
          await platform.invokeMethod('getSdkVersion') ?? '未知';
      final String model = await platform.invokeMethod('getModel') ?? '未知';
      return 'SDK 版本: $version, 手机型号: $model';
    } on PlatformException catch (e) {
      return '无法获取安卓信息: ${e.message}';
    }
  }
}