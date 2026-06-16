import 'package:get/get.dart';
import '../controllers/health_controller.dart';
import '../controllers/navigation_controller.dart';

class HealthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<HealthController>(() => HealthController());
  }
}
