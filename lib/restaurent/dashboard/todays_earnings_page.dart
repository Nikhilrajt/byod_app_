import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class TodaysEarningsPage extends StatefulWidget {
  const TodaysEarningsPage({super.key});

  @override
  State<TodaysEarningsPage> createState() => _TodaysEarningsPageState();
}

class _TodaysEarningsPageState extends State<TodaysEarningsPage> {
  DateTimeRange? selectedRange;
  String selectedType = "all";

  static const LinearGradient kGradient = LinearGradient(
    colors: [Color(0xFF2D1B4E), Color(0xFF4A2C6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: user == null
                ? const Center(child: Text("Not logged in"))
                : _body(user.uid),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
      decoration: const BoxDecoration(
        gradient: kGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                "Total Earnings",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.date_range, color: Colors.white),
                onPressed: _pickDateRange,
              ),
            ],
          ),
          Text(
            "Revenue overview & insights",
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 12),
          _orderTypeChips(),
        ],
      ),
    );
  }

  // ================= BODY =================
  Widget _body(String restaurantId) {
    Query query = FirebaseFirestore.instance
        .collection('orders')
        .where('restaurantId', isEqualTo: restaurantId)
        .where('orderStatus', isEqualTo: 'completed');

    if (selectedType != "all") {
      query = query.where('orderType', isEqualTo: selectedType);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final now = DateTime.now();

        double today = 0, week = 0, month = 0, total = 0;
        int orderCount = 0;
        final Map<String, double> daily = {};
        final Map<String, double> payment = {'upi': 0, 'cash': 0, 'card': 0};

        for (var d in docs) {
          final data = d.data() as Map<String, dynamic>;
          final date = (data['createdAt'] as Timestamp).toDate();
          final amount = (data['totalAmount'] as num).toDouble();

          if (selectedRange != null &&
              (date.isBefore(selectedRange!.start) ||
                  date.isAfter(selectedRange!.end)))
            continue;

          orderCount++;
          total += amount;

          final key = DateFormat('yyyy-MM-dd').format(date);
          daily[key] = (daily[key] ?? 0) + amount;

          if (DateUtils.isSameDay(date, now)) today += amount;
          if (date.isAfter(now.subtract(const Duration(days: 7)))) {
            week += amount;
          }
          if (date.month == now.month && date.year == now.year) {
            month += amount;
          }

          String pm = (data['paymentMethod'] ?? 'upi').toString().toLowerCase();
          if (pm.contains('cash') || pm.contains('cod')) {
            pm = 'cash';
          } else if (pm.contains('card') ||
              pm.contains('credit') ||
              pm.contains('debit')) {
            pm = 'card';
          } else {
            pm = 'upi';
          }
          payment[pm] = (payment[pm] ?? 0) + amount;
        }

        final avg = orderCount == 0 ? 0 : total / orderCount;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _summary(today, week, month),
              const SizedBox(height: 24),
              _avgCard(total.toDouble(), avg.toDouble(), orderCount),
              const SizedBox(height: 24),
              _graph(daily),
              const SizedBox(height: 24),
              _paymentBreakdown(payment),
              const SizedBox(height: 24),
              _bestWorst(daily),
              const SizedBox(height: 24),
              _dailyList(daily),
            ],
          ),
        );
      },
    );
  }

  // ================= WIDGETS =================

  Widget _orderTypeChips() {
    return Wrap(
      spacing: 8,
      children: ["all", "normal", "byod"].map((e) {
        return ChoiceChip(
          label: Text(e.toUpperCase()),
          selected: selectedType == e,
          onSelected: (_) => setState(() => selectedType = e),
          selectedColor: Colors.white,
          labelStyle: TextStyle(
            color: selectedType == e ? const Color(0xFF4A2C6B) : Colors.white,
          ),
          backgroundColor: Colors.white24,
        );
      }).toList(),
    );
  }

  Widget _summary(double t, double w, double m) {
    Widget card(String l, double v) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: _card(),
          child: Column(
            children: [
              Text(l, style: GoogleFonts.poppins(fontSize: 12)),
              const SizedBox(height: 6),
              Text(
                "₹${v.toStringAsFixed(0)}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A2C6B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        card("Today", t),
        const SizedBox(width: 10),
        card("Week", w),
        const SizedBox(width: 10),
        card("Month", m),
      ],
    );
  }

  Widget _avgCard(double total, double avg, int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Revenue",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                "₹${total.toStringAsFixed(0)}",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A2C6B),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Avg Order Value",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "₹${avg.toStringAsFixed(0)}",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6C63FF),
                ),
              ),
              Text("$count orders", style: GoogleFonts.poppins(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _graph(Map<String, double> data) {
    final days = List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      return DateFormat('yyyy-MM-dd').format(d);
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Last 7 Days Earnings",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(days.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[days[i]] ?? 0,
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                        color: const Color(0xFF6C63FF),
                      ),
                    ],
                  );
                }),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final d = DateTime.parse(days[v.toInt()]);
                        return Text(
                          DateFormat('dd').format(d),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentBreakdown(Map<String, double> p) {
    final total = p.values.fold(0.0, (sum, v) => sum + v);
    final upi = p['upi'] ?? 0;
    final cash = p['cash'] ?? 0;
    final card = p['card'] ?? 0;

    Widget row(String l, double v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: l == "UPI"
                      ? const Color(0xFF6C63FF)
                      : l == "Cash"
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(width: 8),
              Text(l.toUpperCase()),
            ],
          ),
          Text(
            "₹${v.toStringAsFixed(0)}",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Payment Methods",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          if (total > 0)
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                  sections: [
                    if (upi > 0)
                      PieChartSectionData(
                        value: upi,
                        color: const Color(0xFF6C63FF),
                        radius: 40,
                        showTitle: false,
                      ),
                    if (cash > 0)
                      PieChartSectionData(
                        value: cash,
                        color: const Color(0xFF4CAF50),
                        radius: 40,
                        showTitle: false,
                      ),
                    if (card > 0)
                      PieChartSectionData(
                        value: card,
                        color: const Color(0xFFFF6B6B),
                        radius: 40,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          row("UPI", upi),
          row("Cash", cash),
          row("Card", card),
        ],
      ),
    );
  }

  Widget _bestWorst(Map<String, double> d) {
    if (d.isEmpty) return const SizedBox();

    final best = d.entries.reduce((a, b) => a.value > b.value ? a : b);
    final worst = d.entries.reduce((a, b) => a.value < b.value ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        children: [_badge("Best Day", best), _badge("Lowest Day", worst)],
      ),
    );
  }

  Widget _badge(String l, MapEntry<String, double> e) {
    return ListTile(
      leading: Icon(
        l == "Best Day" ? Icons.trending_up : Icons.trending_down,
        color: l == "Best Day" ? Colors.green : Colors.red,
      ),
      title: Text(l),
      trailing: Text(
        "₹${e.value.toStringAsFixed(0)}",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(DateFormat('dd MMM yyyy').format(DateTime.parse(e.key))),
    );
  }

  Widget _dailyList(Map<String, double> d) {
    final keys = d.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Daily Breakdown",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...keys.map(
          (k) => ListTile(
            leading: const Icon(Icons.calendar_today, size: 18),
            title: Text(DateFormat('dd MMM yyyy').format(DateTime.parse(k))),
            trailing: Text(
              "₹${d[k]!.toStringAsFixed(0)}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _card() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
    ],
  );

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedRange = picked);
    }
  }
}
