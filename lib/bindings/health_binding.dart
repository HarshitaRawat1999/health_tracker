import 'package:health_tracker/app_exports.dart';

class HealthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<HealthController>(() => HealthController());
  }
}
