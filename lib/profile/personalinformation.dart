import 'package:flutter/material.dart';

class Personalinformation extends StatefulWidget {
  const Personalinformation({super.key});

  @override
  State<Personalinformation> createState() => _PersonalinformationState();
}

class _PersonalinformationState extends State<Personalinformation> {
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  final _nameController = TextEditingController();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Dropdown state
  String? _selectedCountry;
  String? _selectedProvince;

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _refreshForm() {
    setState(() {
      _nameController.clear();
      _dayController.clear();
      _monthController.clear();
      _yearController.clear();
      _emailController.clear();
      _phoneController.clear();
      _selectedCountry = null;
      _selectedProvince = null;
      _formKey.currentState?.reset();
    });
  }

  bool _isValidDate(int day, int month, int year) {
    try {
      final date = DateTime(year, month, day);
      return date.year == year && date.month == month && date.day == day;
    } catch (e) {
      return false;
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // Get form values
      // ignore: unused_local_variable
      final name = _nameController.text.trim();
      final day = int.tryParse(_dayController.text) ?? 0;
      final month = int.tryParse(_monthController.text) ?? 0;
      final year = int.tryParse(_yearController.text) ?? 0;
      // ignore: unused_local_variable
      final email = _emailController.text.trim();
      // ignore: unused_local_variable
      final phone = _phoneController.text.trim();
      // ignore: unused_local_variable
      final country = _selectedCountry ?? '';
      // ignore: unused_local_variable
      final province = _selectedProvince ?? '';

      // Create date of birth
      // ignore: unused_local_variable
      final dateOfBirth = DateTime(year, month, day);

      // TODO: Save the data to your backend, database, or state management
      // Example: await savePersonalInfo(name, dateOfBirth, email, phone, country, province);
      // The variables above (name, email, phone, country, province, dateOfBirth) are ready to use

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Personal information saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // You can also navigate back or perform other actions here
      // Navigator.pop(context);
    }
  }

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
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _refreshForm),
        ],
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
                  controller: _nameController,
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
                        controller: _dayController,
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
                          // Validate complete date if all fields are filled
                          final month = int.tryParse(_monthController.text);
                          final year = int.tryParse(_yearController.text);
                          if (month != null && year != null) {
                            if (!_isValidDate(day, month, year)) {
                              return 'Invalid date';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _monthController,
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
                          // Validate complete date if all fields are filled
                          final day = int.tryParse(_dayController.text);
                          final year = int.tryParse(_yearController.text);
                          if (day != null && year != null) {
                            if (!_isValidDate(day, month, year)) {
                              return 'Invalid date';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
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
                          // Validate complete date if all fields are filled
                          final day = int.tryParse(_dayController.text);
                          final month = int.tryParse(_monthController.text);
                          if (day != null && month != null) {
                            if (!_isValidDate(day, month, year)) {
                              return 'Invalid date';
                            }
                            // Check if date is not in the future
                            final date = DateTime(year, month, day);
                            if (date.isAfter(DateTime.now())) {
                              return 'Future date';
                            }
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
                  controller: _emailController,
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
                  controller: _phoneController,
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
                  value: _selectedCountry,
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
                  onChanged: (value) {
                    setState(() {
                      _selectedCountry = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a country';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // DropdownButtonFormField<String>(
                //   value: _selectedProvince,
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(),
                //     hintText: 'address',
                //   ),
                //   items: ['Province 1', 'Province 2', 'Province 3']
                //       .map(
                //         (province) => DropdownMenuItem(
                //           value: province,
                //           child: Text(province),
                //         ),
                //       )
                //       .toList(),
                //   onChanged: (value) {
                //     setState(() {
                //       _selectedProvince = value;
                //     });
                //   },
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please select a province';
                //     }
                //     return null;
                //   },
                // ),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Address',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2323C3),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _saveForm,
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
