import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:my_business/features/seller%20dashboard/controllers/seller_dashboard_controller.dart';

class SellerDashboardBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SellerDashboardController(), fenix: true);
  }
}