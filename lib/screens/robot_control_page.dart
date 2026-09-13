import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:http/http.dart' as http;
import 'package:wifi_iot/wifi_iot.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:media_scanner/media_scanner.dart';
import 'portal_state.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';
import '../widgets/futuristic_ui.dart';

class RobotControlPage extends StatefulWidget {
  final String? initialIp;
  const RobotControlPage({super.key, this.initialIp});

  @override
  State<RobotControlPage> createState() => _RobotControlPageState();
}

class _RobotControlPageState extends State<RobotControlPage> {
  String? _robotIp;
    bool _isSearching = true;

  /* Status */
  int _distance = 0;
  double _tempAmbient = 0.0;
  double _tempObject = 0.0;
  bool _laserOn = false;
  int _drive = 0;
  int _turn = 0;

  /* Recording */
  bool _isRecording = false;
  bool _showPreview = true;
  Timer? _recordTimer;
  Duration _recordDuration = Duration.zero;
  String? _localVideoPath;
  Session? _ffmpegSession;

  /* Status polling */
  Timer? _statusTimer;

  /* Motor smoothing */
      double _driveVal = 0;
      double _turnVal = 0;

      /* Portal navigation */
          PortalInfo? _navTarget;
          Timer? _navTimer;
          double _navPosX = 0;
          double _navPosZ = 0;
          bool _navigating = false;

          /* Robot pose from firmware */
          double _robotX = 0, _robotY = 0, _robotHeading = 0;
          List<Offset> _trajectory = [];
          bool _showMap = false;
          Timer? _poseTimer;

