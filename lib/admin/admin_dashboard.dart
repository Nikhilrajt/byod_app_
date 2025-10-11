import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isNavigationRailExtended = false;

  final List<Widget> _views = [
    DashboardView(),
    OrderManagementView(),
    RestaurantManagementView(),
    DriverManagementView(),
    UserManagementView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: _isNavigationRailExtended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            extended: _isNavigationRailExtended,
            backgroundColor: Colors.white,
            selectedLabelTextStyle: TextStyle(color: Colors.deepOrange),
            unselectedLabelTextStyle: TextStyle(color: Colors.grey[700]),
            leading: IconButton(
              icon: Icon(_isNavigationRailExtended ? Icons.menu_open : Icons.menu),
              onPressed: () {
                setState(() {
                  _isNavigationRailExtended = !_isNavigationRailExtended;
                });
              },
            ),
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard, color: Colors.deepOrange),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long, color: Colors.deepOrange),
                label: Text('Orders'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restaurant_outlined),
                selectedIcon: Icon(Icons.restaurant, color: Colors.deepOrange),
                label: Text('Restaurants'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.drive_eta_outlined),
                selectedIcon: Icon(Icons.drive_eta, color: Colors.deepOrange),
                label: Text('Drivers'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_alt_outlined),
                selectedIcon: Icon(Icons.people_alt, color: Colors.deepOrange),
                label: Text('Users'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _views[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildSummaryCard('Total Orders', '1,234', Icons.receipt_long, Colors.blue),
              _buildSummaryCard('Total Revenue', '₹56,789', Icons.monetization_on, Colors.green),
              _buildSummaryCard('Active Drivers', '23', Icons.drive_eta, Colors.orange),
              _buildSummaryCard('Restaurants', '45', Icons.restaurant, Colors.red),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Recent Orders',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('Customer')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Status')),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Text('#12349')),
                    DataCell(Text('Eve')),
                    DataCell(Text('₹10.50')),
                    DataCell(_buildStatusChip('Cancelled')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('#12348')),
                    DataCell(Text('David')),
                    DataCell(Text('₹30.00')),
                    DataCell(_buildStatusChip('Pending')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('#12347')),
                    DataCell(Text('Charlie')),
                    DataCell(Text('₹12.00')),
                    DataCell(_buildStatusChip('Out for Delivery')),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(20),
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                Icon(icon, color: color),
              ],
            ),
            SizedBox(height: 10),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Delivered':
        color = Colors.green;
        break;
      case 'Processing':
        color = Colors.orange;
        break;
      case 'Out for Delivery':
        color = Colors.blue;
        break;
      case 'Cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status, style: TextStyle(color: Colors.white)),
      backgroundColor: color,
    );
  }
}

class OrderManagementView extends StatefulWidget {
  @override
  _OrderManagementViewState createState() => _OrderManagementViewState();
}

class _OrderManagementViewState extends State<OrderManagementView> {
  String? _selectedStatus = 'All';
  String? _selectedDriver = 'All';
  String? _selectedRestaurant = 'All';

  final List<String> _statuses = ['All', 'Pending', 'Processing', 'Out for Delivery', 'Delivered', 'Cancelled'];
  final List<String> _drivers = ['All', 'John Doe', 'Jane Smith', 'Peter Jones'];
  final List<String> _restaurants = ['All', 'Pizza Hut', 'Burger King', 'Subway'];

