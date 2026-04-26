import 'package:get/get.dart';
import 'package:my_business/features/business%20oveview/views/business_overview_screen.dart';
import 'package:my_business/features/order%20entry/views/order_entry_screen.dart';
import 'package:my_business/features/product%20sell/views/product_sell_screen.dart';
import 'package:my_business/features/product_return/views/product_return_screen.dart';
import 'package:my_business/features/seller%20dashboard/views/seller_dashboard_screen.dart';
import 'package:my_business/routes/app_routes.dart';
import 'package:my_business/features/auth/views/login_screen.dart';
import 'package:my_business/features/auth/views/registration_screen.dart';
import 'package:my_business/features/home/views/home_screen.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.registration,
      page: () => const RegistrationScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.productsell, 
      page: () =>  ProductSellScreen()),
      GetPage(
      name: AppRoutes.dashboard, 
      page: () => SellerDashboardScreen()),
      GetPage(
      name: AppRoutes.productreturn, 
      page: () => ProductReturnScreen()),
       GetPage(
      name: AppRoutes.orderentry, 
      page: () => OrderEntryScreen()),
       GetPage(
      name: AppRoutes.businessoverview, 
      page: () => BusinessReportScreen()),
  ];
}