import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/auth/firebase/fibase_serviece.dart';

class AdminRestaurantPage extends StatefulWidget {
  const AdminRestaurantPage({super.key});

  @override
  State<AdminRestaurantPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminRestaurantPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Manage Users',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, or phone...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.deepPurple,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Active'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Inactive'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('role', isEqualTo: 'restaurant')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading users',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter users based on search and filter
                final filteredUsers = snapshot.data!.docs.where((doc) {
                  final userData = doc.data() as Map<String, dynamic>;
                  final name = (userData['fullName'] ?? '')
                      .toString()
                      .toLowerCase();
                  final email = (userData['email'] ?? '')
                      .toString()
                      .toLowerCase();
                  final phone = (userData['phoneNumber'] ?? '').toString();
                  final isActive = userData['isActive'] ?? true;

                  // Search filter
                  final matchesSearch = 
                      _searchQuery.isEmpty ||
                      name.contains(_searchQuery) ||
                      email.contains(_searchQuery) ||
                      phone.contains(_searchQuery);

                  // Status filter
                  bool matchesFilter = true;
                  if (_selectedFilter == 'Active') {
                    matchesFilter = isActive;
                  } else if (_selectedFilter == 'Inactive') {
                    matchesFilter = !isActive;
                  }

                  return matchesSearch && matchesFilter;
                }).toList();

                // Sort by creation date (newest first)
                filteredUsers.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aTime = aData['createdAt'] as Timestamp?;
                  final bTime = bData['createdAt'] as Timestamp?;

                  if (aTime == null && bTime == null) return 0;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;

                  return bTime.compareTo(aTime);
                });

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users match your search',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(filteredUsers[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: Colors.white.withOpacity(0.2),
      selectedColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.deepPurple : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.deepPurple,
      side: BorderSide(
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildUserCard(QueryDocumentSnapshot doc) {
    final userData = doc.data() as Map<String, dynamic>;
    final name = userData['fullName'] ?? 'Unknown User';
    final email = userData['email'] ?? 'No email';
    final phone = userData['phoneNumber'] ?? 'No phone';
    final role = userData['role'] ?? 'user';
    final isActive = userData['isActive'] ?? true;
    final uid = doc.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: _getRoleColor(role).withOpacity(0.2),
                  child: Text(
                    name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getRoleColor(role),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name and Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.deepPurple,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'USER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? Colors.green : Colors.red,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Contact Information
            _buildInfoRow(Icons.email_outlined, email, Colors.blue),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone_outlined, phone, Colors.green),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                // Toggle Status Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleUserStatus(uid, isActive),
                    icon: Icon(
                      isActive ? Icons.block : Icons.check_circle,
                      size: 18,
                    ),
                    label: Text(isActive ? 'Deactivate' : 'Activate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive
                          ? Colors.orange[600]
                          : Colors.green[600],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // View Details Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showUserDetails(userData, name),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                      side: const BorderSide(color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Delete Button
                IconButton(
                  onPressed: () => _showDeleteConfirmation(uid, name),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red[700],
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'restaurant':
        return Colors.orange;
      case 'user':
      default:
        return Colors.deepPurple;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'restaurant':
        return Icons.restaurant;
      case 'user':
      default:
        return Icons.person;
    }
  }

  Future<void> _toggleUserStatus(String uid, bool currentStatus) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isActive': !currentStatus,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentStatus
                  ? 'User deactivated successfully'
                  : 'User activated successfully',
            ),
            backgroundColor: currentStatus ? Colors.orange : Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showChangeRoleDialog(String uid, String currentRole, String userName) {
    String selectedRole = currentRole;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'User Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'USER ACCOUNT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> userData, String userName) {
    final email = userData['email'] ?? 'No email';
    final phone = userData['phoneNumber'] ?? 'No phone';
    final isActive = userData['isActive'] ?? true;
    final createdAt = userData['createdAt'] as Timestamp?;

    String joinDate = 'N/A';
    if (createdAt != null) {
      final date = createdAt.toDate();
      joinDate = '${date.day}/${date.month}/${date.year}';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.deepPurple.withOpacity(0.2),
              child: Text(
                userName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'User Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name', userName, Icons.person),
              const Divider(height: 24),
              _buildDetailRow('Email', email, Icons.email),
              const Divider(height: 24),
              _buildDetailRow('Phone', phone, Icons.phone),
              const Divider(height: 24),
              _buildDetailRow('Join Date', joinDate, Icons.calendar_today),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 16,
                    color: isActive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _updateUserRole(
    String uid,
    String newRole,
    String userName,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': newRole});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role updated to $newRole for $userName'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating role: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(String uid, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Delete User'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete $userName?\n\nThis action cannot be undone.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteUser(uid, userName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String uid, String userName) async {
    try {
      await _firestore.collection('users').doc(uid).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User $userName deleted successfully'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
