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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fogRainAnimationController.dispose();
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(32.0),
                color: Theme.of(context).cardColor,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SlideTransition(
                      position: _fogRainSlideAnimation,
                      child: FadeTransition(
                        opacity: _fogRainFadeAnimation,
                        child: Text(
                          '雾雨空间',
                          style: TextStyle(
                            fontSize: 65,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).hintColor.withOpacity(0.3),
                          ),
                        ),
                      ),
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

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 50.0), // 添加水平和垂直间距
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