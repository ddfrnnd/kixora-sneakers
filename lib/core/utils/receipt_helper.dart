import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fashion_ecommerce/app/theme/app_colors.dart';
import 'package:fashion_ecommerce/core/utils/logger.dart';

class ReceiptHelper {
  ReceiptHelper._();

  /// Desain & Generate PDF Resi Transaksi Premium untuk SoleStep Footwear
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
      final fileName = "Resi_SoleStep_$cleanOrderId.pdf";

      // 1. Inisialisasi Dokumen PDF
      final pdf = pw.Document();
      final now = DateTime.now();
      final dateStr = "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

      // 2. Susun Desain Layar PDF (Sleek Modern Premium Design)
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context pdfContext) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // --- HEADER BANNER ---
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
                          pw.Text(
                            "SOLESTEP FOOTWEAR",
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            "Authentic Sneakers & Premium Footwear Store",
                            style: const pw.TextStyle(
                              color: PdfColors.grey400,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#E53935'),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          "LUNAS / PAID",
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 24),

                // --- INFO TRANSAKSI & PENERIMA ---
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Kolom Kiri: Detail Order
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#F8F9FA'),
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(color: PdfColor.fromHex('#E9ECEF')),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "INFORMASI RESI",
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#E53935'),
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            _pdfInfoRow("No. Resi", orderId),
                            _pdfInfoRow("Tanggal", dateStr),
                            _pdfInfoRow("Metode", "QRIS / Credit Card"),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 16),

                    // Kolom Kanan: Detail Penerima
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(14),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#F8F9FA'),
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(color: PdfColor.fromHex('#E9ECEF')),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "ALAMAT PENGIRIMAN",
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#E53935'),
                              ),
                            ),
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

                // --- TABEL ITEM RINCIAN PEMBELIAN ---
                pw.Text(
                  "RINCIAN PRODUK SEPATU",
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#111111'),
                  ),
                ),
                pw.SizedBox(height: 10),

                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColor.fromHex('#E9ECEF'),
                    width: 1,
                  ),
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColor.fromHex('#111111')),
                      children: [
                        _pdfTableCell("Nama Produk / Shoes", isHeader: true, flex: 3),
                        _pdfTableCell("Qty", isHeader: true, flex: 1, alignRight: true),
                        _pdfTableCell("Harga Satuan", isHeader: true, flex: 2, alignRight: true),
                        _pdfTableCell("Subtotal", isHeader: true, flex: 2, alignRight: true),
                      ],
                    ),
                    // Table Rows
                    ...items.map((item) {
                      final name = item['name'] ?? 'Sepatu Authentic';
                      final qty = item['quantity'] ?? 1;
                      final price = (item['price'] as num?)?.toDouble() ?? 0;
                      final subtotal = price * qty;

                      return pw.TableRow(
                        children: [
                          _pdfTableCell(name, flex: 3),
                          _pdfTableCell("$qty", flex: 1, alignRight: true),
                          _pdfTableCell("Rp ${_formatPrice(price)}", flex: 2, alignRight: true),
                          _pdfTableCell("Rp ${_formatPrice(subtotal)}", flex: 2, alignRight: true),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 20),

                // --- SUMMARY & TOTAL ---
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 260,
                      padding: const pw.EdgeInsets.all(16),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#F8F9FA'),
                        borderRadius: pw.BorderRadius.circular(8),
                        border: pw.Border.all(color: PdfColor.fromHex('#E9ECEF')),
                      ),
                      child: pw.Column(
                        children: [
                          _pdfSummaryRow("Subtotal Produk", "Rp ${_formatPrice(totalPrice - 5000)}"),
                          _pdfSummaryRow("Ongkos Kirim Courier", "Rp 20.000"),
                          _pdfSummaryRow("Diskon Promo Voucher", "-Rp 25.000"),
                          pw.Divider(color: PdfColor.fromHex('#CCCCCC')),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                "TOTAL BAYAR",
                                style: pw.TextStyle(
                                  fontSize: 13,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#E53935'),
                                ),
                              ),
                              pw.Text(
                                "Rp ${_formatPrice(totalPrice)}",
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromHex('#E53935'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),

                // --- FOOTER & BARCODE ---
                pw.Divider(color: PdfColor.fromHex('#E9ECEF')),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "SoleStep Footwear Guarantee",
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex('#111111'),
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          "Semua produk dijamin 100% Original & Authentic.",
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
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

      // Handling Platform Web (Chrome/Edge)
      if (kIsWeb) {
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Resi PDF berhasil dibuat & diunduh!\nFile: $fileName'),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Handling Platform Mobile / Desktop
      Directory? storageDir;
      try {
        if (Platform.isAndroid) {
          storageDir = await getExternalStorageDirectory();
        }
      } catch (_) {}

      storageDir ??= await getApplicationDocumentsDirectory();

      final filePath = "${storageDir.path}/$fileName";
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      AppLogger.success('Resi PDF berhasil disimpan ke: $filePath');

      if (context.mounted) {
        // Tampilkan opsi Preview / Share / Save PDF
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Resi PDF berhasil disimpan!\nPath: $fileName',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Gagal membuat resi PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat resi PDF: ${e.toString().replaceAll("Exception:", "")}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  static pw.Widget _pdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 55,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ),
          pw.Text(": ", style: const pw.TextStyle(fontSize: 9)),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
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
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      alignment: alignRight ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
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
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
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
