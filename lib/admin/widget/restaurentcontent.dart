import 'package:flutter/material.dart';

class Restaurant {
  String name;
  String description;
  bool active;

  Restaurant({required this.name, this.description = '', this.active = true});
}

class RestaurentContent extends StatefulWidget {
  const RestaurentContent({Key? key}) : super(key: key);

  @override
  State<RestaurentContent> createState() => _RestaurentContentState();
}

class _RestaurentContentState extends State<RestaurentContent> {
  final List<Restaurant> _restaurants = List.generate(
    6,
    (i) => Restaurant(
      name: 'Restaurant ${i + 1}',
      description: 'Description for restaurant ${i + 1}',
    ),
  );

  String _search = '';

  List<Restaurant> get _filtered => _search.isEmpty
      ? _restaurants
      : _restaurants
            .where((r) => r.name.toLowerCase().contains(_search.toLowerCase()))
            .toList();

  void _addOrEditRestaurant({Restaurant? item, int? index}) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Add Restaurant' : 'Edit Restaurant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Active'),
                const Spacer(),
                Switch(
                  value: item?.active ?? true,
                  onChanged: (v) {
                    // local visual only; actual value set on save
                    setState(() {});
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              if (name.isEmpty) return;
              if (item != null && index != null) {
                setState(() {
                  _restaurants[index] = Restaurant(
                    name: name,
                    description: desc,
                    active: item.active,
                  );
                });
              } else {
                setState(() {
                  _restaurants.add(Restaurant(name: name, description: desc));
                });
              }
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved')));
    }
  }

  void _showDetails(Restaurant item, int index) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(item.description),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _addOrEditRestaurant(item: item, index: index);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      final removed = _restaurants.removeAt(index);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${removed.name} deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              setState(() {
                                _restaurants.insert(index, removed);
                              });
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final q = await showSearch<String?>(
                context: context,
                delegate: _RestaurantSearchDelegate(_restaurants),
              );
              if (q != null) setState(() => _search = q);
            },
            tooltip: 'Search',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditRestaurant(),
        child: const Icon(Icons.add),
        tooltip: 'Add restaurant',
      ),
      body: ListView.builder(
        itemCount: _filtered.length,
        itemBuilder: (BuildContext context, int idx) {
          final restaurant = _filtered[idx];
          final index = _restaurants.indexOf(restaurant);

          return Dismissible(
            key: ValueKey(restaurant.name + index.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.redAccent,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) {
              final removed = _restaurants.removeAt(index);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${removed.name} deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      setState(() {
                        _restaurants.insert(index, removed);
                      });
                    },
                  ),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey.shade100,
                  child: Text(
                    _getInitials(restaurant.name),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                minLeadingWidth: 56,
                title: Text(
                  restaurant.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  restaurant.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () => _showDetails(restaurant, index),
                ),
                onTap: () => _showDetails(restaurant, index),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class _RestaurantSearchDelegate extends SearchDelegate<String?> {
  final List<Restaurant> all;
  _RestaurantSearchDelegate(this.all);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final q = query.trim().toLowerCase();
    final matches = q.isEmpty
        ? all
        : all.where((r) => r.name.toLowerCase().contains(q)).toList();
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (ctx, i) => ListTile(
        title: Text(matches[i].name),
        subtitle: Text(
          matches[i].description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => close(context, matches[i].name),
      ),
    );
  }
}
