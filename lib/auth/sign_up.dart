// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:project/homescreen/home.dart';

// class SignUp extends StatefulWidget {
//   const SignUp({super.key});

//   @override
//   State<SignUp> createState() => _SignUpState();
// }

// class _SignUpState extends State<SignUp> {
//   bool isSignUpSelected = true;
//   final formKey = GlobalKey<FormState>();
//   bool _obscureText = true;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),

//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               // Align(
//               //   child: Image(
//               //     image: AssetImage('assets/images/foodflex.png'),
//               //     width: 89,
//               //   ),
//               //   alignment: Alignment.topCenter,
//               // ),

//               // Container(
//               //   decoration: BoxDecoration(
//               //     image: DecorationImage(
//               //       image: AssetImage('assets/images/back.jpg'),
//               //       fit: BoxFit.fill,
//               //     ),
//               //     color: Colors.green[100],
//               //     borderRadius: BorderRadius.only(
//               //       topLeft: Radius.circular(30),
//               //       topRight: Radius.circular(30),
//               //     ),
//               //   ),
//               //   height:
//               //       MediaQuery.of(context).size.height *
//               //       0.60, // 60% of screen height
//               //   width: double.infinity,
//               //   padding: EdgeInsets.all(10),
//               Form(
//                 key: formKey,
//                 child: Column(
//                   children: [
//                     Column(
//                       children: [
//                         TextFormField(
//                           style: TextStyle(color: Colors.black87, fontSize: 18),
//                           decoration: InputDecoration(
//                             fillColor: Colors.white,
//                             border: OutlineInputBorder(),
//                             hintText: 'enter your name',
//                             label: Text(
//                               ' Full Name',
//                               style: TextStyle(
//                                 color: const Color.fromARGB(255, 0, 0, 0),
//                               ),
//                             ),
//                             prefixIcon: Icon(Icons.person_outline_rounded),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.length < 4) {
//                               return 'atleast 4 letters';
//                             }
//                           },
//                         ),
//                         SizedBox(height: 20),
//                         TextFormField(
//                           keyboardType: TextInputType.number,
//                           style: TextStyle(color: Colors.black87),
//                           decoration: InputDecoration(
//                             fillColor: Colors.white,
//                             border: OutlineInputBorder(),
//                             label: Text(
//                               'Phone Number',
//                               style: TextStyle(
//                                 color: const Color.fromARGB(255, 0, 0, 0),
//                               ),
//                             ),
//                             prefixIcon: Icon(Icons.phone),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'enter your phone number';
//                             } else if (!RegExp(
//                               r'^[6-9]\d{9}$',
//                             ).hasMatch(value)) {
//                               return 'incorrect phone number';
//                             }
//                           },
//                         ),
//                         SizedBox(height: 10),
//                         TextFormField(
//                           keyboardType: TextInputType.emailAddress,
//                           style: TextStyle(color: Colors.black87, fontSize: 18),
//                           decoration: InputDecoration(
//                             fillColor: Colors.white,
//                             border: OutlineInputBorder(),
//                             hintText: 'enter your email id',
//                             label: Text(
//                               'Email',
//                               style: TextStyle(
//                                 color: const Color.fromARGB(255, 0, 0, 0),
//                               ),
//                             ),

//                             prefixIcon: Icon(Icons.email),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'enter your email ';
//                             } else if (!RegExp(
//                               r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                             ).hasMatch(value)) {
//                               return 'incorrect email';
//                             }
//                           },
//                         ),
//                         SizedBox(height: 20),
//                         TextFormField(
//                           style: TextStyle(color: Colors.black87),
//                           decoration: InputDecoration(
//                             fillColor: Colors.white,
//                             border: OutlineInputBorder(),
//                             label: Text(
//                               'Password',
//                               style: TextStyle(
//                                 color: const Color.fromARGB(255, 0, 0, 0),
//                               ),
//                             ),
//                             prefixIcon: Icon(Icons.lock),
//                             suffixIcon: IconButton(
//                               icon: Icon(
//                                 _obscureText
//                                     ? Icons.visibility_off
//                                     : Icons.visibility,
//                                 color: Colors.white,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _obscureText = !_obscureText;
//                                 });
//                               },
//                             ),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'enter your password';
//                             }
//                             final passwordRegex = RegExp(
//                               r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
//                             );
//                             if (!passwordRegex.hasMatch(value)) {
//                               return 'Password must be at least 8 characters,\ninclude upper & lower case, number, and special character';
//                             }
//                           },
//                           obscureText: _obscureText,
//                         ),