  @override
    void initState() {
      super.initState();
      if (widget.initialIp != null) {
        _robotIp = widget.initialIp;
        _isSearching = false;
        _startStatusPolling();
      } else {
        _checkWifiAndConnect();
      }
    }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _recordTimer?.cancel();
    _ffmpegSession?.cancel();
    super.dispose();
  }

  String get _baseUrl => 'http://$_robotIp';
  String get _streamUrl => 'http://$_robotIp:81/stream';

  /* ==================== CONNECTION ==================== */

    Future<void> _checkWifiAndConnect() async {
      try {
        String? ssid = await WiFiForIoTPlugin.getSSID();
        debugPrint('PAWME: Current SSID = "$ssid"');
        /* Check if connected to PAWME-Robot (case-insensitive) */
        if (ssid != null && ssid.toLowerCase().contains('pawme')) {
          _robotIp = '192.168.4.1';
          _isSearching = false;
          _startStatusPolling();
          if (mounted) setState(() {});
          return;
        }
      } catch (e) {
        debugPrint('PAWME: WiFi check error: $e');
      }
      /* SSID didn't match — try direct connect anyway */
      _tryDirectConnect();
    }

    Future<void> _tryDirectConnect() async {
      const candidates = ['192.168.4.1', '192.168.1.1'];
      for (final ip in candidates) {
        try {
          final res = await http.get(Uri.parse('http://$ip/status'))
              .timeout(const Duration(seconds: 1));
          if (res.statusCode == 200) {
            _robotIp = ip;
            _isSearching = false;
            _startStatusPolling();
            if (mounted) setState(() {});
            return;
          }
        } catch (_) {}
      }
      /* Nothing found */
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }

  /* ==================== STATUS POLLING ==================== */

  void _startStatusPolling() {
    _statusTimer = Timer.periodic(const Duration(milliseconds: 500), (_) => _fetchStatus());
    _fetchStatus();
    _startPosePolling();
  }

  Future<void> _fetchStatus() async {
    if (_robotIp == null) return;
    try {
      final res = await http.get(Uri.parse('$_baseUrl/status'))
          .timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _distance = data['distance'] ?? 0;
          _tempAmbient = (data['temp_ambient'] ?? 0.0).toDouble();
          _tempObject = (data['temp_object'] ?? 0.0).toDouble();
          _laserOn = data['laser'] ?? false;
          _drive = data['drive'] ?? 0;
          _turn = data['turn'] ?? 0;
        });
      }
    } catch (_) {}
  }

  /* ==================== MOTOR CONTROL ==================== */

  Future<void> _sendMotor(double drive, double turn) async {
    if (_robotIp == null) return;
    final d = (drive * 255).round().clamp(-255, 255);
    final t = (turn * 255).round().clamp(-255, 255);
    try {
      await http.get(Uri.parse('$_baseUrl/motor?drive=$d&turn=$t'))
          .timeout(const Duration(seconds: 1));
    } catch (_) {}
  }

  /* ==================== LASER & BEEP ==================== */

  Future<void> _toggleLaser() async {
    if (_robotIp == null) return;
    try {
      await http.get(Uri.parse('$_baseUrl/laser'))
          .timeout(const Duration(seconds: 2));
      _fetchStatus();
    } catch (_) {}
  }

  Future<void> _sendBeep() async {
    if (_robotIp == null) return;
    try {
      await http.get(Uri.parse('$_baseUrl/beep'))
          .timeout(const Duration(seconds: 1));
    } catch (_) {}
  }

  /* ==================== POSE POLLING ==================== */

  void _startPosePolling() {
    _poseTimer = Timer.periodic(const Duration(milliseconds: 500), (_) => _fetchPose());
  }

  Future<void> _fetchPose() async {
    if (_robotIp == null) return;
    try {
      final res = await http.get(Uri.parse('$_baseUrl/api/pose'))
          .timeout(const Duration(seconds: 1));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _robotX = (data['x'] ?? 0).toDouble();
          _robotY = (data['y'] ?? 0).toDouble();
          _robotHeading = (data['heading'] ?? 0).toDouble();
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchTrajectory() async {
    if (_robotIp == null) return;
    try {
      final res = await http.get(Uri.parse('$_baseUrl/api/trajectory'))
          .timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final pts = data['points'] as List? ?? [];
        setState(() {
          _trajectory = pts.map((p) => Offset(
            (p[0] as num).toDouble() / 1000.0,
            (p[1] as num).toDouble() / 1000.0,
          )).toList();
        });
      }
    } catch (_) {}
  }

  /* ==================== PORTAL NAVIGATION ==================== */

  void _startNavigation() {
    if (_navTarget == null) return;
    final state = PortalState();
    _navPosX = state.hasPosition ? state.userX : 0;
    _navPosZ = state.hasPosition ? state.userZ : 0;
    final heading = state.hasPosition ? state.userHeading : 0;
    setState(() => _navigating = true);

    _navTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted || !_navigating || _navTarget == null) {
        _navTimer?.cancel();
        return;
      }

      final target = _navTarget!;
      final dx = target.x - _navPosX;
      final dz = target.z - _navPosZ;
      final dist = math.sqrt(dx * dx + dz * dz);

      if (dist < 0.3) {
        _sendMotor(0, 0);
        _navTimer?.cancel();
        setState(() { _navigating = false; _driveVal = 0; _turnVal = 0; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Arrived at ${target.name}')),
          );
        }
        return;
      }

      /* Calculate angle from robot to target in degrees */
      double targetAngle = math.atan2(dx, dz) * 180 / math.pi;
      if (targetAngle < 0) targetAngle += 360;

      /* Turn needed = difference between where robot points and where target is */
      double turnNeeded = targetAngle - heading;
      while (turnNeeded > 180) turnNeeded -= 360;
      while (turnNeeded < -180) turnNeeded += 360;

      double drive, turn;
      if (turnNeeded.abs() > 15) {
        /* Turn in place */
        drive = 0;
        turn = (turnNeeded > 0 ? 1.0 : -1.0) * 0.6;
      } else {
        /* Drive forward with slight turn correction */
        drive = 0.5;
        turn = turnNeeded / 15.0 * 0.3;
      }

      _sendMotor(drive, turn);

      /* Simulate position update based on drive direction */
      double rad = heading * math.pi / 180;
      _navPosX += drive * 0.01 * math.sin(rad);
      _navPosZ += drive * 0.01 * math.cos(rad);

      setState(() {});
    });
  }

  void _stopNavigation() {
    _navTimer?.cancel();
    _sendMotor(0, 0);
    setState(() {
      _navigating = false;
      _driveVal = 0;
      _turnVal = 0;
    });
  }

  /* Calculate distance from robot pose to target portal */
    double get _navDx => _navTarget != null ? _navTarget!.x - _robotX : 0;
    double get _navDz => _navTarget != null ? _navTarget!.z - _robotY : 0;
    double get _navDist => _navTarget != null ? math.sqrt(_navDx * _navDx + _navDz * _navDz) : 0;
  double get _navAngle => _navTarget != null ? math.atan2(_navDx, _navDz) * 180 / math.pi : 0;

  /* ==================== RECORDING ==================== */

  void _toggleRecording() {
    if (_robotIp == null) return;
    if (!_isRecording) {
      _startRecording();
    } else {
      _stopRecording();
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _showPreview = false;
    });
    await Future.delayed(const Duration(milliseconds: 1500));

    final tempDir = await getTemporaryDirectory();
    _localVideoPath = '${tempDir.path}/pawme_${DateTime.now().millisecondsSinceEpoch}.mp4';
    _recordDuration = Duration.zero;
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordDuration += const Duration(seconds: 1));
    });

    final command = '-f mjpeg -i $_streamUrl -c:v mpeg4 -q:v 5 -y $_localVideoPath';
    _ffmpegSession = await FFmpegKit.executeAsync(command, (session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        await _moveToGallery();
      }
      setState(() => _showPreview = true);
    });
  }

  Future<void> _stopRecording() async {
    _recordTimer?.cancel();
    if (_ffmpegSession != null) {
      await _ffmpegSession!.cancel();
      await Future.delayed(const Duration(seconds: 2));
    }
    setState(() => _isRecording = false);
  }

  Future<void> _moveToGallery() async {
    if (_localVideoPath == null) return;
    final file = File(_localVideoPath!);
    if (!await file.exists() || await file.length() == 0) return;
    final dir = Directory('/storage/emulated/0/DCIM/Pawme');
    if (!await dir.exists()) await dir.create(recursive: true);
    final newPath = '${dir.path}/pawme_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final newFile = await file.copy(newPath);
    await MediaScanner.loadMedia(path: newFile.path);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Video saved to DCIM/Pawme")),
      );
    }
  }

  String _fmtDur(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds.remainder(60))}';
  }

  /* ==================== BUILD ==================== */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          _robotIp != null ? 'PAWME Robot' : 'Connecting...',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_robotIp != null)
            IconButton(
              icon: Icon(_showMap ? Icons.videocam : Icons.map),
              onPressed: () {
                setState(() => _showMap = !_showMap);
                if (_showMap) _fetchTrajectory();
              },
              tooltip: 'Toggle map',
            ),
          if (_robotIp != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchStatus,
              tooltip: 'Refresh status',
            ),
        ],
      ),
      body: _robotIp == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSearching) ...[
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    const Text('Searching for PAWME robot...',
                        style: TextStyle(color: Colors.white70)),
                  ] else ...[
                    const Icon(Icons.wifi_off, color: Colors.white54, size: 48),
                    const SizedBox(height: 16),
                    const Text('No robot found',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => setState(() { _isSearching = true; _checkWifiAndConnect(); }),
                      child: const Text('Scan again'),
                    ),
                  ],
                ],
              ),
            )
          : _buildControlInterface(),
    );
  }

  Widget _buildControlInterface() {
    return Column(
      children: [
        /* ===== CAMERA STREAM ===== */
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              Center(
                child: _showPreview && !_showMap
                    ? Transform.rotate(
                        angle: math.pi, // 180° — camera mounted upside down
                        child: Mjpeg(
                          key: const ValueKey('preview'),
                          isLive: true,
                          stream: _streamUrl,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              /* 2D Map overlay */
              if (_showMap)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: CustomPaint(
                      painter: _MapPainter(
                        robotX: _robotX,
                        robotY: _robotY,
                        robotHeading: _robotHeading,
                        portals: PortalState().portals,
                        trajectory: _trajectory,
                        navTarget: _navTarget,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              if (_isRecording)
                Positioned(
                  top: 8,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'REC ${_fmtDur(_recordDuration)}',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              /* Status overlay */
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: GlassCard(
                  glowColor: AppColors.primary,
                  glowIntensity: 0.3,
                  borderRadius: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statusChip(Icons.straighten, '${_distance}mm'),
                      _statusChip(Icons.thermostat, '${_tempAmbient.toStringAsFixed(1)}°'),
                      _statusChip(Icons.whatshot, '${_tempObject.toStringAsFixed(1)}°'),
                      _statusChip(
                        Icons.toggle_on,
                        _laserOn ? 'ON' : 'OFF',
                        color: _laserOn ? Colors.redAccent : Colors.white54,
                      ),
                    ],
                  ),
                ),
              ),

              /* Navigation guidance overlay — always show when portal selected */
              if (_navTarget != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _navigating ? Icons.navigation : Icons.near_me,
                              color: _navigating ? Colors.amber : Colors.blueAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(_navTarget!.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Distance: ${_navDist.toStringAsFixed(2)}m  Bearing: ${_navAngle.toStringAsFixed(1)}°',
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontFamily: 'monospace')),
                        if (_navigating)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text('Auto-piloting...', style: TextStyle(color: Colors.amber, fontSize: 10)),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
                  ),

                  /* ===== PORTAL NAVIGATION DROPDOWN ===== */
                  if (PortalState().portals.isNotEmpty)
                    GlassCard(
                      glowColor: AppColors.accent,
                      glowIntensity: 0.2,
                      borderRadius: 0,
                      hasBorder: false,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.near_me, color: Colors.amber, size: 16),
                          const SizedBox(width: 8),
                          const Text('Go to:', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _navTarget?.name,
                                hint: const Text('Select portal...', style: TextStyle(color: Colors.white38, fontSize: 13)),
                                dropdownColor: const Color(0xFF2A2A2A),
                                isExpanded: true,
                                items: PortalState().portals.map((p) => DropdownMenuItem(
                                  value: p.name,
                                  child: Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
                                )).toList(),
                                onChanged: (name) {
                                  if (name == null) return;
                                  final portal = PortalState().portals.firstWhere((p) => p.name == name);
                                  if (_navigating) _stopNavigation();
                                  setState(() {
                                    _navTarget = portal;
                                    _navPosX = PortalState().hasPosition ? PortalState().userX : 0;
                                    _navPosZ = PortalState().hasPosition ? PortalState().userZ : 0;
                                    _navigating = false;
                                  });
                                },
                              ),
                            ),
                          ),
                          if (_navTarget != null)
                            IconButton(
                              icon: Icon(
                                _navigating ? Icons.stop_circle : Icons.play_arrow,
                                color: _navigating ? Colors.redAccent : Colors.greenAccent,
                              ),
                              onPressed: () {
                                if (_navigating) {
                                  _stopNavigation();
                                } else {
                                  _startNavigation();
                                }
                              },
                              tooltip: _navigating ? 'Stop navigation' : 'Start navigation',
                            ),
                        ],
                      ),
                    ),

                  /* ===== CONTROLS ===== */
        GlassCard(
          glowColor: AppColors.primary,
          glowIntensity: 0.15,
          borderRadius: 0,
          hasBorder: false,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /* Joysticks row */
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Joystick(
                    label: 'DRIVE',
                    onChanged: (v) {
                      _driveVal = v;
                      _sendMotor(_driveVal, _turnVal);
                    },
                    axis: _JoystickAxis.vertical,
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          _ActionButton(
                            icon: Icons.stop_circle,
                            label: 'STOP',
                            color: Colors.redAccent,
                            onTap: () {
                              _driveVal = 0;
                              _turnVal = 0;
                              _sendMotor(0, 0);
                            },
                          ),
                          const SizedBox(width: 12),
                          _ActionButton(
                            icon: Icons.volume_up,
                            label: 'BEEP',
                            onTap: _sendBeep,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _ActionButton(
                        icon: _laserOn ? Icons.toggle_on : Icons.toggle_off_outlined,
                        label: 'LASER',
                        color: _laserOn ? Colors.redAccent : null,
                        onTap: _toggleLaser,
                      ),
                    ],
                  ),
                  _Joystick(
                    label: 'TURN',
                    onChanged: (v) {
                      _turnVal = v;
                      _sendMotor(_driveVal, _turnVal);
                    },
                    axis: _JoystickAxis.horizontal,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              /* Record button */
              GestureDetector(
                onTap: _toggleRecording,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.red,
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.fiber_manual_record,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusChip(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color ?? Colors.white70),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color ?? Colors.white, fontSize: 12)),
      ],
    );
  }
}

