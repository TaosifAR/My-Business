import 'package:get/get.dart';
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
  ];
}