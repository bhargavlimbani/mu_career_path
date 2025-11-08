// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:ifqara/theme/app_theme.dart';
// import 'package:ifqara/core/app_shell.dart';
// import 'package:ifqara/security/password_crypto.dart';
// import 'package:ifqara/services/auth_store.dart';
// import 'package:ifqara/views/screens/unified_shop_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _email = TextEditingController();
//   final _password = TextEditingController();

//   bool _obscure = true;
//   bool _loading = false;

//   static const String kPasswordSecret = 'p9WqX3r7B2mV8nC4kY6tQ0zL1sD5fH9J';

//   @override
//   void dispose() {
//     _email.dispose();
//     _password.dispose();
//     super.dispose();
//   }

//   Future<void> _onLogin() async {
//     if (!(_formKey.currentState?.validate() ?? false)) return;

//     setState(() => _loading = true);
//     try {
//       final email = _email.text.trim();
//       final plain = _password.text;

//       final encB64 = encryptPasswordForPhp(plain, kPasswordSecret);

//       final uri = Uri.parse(
//         'https://ifqara.com/wp-json/custom-auth/v1/generate-app-password',
//       );

//       http.Response resp;
//       try {
//         resp = await http
//             .post(
//           uri,
//           headers: const {'Content-Type': 'application/json'},
//           body: jsonEncode({
//             'email': email,
//             'password_enc': encB64,
//             'api_key': kPasswordSecret,
//           }),
//         )
//             .timeout(const Duration(seconds: 20));
//       } on TimeoutException {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Server is taking too long to respond. Try again."),
//           ),
//         );
//         return;
//       }

//       Map<String, dynamic>? data;
//       try {
//         final body = resp.body.isNotEmpty ? resp.body : '{}';
//         final decoded = jsonDecode(body);
//         if (decoded is Map<String, dynamic>) data = decoded;
//       } catch (e) {
//         debugPrint("JSON decode failed: $e");
//       }

//       final appPassword = data?['app_password']?.toString();
//       if (resp.statusCode == 200 &&
//           appPassword != null &&
//           appPassword.isNotEmpty) {
//         await AuthStore.instance.saveLogin(
//           appPassword: appPassword,
//           userEmail: (data?['user_email']?.toString().isNotEmpty ?? false)
//               ? data!['user_email'].toString()
//               : email,
//           userId: (data?['user_id'] is int)
//               ? data!['user_id'] as int
//               : int.tryParse('${data?['user_id'] ?? ''}'),
//           uuid: data?['uuid']?.toString(),
//         );

//         if (!mounted) return;
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (_) => const JewelryApp()),
//         );
//         return;
//       }

//       final msg = data?['message']?.toString().trim();
//       throw Exception(
//         (msg?.isNotEmpty == true)
//             ? msg
//             : 'Login failed (code ${resp.statusCode})',
//       );
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Login failed: $e')),
//       );
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   String? _validateEmail(String? v) {
//     if (v == null || v.trim().isEmpty) return 'Enter email';
//     final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim());
//     if (!ok) return 'Enter a valid email';
//     return null;
//   }

//   String? _validatePassword(String? v) {
//     if (v == null || v.isEmpty) return 'Enter password';
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.secondary,
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Background
//           Image.asset(
//             "assets/splash/jewelry_model.jpg",
//             fit: BoxFit.cover,
//           ),

//           // Dark gradient overlay
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.black.withOpacity(0.6),
//                   Colors.black.withOpacity(0.2),
//                 ],
//                 begin: Alignment.bottomCenter,
//                 end: Alignment.topCenter,
//               ),
//             ),
//           ),

//           Center(
//             child: SingleChildScrollView(
//               child: Container(
//                 width: double.infinity,
//                 margin: const EdgeInsets.symmetric(horizontal: 28),
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: AppTheme.secondary,
//                   borderRadius: BorderRadius.circular(28),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.15),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       // Logo
//                       Image.asset(
//                         "assets/icons/ifqara_icon_monochrome.png",
//                         height: 200,
//                         fit: BoxFit.contain,
//                       ),
//                       const SizedBox(height: 20),

//                       // Email
//                       TextFormField(
//                         controller: _email,
//                         keyboardType: TextInputType.emailAddress,
//                         style: const TextStyle(color: AppTheme.textColor),
//                         decoration: _inputDecoration(
//                           label: "Email",
//                           icon: Icons.email_outlined,
//                         ),
//                         validator: _validateEmail,
//                       ),
//                       const SizedBox(height: 18),

//                       // Password
//                       TextFormField(
//                         controller: _password,
//                         obscureText: _obscure,
//                         style: const TextStyle(color: AppTheme.textColor),
//                         decoration: _inputDecoration(
//                           label: "Password",
//                           icon: Icons.lock_outline,
//                           suffix: IconButton(
//                             onPressed: () =>
//                                 setState(() => _obscure = !_obscure),
//                             icon: Icon(
//                               _obscure
//                                   ? Icons.visibility_off
//                                   : Icons.visibility,
//                               color: AppTheme.primary,
//                             ),
//                           ),
//                         ),
//                         validator: _validatePassword,
//                       ),
//                       const SizedBox(height: 28),

//                       // Login Button (single color)
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             backgroundColor: AppTheme.primary, // single color
//                             shadowColor: AppTheme.primary.withOpacity(0.4),
//                             elevation: 6,
//                           ),
//                           onPressed: _loading ? null : _onLogin,
//                           child: Container(
//                             alignment: Alignment.center,
//                             height: 50,
//                             child: _loading
//                                 ? const SizedBox(
//                               height: 24,
//                               width: 24,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor:
//                                 AlwaysStoppedAnimation<Color>(
//                                     Colors.white),
//                               ),
//                             )
//                                 : const Text(
//                               'Login',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 18,
//                                 color: Colors.white,
//                                 letterSpacing: 0.8,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 18),

//                       // Forgot Password
//                       TextButton(
//                         onPressed: () {},
//                         child: Text(
//                           "Forgot Password?",
//                           style: TextStyle(
//                             color: AppTheme.textColor.withOpacity(0.7),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   InputDecoration _inputDecoration({
//     required String label,
//     required IconData icon,
//     Widget? suffix,
//   }) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: TextStyle(color: AppTheme.textColor.withOpacity(0.7)),
//       prefixIcon: Icon(icon, color: AppTheme.primary),
//       suffixIcon: suffix,
//       filled: true,
//       fillColor: AppTheme.secondary,
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(
//           color: AppTheme.primary.withOpacity(0.5),
//         ),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: BorderSide(
//           color: AppTheme.primary,
//           width: 1.5,
//         ),
//       ),
//     );
//   }
// }