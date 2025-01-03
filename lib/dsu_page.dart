import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

class DSUInstallationScreen extends StatefulWidget {
  const DSUInstallationScreen({super.key});

  @override
  State<DSUInstallationScreen> createState() => _DSUInstallationScreenState();
}

class _DSUInstallationScreenState extends State<DSUInstallationScreen> {
  bool _isRooted = false;
  bool _continuedWithoutRoot = false; // New state to track if user continued without root
  bool _isFirstLaunch = true; // Replace with actual first launch check logic
  String? _selectedInstallationMode;
  String? _selectedFilePath;
  bool _configureUserSpace = false;
  String _userSpaceSize = '';
  int _remainingStorageGB = 0; // Placeholder for remaining storage

  @override
  void initState() {
    super.initState();
    _checkRootStatus();
    _calculateRemainingStorage(); // Simulate storage calculation
  }

  Future<void> _checkRootStatus() async {
    try {
      final ProcessResult result =
          await Process.run('su', ['-c', 'id'], runInShell: true);
      setState(() {
        _isRooted = result.exitCode == 0;
      });
    } catch (e) {
      setState(() {
        _isRooted = false;
      });
    }
  }

  // Placeholder for calculating remaining storage
  Future<void> _calculateRemainingStorage() async {
    // In a real application, you would use platform channels or a plugin
    // to get the actual remaining storage.
    // This is just a simulation.
    setState(() {
      _remainingStorageGB = 50; // Example: 50 GB remaining
    });
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
      });
    } else {
      // User canceled the picker
    }
  }

  Widget _buildInstallationModeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedInstallationMode != null)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _selectedInstallationMode = null;
                    _selectedFilePath = null;
                  });
                },
              ),
            Text(
              '安装',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_selectedInstallationMode == null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedInstallationMode = 'local';
                      });
                    },
                    child: const Text('本地安装'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('提示'),
                            content: const Text('联网安装功能暂未开放。'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('确定'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('联网安装'),
                  ),
                ],
              ),
            if (_selectedInstallationMode == 'local') ...[
              const SizedBox(height: 16),
              TextField(
                readOnly: true,
                controller: TextEditingController(
                    text: _selectedFilePath != null
                        ? path.basename(_selectedFilePath!)
                        : ''),
                decoration: const InputDecoration(
                  labelText: '选择文件',
                  border: OutlineInputBorder(),
                ),
                onTap: _selectFile,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_selectedFilePath != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilePath = null;
                        });
                      },
                      child: const Text('取消'),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isRooted && _selectedFilePath != null ? () {} : null,
                    child: const Text('安装'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfigureUserSpaceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '配置用户空间',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('启用用户空间配置'),
                Switch(
                  value: _configureUserSpace,
                  onChanged: _isRooted || _continuedWithoutRoot ? (value) {
                    setState(() {
                      _configureUserSpace = value;
                      if (!value) {
                        _userSpaceSize = '';
                      }
                    });
                  } : null, // Disable if no root and didn't continue
                ),
              ],
            ),
            if (_configureUserSpace) ...[
              const SizedBox(height: 16),
              TextField(
                enabled: _isRooted || _continuedWithoutRoot, // Disable if no root and didn't continue
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  labelText: '设置大小 (GB)',
                  border: const OutlineInputBorder(),
                  hintText: '剩余存储: $_remainingStorageGB GB',
                  errorText: _userSpaceSize.isNotEmpty &&
                          int.tryParse(_userSpaceSize) != null &&
                          int.parse(_userSpaceSize) > _remainingStorageGB
                      ? '超出剩余存储'
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _userSpaceSize = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutDSUCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '关于 DSU',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Dynamic System Updates (DSU) 允许您在不刷写设备系统分区的情况下尝试新的 Android 系统镜像。',
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () async {
                  // Open file picker to select a file for "了解更多"
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    // You can do something with the selected file here
                    print('Selected file for DSU info: ${result.files.single.path}');
                  }
                },
                child: const Text('详细了解'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DSU 安装'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isRooted || _continuedWithoutRoot
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    if (_isFirstLaunch) _buildInstallationModeCard(),
                    if (!_isFirstLaunch || _selectedInstallationMode != null)
                      _buildInstallationModeCard(),
                    const SizedBox(height: 16),
                    _buildConfigureUserSpaceCard(),
                    const SizedBox(height: 16),
                    _buildAboutDSUCard(),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '未检测到 Root 权限，DSU 安装需要 Root 权限。',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _continuedWithoutRoot = true;
                        });
                      },
                      child: const Text('继续 (部分功能受限)'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}