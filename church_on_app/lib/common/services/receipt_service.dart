import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptService {
  Future<Uint8List> buildPaymentReceipt({
    required String churchName,
    required String userName,
    required double amountZmw,
    required String method,
    required String reference,
    required DateTime createdAt,
  }) async {
    final pdf = pw.Document();
    final df = DateFormat.yMMMEd().add_jms();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Payment Receipt', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(churchName, style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 16),
              pw.Divider(),
              _row('Payer', userName),
              _row('Amount (ZMW)', amountZmw.toStringAsFixed(2)),
              _row('Method', method.toUpperCase()),
              _row('Reference', reference),
              _row('Date', df.format(createdAt.toLocal())),
              pw.Divider(),
              pw.SizedBox(height: 12),
              pw.Text('Thank you for your generosity!', style: const pw.TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
    return pdf.save();
  }

  pw.Widget _row(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [pw.Text(k), pw.Text(v, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))],
        ),
      );

  Future<void> sharePdf(Uint8List bytes, {String filename = 'receipt.pdf'}) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}