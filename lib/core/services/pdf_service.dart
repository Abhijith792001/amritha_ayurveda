import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateRegistrationPdf(
    Map<String, dynamic> data,
    List<Map<String, dynamic>> treatments,
  ) async {
    try {
      final pdf = pw.Document();

      // Loading assets with survival logic
      pw.ImageProvider? logo;
      pw.ImageProvider? signature;
      pw.Font? poppins;
      pw.Font? poppinsBold;

      try {
        logo = await imageFromAssetBundle('assets/images/logo.png');
      } catch (e) {
        print("PDF Error: Logo not found - $e");
      }

      try {
        signature = await imageFromAssetBundle('assets/images/signature.png');
      } catch (e) {
        print("PDF Error: Signature not found - $e");
      }

      // Load local fonts to avoid network dependency
      try {
        poppins = await fontFromAssetBundle('assets/fonts/Poppins.ttf');
        // If you have a bold version, load it here.
        // Otherwise, pdf package will fake bold if only regular is provided.
        poppinsBold = poppins;
      } catch (e) {
        print("PDF Error: Font not found, falling back to default - $e");
      }

      // Extracting date and time
      final fullDateTime = data['date_nd_time'] ?? '';
      String treatmentDate = '';
      String treatmentTime = '';
      if (fullDateTime.contains('-')) {
        final parts = fullDateTime.split('-');
        treatmentDate = parts[0];
        treatmentTime = parts[1];
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: poppins, bold: poppinsBold),
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Watermark
                if (logo != null)
                  pw.Center(
                    child: pw.Opacity(
                      opacity: 0.05,
                      child: pw.Image(logo!, width: 400),
                    ),
                  ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(30),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Header
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (logo != null)
                            pw.Image(logo!, width: 80)
                          else
                            pw.SizedBox(width: 80),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                'KUMARAKOM',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              pw.Text(
                                'Cheepunkal P.O. Kumarakom, kottayam, Kerala - 686563',
                                style: const pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColors.grey,
                                ),
                              ),
                              pw.Text(
                                'e-mail: unknown@gmail.com',
                                style: const pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColors.grey,
                                ),
                              ),
                              pw.Text(
                                'Mob: +91 9876543210 | +91 9786543210',
                                style: const pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColors.grey,
                                ),
                              ),
                              pw.Text(
                                'GST No: 32AABCU9603R1ZW',
                                style: const pw.TextStyle(
                                  fontSize: 8,
                                  color: PdfColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),
                      pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                      pw.SizedBox(height: 15),

                      // Patient Details
                      pw.Text(
                        'Patient Details',
                        style: pw.TextStyle(
                          color: PdfColor.fromHex('#21B573'),
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildInfoText('Name', data['name'] ?? ''),
                              _buildInfoText('Address', data['address'] ?? ''),
                              _buildInfoText(
                                'WhatsApp Number',
                                data['phone'] ?? '',
                              ),
                            ],
                          ),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildInfoText(
                                'Booked On',
                                '31/01/2024',
                              ), // Placeholder as in design
                              _buildInfoText('Treatment Date', treatmentDate),
                              _buildInfoText('Treatment Time', treatmentTime),
                            ],
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 20),
                      _buildDashedDivider(),
                      pw.SizedBox(height: 10),

                      // Table Header
                      pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 3,
                            child: _buildTableHeader('Treatment'),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: _buildTableHeader(
                              'Price',
                              align: pw.TextAlign.center,
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: _buildTableHeader(
                              'Male',
                              align: pw.TextAlign.center,
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: _buildTableHeader(
                              'Female',
                              align: pw.TextAlign.center,
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: _buildTableHeader(
                              'Total',
                              align: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 10),

                      // Rows
                      ...treatments.asMap().entries.map((entry) {
                        final t = entry.value;
                        const price = 230; // Matches design
                        final male = int.tryParse(t['male'].toString()) ?? 0;
                        final female =
                            int.tryParse(t['female'].toString()) ?? 0;
                        final total = (male + female) * price;

                        return pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 8),
                          child: pw.Row(
                            children: [
                              pw.Expanded(
                                flex: 3,
                                child: pw.Text(
                                  t['treatment'] ?? '',
                                  style: const pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                flex: 1,
                                child: pw.Text(
                                  'Rs. $price',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                flex: 1,
                                child: pw.Text(
                                  '$male',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                flex: 1,
                                child: pw.Text(
                                  '$female',
                                  textAlign: pw.TextAlign.center,
                                  style: const pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ),
                              pw.Expanded(
                                flex: 1,
                                child: pw.Text(
                                  'Rs. $total',
                                  textAlign: pw.TextAlign.right,
                                  style: const pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      pw.SizedBox(height: 10),
                      _buildDashedDivider(),
                      pw.SizedBox(height: 10),

                      // Summary
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              _buildSummaryRow(
                                'Total Amount',
                                'Rs. ${data['total_amount']}',
                                isBold: true,
                                fontSize: 12,
                              ),
                              _buildSummaryRow(
                                'Discount',
                                'Rs. ${data['discount_amount']}',
                              ),
                              _buildSummaryRow(
                                'Advance',
                                'Rs. ${data['advance_amount']}',
                              ),
                              pw.SizedBox(height: 5),
                              _buildDashedDivider(width: 150),
                              pw.SizedBox(height: 5),
                              _buildSummaryRow(
                                'Balance',
                                'Rs. ${data['balance_amount']}',
                                isBold: true,
                                fontSize: 12,
                              ),
                            ],
                          ),
                        ],
                      ),

                      pw.Spacer(),

                      // Footer
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Thank you for choosing us',
                              style: pw.TextStyle(
                                color: PdfColor.fromHex('#21B573'),
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              "Your well-being is our commitment, and we're honored\nyou've entrusted us with your health journey",
                              textAlign: pw.TextAlign.right,
                              style: const pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.grey500,
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            if (signature != null)
                              pw.Image(signature!, width: 100),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 30),
                      _buildDashedDivider(),
                      pw.SizedBox(height: 10),
                      pw.Center(
                        child: pw.Text(
                          '“Booking amount is non-refundable, and it\'s important to arrive on the allotted time for your treatment”',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print("PDF Generation Global Error: $e");
    }
  }

  static pw.Widget _buildInfoText(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            ),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableHeader(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: PdfColor.fromHex('#21B573'),
      ),
    );
  }

  static pw.Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 10,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                fontSize: fontSize,
              ),
            ),
          ),
          pw.SizedBox(
            width: 60,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDashedDivider({double width = double.infinity}) {
    return pw.Container(
      width: width,
      child: pw.CustomPaint(
        size: const PdfPoint(0, 1),
        painter: (PdfGraphics canvas, PdfPoint size) {
          canvas
            ..setStrokeColor(PdfColors.grey300)
            ..setLineWidth(1)
            ..setLineDashPattern([3, 3])
            ..moveTo(0, 0)
            ..lineTo(size.x, 0)
            ..strokePath();
        },
      ),
    );
  }
}