//                         SizedBox(height: 30),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.deepPurple,
//                             minimumSize: Size(500, 50),
//                           ),
//                           onPressed: () {
//                             if (formKey.currentState!.validate()) {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => HomeScreen(),
//                                 ),
//                               );
//                             }
//                           },
//                           child: Text(
//                             'Create Account',
//                             style: TextStyle(color: Colors.white, fontSize: 25),
//                           ),
//                         ),
//                         SizedBox(height: 5),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Divider(color: Colors.red, thickness: 1),
//                             ),
//                             Text(
//                               'OR',
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 60),

//                             Expanded(
//                               child: Divider(color: Colors.red, thickness: 1),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 10),
//                         ElevatedButton.icon(
//                           style: ElevatedButton.styleFrom(
//                             minimumSize: Size(500, 50),
//                           ),
//                           onPressed: () {},
//                           icon: const FaIcon(
//                             FontAwesomeIcons.google,
//                             color: Colors.green,
//                           ),
//                           label: Text(
//                             'Continue with Google',
//                             style: TextStyle(fontSize: 20),
//                           ),
//                         ),

//                         SizedBox(height: 15),
//                         ElevatedButton.icon(
//                           style: ElevatedButton.styleFrom(
//                             minimumSize: Size(500, 50),
//                           ),
//                           onPressed: () {},
//                           icon: const FaIcon(
//                             FontAwesomeIcons.facebook,
//                             color: Colors.blue,
//                           ),
//                           label: Text(
//                             'Continue with Facebook',
//                             style: TextStyle(fontSize: 20),
//                           ),
//                         ),
//                         SizedBox(height: 15),
//                         // ElevatedButton.icon(
//                         //   style: ElevatedButton.styleFrom(
//                         //     minimumSize: Size(500, 50),
//                         //   ),
//                         //   onPressed: () {},
//                         //   icon: const FaIcon(
//                         //     FontAwesomeIcons.apple,
//                         //     color: Colors.black,
//                         //   ),
//                         //   label: Text(
//                         //     'Continue with Apple ID',
//                         //     style: TextStyle(fontSize: 20),
//                         //   ),
//                         // ),
//                       ],
//                     ),

//                     // SizedBox(height: 20),
//                     // TextField(
//                     //   style: TextStyle(color: Colors.white),
//                     //   decoration: InputDecoration(
//                     //     fillColor: const Color.fromARGB(255, 255, 255, 255),
//                     //     border: OutlineInputBorder(),
//                     //     label: Text('Password'),
//                     //     prefixIcon: Icon(Icons.lock),
//                     //   ),
//                     //   obscureText: true,
//                     // ),
//                     // SizedBox(height: 20),
//                     // ElevatedButton(
//                     //   style: ElevatedButton.styleFrom(
//                     //     backgroundColor: Colors.black,
//                     //     minimumSize: Size(100, 50),
//                     //   ),
//                     //   onPressed: () {},
//                     //   child: Text('Login', style: TextStyle(color: Colors.white)),
//                     // ),
//                     // SizedBox(height: 10),
//                     // Divider(color: Colors.red, thickness: 0.5),

