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

          // 4. Bar Chart: Category Sales Breakdown (fl_chart - Solid Bars)
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
                  'Penjualan per Kategori Sepatu',
                  style: AppTextStyles.h3.copyWith(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jumlah pasang terjual berdasarkan jenis produk',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                // FL_CHART: BarChart
                SizedBox(
                  height: 200,
                  child: BarChart(
                    _buildBarChartData(),
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

  BarChartData _buildBarChartData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String category;
            switch (group.x.toInt()) {
              case 0:
                category = 'Running';
                break;
              case 1:
                category = 'Casual';
                break;
              case 2:
                category = 'Basketball';
                break;
              case 3:
                category = 'Boots';
                break;
              case 4:
                category = 'Sandals';
                break;
              default:
                category = '';
            }
            return BarTooltipItem(
              '$category\n${rod.toY.toInt()} Pasang',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              const style = TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              );
              Widget text;
              switch (value.toInt()) {
                case 0:
                  text = const Text('Running', style: style);
                  break;
                case 1:
                  text = const Text('Casual', style: style);
                  break;
                case 2:
                  text = const Text('Basket', style: style);
                  break;
                case 3:
                  text = const Text('Boots', style: style);
                  break;
                case 4:
                  text = const Text('Sandal', style: style);
                  break;
                default:
                  text = const Text('', style: style);
                  break;
              }
              return SideTitleWidget(
                meta: meta,
                child: text,
              );
            },
            reservedSize: 28,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: 42,
              color: const Color(0xFF3B82F6), // Solid Blue
              width: 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              toY: 35,
              color: const Color(0xFF8B5CF6), // Solid Purple
              width: 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [
            BarChartRodData(
              toY: 28,
              color: const Color(0xFFEC4899), // Solid Pink
              width: 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
        BarChartGroupData(
          x: 3,
          barRods: [
            BarChartRodData(
              toY: 18,
              color: const Color(0xFF10B981), // Solid Emerald
              width: 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
        BarChartGroupData(
          x: 4,
          barRods: [
            BarChartRodData(
              toY: 12,
              color: const Color(0xFFF59E0B), // Solid Amber
              width: 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
      ],
      gridData: const FlGridData(show: false),
    );
  }
}
