// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:project/admin/admin_dashboard.dart';
// import 'package:project/auth/sign_up.dart';
// import 'package:project/auth/forgot%20password/forgot_password.dart';
// import 'package:project/homescreen/home.dart';
// import 'package:project/restaurent/home.dart';
// // import 'package:project/restaurent/auth/restaurant_home_screen.dart';

// class Loginscreen extends StatefulWidget {
//   const Loginscreen({super.key});

//   @override
//   State<Loginscreen> createState() => _LoginscreenState();
// }

// class _LoginscreenState extends State<Loginscreen> {
//   // double width = 300;
//   // double height = 50.0;
//   bool login = true;
//   double loginAlign = -1;
//   double signInAlign = 1;
//   Color selectedColor = Colors.white;
//   Color normalColor = Colors.black54;
//   bool _obscureText = true;
//   final _formKey = GlobalKey<FormState>();

//   late Color loginColor;
//   late Color signInColor;
//   @override
//   void initState() {
//     super.initState();

//     loginColor = selectedColor;
//     signInColor = normalColor;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),

//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,

//         children: [
//           SizedBox(height: 10),
//           Center(
//             child: Container(
//               width: 200,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: Colors.black26,
//                 borderRadius: BorderRadius.all(Radius.circular(50.0)),
//               ),
//               child: Stack(
//                 children: [
//                   AnimatedAlign(
//                     alignment: Alignment(login ? -1 : 1, 0),
//                     duration: Duration(milliseconds: 300),
//                     child: Container(
//                       width: 200 * 0.5,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         color: Colors.deepPurple,
//                         borderRadius: BorderRadius.all(Radius.circular(50.0)),
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         login = true;
//                         loginColor = selectedColor;

//                         signInColor = normalColor;
//                       });
//                     },
//                     child: Align(
//                       alignment: Alignment(-1, 0),
//                       child: Container(
//                         width: 200 * 0.6,
//                         color: Colors.transparent,
//                         alignment: Alignment.center,
//                         child: Text(
//                           'Login',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         login = false;
//                         signInColor = selectedColor;

//                         loginColor = normalColor;
//                       });
//                     },
//                     child: Align(
//                       alignment: Alignment(1, 0),
//                       child: Container(
//                         width: 200 * 0.6,
//                         color: Colors.transparent,
//                         alignment: Alignment.center,
//                         child: Text(
//                           'SignUp',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(height: 50),

//           // Align(
//           //   child: Image(
//           //     image: AssetImage('assets/images/foodflex.png'),
//           //     width: 89,
//           //   ),
//           //   alignment: Alignment.topCenter,
//           // ),

//           // Container(
//           //   decoration: BoxDecoration(
//           //     image: DecorationImage(
//           //       image: AssetImage('assets/images/back.jpg'),
//           //       fit: BoxFit.fill,
//           //     ),
//           //     color: Colors.green[100],
//           //     borderRadius: BorderRadius.only(
//           //       topLeft: Radius.circular(30),
//           //       topRight: Radius.circular(30),
//           //     ),
//           //   ),
//           //   height:
//           //       MediaQuery.of(context).size.height *
//           //       0.60, // 60% of screen height
//           //   width: double.infinity,
//           //   padding: EdgeInsets.all(10),
//           login
//               ? Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Welcome back!',
//                             style: TextStyle(
//                               fontSize: 30,
//                               color: const Color.fromARGB(255, 0, 0, 0),
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 15),
//                       TextFormField(
//                         // keyboardType: TextInputType.,
//                         style: TextStyle(color: Colors.black87),
//                         decoration: InputDecoration(
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(),
//                           label: Text(
//                             'Email/Phone',
//                             style: TextStyle(
//                               color: const Color.fromARGB(255, 0, 0, 0),
//                             ),
//                           ),
//                           prefixIcon: Icon(Icons.person_outline_rounded),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter email or phone number';
//                           }

//                           final emailRegex = RegExp(
//                             r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
//                           );
//                           final phoneRegex = RegExp(
//                             r'^[6-9]\d{9}$',
//                           ); // Indian mobile format

//                           if (!emailRegex.hasMatch(value) &&
//                               !phoneRegex.hasMatch(value)) {
//                             return 'Enter a valid email or phone number';
//                           }

