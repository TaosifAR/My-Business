import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_business/features/auth/controllers/auth_controller.dart';
import 'package:my_business/features/auth/views/registration_screen.dart';

class LoginScreen extends StatefulWidget { // Controllers use korar jonno StatefulWidget kora bhalo
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // GlobalKey for the form validation
  final _formKey = GlobalKey<FormState>();

  // Controllers to capture input
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get the AuthController instance
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
          child: Form( // Wrapped with Form for validation
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Text(
                  "Login to manage your inventory",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Email Input Field
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) =>
                      GetUtils.isEmail(value!) ? null : "Enter a valid email",
                ),
                const SizedBox(height: 20),

                // Password Input Field
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Enter your password" : null,
                ),
                const SizedBox(height: 30),

                // Login Button with Loading State
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Obx(() => ElevatedButton(
                    onPressed: authController.isLoading.value
                        ? null // Disable button while loading
                        : () {
                            if (_formKey.currentState!.validate()) {
                              // Call the login method from AuthController
                              authController.login(
                                emailController.text.trim(),
                                passwordController.text,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: authController.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Login",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  )),
                ),
                const SizedBox(height: 20),

                // Navigation to Registration Screen
                Center(
                  child: TextButton(
                    onPressed: () => Get.to(() => const RegistrationScreen()),
                    child: const Text(
                      "Don't have an account? Register Now",
                      style: TextStyle(color: Color(0xFF0F172A)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Memory leak rokkhay controllers dispose kora dorkar
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}