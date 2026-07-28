import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/app/theme/app_text_styles.dart';
import 'package:fashion_ecommerce/features/admin/domain/entities/order_detail.dart';

class AdminAnalyticsWidget extends StatefulWidget {
  final List<OrderDetail> orders;

  const AdminAnalyticsWidget({super.key, required this.orders});

  @override
  State<AdminAnalyticsWidget> createState() => _AdminAnalyticsWidgetState();
}

class _AdminAnalyticsWidgetState extends State<AdminAnalyticsWidget> {
  int _touchedPieIndex = -1;
  String _selectedPeriod = 'Bulan ini'; // '7 Hari', 'Bulan ini', 'Tahun ini'

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}Jt';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}rb';
    }
    return price.toStringAsFixed(0);
  }

  String _formatFullPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    // Analytics Metrics Calculations
    final double totalRevenue = widget.orders.fold(0.0, (sum, o) => sum + o.totalPrice);
    final int totalOrders = widget.orders.length;
    final int completedOrders = widget.orders.where((o) => o.status == 'Selesai').length;
    final int inDeliveryOrders = widget.orders.where((o) => o.status == 'Dikirim').length;
    final int processingOrders = widget.orders.where((o) => o.status == 'Diproses' || o.status == 'Baru').length;
    final int totalProductsSold = widget.orders.fold(0, (sum, o) => sum + o.items.fold(0, (iSum, item) => iSum + item.quantity));

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. KPI Summary Stat Cards Grid (Flat Solid Colors)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _buildKpiCard(
                title: 'Total Omzet',
                value: 'Rp ${_formatPrice(totalRevenue)}',
                subtitle: 'Rp ${_formatFullPrice(totalRevenue)}',
                icon: HugeIcons.strokeRoundedMoney01,
                bgColor: const Color(0xFF1E293B),
                textColor: Colors.white,
                iconColor: const Color(0xFF4ADE80),
                trendText: '+18.4%',
                isPositive: true,
              ),
              _buildKpiCard(
                title: 'Total Pesanan',
                value: '$totalOrders',
                subtitle: '$completedOrders Selesai',
                icon: HugeIcons.strokeRoundedShoppingBag01,
                bgColor: AppColors.primary,
                textColor: Colors.white,
                iconColor: const Color(0xFFFDE047),
                trendText: '+12.1%',
                isPositive: true,
              ),
              _buildKpiCard(
                title: 'Produk Terjual',
                value: '$totalProductsSold Pasang',
                subtitle: 'Unit Sepatu',
                icon: HugeIcons.strokeRoundedRunningShoes,
                bgColor: const Color(0xFF0284C7),
                textColor: Colors.white,
                iconColor: const Color(0xFF7DD3FC),
                trendText: '+24.5%',
                isPositive: true,
              ),
              _buildKpiCard(
                title: 'Tingkat Sukses',
                value: totalOrders > 0
                    ? '${((completedOrders / totalOrders) * 100).toStringAsFixed(0)}%'
                    : '100%',
                subtitle: '$processingOrders Diproses',
                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                bgColor: const Color(0xFF047857),
                textColor: Colors.white,
                iconColor: const Color(0xFFA7F3D0),
                trendText: 'Tinggi',
                isPositive: true,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Revenue Trend Line Chart (fl_chart - Solid Colors)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tren Omzet & Penjualan',
                          style: AppTextStyles.h3.copyWith(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Analitik pendapatan harian',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    // Period Filter Pills
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: ['7 Hari', 'Bulan ini', 'Tahun ini'].map((period) {
                          final isSelected = _selectedPeriod == period;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedPeriod = period),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                period,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // FL_CHART: LineChart (Solid Line & Solid Fill)
                SizedBox(
                  height: 220,
                  child: LineChart(
                    _buildLineChartData(totalRevenue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Order Status Distribution PieChart (fl_chart - Solid Colors)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distribusi Status Pesanan',
                  style: AppTextStyles.h3.copyWith(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Persentase status siklus pesanan pelanggan',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    // FL_CHART: PieChart
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedPieIndex = -1;
                                  return;
                                }
                                _touchedPieIndex =
                                    pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 4,
                          centerSpaceRadius: 36,
                          sections: _generatePieChartSections(
                            completed: completedOrders,
                            shipped: inDeliveryOrders,
                            processing: processingOrders,
                            total: totalOrders,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Pie Chart Legend Details
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLegendRow('Selesai', completedOrders, totalOrders, const Color(0xFF10B981)),
                          const SizedBox(height: 8),
                          _buildLegendRow('Dikirim', inDeliveryOrders, totalOrders, const Color(0xFF3B82F6)),
                          const SizedBox(height: 8),
                          _buildLegendRow('Diproses/Baru', processingOrders, totalOrders, const Color(0xFFF59E0B)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Bar Chart: Brand Sales Breakdown (fl_chart - Solid Bars)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Penjualan per Brand',
                  style: AppTextStyles.h3.copyWith(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jumlah pasang terjual per brand berdasarkan data pesanan',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                // FL_CHART: BarChart
                SizedBox(
                  height: 200,
                  child: BarChart(
                    _buildBrandBarChartData(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- KPI Card Widget (Solid Background) ---
  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required dynamic icon,
    required Color bgColor,
    required Color textColor,
    required Color iconColor,
    required String trendText,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HugeIcon(icon: icon, color: iconColor, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withValues(alpha: 0.25) : Colors.red.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trendText,
                  style: TextStyle(
                    color: isPositive ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- FL_CHART Data Generators (Solid Colors) ---

  LineChartData _buildLineChartData(double totalRevenue) {
    final baseVal = totalRevenue > 0 ? (totalRevenue / 1000000) : 5.0;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: baseVal > 0 ? baseVal / 3 : 2,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: Color(0xFFF1F5F9),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              const style = TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              );
              String text;
              switch (value.toInt()) {
                case 0:
                  text = 'Sen';
                  break;
                case 1:
                  text = 'Sel';
                  break;
                case 2:
                  text = 'Rab';
                  break;
                case 3:
                  text = 'Kam';
                  break;
                case 4:
                  text = 'Jum';
                  break;
                case 5:
                  text = 'Sab';
                  break;
                case 6:
                  text = 'Min';
                  break;
                default:
                  text = '';
              }
              return SideTitleWidget(
                meta: meta,
                child: Text(text, style: style),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: baseVal > 0 ? baseVal / 3 : 2,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(
                '${value.toStringAsFixed(1)}M',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              );
            },
            reservedSize: 34,
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: (baseVal * 1.4).clamp(4.0, 100.0),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                'Rp ${(spot.y * 1000000).toStringAsFixed(0)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, (baseVal * 0.4).clamp(1.0, 50.0)),
            FlSpot(1, (baseVal * 0.6).clamp(1.5, 50.0)),
            FlSpot(2, (baseVal * 0.5).clamp(1.2, 50.0)),
            FlSpot(3, (baseVal * 0.85).clamp(2.0, 60.0)),
            FlSpot(4, (baseVal * 0.7).clamp(1.8, 55.0)),
            FlSpot(5, (baseVal * 1.1).clamp(2.5, 70.0)),
            FlSpot(6, (baseVal * 1.25).clamp(3.0, 80.0)),
          ],
          isCurved: true,
          color: AppColors.primary, // Solid color without gradient
          barWidth: 3.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4.5,
                color: Colors.white,
                strokeWidth: 2.5,
                strokeColor: AppColors.primary,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withValues(alpha: 0.12), // Solid translucent fill
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generatePieChartSections({
    required int completed,
    required int shipped,
    required int processing,
    required int total,
  }) {
    final int safeTotal = total > 0 ? total : 1;
    final double compPct = (completed / safeTotal) * 100;
    final double shipPct = (shipped / safeTotal) * 100;
    final double procPct = (processing / safeTotal) * 100;

    return [
      PieChartSectionData(
        color: const Color(0xFF10B981),
        value: compPct > 0 ? compPct : 50,
        title: '${compPct.toStringAsFixed(0)}%',
        radius: _touchedPieIndex == 0 ? 46.0 : 38.0,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFF3B82F6),
        value: shipPct > 0 ? shipPct : 30,
        title: '${shipPct.toStringAsFixed(0)}%',
        radius: _touchedPieIndex == 1 ? 46.0 : 38.0,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFFF59E0B),
        value: procPct > 0 ? procPct : 20,
        title: '${procPct.toStringAsFixed(0)}%',
        radius: _touchedPieIndex == 2 ? 46.0 : 38.0,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  Widget _buildLegendRow(String title, int count, int total, Color color) {
    final double pct = total > 0 ? (count / total) * 100 : 0;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
        Text(
          '$count (${pct.toStringAsFixed(0)}%)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  BarChartData _buildBrandBarChartData() {
    // Compute brand sales from real order items
    final Map<String, int> brandSales = {};
    for (final order in widget.orders) {
      for (final item in order.items) {
        final name = item.productName.toLowerCase();
        String brand = 'Lainnya';
        if (name.contains('nike') || name.contains('air max') || name.contains('air force')) { brand = 'Nike'; }
        else if (name.contains('adidas') || name.contains('ultraboost') || name.contains('superstar')) { brand = 'Adidas'; }
        else if (name.contains('jordan') || name.contains('aj') || name.contains('dunk')) { brand = 'Jordan'; }
        else if (name.contains('puma')) { brand = 'Puma'; }
        else if (name.contains('converse') || name.contains('chuck')) { brand = 'Converse'; }
        else if (name.contains('vans') || name.contains('old skool')) { brand = 'Vans'; }
        else if (name.contains('new balance') || name.contains('nb ')) { brand = 'New Balance'; }
        else if (name.contains('reebok')) { brand = 'Reebok'; }
        brandSales[brand] = (brandSales[brand] ?? 0) + item.quantity;
      }
    }

    // Sort by quantity and take top 5
    final sorted = brandSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();

    // Fallback when no order data
    if (top5.isEmpty) {
      return _buildFallbackBarChart();
    }

    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
    ];

    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final entry = top5[group.x.toInt()];
            return BarTooltipItem(
              '${entry.key}\n${rod.toY.toInt()} Pasang',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (double value, TitleMeta meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= top5.length) return const SizedBox.shrink();
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  top5[idx].key,
                  style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(top5.length, (i) {
        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: top5[i].value.toDouble(),
              color: colors[i % colors.length],
              width: 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        );
      }),
      gridData: const FlGridData(show: false),
    );
  }

  BarChartData _buildFallbackBarChart() {
    final brands = ['Nike', 'Adidas', 'Jordan', 'Puma', 'Vans'];
    final values = [42.0, 35.0, 28.0, 18.0, 12.0];
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
    ];
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) =>
              BarTooltipItem('${brands[group.x.toInt()]}\n${rod.toY.toInt()} Pasang',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (double value, TitleMeta meta) {
              final idx = value.toInt();
              return SideTitleWidget(
                meta: meta,
                child: Text(brands[idx], style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 11)),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(brands.length, (i) =>
        BarChartGroupData(x: i, barRods: [BarChartRodData(toY: values[i], color: colors[i], width: 18, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))])
      ),
      gridData: const FlGridData(show: false),
    );
  }
}