//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 5),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ForgotPassword(),
//                                 ),
//                               );
//                             },
//                             child: Text(
//                               'forgot password?',
//                               style: TextStyle(
//                                 color: const Color.fromARGB(255, 70, 64, 255),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       TextFormField(
//                         obscureText: _obscureText,
//                         style: TextStyle(color: Colors.black87),
//                         decoration: InputDecoration(
//                           fillColor: Colors.white,
//                           border: OutlineInputBorder(),
//                           label: Text(
//                             'Password',
//                             style: TextStyle(
//                               color: const Color.fromARGB(255, 0, 0, 0),
//                             ),
//                           ),
//                           prefixIcon: Icon(Icons.lock),
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _obscureText
//                                   ? Icons.visibility_off
//                                   : Icons.visibility,
//                               color: Colors.white,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _obscureText = !_obscureText;
//                               });
//                             },
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Password is required';
//                           } else if (value.length < 8) {
//                             return 'Must be atleast 8 characters';
//                           } else if (!RegExp(r'[0-9]').hasMatch(value)) {
//                             return 'Must contain atleast one number';
//                           } else if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
//                             return 'Must contain a special character (!@#\$&*~)';
//                           }
//                           return null;
//                         },
//                       ),

//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.deepPurple,
//                           minimumSize: Size(500, 50),
//                         ),
//                         onPressed: () {
//                           if (_formKey.currentState!.validate()) {
//                             Navigator.pushAndRemoveUntil(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => HomeScreen(),
//                               ),
//                               (route) => false,
//                             );
//                           }
//                         },
//                         child: Text(
//                           'Login',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       SizedBox(height: 30),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Divider(color: Colors.red, thickness: 1),
//                           ),
//                           Text(
//                             'OR',
//                             style: TextStyle(
//                               color: const Color.fromARGB(255, 43, 6, 145),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),

//                           Expanded(
//                             child: Divider(color: Colors.red, thickness: 1),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 30),

//                       // Icon(Icons.goo)
//                       // ElevatedButton.icon(
//                       //   onPressed: () {},
//                       //   icon: const FaIcon(
//                       //     FontAwesomeIcons.facebook,
//                       //     color: Colors.blueGrey,
//                       //   ),
//                       //   label: const Text("Continue with facebook"),
//                       // ),
//                       SizedBox(height: 5),
//                       ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: Size(500, 50),
//                         ),
//                         onPressed: () {},
//                         icon: const FaIcon(
//                           FontAwesomeIcons.google,
//                           color: Color.fromARGB(255, 234, 13, 13),
//                         ),
//                         label: Text(
//                           'Continue with Google',
//                           style: TextStyle(fontSize: 20),
//                         ),
//                       ),

//                       SizedBox(height: 5),
//                       ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           minimumSize: Size(500, 50),
//                         ),
//                         onPressed: () {},
//                         icon: const FaIcon(
//                           FontAwesomeIcons.facebook,
//                           color: Colors.blue,
//                         ),
//                         label: Text(
//                           'Continue with Facebook',
//                           style: TextStyle(fontSize: 20),
//                         ),
//                       ),
//                       SizedBox(height: 5),

