import 'package:flutter/material.dart';
import 'package:project/admin/widget/detailed_info_section.dart';
import 'package:project/admin/widget/order_summary_section.dart';
import 'package:project/admin/widget/review_section.dart';
import 'package:project/admin/widget/sales_performance_section.dart';
import 'package:project/admin/widget/top_selling_items_section.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  int _selectedIndex = 0;
  bool _isStatusActive = true;
  bool _isOperationalHoursActive = true;
  bool _isOperationalInfoActive = true;

  final List<String> _tabs = [
    'Overview',
    'Menu',
    'Orders',
    'Reviews',
    'Payouts',
    'Promotions',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 900;
        final crossAxisCount = isLargeScreen
            ? 3
            : (constraints.maxWidth > 600 ? 2 : 1);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 30),
              _Tabs(
                tabs: _tabs,
                selectedIndex: _selectedIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
              const SizedBox(height: 30),
              GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DetailedInfoSection(
                    title: 'General Information',
                    children: [
                      _InfoRow(
                        label: 'Status',
                        value: _isStatusActive ? 'Active' : 'Inactive',
                        hasToggle: true,
                        isActive: _isStatusActive,
                        onToggle: (value) {
                          setState(() {
                            _isStatusActive = value;
                          });
                        },
                      ),
                      const _InfoRow(label: 'Cuisine', value: 'American, BBQ'),
                      const _InfoRow(
                        label: 'Address',
                        value: '123 QA St, Amytown',
                      ),
                      const _InfoRow(label: 'Phone', value: '(123) 456-7890'),
                      const _InfoRow(label: 'Commission Rate', value: '15%'),
                    ],
                    footer: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            print('Edit Restaurant button pressed');
                            // In a real app, you would navigate to a new screen
                            // to edit the restaurant details.
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Edit Restaurant'),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isStatusActive = !_isStatusActive;
                            });
                            print('Suspend Account button pressed. Status is now: ${_isStatusActive}');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _isStatusActive ? Colors.redAccent : Colors.green,
                            side: BorderSide(color: _isStatusActive ? Colors.redAccent : Colors.green),
                          ),
                          child: Text(_isStatusActive ? 'Suspend Account' : 'Activate Account'),
                        ),
                      ],
                    ),
                  ),
                  DetailedInfoSection(
                    title: 'Operational Hours',
                    children: [
                      _InfoRow(
                        label: 'Status',
                        value: _isOperationalHoursActive
                            ? 'Active'
                            : 'Inactive',
                        hasToggle: true,
                        isActive: _isOperationalHoursActive,
                        onToggle: (value) {
                          setState(() {
                            _isOperationalHoursActive = value;
                          });
                        },
                      ),
                      const _InfoRow(
                        label: 'Fri - Sat',
                        value: '11:00 AM - 09:14 PM',
                      ),
                      const _InfoRow(label: 'Phone', value: '(555) PM - 8 PM'),
                    ],
                    footer: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: const Text('Edit Schedule'),
                    ),
                  ),
                  DetailedInfoSection(
                    title: 'Operational Info',
                    children: [
                      _InfoRow(
                        label: 'Status',
                        value: _isOperationalInfoActive ? 'Active' : 'Inactive',
                        hasToggle: true,
                        isActive: _isOperationalInfoActive,
                        onToggle: (value) {
                          setState(() {
                            _isOperationalInfoActive = value;
                          });
                        },
                      ),
                      const _InfoRow(
                        label: 'Fri - Sat',
                        value: '11:00 AM - 01:10 PM',
                      ),
                      const _InfoRow(label: 'Sun', value: '123 AM - 8 PM'),
                      const _InfoRow(label: 'Phone', value: '(123) - 437'),
                    ],
                    footer: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: const Text('Manage Zones'),
                    ),
                  ),
                  const SalesPerformanceSection(),
                  // const OrderSummarySection(),
                  const ReviewSection(),
                  const TopSellingItemsSection(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool hasToggle;
  final bool isActive;
  final ValueChanged<bool>? onToggle;

  const _InfoRow({
    required this.label,
    required this.value,
    this.hasToggle = false,
    this.isActive = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasToggle)
            Switch(
              value: isActive,
              onChanged: onToggle,
              activeColor: Colors.blueAccent,
            )
          else
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 900;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Restaurant Management',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 5),
              Text(
                'Restaurants > FlavorFusion Grill',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (isLargeScreen)
          SizedBox(
            width: 250,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _Tabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          return _TabButton(
            text: tabs[index],
            isActive: selectedIndex == index,
            onTap: () => onTabSelected(index),
          );
        }),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.text,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.white : Colors.grey,
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 5),
                height: 3,
                width: 30,
                color: Colors.blueAccent,
              ),
          ],
        ),
      ),
    );
  }
}
