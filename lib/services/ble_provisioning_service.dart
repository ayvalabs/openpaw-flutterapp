import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// Talks to the OpenPaw firmware's NimBLE GATT provisioning service.
///
/// Firmware contract (see components/ble/ble_prov.c):
///   service 006e4000-… with characteristics
///     CRED   006e4001 (write)        JSON {"ssid":"..","pass":".."}
///     STATUS 006e4002 (read/notify)  1 byte: 0 idle 1 connecting 2 connected 3 failed
///     INFO   006e4003 (read)         `version|sta-mac`
class BleProvisioningService {
  static final Guid serviceUuid = Guid('006e4000-1212-efde-1523-785feabcd123');
  static final Guid credUuid = Guid('006e4001-1212-efde-1523-785feabcd123');
  static final Guid statusUuid = Guid('006e4002-1212-efde-1523-785feabcd123');
  static final Guid infoUuid = Guid('006e4003-1212-efde-1523-785feabcd123');

  /// Device advert name prefix (OpenPaw-XXYY).
  static const String namePrefix = 'OpenPaw';

  BluetoothDevice? _device;
  BluetoothCharacteristic? _cred;
  BluetoothCharacteristic? _status;
  BluetoothCharacteristic? _info;

  BluetoothDevice? get device => _device;

  /// Scan for OpenPaw robots. We filter by name (the 128-bit service UUID is in
  /// the scan response, which some Android stacks won't match in a scan filter).
  Stream<List<ScanResult>> scanForRobots(
      {Duration timeout = const Duration(seconds: 10)}) {
    FlutterBluePlus.startScan(timeout: timeout);
    return FlutterBluePlus.scanResults.map((results) => results
        .where((r) =>
            r.device.platformName.startsWith(namePrefix) ||
            r.advertisementData.advName.startsWith(namePrefix))
        .toList());
  }

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  /// Connect and resolve the three characteristics.
  Future<void> connect(BluetoothDevice device) async {
    await stopScan();
    _device = device;
    await device.connect(timeout: const Duration(seconds: 15));

    final services = await device.discoverServices();
    final svc = services.firstWhere(
      (s) => s.uuid == serviceUuid,
      orElse: () => throw StateError('OpenPaw GATT service not found'),
    );
    for (final c in svc.characteristics) {
      if (c.uuid == credUuid) {
        _cred = c;
      } else if (c.uuid == statusUuid) {
        _status = c;
      } else if (c.uuid == infoUuid) {
        _info = c;
      }
    }
    if (_cred == null || _status == null) {
      throw StateError('OpenPaw characteristics missing');
    }
  }

  /// Reads INFO, formatted as `version|sta-mac`.
  Future<String> readInfo() async {
    if (_info == null) return '';
    final value = await _info!.read();
    return utf8.decode(value);
  }

  /// Subscribe to STATUS notifications. Emits the raw status byte.
  Stream<int> statusStream() async* {
    await _status!.setNotifyValue(true);
    yield* _status!.lastValueStream
        .where((v) => v.isNotEmpty)
        .map((v) => v.first);
  }

  /// Write Wi-Fi credentials to CRED; firmware stores them and connects.
  Future<void> provision(String ssid, String pass) async {
    final payload = utf8.encode(jsonEncode({'ssid': ssid, 'pass': pass}));
    await _cred!.write(payload, withoutResponse: false);
  }

  Future<void> disconnect() async {
    try {
      await _device?.disconnect();
    } finally {
      _device = null;
      _cred = _status = _info = null;
    }
  }
}
