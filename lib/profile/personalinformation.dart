import 'package:flutter/material.dart';

class Personalinformation extends StatefulWidget {
  const Personalinformation({super.key});

  @override
  State<Personalinformation> createState() => _PersonalinformationState();
}

class _PersonalinformationState extends State<Personalinformation> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: () {})],
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person_2_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Date of Birth',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'dd',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'DD';
                          }
                          final day = int.tryParse(value);
                          if (day == null || day < 1 || day > 31) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'mm',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'MM';
                          }
                          final month = int.tryParse(value);
                          if (month == null || month < 1 || month > 12) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'yyyy',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'YYYY';
                          }
                          final year = int.tryParse(value);
                          if (year == null ||
                              year < 1900 ||
                              year > DateTime.now().year) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Phone Number',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your number',
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8.0, right: 4.0),
                          child: Icon(Icons.flag),
                        ),
                        Text(
                          '+91',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    final phoneRegex = RegExp(r'^[0-9]{10,}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Invalid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add Your Address',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Country',
                  ),
                  items: ['Country 1', 'Country 2', 'Country 3']
                      .map(
                        (country) => DropdownMenuItem(
                          value: country,
                          child: Text(country),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a country';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Province',
                  ),
                  items: ['Province 1', 'Province 2', 'Province 3']
                      .map(
                        (province) => DropdownMenuItem(
                          value: province,
                          child: Text(province),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {},
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a province';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2323C3),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // All fields are valid, proceed
                      }
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
}
