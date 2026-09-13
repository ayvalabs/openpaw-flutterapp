/// Shared state for portal data between screens.
/// AukiPortalsScreen writes here; RobotControlPage reads.
class PortalState {
  static final PortalState _instance = PortalState._();
  factory PortalState() => _instance;
  PortalState._();

  List<PortalInfo> portals = [];
  double userX = 0, userY = 0, userZ = 0;
  double userHeading = 0; // compass heading in degrees when QR was scanned
  String currentPortal = '';
  bool hasPosition = false;
  String bridgeUrl = 'http://192.168.4.2:3000';
}

class PortalInfo {
  final String name;
  final double x, y, z;
  PortalInfo({required this.name, required this.x, required this.y, required this.z});
}