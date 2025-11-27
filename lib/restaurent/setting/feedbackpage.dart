import 'package:flutter/material.dart';

class Feedbackpage extends StatefulWidget {
  const Feedbackpage({super.key});

  @override
  State<Feedbackpage> createState() => _FeedbackpageState();
}

enum FeedbackStatus { New, Reviewed, Resolved }

class CustomerFeedback {
  final String id;
  final String customerName;
  final String message;
  final double rating; // 0.0 - 5.0
  final DateTime createdAt;
  FeedbackStatus status;

  CustomerFeedback({
    required this.id,
    required this.customerName,
    required this.message,
    required this.rating,
    required this.createdAt,
    this.status = FeedbackStatus.New,
  });
}

class _FeedbackpageState extends State<Feedbackpage> {
  List<CustomerFeedback> feedbacks = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadMockFeedback();
  }

  void _loadMockFeedback() {
    feedbacks = [
      CustomerFeedback(
        id: 'FB-001',
        customerName: 'Alice Johnson',
        message: 'Loved the pizza! Could use a bit more cheese next time 🙂',
        rating: 4.5,
        createdAt: DateTime.now().subtract(
          const Duration(hours: 3, minutes: 10),
        ),
      ),
      CustomerFeedback(
        id: 'FB-002',
        customerName: 'Mohammed Ali',
        message: 'Fries were cold on arrival.',
        rating: 2.0,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
        status: FeedbackStatus.Reviewed,
      ),
      CustomerFeedback(
        id: 'FB-003',
        customerName: 'Sofia R',
        message: 'Great portion sizes and fast delivery.',
        rating: 5.0,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: FeedbackStatus.Resolved,
      ),
    ];
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1));
    // Replace with real fetch in production
    setState(() => loading = false);
  }

  void _updateStatus(CustomerFeedback fb, FeedbackStatus next) {
    setState(() => fb.status = next);
    // TODO: call backend to persist status
  }

  void _deleteFeedback(CustomerFeedback fb) {
    setState(() => feedbacks.removeWhere((f) => f.id == fb.id));
    // TODO: call backend to delete
  }

  String _statusLabel(FeedbackStatus s) {
    switch (s) {
      case FeedbackStatus.New:
        return 'New';
      case FeedbackStatus.Reviewed:
        return 'Reviewed';
      case FeedbackStatus.Resolved:
        return 'Resolved';
    }
  }

  Color _statusColor(FeedbackStatus s) {
    switch (s) {
      case FeedbackStatus.New:
        return Colors.orange;
      case FeedbackStatus.Reviewed:
        return Colors.blue;
      case FeedbackStatus.Resolved:
        return Colors.green;
    }
  }

  Widget _buildRatingStars(double rating) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full)
          return const Icon(Icons.star, size: 16, color: Colors.amber);
        if (i == full && half)
          return const Icon(Icons.star_half, size: 16, color: Colors.amber);
        return const Icon(Icons.star_border, size: 16, color: Colors.amber);
      }),
    );
  }

  void _showFeedbackDetails(CustomerFeedback fb) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${fb.customerName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          backgroundColor: _statusColor(
                            fb.status,
                          ).withOpacity(0.12),
                          label: Text(
                            _statusLabel(fb.status),
                            style: TextStyle(color: _statusColor(fb.status)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildRatingStars(fb.rating),
                        const SizedBox(width: 8),
                        Text(fb.rating.toString()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(fb.message),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Actions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: fb.status == FeedbackStatus.Resolved
                              ? null
                              : () =>
                                    _updateStatus(fb, FeedbackStatus.Resolved),
                          child: const Text('Mark Resolved'),
                        ),
                        OutlinedButton(
                          onPressed: fb.status == FeedbackStatus.New
                              ? () => _updateStatus(fb, FeedbackStatus.Reviewed)
                              : null,
                          child: const Text('Mark Reviewed'),
                        ),
                        TextButton(
                          onPressed: () => _deleteFeedback(fb),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Feedback'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : feedbacks.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No feedback yet')),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: feedbacks.length,
                separatorBuilder: (context, i) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final fb = feedbacks[i];
                  return Card(
                    child: ListTile(
                      onTap: () => _showFeedbackDetails(fb),
                      leading: CircleAvatar(
                        child: Text(
                          fb.customerName.isNotEmpty ? fb.customerName[0] : '?',
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              fb.customerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            backgroundColor: _statusColor(
                              fb.status,
                            ).withOpacity(0.12),
                            label: Text(
                              _statusLabel(fb.status),
                              style: TextStyle(color: _statusColor(fb.status)),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            fb.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildRatingStars(fb.rating),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  fb.createdAt.toLocal().toString(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'resolve')
                            _updateStatus(fb, FeedbackStatus.Resolved);
                          if (v == 'review')
                            _updateStatus(fb, FeedbackStatus.Reviewed);
                          if (v == 'delete') _deleteFeedback(fb);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'resolve',
                            child: Text('Mark Resolved'),
                          ),
                          const PopupMenuItem(
                            value: 'review',
                            child: Text('Mark Reviewed'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
