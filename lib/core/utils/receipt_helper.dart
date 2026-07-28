import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/core/utils/logger.dart';
import 'package:fashion_ecommerce/features/admin/domain/entities/order_detail.dart';

class ReceiptHelper {
  ReceiptHelper._();

  // ─── LAPORAN REKAP PENJUALAN (ADMIN) ──────────────────────────────────────

  /// Generate PDF Laporan Rekap Penjualan untuk Admin Kixora
  static Future<void> generateSalesReport({
    required BuildContext context,
    required List<OrderDetail> orders,
  }) async {
    try {
      final now = DateTime.now();
      final dateStr =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      final timeStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final fileName =
          'Laporan_Kixora_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.pdf';

      final double totalRevenue =
          orders.fold(0.0, (s, o) => s + o.totalPrice);
      final int totalItems = orders.fold(
          0,
          (s, o) =>
              s + o.items.fold(0, (si, i) => si + i.quantity));
      final int completed =
          orders.where((o) => o.status == 'Selesai').length;
      final int processing =
          orders.where((o) => o.status == 'Diproses' || o.status == 'Baru').length;
      final int shipped =
          orders.where((o) => o.status == 'Dikirim').length;
      final int cancelled =
          orders.where((o) => o.status == 'Dibatalkan').length;

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (pw.Context ctx) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#111111'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('KIXORA SNEAKERS',
                        style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 2),
                    pw.Text('Laporan Rekap Penjualan',
                        style: const pw.TextStyle(
                            color: PdfColors.grey400, fontSize: 10)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Dicetak: $dateStr $timeStr',
                        style: const pw.TextStyle(
                            color: PdfColors.grey400, fontSize: 9)),
                    pw.Text('Hal. ${ctx.pageNumber} / ${ctx.pagesCount}',
                        style: const pw.TextStyle(
                            color: PdfColors.grey500, fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
          build: (pw.Context ctx) => [
            // ── SUMMARY STATS ──
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0')),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Ringkasan Penjualan',
                      style: pw.TextStyle(
                          fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 12),
                  pw.Row(
                    children: [
                      _statBox('Total Pesanan', '${orders.length}',
                          PdfColor.fromHex('#1E293B')),
                      pw.SizedBox(width: 10),
                      _statBox('Total Omzet',
                          'Rp ${_formatPrice(totalRevenue)}',
                          PdfColor.fromHex('#E53935')),
                      pw.SizedBox(width: 10),
                      _statBox('Produk Terjual', '$totalItems Pasang',
                          PdfColor.fromHex('#0284C7')),
                      pw.SizedBox(width: 10),
                      _statBox(
                          'Selesai', '$completed', PdfColor.fromHex('#047857')),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Diproses/Baru: $processing  •  Dikirim: $shipped  •  Dibatalkan: $cancelled',
                    style:
                        const pw.TextStyle(color: PdfColors.grey700, fontSize: 9),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // ── TABEL PESANAN ──
            pw.Text('Daftar Seluruh Pesanan',
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),

            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#E2E8F0'), width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(1.2),
                4: const pw.FlexColumnWidth(1.8),
                5: const pw.FlexColumnWidth(1.2),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration:
                      pw.BoxDecoration(color: PdfColor.fromHex('#111111')),
                  children: [
                    _th('ID Pesanan'),
                    _th('Pelanggan'),
                    _th('Tanggal'),
                    _th('Item'),
                    _th('Total'),
                    _th('Status'),
                  ],
                ),
                // Data rows
                ...orders.asMap().entries.map((entry) {
                  final i = entry.key;
                  final order = entry.value;
                  final bg = i.isOdd
                      ? PdfColor.fromHex('#F8FAFC')
                      : PdfColors.white;
                  final itemCount = order.items
                      .fold(0, (s, it) => s + it.quantity);
                  final shortId = order.id.length > 14
                      ? '...${order.id.substring(order.id.length - 12)}'
                      : order.id;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: bg),
                    children: [
                      _td(shortId),
                      _td(order.customerName),
                      _td('${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}'),
                      _td('$itemCount psg', alignRight: true),
                      _td('Rp ${_formatPrice(order.totalPrice)}',
                          alignRight: true),
                      _td(order.status, color: _statusColor(order.status)),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),

            // ── TOTAL FOOTER ──
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 220,
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#111111'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _summaryRow('Total Pesanan', '${orders.length}',
                        isWhite: true),
                    _summaryRow('Total Produk Terjual', '$totalItems Pasang',
                        isWhite: true),
                    pw.Divider(color: PdfColors.grey600),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('TOTAL OMZET',
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold)),
                        pw.Text('Rp ${_formatPrice(totalRevenue)}',
                            style: pw.TextStyle(
                                color: PdfColor.fromHex('#4ADE80'),
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 24),
            pw.Divider(color: PdfColor.fromHex('#E2E8F0')),
            pw.SizedBox(height: 6),
            pw.Text(
              'Dokumen ini digenerate secara otomatis oleh sistem Kixora Sneakers pada $dateStr $timeStr.',
              style:
                  const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
            ),
          ],
        ),
      );

      final pdfBytes = await pdf.save();

      if (kIsWeb) {
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(children: [
                const Icon(Icons.picture_as_pdf, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                    child: Text('Laporan rekap berhasil diunduh!\nFile: $fileName')),
              ]),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      Directory? storageDir;
      try {
        if (Platform.isAndroid) {
          storageDir = await getExternalStorageDirectory();
        }
      } catch (_) {}
      storageDir ??= await getApplicationDocumentsDirectory();

      final filePath = '${storageDir.path}/$fileName';
      await File(filePath).writeAsBytes(pdfBytes);
      AppLogger.success('Laporan PDF disimpan ke: $filePath');

      if (context.mounted) {
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.picture_as_pdf, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Laporan rekap berhasil disimpan!\n$fileName')),
            ]),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Gagal generate laporan PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal membuat laporan: ${e.toString().replaceAll("Exception:", "").trim()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ─── PDF HELPER WIDGETS ────────────────────────────────────────────────────

  static pw.Widget _statBox(
      String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 2),
            pw.Text(label,
                style: const pw.TextStyle(
                    color: PdfColors.grey300, fontSize: 8)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _th(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(text,
          style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _td(String text,
      {bool alignRight = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: pw.Text(
        text,
        style:
            pw.TextStyle(fontSize: 8, color: color ?? PdfColors.black),
        textAlign:
            alignRight ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _summaryRow(String label, String value,
      {bool isWhite = false}) {
    final c = isWhite ? PdfColors.grey300 : PdfColors.grey700;
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, color: c)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: isWhite ? PdfColors.white : PdfColors.black)),
        ],
      ),
    );
  }

  static PdfColor _statusColor(String status) {
    switch (status) {
      case 'Selesai':
        return PdfColor.fromHex('#047857');
      case 'Dikirim':
        return PdfColor.fromHex('#1D4ED8');
      case 'Diproses':
        return PdfColor.fromHex('#B45309');
      case 'Dibatalkan':
        return PdfColor.fromHex('#B91C1C');
      default:
        return PdfColors.grey700;
    }
  }

  // ─── RESI TRANSAKSI (USER) ────────────────────────────────────────────────

  /// Desain & Generate PDF Resi Transaksi Premium untuk Kixora Sneakers
  static Future<void> saveReceiptToDevice({
    required BuildContext context,
    required String orderId,
    required String recipientName,
    required String recipientPhone,
    required String address,
    required double totalPrice,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final cleanOrderId = orderId.replaceAll(RegExp(r'[^\w\-]'), '');
      final fileName = "Resi_Kixora_$cleanOrderId.pdf";

      final pdf = pw.Document();
      final now = DateTime.now();
      final dateStr =
          "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context pdfContext) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // HEADER BANNER
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#111111'),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("KIXORA SNEAKERS",
                              style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 22,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text(
                              "Authentic Sneakers & Premium Footwear Store",
                              style: const pw.TextStyle(
                                  color: PdfColors.grey400, fontSize: 10)),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#E53935'),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text("LUNAS / PAID",
                            style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 12,
                                fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),

                // INFO TRANSAKSI & PENERIMA
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#F8F9FA'),
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(
                              color: PdfColor.fromHex('#E9ECEF')),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("INFORMASI RESI",
                                style: pw.TextStyle(
                                    fontSize: 11,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromHex('#E53935'))),
                            pw.SizedBox(height: 8),
                            _pdfInfoRow("No. Resi", orderId),
                            _pdfInfoRow("Tanggal", dateStr),
                            _pdfInfoRow("Metode", "QRIS / Credit Card"),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#F8F9FA'),
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(
                              color: PdfColor.fromHex('#E9ECEF')),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("ALAMAT PENGIRIMAN",
                                style: pw.TextStyle(
                                    fontSize: 11,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromHex('#E53935'))),
                            pw.SizedBox(height: 8),
                            _pdfInfoRow("Penerima", recipientName),
                            _pdfInfoRow("No. HP", recipientPhone),
                            _pdfInfoRow("Alamat", address),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // TABEL ITEM
                pw.Text("RINCIAN PRODUK SEPATU",
                    style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#111111'))),
                pw.SizedBox(height: 10),

                pw.Table(
                  border: pw.TableBorder.all(
                      color: PdfColor.fromHex('#E9ECEF'), width: 1),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#111111')),
                      children: [
                        _pdfTableCell("Nama Produk / Shoes",
                            isHeader: true, flex: 3),
                        _pdfTableCell("Qty",
                            isHeader: true, flex: 1, alignRight: true),
                        _pdfTableCell("Harga Satuan",
                            isHeader: true, flex: 2, alignRight: true),
                        _pdfTableCell("Subtotal",
                            isHeader: true, flex: 2, alignRight: true),
                      ],
                    ),
                    ...items.map((item) {
                      final name = item['name'] ?? 'Sepatu Authentic';
                      final qty = item['quantity'] ?? 1;
                      final price =
                          (item['price'] as num?)?.toDouble() ?? 0;
                      final subtotal = price * qty;
                      return pw.TableRow(
                        children: [
                          _pdfTableCell(name, flex: 3),
                          _pdfTableCell("$qty",
                              flex: 1, alignRight: true),
                          _pdfTableCell(
                              "Rp ${_formatPrice(price)}",
                              flex: 2,
                              alignRight: true),
                          _pdfTableCell(
                              "Rp ${_formatPrice(subtotal)}",
                              flex: 2,
                              alignRight: true),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 20),

                // TOTAL
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 260,
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#F8F9FA'),
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(
                            color: PdfColor.fromHex('#E9ECEF')),
                      ),
                      child: pw.Column(
                        children: [
                          _pdfSummaryRow("Subtotal Produk",
                              "Rp ${_formatPrice(totalPrice - 5000)}"),
                          _pdfSummaryRow(
                              "Ongkos Kirim", "Rp 20.000"),
                          _pdfSummaryRow(
                              "Diskon Voucher", "-Rp 25.000"),
                          pw.Divider(
                              color: PdfColor.fromHex('#CCCCCC')),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text("TOTAL BAYAR",
                                  style: pw.TextStyle(
                                      fontSize: 13,
                                      fontWeight: pw.FontWeight.bold,
                                      color:
                                          PdfColor.fromHex('#E53935'))),
                              pw.Text(
                                  "Rp ${_formatPrice(totalPrice)}",
                                  style: pw.TextStyle(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                      color:
                                          PdfColor.fromHex('#E53935'))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),

                // FOOTER & BARCODE
                pw.Divider(color: PdfColor.fromHex('#E9ECEF')),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Kixora Sneakers Guarantee",
                            style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#111111'))),
                        pw.SizedBox(height: 2),
                        pw.Text(
                            "Semua produk dijamin 100% Original & Authentic.",
                            style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey600)),
                      ],
                    ),
                    pw.BarcodeWidget(
                      data: orderId,
                      barcode: pw.Barcode.code128(),
                      width: 120,
                      height: 35,
                      drawText: true,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();

      if (kIsWeb) {
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              const Icon(Icons.picture_as_pdf, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Resi PDF berhasil dibuat!\nFile: $fileName')),
            ]),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ));
        }
        return;
      }

      Directory? storageDir;
      try {
        if (Platform.isAndroid) {
          storageDir = await getExternalStorageDirectory();
        }
      } catch (_) {}
      storageDir ??= await getApplicationDocumentsDirectory();

      final filePath = "${storageDir.path}/$fileName";
      await File(filePath).writeAsBytes(pdfBytes);
      AppLogger.success('Resi PDF disimpan ke: $filePath');

      if (context.mounted) {
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.picture_as_pdf, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('Resi PDF berhasil disimpan!\n$fileName')),
          ]),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
        ));
      }
    } catch (e) {
      AppLogger.error('Gagal membuat resi PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal membuat resi: ${e.toString().replaceAll("Exception:", "")}'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }

  // ─── SHARED PDF HELPERS ────────────────────────────────────────────────────

  static pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
              width: 55,
              child: pw.Text(label,
                  style: const pw.TextStyle(
                      fontSize: 9, color: PdfColors.grey700))),
          pw.Text(": ", style: const pw.TextStyle(fontSize: 9)),
          pw.Expanded(
              child: pw.Text(value,
                  style: pw.TextStyle(
                      fontSize: 9, fontWeight: pw.FontWeight.bold))),
        ],
      ),
    );
  }

  static pw.Widget _pdfTableCell(
    String text, {
    bool isHeader = false,
    required int flex,
    bool alignRight = false,
  }) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      alignment: alignRight
          ? pw.Alignment.centerRight
          : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight:
              isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _pdfSummaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: const pw.TextStyle(
                  fontSize: 10, color: PdfColors.grey700)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
