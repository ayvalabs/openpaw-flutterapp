import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../constants/app_colors.dart';
import '../widgets/futuristic_ui.dart';
import 'portal_state.dart';

class AukiPortalsScreen extends StatefulWidget {
  const AukiPortalsScreen({super.key});
  @override
  State<AukiPortalsScreen> createState() => _AukiPortalsScreenState();
}

class _AukiPortalsScreenState extends State<AukiPortalsScreen> {
  String _bridgeUrl = 'http://192.168.4.2:3000';
  bool _connected = false;
  bool _loading = false;
  bool _arMode = false;
  bool _autoDetecting = true;

  List<PortalData> _portals = [];
  String? _statusMsg;

  @override
  void initState() {
    super.initState();
    _autoDetectBridge();
  }

  Future<void> _autoDetectBridge() async {
    const ips = ['192.168.4.2', '192.168.4.3', '192.168.4.1', '192.168.4.4', '192.168.4.5'];
    for (final ip in ips) {
      try {
        final res = await http.get(Uri.parse('http://$ip:3000/api/phone/status'))
            .timeout(const Duration(milliseconds: 500));
        if (res.statusCode == 200) {
          setState(() {
            _bridgeUrl = 'http://$ip:3000';
            _autoDetecting = false;
          });
          _statusMsg = 'Bridge found at $ip';
          return;
        }
      } catch (_) {}
    }
    setState(() => _autoDetecting = false);
  }

  MobileScannerController? _qrController;
  bool _scanning = false;
  double _heading = 0;
  StreamSubscription? _compassSub;

  double _userX = 0, _userY = 0, _userZ = 0;
  bool _positionSet = false;
  String _currentPortal = '';

  @override
  void dispose() {
    _qrController?.dispose();
    super.dispose();
  }

  String get _base => _bridgeUrl.replaceAll(RegExp(r'/+$'), '');

