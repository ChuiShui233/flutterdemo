import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const ClampingScrollPhysics(), // 防止滑动超出
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: const [
              WelcomePage(),
              PrivacyPolicyPage(),
              StartUsingPage(),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: _currentPage < 2
                ? ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('下一步'),
                  )
                : const SizedBox(),
          ),
          if (_currentPage == 1)
            Positioned(
              bottom: 20,
              left: 20, // 调整到左边
              child: TextButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('返回'),
              ),
            ),
          if (_currentPage == 2)
            Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fogRainAnimationController;
  late Animation<double> _fogRainFadeAnimation;
  late Animation<Offset> _fogRainSlideAnimation;
  late AnimationController _shapeAnimationController;
  late Animation<double> _shapeAnimation;
   late AnimationController _blurBoxFadeAnimationController;
  late Animation<double> _blurBoxFadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();

    _fogRainAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fogRainFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _fogRainAnimationController,
      curve: Curves.easeInOutQuad,
    ));
    _fogRainSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fogRainAnimationController,
      curve: Curves.easeInOutQuad,
    ));
    _fogRainAnimationController.forward();


    _shapeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _shapeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _shapeAnimationController,
      curve: Curves.easeInOut,
    ));
       _blurBoxFadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // 动画时长
    );
       _blurBoxFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _blurBoxFadeAnimationController,
        curve: Curves.easeIn, // 使用 easeIn 曲线
      ),
    );


    Future.delayed(const Duration(seconds: 1), () {
      _blurBoxFadeAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fogRainAnimationController.dispose();
        _shapeAnimationController.dispose();
          _blurBoxFadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      )),
      child: FadeTransition(
        opacity: _animationController,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              elevation: 8, // 添加阴影效果
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(32.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SlideTransition(
                      position: _fogRainSlideAnimation,
                      child: FadeTransition(
                        opacity: _fogRainFadeAnimation,
                        child: Text(
                          '雾雨',
                          style: TextStyle(
                            fontSize: 75,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).hintColor.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                      AnimatedBuilder(
                        animation: _shapeAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(400, 400),
                            painter: _ShapePainter(
                                animationValue: _shapeAnimation.value,
                                color: Theme.of(context).primaryColor),
                          );
                        },
                      ),
                    AnimatedBuilder(
                      animation: _blurBoxFadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _blurBoxFadeAnimation.value,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10 * _blurBoxFadeAnimation.value, sigmaY: 10*_blurBoxFadeAnimation.value),
                              child: Container(
                                width: 400,  // 设置宽度
                                height: 180,  // 设置高度
                                color: Colors.grey.withOpacity(0.1),
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                    const Text(
                      'Welcome',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class _ShapePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _ShapePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 4;
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // 使用动画值控制缩放和旋转
    final scale = 0.5 + 0.5 * animationValue; // 从 0.5 到 1 的缩放
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale, scale);
    canvas.rotate(2 * pi * animationValue); // 旋转效果


    // 绘制三角形
    final path = Path();
    path.moveTo(0, -radius * 2.0); // 放大三角形高度
    path.lineTo(radius * 2.0 * sin(pi / 3), radius * 2.0 * cos(pi / 3)); // 放大三角形宽度
    path.lineTo(-radius * 2.0 * sin(pi / 3), radius * 2.0 * cos(pi / 3)); // 放大三角形宽度
    path.close();
    canvas.drawPath(path, paint);


    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}


class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 75.0), // 添加水平和垂直间距
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 高度居中
        children: <Widget>[
          const Text(
            '隐私政策许可',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: const SingleChildScrollView(
                child: Text(
                  '''
此处放置你的隐私政策内容。你可以添加更详细的条款和说明。
例如：我们收集哪些信息，如何使用这些信息，以及如何保护这些信息等。
请确保你的隐私政策内容完整且符合法律法规。
                  ''',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StartUsingPage extends StatelessWidget {
  const StartUsingPage({super.key});

  Future<void> _markWelcomeShown(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('welcomeShown', true);
    // 跳转到主页的逻辑，你需要根据你的实际情况修改
    Navigator.of(context).pushReplacementNamed('/'); // 假设你的主页路由是 '/'
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '准备好开始使用了吗？',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _markWelcomeShown(context),
              child: const Text('开始使用'),
            ),
          ],
        ),
      ),
    );
  }
}