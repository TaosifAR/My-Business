import 'package:get/get.dart';
import 'package:my_business/features/auth/controllers/auth_controller.dart'; // Correct import path
import 'package:my_business/features/seller%20dashboard/controllers/seller_dashboard_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // 1. Register AuthController permanently
    // We use Get.put with permanent: true because AuthController 
    // needs to run as long as the app is open to track login status.
    Get.put(AuthController(), permanent: true);

    // 2. Register other controllers lazily
    // fenix: true ensures that if the controller is deleted from memory, 
    // it will be re-initialized when called again.
    Get.lazyPut(() => SellerDashboardController(), fenix: true);
  }
}