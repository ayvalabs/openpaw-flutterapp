import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_colors.dart';
import '../services/ble_provisioning_service.dart';

/// BLE-based Wi-Fi provisioning: scan for the robot, connect, send Home Wi-Fi
/// credentials over GATT, and watch the connection status it reports back.
class BleWifiSetupPage extends StatefulWidget {
  const BleWifiSetupPage({super.key});

  @override
  State<BleWifiSetupPage> createState() => _BleWifiSetupPageState();
}

enum _Phase { scanning, connecting, form }

class _BleWifiSetupPageState extends State<BleWifiSetupPage> {
  final BleProvisioningService _ble = BleProvisioningService();
  final TextEditingController _ssid = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  _Phase _phase = _Phase.scanning;
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<int>? _statusSub;
  List<ScanResult> _found = [];
  String _info = '';
  int? _wifiStatus; // 0 idle 1 connecting 2 connected 3 failed
  String? _error;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _phase = _Phase.scanning;
      _found = [];
      _error = null;
    });

    // Android 12+ needs runtime BLUETOOTH_SCAN/CONNECT (+ location on older).
    // iOS surfaces its own Bluetooth prompt when the scan starts — don't gate here
    // (the Android permission objects report "denied" on iOS and would false-fail).
    if (Platform.isAndroid) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();
      if (statuses.values.any((s) => s.isPermanentlyDenied)) {
        setState(() => _error =
            'Bluetooth & location permission is blocked. Enable it in Settings to find your robot.');
        return;
      }
    }

    // Wait for the BLE adapter to power on. On iOS this also triggers the
    // system Bluetooth permission prompt on first launch.
    try {
      await FlutterBluePlus.adapterState
          .firstWhere((s) => s == BluetoothAdapterState.on)
          .timeout(const Duration(seconds: 12));
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Turn on Bluetooth, then tap Rescan.');
      }
      return;
    }

    _scanSub?.cancel();
    _scanSub = _ble.scanForRobots().listen((results) {
      if (mounted) setState(() => _found = results);
    });
  }

  Future<void> _connect(BluetoothDevice device) async {
    setState(() {
      _phase = _Phase.connecting;
      _error = null;
    });
    try {
      await _ble.connect(device);
      final info = await _ble.readInfo();
      _statusSub = _ble.statusStream().listen((s) {
        if (mounted) setState(() => _wifiStatus = s);
      });
      if (!mounted) return;
      setState(() {
        _info = info;
        _phase = _Phase.form;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not connect: $e';
        _phase = _Phase.scanning;
      });
      _startScan();
    }
  }

  Future<void> _send() async {
    if (_ssid.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter your Wi-Fi SSID')));
      return;
    }
    setState(() => _sending = true);
    try {
      await _ble.provision(_ssid.text.trim(), _pass.text);
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to send credentials: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _statusSub?.cancel();
    _ble.stopScan();
    _ble.disconnect();
    _ssid.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Connect Robot to Wi-Fi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_error != null && _phase == _Phase.scanning && _found.isEmpty) {
      return _centered(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error!, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _startScan, child: const Text('Retry')),
        ],
      ));
    }
    switch (_phase) {
      case _Phase.scanning:
        return _buildScanList(theme);
      case _Phase.connecting:
        return _centered(const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to robot…'),
          ],
        ));
      case _Phase.form:
        return _buildForm(theme);
    }
  }

  Widget _buildScanList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Find your robot', style: theme.textTheme.displaySmall),
        const SizedBox(height: 8),
        const Text(
          'Make sure your robot is powered on. Nearby OpenPaw robots appear below.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _found.isEmpty
              ? _centered(const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Scanning…'),
                  ],
                ))
              : ListView.separated(
                  itemCount: _found.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final r = _found[i];
                    final name = r.device.platformName.isNotEmpty
                        ? r.device.platformName
                        : r.advertisementData.advName;
                    return ListTile(
                      leading: const Icon(Icons.pets, color: AppColors.primary),
                      title: Text(name),
                      subtitle: Text('Signal ${r.rssi} dBm'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _connect(r.device),
                    );
                  },
                ),
        ),
        SafeArea(
          child: TextButton(onPressed: _startScan, child: const Text('Rescan')),
        ),
      ],
    );
  }

  Widget _buildForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Configuration', style: theme.textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          _info.isEmpty
              ? 'Connected. Enter your Home Wi-Fi (2.4 GHz) — the robot will join it.'
              : 'Connected to firmware ${_info.split('|').first}. Enter your Home Wi-Fi (2.4 GHz).',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _ssid,
          decoration: const InputDecoration(
            labelText: 'Home Wi-Fi SSID',
            hintText: 'e.g. MyHomeNetwork',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _pass,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Wi-Fi Password',
            hintText: '••••••••',
          ),
        ),
        const SizedBox(height: 24),
        if (_wifiStatus != null) _statusBanner(theme),
        const Spacer(),
        SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _sending ? null : _send,
              child: _sending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Send to Robot'),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _statusBanner(ThemeData theme) {
    final (label, color, icon) = switch (_wifiStatus) {
      1 => ('Robot is connecting to Wi-Fi…', AppColors.warning, Icons.wifi_find),
      2 => ('Robot connected to Wi-Fi!', AppColors.success, Icons.wifi),
      3 => ('Robot failed to connect — check the password.', AppColors.error, Icons.wifi_off),
      _ => ('Waiting for credentials…', AppColors.textSecondary, Icons.hourglass_empty),
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: color))),
        ],
      ),
    );
  }

  Widget _centered(Widget child) => Center(child: child);
}
