import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wifi_iot/wifi_iot.dart';
import '../constants/app_colors.dart';
import '../widgets/futuristic_ui.dart';
import 'robot_reboot_page.dart';

class HomeWifiSetupPage extends StatefulWidget {
  const HomeWifiSetupPage({super.key});

  @override
  State<HomeWifiSetupPage> createState() => _HomeWifiSetupPageState();
}

class _HomeWifiSetupPageState extends State<HomeWifiSetupPage> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isSending = false;

  Future<void> _provisionRobot() async {
    if (_ssidController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your Home WiFi SSID"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      );
      return;
    }
    setState(() => _isSending = true);
    try {
      await WiFiForIoTPlugin.forceWifiUsage(true);
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint("Sending credentials to http://192.168.4.1/wifi...");
      final response = await http.post(
        Uri.parse('http://192.168.4.1/wifi'),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'ssid': _ssidController.text.trim(),
          'pass': _passController.text.trim(),
        },
      ).timeout(const Duration(seconds: 5));
      debugPrint("Robot Response: ${response.statusCode} - ${response.body}");
    } catch (e) {
      debugPrint("Request finished with expected interruption: $e");
    } finally {
      await Future.delayed(const Duration(seconds: 1));
      await WiFiForIoTPlugin.forceWifiUsage(false);
      if (mounted) {
        setState(() => _isSending = false);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const RobotRebootPage(),
            transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text("Step 2: Provision Robot"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const CyberText(
                          'Configuration',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
            const SizedBox(height: 8),
            Text(
              "Enter the SSID and Password of your Home WiFi.\nThe robot will reboot and attempt to join this network.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _ssidController,
                    decoration: const InputDecoration(
                      labelText: "Home WiFi SSID",
                      hintText: "e.g. MyHomeNetwork",
                      prefixIcon: Icon(Icons.wifi),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "WiFi Password",
                      hintText: "••••••••",
                      prefixIcon: Icon(Icons.lock_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SafeArea(
              child: NeonButton(
                label: 'Connect Robot to Home WiFi',
                isLoading: _isSending,
                onPressed: _isSending ? null : _provisionRobot,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}