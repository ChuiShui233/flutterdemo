import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:my_csmy/easter_egg_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart'; // 导入 salomon_bottom_bar 库

import 'system_settings_page.dart'; // 导入系统修改页
import 'theme_installation_page.dart'; // 导入主题安装页
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

class _MyAppState extends State<MyApp> {
  ThemeModeOption _themeMode = ThemeModeOption.system;
  Color _monetSeedColor = Colors.blue;
  bool _useDynamicColor = false;
  bool _useBlurEffect = false;
  double _borderRadius = 12.0;
  double _blurIntensity = 5.0; // 新增模糊强度
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkAndroidVersion();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = ThemeModeOption.values[prefs.getInt('themeMode') ?? 0];
      _monetSeedColor = Color(prefs.getInt('monetSeedColor') ?? Colors.blue.value);
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

  // 通用的显示模糊遮罩的方法
  Future<T?> _showBlurredDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool useRootNavigator = true,
    bool barrierDismissible = true,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
  }) {
    return showGeneralDialog(
      context: context,
      useRootNavigator: useRootNavigator,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300), // 遮罩出现速度更平缓
      pageBuilder: (context, animation, secondaryAnimation) => Stack(
        children: [
          if (_useBlurEffect)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _blurIntensity, sigmaY: _blurIntensity),
              child: FadeTransition(
                opacity: animation,
                child: Container(
                  color: Colors.transparent, // 保持透明，让模糊效果可见
                ),
              ),
            ),
          FadeTransition(
            opacity: animation,
            child: Builder(builder: builder),
          ),
        ],
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
    );
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
      return _isWelcomeShown
          ? _buildMainScreen(context) // 使用 _buildMainScreen 方法
          : const WelcomeScreen();
    }
  }

  Widget _buildMainScreen(BuildContext context) {
    final myAppState = context.findAncestorStateOfType<_MyAppState>();
    return MainScreen(
      useBlurEffect: myAppState?._useBlurEffect ?? false,
      borderRadius: myAppState?._borderRadius ?? 12.0,
      blurIntensity: myAppState?._blurIntensity ?? 5.0, // 传递模糊强度
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool useBlurEffect;
  final double borderRadius;
  final double blurIntensity; // 新增模糊强度

  const MainScreen({
    super.key,
    required this.useBlurEffect,
    required this.borderRadius,
    required this.blurIntensity,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    FeaturesPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('水月共创'),
        elevation: 4.0,
        // 移除 actions 属性中的 PopupMenuButton
        actions: [
          // 这里可以添加其他的 action，如果不需要任何 action，就保留空列表
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }
  
  Widget _buildBottomNavigationBar() {
    final bottomBar = Padding(
      padding: const EdgeInsets.all(18.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.0),
        child: widget.useBlurEffect
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: widget.blurIntensity, sigmaY: widget.blurIntensity),
                child: Container(
                  color: Theme.of(context).bottomNavigationBarTheme.backgroundColor?.withOpacity(0.7) ?? 
                      Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7), 
                  child: _buildSalomonBottomBar(),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
                      Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: _buildSalomonBottomBar(),
              ),
      ),
    );

    return Align(
      alignment: Alignment.bottomCenter, // 始终在底部
      child: SafeArea(
        child: bottomBar,
      ),
    );
  }

  Widget _buildSalomonBottomBar() {
    return SalomonBottomBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: [
        SalomonBottomBarItem(
          icon: const Icon(Icons.home),
          title: const Text("主页"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.build),
          title: const Text("功能"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.settings),
          title: const Text("设置"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
      ],
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
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void _loadCurrentTheme() {
    final myAppState = context.findAncestorStateOfType<_MyAppState>();
    _currentThemeMode = myAppState?._themeMode;
    _selectedMonetColor = myAppState?._monetSeedColor ?? Colors.blue;
    _useDynamicColor = myAppState?._useDynamicColor ?? false;
    _useBlurEffect = myAppState?._useBlurEffect ?? false;
    _blurIntensity = myAppState?._blurIntensity ?? 5.0;
  }

  void _showVersionDialog() {
    context.findAncestorStateOfType<_MyAppState>()?._showBlurredDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('版本警告'),
          content: const Text('当前版本为测试版本，可能存在一些问题和未完善功能。\n如有任何问题，请及时反馈。'),
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
          if (!_isAndroid12Plus || (_isAndroid12Plus && !_useDynamicColor))
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
            title: const Text('开启底部全局模糊'),
            value: _useBlurEffect,
            onChanged: (bool value) {
              setState(() {
                _useBlurEffect = value;
              });
              myAppState?._toggleBlurEffect(value);
            },
          ),
          ListTile(
            title: const Text('调整全局模糊强度'),
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
                : const Text('加载版本信息中...'),
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
              '雾雨工具箱是一个针对Oplus设备的通用优化工具箱，我希望以开源的形式，让更多的人参与到这个项目的建设中来🤗',
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
                "ShuiYue's blog",
                textAlign: TextAlign.center,
              ),
              onTap: () => _launchURL('https://cc12.eu.org/'),
            ),
            if (kDebugMode)
              const Text(
                '当前为 Release 模式',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}