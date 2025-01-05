import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

import 'welcome.dart'; // 导入 welcome.dart
import 'dart:io';

import 'dsu_page.dart';

part 'home_page.dart'; // 声明 home_page.dart 是本文件的一部分
part 'features_page.dart'; // 声明 features_page.dart 是本文件的一部分

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

enum ThemeModeOption {
  system,
  light,
  dark,
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  ThemeModeOption _themeMode = ThemeModeOption.system;
  Color _monetSeedColor = Colors.blue;
  bool _useDynamicColor = false;
  bool _useBlurEffect = false;
  double _borderRadius = 12.0;
  double _blurIntensity = 5.0; // 新增模糊强度

  // 动画相关的控制器
  late final AnimationController _blurFadeController = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _blurFadeAnimation = CurvedAnimation(
    parent: _blurFadeController,
    curve: Curves.easeInOut,
  );

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkAndroidVersion();
  }

  @override
  void dispose() {
    _blurFadeController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = ThemeModeOption.values[prefs.getInt('themeMode') ?? 0];
      int? savedColor = prefs.getInt('monetSeedColor');
      _monetSeedColor = savedColor != null ? Color(savedColor) : Colors.blue;
      _useDynamicColor = prefs.getBool('useDynamicColor') ?? false;
      _useBlurEffect = prefs.getBool('useBlurEffect') ?? false;
      _borderRadius = prefs.getDouble('borderRadius') ?? 12.0;
      _blurIntensity = prefs.getDouble('blurIntensity') ?? 5.0; // 加载模糊强度
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setInt('monetSeedColor', _monetSeedColor.value);
    await prefs.setBool('useDynamicColor', _useDynamicColor);
    await prefs.setBool('useBlurEffect', _useBlurEffect);
    await prefs.setDouble('borderRadius', _borderRadius);
    await prefs.setDouble('blurIntensity', _blurIntensity); // 保存模糊强度
  }

  Future<void> _checkAndroidVersion() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
          if (androidInfo.version.sdkInt >= 31) {
            setState(() {
              _useDynamicColor = true;
            });
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching device info: $e");
        }
      }
    }
  }

  void _changeTheme(ThemeModeOption newThemeMode) {
    setState(() {
      _themeMode = newThemeMode;
    });
    _saveSettings();
  }

  void _changeMonetSeedColor(Color color) {
    setState(() {
      _monetSeedColor = color;
    });
    _saveSettings();
  }

  void _toggleDynamicColor(bool value) {
    setState(() {
      _useDynamicColor = value;
    });
    _saveSettings();
  }

  void _toggleBlurEffect(bool value) {
    setState(() {
      _useBlurEffect = value;
    });
    _saveSettings();
  }

  void _changeBorderRadius(double value) {
    setState(() {
      _borderRadius = value;
    });
    _saveSettings();
  }

  void _changeBlurIntensity(double value) {
    setState(() {
      _blurIntensity = value;
    });
    _saveSettings();
  }

  void _resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _loadSettings();
  }

  ThemeMode get _effectiveThemeMode {
    switch (_themeMode) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '水月共创',
      debugShowCheckedModeBanner: false,
      themeMode: _effectiveThemeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed:
            _useDynamicColor && Platform.isAndroid ? null : _monetSeedColor,
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
        sliderTheme: SliderThemeData(
          thumbShape: SliderComponentShape.noThumb, // 移除滑块上的圆点
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed:
            _useDynamicColor && Platform.isAndroid ? null : _monetSeedColor,
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
        sliderTheme: SliderThemeData(
          thumbShape: SliderComponentShape.noThumb, // 移除滑块上的圆点
        ),
      ),
      home: const AppEntry(),

      // 这里是入口，欢迎页
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _isWelcomeShown = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkWelcomeShown();
  }

  Future<void> _checkWelcomeShown() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isWelcomeShown = prefs.getBool('welcomeShown') ?? false;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      final myAppState = context.findAncestorStateOfType<_MyAppState>()!;
      return _isWelcomeShown
          ? MainScreen(
              useBlurEffect: myAppState._useBlurEffect,
              borderRadius: myAppState._borderRadius,
              blurIntensity: myAppState._blurIntensity,
              blurFadeAnimation: myAppState._blurFadeAnimation, // 传递动画
            )
          : const WelcomeScreen();
    }
  }
}

class MainScreen extends StatefulWidget {
  final bool useBlurEffect;
  final double borderRadius;
  final double blurIntensity; // 新增模糊强度
  final Animation<double> blurFadeAnimation; // 接收动画

