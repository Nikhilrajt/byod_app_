import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project/homescreen/home.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isSignUpSelected = true;
  final formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),

        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Column(
                      children: [
                        TextFormField(
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            hintText: 'enter your name',
                            label: Text(
                              ' Full Name',
                              style: TextStyle(color: Colors.white),
                            ),
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 4) {
                              return 'atleast 4 letters';
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            label: Text(
                              'Phone Number',
                              style: TextStyle(color: Colors.white),
                            ),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'enter your phone number';
                            } else if (!RegExp(
                              r'^[6-9]\d{9}$',
                            ).hasMatch(value)) {
                              return 'incorrect phone number';
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                            hintText: 'enter your email id',
                            label: Text(
                              'Email',
                              style: TextStyle(color: Colors.white),
                            ),

                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'enter your email ';
                            } else if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'incorrect email';
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
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
                              return 'enter your password';
                            }
                            final passwordRegex = RegExp(
                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                            );
                            if (!passwordRegex.hasMatch(value)) {
                              return 'Password must be at least 8 characters,\ninclude upper & lower case, number, and special character';
                            }
                          },
                          obscureText: _obscureText,
                        ),

                        SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            minimumSize: Size(500, 50),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'Create Account',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                        SizedBox(height: 5),
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
                            SizedBox(height: 60),

                            Expanded(
                              child: Divider(color: Colors.red, thickness: 1),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(500, 50),
                          ),
                          onPressed: () {},
                          icon: const FaIcon(
                            FontAwesomeIcons.google,
                            color: Colors.green,
                          ),
                          label: Text(
                            'Continue with Google',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),

                        SizedBox(height: 10),
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
                        SizedBox(height: 15),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(500, 50),
                          ),
                          onPressed: () {},
                          icon: const FaIcon(
                            FontAwesomeIcons.apple,
                            color: Colors.black,
                          ),
                          label: Text(
                            'Continue with Apple ID',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),

                    // SizedBox(height: 20),
                    // TextField(
                    //   style: TextStyle(color: Colors.white),
                    //   decoration: InputDecoration(
                    //     fillColor: const Color.fromARGB(255, 255, 255, 255),
                    //     border: OutlineInputBorder(),
                    //     label: Text('Password'),
                    //     prefixIcon: Icon(Icons.lock),
                    //   ),
                    //   obscureText: true,
                    // ),
                    // SizedBox(height: 20),
                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.black,
                    //     minimumSize: Size(100, 50),
                    //   ),
                    //   onPressed: () {},
                    //   child: Text('Login', style: TextStyle(color: Colors.white)),
                    // ),
                    // SizedBox(height: 10),
                    // Divider(color: Colors.red, thickness: 0.5),

                    // // Icon(Icons.goo)
                    // // ElevatedButton.icon(
                    // //   onPressed: () {},
                    // //   icon: const FaIcon(
                    // //     FontAwesomeIcons.facebook,
                    // //     color: Colors.blueGrey,
                    // //   ),
                    // //   label: const Text("Continue with facebook"),
                    // // ),
                    // SizedBox(height: 5),
                    // ElevatedButton.icon(
                    //   onPressed: () {},
                    //   icon: const FaIcon(FontAwesomeIcons.google),
                    //   label: Text('Continue with Google'),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
