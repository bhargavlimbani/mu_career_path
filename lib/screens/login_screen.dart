import 'package:flutter/material.dart';
import 'package:mu_career_pat_offline/services/auth_service.dart';
import 'package:mu_career_pat_offline/theme/app_theme.dart';
import 'register_screen.dart';
import 'student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscure = true;

  final AuthService _auth = AuthService();

  // 🔐 Login function
  void _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _auth.loginWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StudentDashboard()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.blackColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🖼️ Logo
                  Image.asset(
                    "assets/icon.png",
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),

                  // ✉️ Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: AppTheme.blackColor),
                    decoration: AppTheme.inputDecoration(
                      label: "Email",
                      icon: Icons.email_outlined,
                      hintTextColor: Colors.grey[600],
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter an email' : null,
                  ),
                  const SizedBox(height: 18),

                  // 🔒 Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    style: TextStyle(color: AppTheme.blackColor),
                    decoration: AppTheme.inputDecoration(
                      label: "Password",
                      icon: Icons.lock_outline,
                      hintTextColor: Colors.grey[600],
                      suffix: IconButton(
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'Enter your password'
                        : null,
                  ),
                  const SizedBox(height: 28),

                  // 🔘 Login button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: AppTheme.elevatedButtonStyle(),
                      onPressed: _isLoading ? null : _loginUser,
                      child: _isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        AppTheme.secondaryColor),
                              ),
                            )
                          : const Text(
                              "Login",
                              style: AppTheme.buttonText,
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 📝 Register link
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.blackColor,
                    ),
                    child: Text(
                      "Don’t have an account? Register",
                      style: AppTheme.linkText
                          .copyWith(color: AppTheme.blackColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
