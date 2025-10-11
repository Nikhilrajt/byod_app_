import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project/auth/sign_up.dart';
import 'package:project/auth/forgot%20password/forgot_password.dart';
import 'package:project/homescreen/home.dart';
import 'package:project/restaurent/home.dart';
// import 'package:project/restaurent/auth/restaurant_home_screen.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  // double width = 300;
  // double height = 50.0;
  bool login = true;
  double loginAlign = -1;
  double signInAlign = 1;
  Color selectedColor = Colors.white;
  Color normalColor = Colors.black54;
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  late Color loginColor;
  late Color signInColor;
  @override
  void initState() {
    super.initState();

    loginColor = selectedColor;
    signInColor = normalColor;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          SizedBox(height: 100),
          Center(
            child: Container(
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.all(Radius.circular(50.0)),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    alignment: Alignment(login ? -1 : 1, 0),
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      width: 200 * 0.5,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        login = true;
                        loginColor = selectedColor;

                        signInColor = normalColor;
                      });
                    },
                    child: Align(
                      alignment: Alignment(-1, 0),
                      child: Container(
                        width: 200 * 0.6,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        login = false;
                        signInColor = selectedColor;

                        loginColor = normalColor;
                      });
                    },
                    child: Align(
                      alignment: Alignment(1, 0),
                      child: Container(
                        width: 200 * 0.6,
                        color: Colors.transparent,
                        alignment: Alignment.center,
                        child: Text(
                          'SignUp',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 50),

          // Align(
          //   child: Image(
          //     image: AssetImage('assets/images/foodflex.png'),
          //     width: 89,
          //   ),
          //   alignment: Alignment.topCenter,
          // ),

          // Container(
          //   decoration: BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage('assets/images/back.jpg'),
          //       fit: BoxFit.fill,
          //     ),
          //     color: Colors.green[100],
          //     borderRadius: BorderRadius.only(
          //       topLeft: Radius.circular(30),
          //       topRight: Radius.circular(30),
          //     ),
          //   ),
          //   height:
          //       MediaQuery.of(context).size.height *
          //       0.60, // 60% of screen height
          //   width: double.infinity,
          //   padding: EdgeInsets.all(10),
          login
              ? Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 30,
                              color: const Color.fromARGB(255, 248, 247, 247),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        // keyboardType: TextInputType.,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          label: Text(
                            'Email/Phone',
                            style: TextStyle(color: Colors.white),
                          ),
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email or phone number';
                          }

                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                          );
                          final phoneRegex = RegExp(
                            r'^[6-9]\d{9}$',
                          ); // Indian mobile format

                          if (!emailRegex.hasMatch(value) &&
                              !phoneRegex.hasMatch(value)) {
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
                                MaterialPageRoute(
                                  builder: (context) => ForgotPassword(),
                                ),
                              );
                            },
                            child: Text(
                              'forgot password?',
                              style: TextStyle(color: Colors.amberAccent),
                            ),
                          ),
                        ],
                      ),
                      TextFormField(
                        obscureText: _obscureText,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          border: OutlineInputBorder(),
                          label: Text(
                            'Password',
                            style: TextStyle(color: Colors.white),
                          ),
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          } else if (value.length < 8) {
                            return 'Must be atleast 8 characters';
                          } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Must contain atleast one number';
                          } else if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
                            return 'Must contain a special character (!@#\$&*~)';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          minimumSize: Size(500, 50),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.red, thickness: 1),
                          ),
                          Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Expanded(
                            child: Divider(color: Colors.red, thickness: 1),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),

                      // Icon(Icons.goo)
                      // ElevatedButton.icon(
                      //   onPressed: () {},
                      //   icon: const FaIcon(
                      //     FontAwesomeIcons.facebook,
                      //     color: Colors.blueGrey,
                      //   ),
                      //   label: const Text("Continue with facebook"),
                      // ),
                      SizedBox(height: 5),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(500, 50),
                        ),
                        onPressed: () {},
                        icon: const FaIcon(
                          FontAwesomeIcons.google,
                          color: Color.fromARGB(255, 234, 13, 13),
                        ),
                        label: Text(
                          'Continue with Google',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),

                      SizedBox(height: 5),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(500, 50),
                        ),
                        onPressed: () {},
                        icon: const FaIcon(
                          FontAwesomeIcons.facebook,
                          color: Colors.blue,
                        ),
                        label: Text(
                          'Continue with Facebook',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      SizedBox(height: 5),

                      // ElevatedButton.icon(
                      //   style: ElevatedButton.styleFrom(
                      //     minimumSize: Size(500, 50),
                      //   ),
                      //   onPressed: () {},
                      //   icon: const FaIcon(
                      //     FontAwesomeIcons.apple,
                      //     color: Colors.black,
                      //   ),
                      //   label: Text(
                      //     'Continue with Apple ID',
                      //     style: TextStyle(fontSize: 20),
                      //   ),
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Dont have an account?',
                            style: TextStyle(color: Colors.white),
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
                              style: TextStyle(
                                color: const Color.fromARGB(255, 241, 245, 4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => restaurent_home_page(),
                                ),
                              );
                            },
                            child: Text(
                              'Login As restaurent',
                              style: TextStyle(color: Colors.amberAccent),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : SignUp(),
        ],
      ),
    );
  }
}