  final List<Map<String, dynamic>> _orders = [
    {
      'id': '#12345',
      'customer': 'Alice',
      'restaurant': 'Pizza Hut',
      'driver': 'John Doe',
      'status': 'Delivered',
      'amount': 25.50,
    },
    {
      'id': '#12346',
      'customer': 'Bob',
      'restaurant': 'Burger King',
      'driver': 'Jane Smith',
      'status': 'Processing',
      'amount': 15.75,
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredOrders = _orders.where((order) {
      final statusMatch = _selectedStatus == 'All' || order['status'] == _selectedStatus;
      final driverMatch = _selectedDriver == 'All' || order['driver'] == _selectedDriver;
      final restaurantMatch = _selectedRestaurant == 'All' || order['restaurant'] == _selectedRestaurant;
      return statusMatch && driverMatch && restaurantMatch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildFilterDropdown('Status', _selectedStatus, _statuses, (val) => setState(() => _selectedStatus = val)),
              _buildFilterDropdown('Driver', _selectedDriver, _drivers, (val) => setState(() => _selectedDriver = val)),
              _buildFilterDropdown('Restaurant', _selectedRestaurant, _restaurants, (val) => setState(() => _selectedRestaurant = val)),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DataTable(
                  sortAscending: true,
                  sortColumnIndex: 0,
                  columns: [
                    DataColumn(label: Text('Order ID')),
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Restaurant')),
                    DataColumn(label: Text('Driver')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: filteredOrders.map((order) {
                    return DataRow(
                      cells: [
                        DataCell(Text(order['id'])),
                        DataCell(Text(order['customer'])),
                        DataCell(Text(order['restaurant'])),
                        DataCell(Text(order['driver'])),
                        DataCell(Text('₹${order['amount'].toStringAsFixed(2)}')),
                        DataCell(DashboardView._buildStatusChip(order['status'])),
                        DataCell(
                          Row(
                            children: [
                              IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                              IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () {}),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      hint: Text(hint),
      value: value,
      items: items.map((String val) {
        return DropdownMenuItem<String>(
          value: val,
          child: Text(val),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class RestaurantManagementView extends StatefulWidget {
  @override
  _RestaurantManagementViewState createState() => _RestaurantManagementViewState();
}

class _RestaurantManagementViewState extends State<RestaurantManagementView> {
  final List<Map<String, dynamic>> _restaurants = [
    {
      'name': 'Nigs Hut',
      'imagePath': 'assets/images/res1.jpg',
      'rating': 4.3,
      'time': '65-90 mins',
      'category': 'Restaurant',
      'location': 'Mannarkkad',
      'offer': 'ITEMS AT ₹99',
    },
    {
      'name': 'FoodFlex',
      'imagePath': 'assets/images/res2.jpeg',
      'rating': 4.5,
      'time': '40-55 mins',
      'category': 'Healthy',
      'location': 'Palakkad',
      'offer': 'UPTO 50% OFF',
    },
  ];

  void _addRestaurant(Map<String, dynamic> restaurant) {
    setState(() {
      _restaurants.add(restaurant);
    });
  }

  void _showAddRestaurantDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _imageController = TextEditingController();
    final _ratingController = TextEditingController();
    final _timeController = TextEditingController();
    final _categoryController = TextEditingController();
    final _locationController = TextEditingController();
    final _offerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Restaurant'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                  ),
                  TextFormField(
                    controller: _imageController,
                    decoration: InputDecoration(labelText: 'Image Path'),
                     validator: (value) => value!.isEmpty ? 'Please enter an image path' : null,
                  ),
                  TextFormField(
                    controller: _ratingController,
                    decoration: InputDecoration(labelText: 'Rating'),
                    keyboardType: TextInputType.number,
                     validator: (value) => value!.isEmpty ? 'Please enter a rating' : null,
                  ),
                  TextFormField(
                    controller: _timeController,
                    decoration: InputDecoration(labelText: 'Time'),
                     validator: (value) => value!.isEmpty ? 'Please enter a time' : null,
                  ),
                  TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(labelText: 'Category'),
                     validator: (value) => value!.isEmpty ? 'Please enter a category' : null,
                  ),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(labelText: 'Location'),
                     validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
                  ),
                  TextFormField(
                    controller: _offerController,
                    decoration: InputDecoration(labelText: 'Offer'),
                     validator: (value) => value!.isEmpty ? 'Please enter an offer' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addRestaurant({
                    'name': _nameController.text,
                    'imagePath': _imageController.text,
                    'rating': double.parse(_ratingController.text),
                    'time': _timeController.text,
                    'category': _categoryController.text,
                    'location': _locationController.text,
                    'offer': _offerController.text,
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Restaurant Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddRestaurantDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = _restaurants[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Image.asset(restaurant['imagePath'], width: 100, fit: BoxFit.cover),
              title: Text(restaurant['name']),
              subtitle: Text(restaurant['location']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () {}),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DriverManagementView extends StatefulWidget {
  @override
  _DriverManagementViewState createState() => _DriverManagementViewState();
}

class _DriverManagementViewState extends State<DriverManagementView> {
  final List<Map<String, dynamic>> _drivers = [
    {
      'name': 'John Doe',
      'phone': '123-456-7890',
      'vehicle': 'Car - ABC 123',
      'status': 'Online',
    },
    {
      'name': 'Jane Smith',
      'phone': '098-765-4321',
      'vehicle': 'Bike - XYZ 789',
      'status': 'Offline',
    },
  ];

  void _addDriver(Map<String, dynamic> driver) {
    setState(() {
      _drivers.add(driver);
    });
  }

  void _showAddDriverDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _phoneController = TextEditingController();
    final _vehicleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Driver'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
                  ),
                  TextFormField(
                    controller: _vehicleController,
                    decoration: InputDecoration(labelText: 'Vehicle'),
                    validator: (value) => value!.isEmpty ? 'Please enter vehicle details' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addDriver({
                    'name': _nameController.text,
                    'phone': _phoneController.text,
                    'vehicle': _vehicleController.text,
                    'status': 'Offline',
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Driver Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddDriverDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _drivers.length,
        itemBuilder: (context, index) {
          final driver = _drivers[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(Icons.person, size: 40),
              title: Text(driver['name']),
              subtitle: Text(driver['phone']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(label: Text(driver['status']), backgroundColor: driver['status'] == 'Online' ? Colors.green : Colors.grey),
                  IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () {}),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class UserManagementView extends StatefulWidget {
  @override
  _UserManagementViewState createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Alice',
      'email': 'alice@example.com',
      'role': 'Customer',
    },
    {
      'name': 'Bob',
      'email': 'bob@example.com',
      'role': 'Customer',
    },
  ];

  void _addUser(Map<String, dynamic> user) {
    setState(() {
      _users.add(user);
    });
  }

  void _showAddUserDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    String _role = 'Customer';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add User'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _role,
                    decoration: InputDecoration(labelText: 'Role'),
                    items: ['Customer', 'Admin'].map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _role = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addUser({
                    'name': _nameController.text,
                    'email': _emailController.text,
                    'role': _role,
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('User Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddUserDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(Icons.person, size: 40),
              title: Text(user['name']),
              subtitle: Text(user['email']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(label: Text(user['role'])),
                  IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                  IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () {}),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}