/* ==================== JOYSTICK WIDGET ==================== */

enum _JoystickAxis { vertical, horizontal }

class _Joystick extends StatefulWidget {
  final String label;
  final _JoystickAxis axis;
  final ValueChanged<double> onChanged;

  const _Joystick({
    required this.label,
    required this.onChanged,
    this.axis = _JoystickAxis.vertical,
  });

  @override
  State<_Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<_Joystick> {
  double _value = 0;
  double? _startPos;

  void _onStart(details) {
    _startPos = widget.axis == _JoystickAxis.vertical
        ? details.localPosition.dy
        : details.localPosition.dx;
  }

  void _onMove(details) {
    if (_startPos == null) return;
    final pos = widget.axis == _JoystickAxis.vertical
        ? details.localPosition.dy
        : details.localPosition.dx;
    final delta = pos - _startPos!;
    final range = 40.0;
    double v;
    if (widget.axis == _JoystickAxis.vertical) {
      v = -(delta / range);  // up = positive (for DRIVE)
    } else {
      v = delta / range;     // left = negative, right = positive (for TURN)
    }
    v = v.clamp(-1.0, 1.0);
    setState(() => _value = v);
    widget.onChanged(v);
  }

  void _onEnd(_) {
    setState(() => _value = 0);
    _startPos = null;
    widget.onChanged(0);
  }

  @override
  Widget build(BuildContext context) {
    final knobOffset = widget.axis == _JoystickAxis.vertical
        ? Offset(0, -_value * 40)
        : Offset(_value * 40, 0);

    return GestureDetector(
      onPanStart: _onStart,
      onPanUpdate: _onMove,
      onPanEnd: _onEnd,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Stack(
          children: [
            Center(
              child: Transform.translate(
                offset: knobOffset,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE94560),
                    boxShadow: [
                      BoxShadow(color: Color(0x4DE94560), blurRadius: 12),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              left: 0,
              right: 0,
              child: Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ==================== ACTION BUTTON ==================== */

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Icon(icon, color: c, size: 22),
      ),
    );
  }
}

/* ==================== 2D MAP PAINTER ==================== */

class _MapPainter extends CustomPainter {
  final double robotX, robotY, robotHeading;
  final List<PortalInfo> portals;
  final List<Offset> trajectory;
  final PortalInfo? navTarget;

  _MapPainter({
    required this.robotX,
    required this.robotY,
    required this.robotHeading,
    required this.portals,
    required this.trajectory,
    this.navTarget,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF0A0A1A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);

    /* Transform: map meters to pixels, center on robot */
    final scale = 80.0; // pixels per meter
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx - robotX * scale, cy + robotY * scale);

    /* Grid */
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 0.5;
    for (double g = -10; g <= 10; g += 0.5) {
      canvas.drawLine(Offset(g * scale, -5 * scale), Offset(g * scale, 5 * scale), gridPaint);
      canvas.drawLine(Offset(-5 * scale, g * scale), Offset(5 * scale, g * scale), gridPaint);
    }

    /* Trajectory line */
    if (trajectory.length > 1) {
      final trajPaint = Paint()
        ..color = Colors.blue.withOpacity(0.4)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      final path = Path();
      path.moveTo(trajectory.first.dx * scale, -trajectory.first.dy * scale);
      for (int i = 1; i < trajectory.length; i++) {
        path.lineTo(trajectory[i].dx * scale, -trajectory[i].dy * scale);
      }
      canvas.drawPath(path, trajPaint);
    }

    /* Portal markers */
    for (final p in portals) {
      final isTarget = navTarget?.name == p.name;
      final px = p.x * scale;
      final py = -p.z * scale;

      /* Glow for target */
      if (isTarget) {
        final glow = Paint()
          ..color = Colors.amber.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        canvas.drawCircle(Offset(px, py), 18, glow);
      }

      /* Marker circle */
      final markerPaint = Paint()
        ..color = isTarget ? Colors.amber : const Color(0xFFE94560)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(px, py), 10, markerPaint);

      /* Border */
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(px, py), 10, borderPaint);

      /* Label */
      final tp = TextPainter(
        text: TextSpan(
          text: p.name,
          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: isTarget ? FontWeight.bold : FontWeight.normal),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py + 14));
    }

    /* Robot position */
    final robotPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, 0), 8, robotPaint);

    /* Heading arrow */
    final arrowLen = 25.0;
    final headRad = robotHeading;
    final arrowPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, 0),
      Offset(arrowLen * math.sin(headRad), -arrowLen * math.cos(headRad)),
      arrowPaint,
    );

    canvas.restore();

    /* Crosshair at center */
    final crossPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(cx - 20, cy), Offset(cx + 20, cy), crossPaint);
    canvas.drawLine(Offset(cx, cy - 20), Offset(cx, cy + 20), crossPaint);

    /* HUD text */
    final hud = TextPainter(
      text: TextSpan(
        text: 'X: ${robotX.toStringAsFixed(2)}m   Y: ${robotY.toStringAsFixed(2)}m   ${(robotHeading * 180 / math.pi).toStringAsFixed(1)}°',
        style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: 'monospace'),
      ),
      textDirection: TextDirection.ltr,
    );
    hud.layout();
    hud.paint(canvas, Offset(8, 8));
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => true;
}