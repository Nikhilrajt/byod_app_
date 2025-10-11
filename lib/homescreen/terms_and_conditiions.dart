import 'package:flutter/material.dart';

class TermsAndConditiions extends StatefulWidget {
  const TermsAndConditiions({super.key});

  @override
  State<TermsAndConditiions> createState() => _TermsAndConditiionsState();
}

class _TermsAndConditiionsState extends State<TermsAndConditiions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms and Conditions',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              _section(
                '1. Acceptance of Terms',
                'By accessing or using this service, you agree to be bound by these terms and conditions. If you do not agree with any part of these terms, you may not use our service.',
              ),
              _section(
                '2. Use of the Service',
                'You are responsible for maintaining the confidentiality of any login information associated with your account. You must notify us immediately of any unauthorized use of your account.',
              ),
              _section(
                '3. Privacy Policy',
                'Your use of this service is also governed by our Privacy Policy, which can be found at Privacy Policy. Please review the Privacy Policy to understand our practices.',
              ),
              _section(
                '4. Termination',
                'We reserve the right to terminate or suspend your account and access to the service at our sole discretion, without prior notice or liability, for any reason whatsoever.',
              ),
              _section(
                '5. Intellectual Property',
                'The content provided through this service, including text, graphics, logos, and software, is protected by copyright and other intellectual property laws.',
              ),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text('Decline'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: BorderSide(color: Colors.deepPurple),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(content, style: TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
