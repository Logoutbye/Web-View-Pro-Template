import 'package:permission_handler/permission_handler.dart';

void requestPermissions() async {
  await Permission.phone.request();

  // Map<Permission, PermissionStatus> statuses = await [
  //   Permission.camera,
  //   Permission.storage,
  //   Permission.microphone,
  //   Permission.phone,
  // ].request();
  // if (statuses[Permission.camera]!.isGranted &&
  //     statuses[Permission.storage]!.isGranted &&
  //     statuses[Permission.microphone]!.isGranted &&
  //     statuses[Permission.phone]!.isGranted) {
  //   // All permissions granted, proceed with the functionality.
  //   print('All permissions granted!');
  // } else {
  //   // Permissions not granted, handle accordingly.
  //   print('Some or all permissions not granted!');
  // }
}
