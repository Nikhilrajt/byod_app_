import 'package:flutter/material.dart';
import 'package:project/auth/intro.dart';
// import 'package:project/auth/loginscreen.dart';

class ConfirmPasswordScreen extends StatefulWidget {
  const ConfirmPasswordScreen({super.key});

  @override
  State<ConfirmPasswordScreen> createState() => _ConfirmPasswordScreenState();
}

class _ConfirmPasswordScreenState extends State<ConfirmPasswordScreen> {
  TextEditingController passCtrl = TextEditingController(),
      confirmpassCtrl = TextEditingController();
  bool _obscureText1 = true, _obscureText2 = true;

  final _ConfirmPassword = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot Password?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        child: Form(
          key: _ConfirmPassword,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 40),
                TextFormField(
                  controller: passCtrl,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    label: Text(
                      'Password',
                      style: TextStyle(color: Colors.black),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText1 ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText1 = !_obscureText1;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'enter your password';
                    }
                    final passwordRegex = RegExp(
                      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                    );
                    if (!passwordRegex.hasMatch(value)) {
                      return 'Password must be at least 8 characters,\ninclude upper & lower case, number, and special character';
                    }
                  },
                  obscureText: _obscureText1,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: confirmpassCtrl,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    label: Text(
                      'confirm password',
                      style: TextStyle(color: Colors.black),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText2 ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText2 = !_obscureText2;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'enter your password';
                    }
                    if (value != passCtrl.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  obscureText: _obscureText2,
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(500, 50),
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      if (_ConfirmPassword.currentState!.validate()) {
                        // ...existing code...

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Password changed successfully'),
                          ),
                        );
                        Future.delayed(Duration(seconds: 2), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Intro()),
                          );
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Passwords do not match')),
                        );
                      }
                    },

                    // ...existing code...
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