//                       // ElevatedButton.icon(
//                       //   style: ElevatedButton.styleFrom(
//                       //     minimumSize: Size(500, 50),
//                       //   ),
//                       //   onPressed: () {},
//                       //   icon: const FaIcon(
//                       //     FontAwesomeIcons.apple,
//                       //     color: Colors.black,
//                       //   ),
//                       //   label: Text(
//                       //     'Continue with Apple ID',
//                       //     style: TextStyle(fontSize: 20),
//                       //   ),
//                       // ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Dont have an account?',
//                             style: TextStyle(
//                               color: const Color.fromARGB(255, 253, 25, 25),
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               setState(() {
//                                 login = false;
//                                 signInColor = selectedColor;

//                                 loginColor = normalColor;
//                               });
//                             },
//                             child: Text(
//                               'Sign up',
//                               style: TextStyle(
//                                 color: const Color.fromARGB(255, 70, 64, 255),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => restaurent_home_page(),
//                                 ),
//                               );
//                             },
//                             child: Text(
//                               'Login As restaurent',
//                               style: TextStyle(
//                                 color: const Color.fromARGB(255, 70, 64, 255),
//                               ),
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => AdminDashboard(),
//                                 ),
//                               );
//                             },
//                             child: Text(
//                               'Admin Login',
//                               style: TextStyle(
//                                 color: const Color.fromARGB(255, 70, 64, 255),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )
//               : SignUp(),
//         ],
//       ),
//     );
//   }
// }
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/admin/dashboard_admin.dart';
import 'package:project/auth/firebase/fibase_serviece.dart';
import 'package:project/auth/forgot%20password/forgot_password.dart';
import 'package:project/auth/sign_up.dart';
import 'package:project/homescreen/home.dart';
import 'package:project/restaurent/home.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  bool login = true;
  bool _obscureText = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  Color selectedColor = Colors.white;
  Color normalColor = Colors.black54;
  late Color loginColor;
  late Color signInColor;

  @override
  void initState() {
    super.initState();
    loginColor = selectedColor;
    signInColor = normalColor;
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signInWithEmailOrPhone(
        emailOrPhone: _emailOrPhoneController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['success']) {
        String role = result['role'];

        print('Login successful! Role: $role');

        Widget homeScreen;
        switch (role) {
          case 'admin':
            homeScreen = AdminDashboard();
            break;
          case 'restaurant':
            homeScreen = restaurent_home_page();
            break;
          case 'user':
          default:
            homeScreen = HomeScreen();
            break;
        }

        _showSnackBar('Welcome back!', Colors.green);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => homeScreen),
          (route) => false,
        );
      } else {
        log('Login failed: ${result['message']}');
        _showSnackBar(result['message'] ?? 'Login failed', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        log('Login failed: $e');
        _showSnackBar('An error occurred. Please try again.', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleRestaurantLogin() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RoleLoginDialog(
        authService: _authService,
        role: UserRole.restaurant,
        title: 'Restaurant Login',
        destination: restaurent_home_page(),
      ),
    );
  }

  Future<void> _handleAdminLogin() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RoleLoginDialog(
        authService: _authService,
        role: UserRole.admin,
        title: 'Admin Login',
        destination: AdminDashboard(),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Center(
      child: Container(
        width: 240,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: Alignment(login ? -1 : 1, 0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Container(
                width: 120,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        login = true;
                        loginColor = selectedColor;
                        signInColor = normalColor;
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Text(
                        'Login',
                        style: GoogleFonts.lato(
                          color: login ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        login = false;
                        signInColor = selectedColor;
                        loginColor = normalColor;
                      });
                    },
                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      child: Text(
                        'SignUp',
                        style: GoogleFonts.lato(
                          color: !login ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName;
    final firstName = (name != null && name.isNotEmpty) ? name.split(' ').first : null;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                firstName != null ? 'Welcome Back, $firstName' : 'Welcome Back',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _emailOrPhoneController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: GoogleFonts.lato(color: Colors.black87),
            decoration: InputDecoration(
              fillColor: Colors.grey[200],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black87, width: 1.5),
              ),
              labelText: 'Email/Phone',
              labelStyle: GoogleFonts.lato(color: Colors.grey[600]),
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: Colors.grey,
              ),
              floatingLabelStyle: const TextStyle(color: Colors.black87),
            ),
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter email or phone number';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
              final phoneRegex = RegExp(r'^[6-9]\d{9}$');

              if (!emailRegex.hasMatch(value) && !phoneRegex.hasMatch(value)) {
                return 'Enter a valid email or phone number';
              }
              return null;
            },
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPassword()),
                  );
                },
                child: Text(
                  'Forgot password?',
                  style: GoogleFonts.lato(
                    color: Colors.deepOrange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscureText,
            textInputAction: TextInputAction.done,
            style: GoogleFonts.lato(color: Colors.black87),
            decoration: InputDecoration(
              fillColor: Colors.grey[200],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black87, width: 1.5),
              ),
              labelText: 'Password',
              labelStyle: GoogleFonts.lato(color: Colors.grey[600]),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
              floatingLabelStyle: const TextStyle(color: Colors.black87),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() => _obscureText = !_obscureText);
                },
              ),
            ),
            onFieldSubmitted: (_) => _handleLogin(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              minimumSize: Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.3),
            ),
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Login',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
          ),
          SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'OR',
                  style: GoogleFonts.lato(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey, thickness: 1)),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                icon: FontAwesomeIcons.google,
                color: const Color(0xFFDB4437),
                onTap: () => _showSnackBar('Google Sign-In coming soon!', Colors.blue),
              ),
              const SizedBox(width: 24),
              _buildSocialButton(
                icon: FontAwesomeIcons.facebook,
                color: const Color(0xFF1877F2),
                onTap: () => _showSnackBar('Facebook Sign-In coming soon!', Colors.blue),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: GoogleFonts.lato(color: Colors.grey[700]),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    login = false;
                    signInColor = selectedColor;
                    loginColor = normalColor;
                  });
                },
                child: Text(
                  'Sign up',
                  style: GoogleFonts.lato(
                    color: Colors.deepOrange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: FaIcon(icon, color: color, size: 22)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/loginman.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                _buildToggleSwitch(),
                SizedBox(height: 50),
                login ? _buildLoginForm() : SignUp(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Role-Based Login Dialog
class RoleLoginDialog extends StatefulWidget {
  final AuthService authService;
  final UserRole role;
  final String title;
  final Widget destination;

  const RoleLoginDialog({
    required this.authService,
    required this.role,
    required this.title,
    required this.destination,
    super.key,
  });

  @override
  State<RoleLoginDialog> createState() => _RoleLoginDialogState();
}

class _RoleLoginDialogState extends State<RoleLoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await widget.authService.signInWithRole(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        expectedRole: widget.role,
      );

      if (!mounted) return;

      if (result['success']) {
        Navigator.of(context).pop();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => widget.destination),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Login failed'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[700]),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[700]),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _isLoading ? null : _handleLogin,
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text('Login', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