//                     // // Icon(Icons.goo)
//                     // // ElevatedButton.icon(
//                     // //   onPressed: () {},
//                     // //   icon: const FaIcon(
//                     // //     FontAwesomeIcons.facebook,
//                     // //     color: Colors.blueGrey,
//                     // //   ),
//                     // //   label: const Text("Continue with facebook"),
//                     // // ),
//                     // SizedBox(height: 5),
//                     // ElevatedButton.icon(
//                     //   onPressed: () {},
//                     //   icon: const FaIcon(FontAwesomeIcons.google),
//                     //   label: Text('Continue with Google'),
//                     // ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project/auth/firebase/fibase_serviece.dart';
import 'package:project/auth/loginscreen.dart';
import 'package:project/homescreen/home.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _obscureText = true;
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.user; // Default role

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Focus nodes for better keyboard management
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;

      if (result['success']) {
        _showSnackBar(
          result['message'] ?? 'Account created successfully!',
          Colors.green,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Loginscreen()),
        );
      } else {
        _showSnackBar(
          result['message'] ?? 'Sign up failed. Please try again.',
          Colors.red,
        );
      }
    } catch (e) {
      if (mounted) {
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

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.user:
        return 'User';
      case UserRole.restaurant:
        return 'Restaurant Owner';
      case UserRole.admin:
        return 'Admin';
      default:
        return 'User';
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.user:
        return Icons.person;
      case UserRole.restaurant:
        return Icons.restaurant;
      case UserRole.admin:
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Role Selection
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_pin,
                          color: Colors.deepPurple,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Select Account Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildRoleCard(UserRole.user)),
                        SizedBox(width: 8),
                        Expanded(child: _buildRoleCard(UserRole.restaurant)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Full Name Field
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(color: Colors.black87, fontSize: 16),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Enter your full name',
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.black54),
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: Colors.deepPurple,
                  ),
                ),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_phoneFocusNode);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                    return 'Name can only contain letters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                maxLength: 10,
                style: TextStyle(color: Colors.black87, fontSize: 16),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Enter 10-digit mobile number',
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.black54),
                  prefixIcon: Icon(Icons.phone, color: Colors.deepPurple),
                  counterText: '',
                ),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_emailFocusNode);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                    return 'Enter valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: TextStyle(color: Colors.black87, fontSize: 16),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Enter your email address',
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black54),
                  prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                ),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: _obscureText,
                textInputAction: TextInputAction.done,
                style: TextStyle(color: Colors.black87, fontSize: 16),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Create a strong password',
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black54),
                  prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                  ),
                ),
                onFieldSubmitted: (_) => _handleSignUp(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                    return 'Must include at least one uppercase letter';
                  }
                  if (!RegExp(r'[a-z]').hasMatch(value)) {
                    return 'Must include at least one lowercase letter';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Must include at least one number';
                  }
                  if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
                    return 'Must include a special character (!@#\$&*~)';
                  }
                  return null;
                },
              ),

              // Password Requirements Hint
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password must have: 8+ chars, uppercase, lowercase, number, special char',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Sign Up Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : _handleSignUp,
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
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey, thickness: 1)),
                ],
              ),

              SizedBox(height: 24),

              // Google Sign-In Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onPressed: () {
                  _showSnackBar('Google Sign-In coming soon!', Colors.blue);
                },
                icon: const FaIcon(
                  FontAwesomeIcons.google,
                  color: Color(0xFFDB4437),
                  size: 20,
                ),
                label: Text(
                  'Continue with Google',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),

              SizedBox(height: 12),

              // Facebook Sign-In Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onPressed: () {
                  _showSnackBar('Facebook Sign-In coming soon!', Colors.blue);
                },
                icon: const FaIcon(
                  FontAwesomeIcons.facebook,
                  color: Color(0xFF1877F2),
                  size: 20,
                ),
                label: Text(
                  'Continue with Facebook',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(UserRole role) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _getRoleIcon(role),
              color: isSelected ? Colors.white : Colors.deepPurple,
              size: 28,
            ),
            SizedBox(height: 6),
            Text(
              _getRoleDisplayName(role),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
