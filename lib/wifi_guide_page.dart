import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

import 'constants/app_colors.dart';
import 'widgets/futuristic_ui.dart';
import 'screens/home_wifi_setup_page.dart';

class WifiGuidePage extends StatefulWidget {
  final String robotSSID;
  const WifiGuidePage({super.key, required this.robotSSID});

  @override
  State<WifiGuidePage> createState() => _WifiGuidePageState();
}

enum WifiStep { chooseNetwork, connecting, result }

class _WifiGuidePageState extends State<WifiGuidePage> {
  List<WifiNetwork> _wifiList = [];
  bool _isLoading = false;
  WifiStep _step = WifiStep.chooseNetwork;
  bool _connectionSuccess = false;
  bool _isConnectedToRobot = false;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndScan();
  }

  Future<void> _requestPermissionsAndScan() async {
    final status = await Permission.locationWhenInUse.request();
    if (!mounted) return;
    if (status.isGranted) {
      _startScan();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission and GPS must be ON')),
      );
    }
  }

  Future<void> _startScan() async {
    setState(() {
      _isLoading = true;
      _wifiList.clear();
      _step = WifiStep.chooseNetwork;
    });
    try {
      final results = await WiFiForIoTPlugin.loadWifiList();
      if (!mounted) return;
      setState(() {
        _wifiList = results
            .where((r) => r.ssid != null && r.ssid!.isNotEmpty)
            .toList()
          ..sort((a, b) => (b.level ?? -100).compareTo(a.level ?? -100));
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _connectToWifi(WifiNetwork wifi, String password) async {
    setState(() {
      _step = WifiStep.connecting;
      _connectionSuccess = false;
      _isConnectedToRobot = false;
    });
    final isRobot = wifi.ssid == widget.robotSSID;
    try {
      await WiFiForIoTPlugin.forceWifiUsage(true);
      final success = await WiFiForIoTPlugin.connect(
        wifi.ssid!,
        password: isRobot ? null : password,
        joinOnce: true,
        security: isRobot ? NetworkSecurity.NONE : NetworkSecurity.WPA,
      ).timeout(const Duration(seconds: 12), onTimeout: () => false);
      if (!mounted) return;
      final currentSsid = await WiFiForIoTPlugin.getSSID();
      final actuallyConnectedToRobot = currentSsid == widget.robotSSID || currentSsid == '"${widget.robotSSID}"';
      setState(() {
        _connectionSuccess = success || actuallyConnectedToRobot;
        _isConnectedToRobot = isRobot && _connectionSuccess;
        _step = WifiStep.result;
      });
    } catch (_) {
      if (mounted) {
        setState(() { _connectionSuccess = false; _step = WifiStep.result; });
      }
    } finally {
      if (!isRobot) {
        await WiFiForIoTPlugin.forceWifiUsage(false);
      }
    }
  }

  Future<void> _askPassword(WifiNetwork wifi) async {
    if (wifi.ssid == widget.robotSSID) {
      _connectToWifi(wifi, "");
      return;
    }
    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Enter WiFi Password',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Password',
            hintStyle: TextStyle(color: AppColors.textHint),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
    if (password != null) {
      _connectToWifi(wifi, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 30),
            Expanded(child: _buildContent()),
            const SizedBox(height: 20),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (_step == WifiStep.connecting) {
      return Column(
        children: [
          const SizedBox(
            width: 48, height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Connecting...',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Joining the robot hotspot...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center),
        ],
      );
    }
    return Column(
      children: [
        CyberText(
                  _step == WifiStep.result
                      ? (_connectionSuccess ? 'Connected!' : 'Connection Failed')
                      : 'Connect to Robot',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
        const SizedBox(height: 8),
        Text(
          _step == WifiStep.result
              ? (_connectionSuccess
                  ? 'Successfully joined ${widget.robotSSID}.'
                  : 'Could not establish connection.')
              : 'Select your Robot to begin setup.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading || _step == WifiStep.connecting) {
      return const SizedBox.shrink();
    }
    return ListView.builder(
      itemCount: _wifiList.length,
      itemBuilder: (_, i) {
        final wifi = _wifiList[i];
        final isRobot = wifi.ssid == widget.robotSSID;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: StaggeredFadeIn(
            index: i,
            child: InkWell(
              onTap: () => _askPassword(wifi),
              child: GlassCard(
                            glowColor: isRobot ? AppColors.primary : null,
                            glowIntensity: isRobot ? 0.5 : 0.1,
                            borderRadius: 14,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            child: Row(
                              children: [
                                Icon(
                                  isRobot ? Icons.smart_toy : Icons.wifi,
                                  color: isRobot ? AppColors.accent : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    wifi.ssid!,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: isRobot ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isRobot)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'SETUP',
                                      style: TextStyle(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: NeonButton(
          label: _step == WifiStep.result
              ? (_connectionSuccess ? 'Connect to Home Network' : 'Retry')
              : 'Refresh List',
          onPressed: () async {
            if (_step == WifiStep.result && _connectionSuccess) {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const HomeWifiSetupPage(),
                  transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              );
            } else {
              _startScan();
            }
          },
        ),
      ),
    );
  }
}