  Future<void> _connect() async {
    setState(() { _loading = true; _statusMsg = null; });
    try {
      final res = await http.get(Uri.parse('$_base/api/auki/status'))
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        await http.post(Uri.parse('$_base/api/auki/connect'))
            .timeout(const Duration(seconds: 3));
        setState(() => _connected = true);
        _loadPortals();
      } else {
        setState(() => _statusMsg = 'Bridge not reachable');
      }
    } catch (e) {
      setState(() => _statusMsg = 'Connection failed: $e');
    }
    setState(() => _loading = false);
  }

  Future<void> _loadPortals() async {
    try {
      final res = await http.get(Uri.parse('$_base/api/auki/portals'))
          .timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = (jsonDecode(res.body)['data'] ?? jsonDecode(res.body)) as Map;
        final list = (data['portals'] as List?) ?? [];
        setState(() {
          _portals = list.map((p) => PortalData(
            name: p['name'] ?? 'Unnamed',
            x: (p['position']?['x'] ?? 0).toDouble(),
            y: (p['position']?['y'] ?? 0).toDouble(),
            z: (p['position']?['z'] ?? 0).toDouble(),
          )).toList();
          final state = PortalState();
          state.portals = _portals
              .map((p) => PortalInfo(name: p.name, x: p.x, y: p.y, z: p.z))
              .toList();
          state.bridgeUrl = _bridgeUrl;
        });
      }
    } catch (_) {}
  }

  void _startScanning() async {
    _qrController = MobileScannerController(autoStart: true);
    _compassSub = magnetometerEventStream().listen((event) {
      double heading = (math.atan2(event.y, event.x) * 180 / math.pi) - 90;
      if (heading < 0) heading += 360;
      _heading = heading;
    });
    setState(() { _scanning = true; _arMode = false; _positionSet = false; });
  }

  void _onQrScanned(BarcodeCapture capture) {
    if (!_scanning || _positionSet || capture.barcodes.isEmpty) return;
    final content = capture.barcodes.first.rawValue ?? '';
    for (final p in _portals) {
      if (content.toLowerCase().contains(p.name.toLowerCase())) {
        setState(() {
          _userX = p.x; _userY = p.y; _userZ = p.z;
          _positionSet = true; _currentPortal = p.name;
          _scanning = false; _arMode = true;
        });
        _qrController?.stop(); _qrController?.dispose(); _qrController = null;
        final state = PortalState();
        state.hasPosition = true; state.userX = _userX; state.userY = _userY;
        state.userZ = _userZ; state.userHeading = _heading;
        state.currentPortal = _currentPortal;
        return;
      }
    }
    if (_portals.isNotEmpty) {
      setState(() {
        _userX = _portals.first.x; _userY = _portals.first.y;
        _userZ = _portals.first.z; _positionSet = true;
        _currentPortal = _portals.first.name;
        _scanning = false; _arMode = true;
      });
      _qrController?.stop(); _qrController?.dispose(); _qrController = null;
    }
  }

  void _stopScanning() {
    _qrController?.stop(); _qrController?.dispose(); _qrController = null;
    setState(() => _scanning = false);
  }

  double _distTo(PortalData p) {
    return math.sqrt(math.pow(p.x - _userX, 2) + math.pow(p.y - _userY, 2) + math.pow(p.z - _userZ, 2));
  }

  List<PortalData> get _sortedPortals {
    final list = List<PortalData>.from(_portals);
    list.sort((a, b) => _distTo(a).compareTo(_distTo(b)));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: CyberText(
          _arMode ? 'AR Portal View' : 'Portals',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          if (_connected && !_scanning && !_arMode)
            IconButton(
              icon: const Icon(Icons.camera_alt, color: AppColors.accent),
              onPressed: _startScanning,
              tooltip: 'Scan QR to locate',
            ),
          if (_scanning)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.accentPink),
              onPressed: _stopScanning,
              tooltip: 'Cancel scan',
            ),
          if (_arMode)
            IconButton(
              icon: const Icon(Icons.list, color: AppColors.accent),
              onPressed: () => setState(() => _arMode = false),
              tooltip: 'List view',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_scanning) return _buildScanner();
    if (_arMode) return _buildArView();
    if (!_connected) return _buildConnectView();
    return _buildListView();
  }

  /* ── Connect screen ────────────────────────────── */
  Widget _buildConnectView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: AppColors.accent.withOpacity(0.2),
                blurRadius: 30,
              )],
            ),
            child: const Icon(Icons.near_me, size: 64, color: AppColors.accent),
          ),
          const SizedBox(height: 24),
          const Text('Portal Locator',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          if (_autoDetecting)
            Column(
              children: [
                const SizedBox(
                  width: 36, height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Searching for bridge on network...',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            )
          else ...[
            GlassCard(
              glowColor: AppColors.accent,
              glowIntensity: 0.4,
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.link, color: AppColors.accent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_bridgeUrl,
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _autoDetecting = true);
                      _autoDetectBridge();
                    },
                    child: const Text('Scan',
                        style: TextStyle(color: AppColors.accent, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            NeonButton(
              label: 'Connect',
              isLoading: _loading,
              onPressed: _loading ? null : _connect,
              color: AppColors.primary,
            ),
          ],
          if (_statusMsg != null) ...[
            const SizedBox(height: 12),
            Text(_statusMsg!,
                style: TextStyle(
                  color: _statusMsg!.contains('fail') ? AppColors.error : AppColors.accentGreen,
                  fontSize: 13,
                )),
          ],
        ],
      ),
    );
  }

  /* ── QR Scanner ────────────────────────────────── */
  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(controller: _qrController, onDetect: _onQrScanned),
        Positioned(
          top: 20, left: 20, right: 20,
          child: GlassCard(
            glowColor: AppColors.accent,
            glowIntensity: 0.5,
            borderRadius: 12,
            child: Column(
              children: [
                const Text('Scan a Portal QR Code',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Point camera at a DMT portal QR to set your position',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                Text('${_portals.length} portals loaded',
                    style: const TextStyle(color: AppColors.accent, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /* ── AR Camera View ────────────────────────────── */
  Widget _buildArView() {
    final sorted = _sortedPortals;
    return Stack(
      children: [
        MobileScanner(controller: MobileScannerController(autoStart: true)),
        Container(color: Colors.black.withOpacity(0.3)),
        Positioned(
          top: 12, left: 12, right: 12,
          child: GlassCard(
            glowColor: AppColors.accentGreen,
            glowIntensity: 0.5,
            borderRadius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.my_location, color: Colors.greenAccent, size: 16),
                    const SizedBox(width: 6),
                    Text('You are at: $_currentPortal',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('X: ${_userX.toStringAsFixed(2)}  Y: ${_userY.toStringAsFixed(2)}  Z: ${_userZ.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'monospace')),
              ],
            ),
          ),
        ),
        ...sorted.map((p) {
          final dx = p.x - _userX;
          final dz = p.z - _userZ;
          final dist = math.sqrt(dx * dx + dz * dz);
          final angle = math.atan2(dx, dz) * 180 / math.pi;
          final isCurrent = p.name == _currentPortal;
          final maxDist = 10.0;
          final screenPos = (dist / maxDist).clamp(0.2, 1.0);
          final size = (1.3 - screenPos) * 80 + 30;

          return Positioned(
            left: (MediaQuery.of(context).size.width / 2) + (dx * 30) - size / 2,
            top: (MediaQuery.of(context).size.height / 3) + (dz * 20) - size / 2,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _userX = p.x; _userY = p.y; _userZ = p.z;
                  _currentPortal = p.name;
                });
              },
              child: Container(
                width: size, height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent
                      ? Colors.green.withOpacity(0.6)
                      : AppColors.primary.withOpacity(0.6),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: isCurrent ? Colors.green : AppColors.primary,
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${dist.toStringAsFixed(1)}m',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(p.name.replaceAll(' ', '\n'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 7)),
                  ],
                ),
              ),
            ),
          );
        }),
        Positioned(
          bottom: 20, left: 12, right: 12,
          child: SizedBox(
            child: GlassCard(
            glowColor: AppColors.primary,
            glowIntensity: 0.2,
            borderRadius: 12,
            padding: const EdgeInsets.all(10),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sorted.length,
              itemBuilder: (_, i) {
                final p = sorted[i];
                final dist = _distTo(p);
                final isCurrent = p.name == _currentPortal;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        isCurrent ? Icons.my_location : Icons.near_me,
                        color: isCurrent ? Colors.greenAccent : AppColors.textHint,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(p.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            )),
                      ),
                      Text('${dist.toStringAsFixed(2)}m',
                          style: TextStyle(
                            color: dist < 2 ? Colors.greenAccent : AppColors.textSecondary,
                            fontSize: 12, fontFamily: 'monospace',
                          )),
                      const SizedBox(width: 8),
                      Text('(${p.x.toStringAsFixed(1)}, ${p.y.toStringAsFixed(1)}, ${p.z.toStringAsFixed(1)})',
                          style: const TextStyle(color: AppColors.textHint, fontSize: 9)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        ),
        Positioned(
          bottom: 170, left: 0, right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Tap a portal marker to teleport',
                  style: TextStyle(color: AppColors.textHint, fontSize: 10)),
            ),
          ),
        ),
      ],
    );
  }

  /* ── List View ─────────────────────────────────── */
  Widget _buildListView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          color: AppColors.primary.withOpacity(0.08),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(_base,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ),
              Text('${_portals.length} portals',
                  style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.camera_alt, size: 18, color: AppColors.accent),
                onPressed: _startScanning,
                tooltip: 'AR view',
              ),
            ],
          ),
        ),
        Expanded(
          child: _portals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.textHint.withOpacity(0.1),
                        ),
                        child: const Icon(Icons.location_off, size: 48, color: AppColors.textHint),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _loadPortals,
                        icon: const Icon(Icons.refresh, color: AppColors.accent),
                        label: const Text('Refresh',
                            style: TextStyle(color: AppColors.accent)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _portals.length,
                  itemBuilder: (_, i) => StaggeredFadeIn(
                    index: i,
                    child: _portalCard(_portals[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _portalCard(PortalData p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        glowColor: AppColors.primary,
        glowIntensity: 0.4,
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.near_me, color: AppColors.accent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(p.name,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _coord('X', p.x, AppColors.accentPink),
                  _coord('Y', p.y, AppColors.accentGreen),
                  _coord('Z', p.z, AppColors.accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coord(String label, double v, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(v.toStringAsFixed(2),
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
                shadows: [Shadow(color: color.withOpacity(0.4), blurRadius: 6)],
              )),
      ],
    );
  }
}

class PortalData {
  final String name;
  final double x, y, z;
  PortalData({required this.name, required this.x, required this.y, required this.z});
}