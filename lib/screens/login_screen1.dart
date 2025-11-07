// import 'package:flutter/material.dart';
// import '../data/local_data.dart';
// import '../widgets/custom_button.dart';
// import '../widgets/custom_textfield.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _email = TextEditingController();
//   final TextEditingController _password = TextEditingController();
//   String _error = '';
//   bool _loading = false;

//   bool _obscurePassword = true; // 👁️ for show/hide

//   void _login() async {
//     setState(() {
//       _loading = true;
//       _error = '';
//     });

//     var ld = LocalData();
//     var user = await ld.login(_email.text.trim(), _password.text.trim());
//     setState(() {
//       _loading = false;
//     });

//     if (user == null) {
//       setState(() {
//         _error = 'Use university or admin email domain.';
//       });
//       return;
//     }

//     if (user.email.endsWith('@marwadieducation.edu.in')) {
//       Navigator.pushReplacementNamed(context, '/admin');
//     } else {
//       Navigator.pushReplacementNamed(context, '/student');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 20),
//               Center(
//                 child: Column(
//                   children: [
//                     Icon(Icons.school,
//                         size: 80, color: Theme.of(context).primaryColor),
//                     SizedBox(height: 8),
//                     Text('MU Career Path',
//                         style: TextStyle(
//                             fontSize: 22, fontWeight: FontWeight.bold)),
//                     SizedBox(height: 4),
//                     Text('University placement portal',
//                         style: TextStyle(color: Colors.grey[700])),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 30),
//               Text('Login',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               SizedBox(height: 12),

//               // Email Field
//               CustomTextField(
//                 controller: _email,
//                 hint: 'Email (use your @marwadiuniversity.ac.in)',
//               ),
//               SizedBox(height: 12),

//               // ✅ Password Field with show/hide icon
//               TextField(
//                 controller: _password,
//                 obscureText: _obscurePassword,
//                 decoration: InputDecoration(
//                   hintText: 'Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                       color: Colors.grey,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//               SizedBox(height: 10),

//               // Error Message
//               if (_error.isNotEmpty)
//                 Text(_error, style: TextStyle(color: Colors.red)),
//               SizedBox(height: 12),

//               // Login Button
//               _loading
//                   ? Center(child: CircularProgressIndicator())
//                   : CustomButton(text: 'Login', onPressed: _login),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
