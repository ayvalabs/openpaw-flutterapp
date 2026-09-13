import 'package:flutter/material.dart';
import 'package:wifi_iot/wifi_iot.dart';
import '../constants/app_colors.dart';
import '../widgets/futuristic_ui.dart';
import 'robot_control_page.dart';

class HomeNetworkConnectPage extends StatefulWidget {
  const HomeNetworkConnectPage({super.key});

  @override
  State<HomeNetworkConnectPage> createState() => _HomeNetworkConnectPageState();
}

class _HomeNetworkConnectPageState extends State<HomeNetworkConnectPage>
    with WidgetsBindingObserver {
  bool _isConnected = false;
  String? _currentSSID;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkCurrentConnection();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkCurrentConnection();
    }
  }

  Future<void> _checkCurrentConnection() async {
    bool connected = await WiFiForIoTPlugin.isConnected();
    String? ssid = await WiFiForIoTPlugin.getSSID();
    setState(() {
      _isConnected = connected &&
          ssid != null &&
          ssid != "<unknown ssid>" &&
          ssid != "PAWME-SETUP";
      _currentSSID = ssid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text("Step 3: Connect Phone"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            StaggeredFadeIn(
              index: 0,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (_isConnected ? AppColors.accentGreen : AppColors.accentOrange)
                      .withOpacity(0.08),
                  boxShadow: [
                    BoxShadow(
                      color: (_isConnected ? AppColors.accentGreen : AppColors.accentOrange)
                          .withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isConnected ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                  size: 56,
                  color: _isConnected ? AppColors.accentGreen : AppColors.accentOrange,
                ),
              ),
            ),
            const SizedBox(height: 24),
            StaggeredFadeIn(
              index: 1,
              child: CyberText(
                _isConnected ? "Phone Connected!" : "Connect to Home WiFi",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            StaggeredFadeIn(
              index: 2,
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _isConnected
                      ? "You are now on $_currentSSID. You can now control your robot."
                      : "Please go to settings and connect to the same WiFi you gave the robot.",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Spacer(),
            StaggeredFadeIn(
              index: 3,
              child: Column(
                children: [
                  if (!_isConnected)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () =>
                            WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text("Open WiFi Settings"),
                      ),
                    ),
                  if (!_isConnected) const SizedBox(height: 12),
                  NeonButton(
                    label: 'Control Robot',
                    onPressed: _isConnected
                        ? () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const RobotControlPage(),
                                transitionsBuilder: (_, a, __, child) =>
                                    FadeTransition(opacity: a, child: child),
                                transitionDuration: const Duration(milliseconds: 400),
                              ),
                            )
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}