  const MainScreen({
    super.key,
    required this.useBlurEffect,
    required this.borderRadius,
    required this.blurIntensity,
    required this.blurFadeAnimation, // 接收动画
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _previousIndex = 0; // 添加上一个索引

  // 动画相关的控制器
  late final AnimationController _blurController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  late final Animation<double> _blurAnimation = CurvedAnimation(
    parent: _blurController,
    curve: Curves.easeInOut,
  );

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    FeaturesPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _blurController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _previousIndex = _selectedIndex; // 记录上一个索引
      _selectedIndex = index;
    });
  }

  void _showBlurredSettingsPage() {
    _blurController.forward(from: 0.0); // 启动模糊进入动画
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true, // 点击背景关闭
        barrierColor: Colors.black.withAlpha((0.2 * 255).toInt()),
        pageBuilder: (BuildContext context, _, __) =>
            _buildBlurredOverlay(const SettingsPage()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 使用 ScaleTransition 添加缩放效果
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((value) {
      _blurController.reverse(from: 1.0); // 启动模糊退出动画
    });
  }

  Widget _buildBlurredOverlay(Widget page) {
    return FadeTransition(
      opacity: _blurAnimation,
      child: Stack(
        children: [
          if (widget.useBlurEffect)
            const ModalBarrier(
              color: Colors.transparent,
            ),
          if (widget.useBlurEffect)
            BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: widget.blurIntensity, sigmaY: widget.blurIntensity), // 使用模糊强度
              child: Container(
                color: Colors.black.withAlpha((0.2 * _blurAnimation.value * 255).toInt()), // 动画控制透明度
              ),
            ),
          page,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('水月共创'),
        elevation: 4.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.settings),
              onSelected: (String result) {
                if (result == 'settings') {
                  _showBlurredSettingsPage();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Text('设置'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final inAnimation = Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .animate(animation);
              final outAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0))
                  .animate(ReverseAnimation(animation));

              return SlideTransition(
                position: _selectedIndex < _previousIndex ? inAnimation : outAnimation,
                child: child,
              );
            },
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          // 全局模糊遮罩
          if (widget.useBlurEffect)
            FadeTransition(
              opacity: widget.blurFadeAnimation,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: widget.blurIntensity, sigmaY: widget.blurIntensity),
                child: Container(
                  color: Colors.transparent, // 全局模糊层不需要额外的颜色
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '主页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: '功能',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.transparent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}

// 设置页
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeModeOption? _currentThemeMode;
  Color _selectedMonetColor = Colors.blue;
  PackageInfo? _packageInfo;
  bool _isAndroid12Plus = false;
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  bool _useDynamicColor = false;
  bool _useBlurEffect = false;
  double _borderRadius = 12.0;
  double _blurIntensity = 5.0; // 新增模糊强度

  @override
  void initState() {
    super.initState();
    _loadCurrentTheme();
    _loadPackageInfo();
    _checkAndroidVersion();
  }

  Future<void> _checkAndroidVersion() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
          setState(() {
            _isAndroid12Plus = androidInfo.version.sdkInt >= 31;
            _useDynamicColor =
                (context.findAncestorStateOfType<_MyAppState>()?._useDynamicColor) ??
                    false;
            _useBlurEffect =
                (context.findAncestorStateOfType<_MyAppState>()?._useBlurEffect) ??
                    false;
            _borderRadius =
                (context.findAncestorStateOfType<_MyAppState>()?._borderRadius) ?? 12.0;
            _blurIntensity =
                (context.findAncestorStateOfType<_MyAppState>()?._blurIntensity) ?? 5.0;
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching device info: $e");
        }
      }
    }
  }

  Future<void> _loadPackageInfo() async {
    if (!kIsWeb) {
      try {
        final info = await PackageInfo.fromPlatform();
        setState(() {
          _packageInfo = info;
        });
      } catch (e) {
        setState(() {
          _packageInfo = null;
        });
      }
    } else {
      setState(() {
        _packageInfo = null;
      });
    }
  }

  void _loadCurrentTheme() {
    final myAppState = context.findAncestorStateOfType<_MyAppState>();
    _currentThemeMode = myAppState?._themeMode;
    _selectedMonetColor = myAppState?._monetSeedColor ?? Colors.blue;
    _useDynamicColor = myAppState?._useDynamicColor ?? false;
    _useBlurEffect = myAppState?._useBlurEffect ?? false;
    _borderRadius = myAppState?._borderRadius ?? 12.0;
    _blurIntensity = myAppState?._blurIntensity ?? 5.0;
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('版本警告'),
          content: const Text('当前版本为测试版本，请注意使用。\n如有任何问题，请及时反馈。'),
          actions: <Widget>[
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final myAppState = context.findAncestorStateOfType<_MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('夜间模式'),
            trailing: DropdownButton<ThemeModeOption>(
              value: _currentThemeMode,
              onChanged: (ThemeModeOption? newValue) {
                if (newValue != null) {
                  setState(() {
                    _currentThemeMode = newValue;
                  });
                  myAppState?._changeTheme(newValue);
                }
              },
              items: const <DropdownMenuItem<ThemeModeOption>>[
                DropdownMenuItem<ThemeModeOption>(
                  value: ThemeModeOption.system,
                  child: Text('跟随系统'),
                ),
                DropdownMenuItem<ThemeModeOption>(
                  value: ThemeModeOption.light,
                  child: Text('亮色模式'),
                ),
                DropdownMenuItem<ThemeModeOption>(
                  value: ThemeModeOption.dark,
                  child: Text('暗色模式'),
                ),
              ],
            ),
          ),
          if (_isAndroid12Plus)
            SwitchListTile(
              title: const Text('使用系统动态颜色 (Material You)'),
              subtitle: const Text('应用颜色将基于你的壁纸'),
              value: _useDynamicColor,
              onChanged: (bool value) {
                setState(() {
                  _useDynamicColor = value;
                });
                myAppState?._toggleDynamicColor(value);
              },
            ),
          if (!_isAndroid12Plus)
            ListTile(
              title: const Text('选择主题颜色'),
              trailing: CircleAvatar(
                backgroundColor: _selectedMonetColor,
                radius: 15,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('选择主题颜色'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: _selectedMonetColor,
                          onColorChanged: (Color color) {
                            setState(() => _selectedMonetColor = color);
                            myAppState?._changeMonetSeedColor(color);
                          },
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text('完成'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          SwitchListTile(
            title: const Text('开启全局模糊效果'),
            value: _useBlurEffect,
            onChanged: (bool value) {
              setState(() {
                _useBlurEffect = value;
              });
              myAppState?._toggleBlurEffect(value);
            },
          ),
          ListTile(
            title: const Text('调整模糊强度'),
            subtitle: Slider(
              value: _blurIntensity,
              min: 0,
              max: 15,
              onChanged: (value) {
                setState(() {
                  _blurIntensity = value;
                });
                myAppState?._changeBlurIntensity(value);
              },
            ),
            trailing: Text(_blurIntensity.toStringAsFixed(1)),
          ),
          ListTile(
            title: const Text('调整圆角大小'),
            subtitle: Slider(
              value: _borderRadius,
              min: 0,
              max: 30,
              onChanged: (value) {
                setState(() {
                  _borderRadius = value;
                });
                myAppState?._changeBorderRadius(value);
              },
            ),
            trailing: Text(_borderRadius.toStringAsFixed(1)),
          ),
          const Divider(),
          ListTile(
            title: const Text('恢复默认设置'),
            onTap: () {
              myAppState?._resetSettings();
            },
          ),
          ListTile(
            title: const Text('关于'),
            subtitle: _packageInfo != null
                ? Text('版本: ${_packageInfo!.version}')
                : const Text('错误版本'), // 无法获取时显示 "错误版本"
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
          ListTile(
            title: const Text('版本检查'),
            onTap: _showVersionDialog,
          ),
        ],
      ),
    );
  }
}

// 关于页
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.info_outline, size: 50),
            ),
            const SizedBox(height: 20),
            const Text(
              '关于本应用',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '这是一个关于页面。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              '鸣谢',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text(
                '雾雨代码空间（wucode)',
                textAlign: TextAlign.center,
              ),
              onTap: () => _launchURL('https://wucode.xyz'),
            ),
            ListTile(
              title: const Text(
                'Device Info Plus',
                textAlign: TextAlign.center,
              ),
              onTap: () => _launchURL('https://pub.dev/packages/device_info_plus'),
            ),
            ListTile(
              title: const Text(
                'Flutter Color Picker',
                textAlign: TextAlign.center,
              ),
              onTap: () => _launchURL('https://pub.dev/packages/flutter_colorpicker'),
            ),
            if (kDebugMode)
              const Text(
                '当前为 Debug 模式',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}