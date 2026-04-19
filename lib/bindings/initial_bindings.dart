import 'package:get/get.dart';
class InitialBindings extends Bindings{
  @override
  void dependencies() {
    // Ekhane apnar controllers, services, etc. ke register korte paren
  // Get.lazyPut(()=> AuthController(), fenix: true) // Example: Get.put(SellerDashboardController());
  }
}