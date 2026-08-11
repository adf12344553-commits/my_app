// lib/pdf_service.dart – FIXED (Uint8List)
import 'dart:html' as html;
import 'dart:typed_data'; // ✅ added
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'app_state.dart';

class PdfService {
  // ---- Helper: fetch image bytes and convert to Uint8List ----
  static Future<Uint8List?> _fetchImageBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return Uint8List.fromList(response.bodyBytes); // ✅ conversion
      }
    } catch (_) {}
    return null;
  }

  // 1. GST INVOICE with Logo
  static Future<void> generateInvoice(
      Order order, BusinessSettings settings) async {
    final pdf = pw.Document();
    final totalWords = _numberToWords(order.grandTotal);
    pw.Widget? logoWidget;
    if (settings.logoUrl.isNotEmpty) {
      final bytes = await _fetchImageBytes(settings.logoUrl);
      if (bytes != null) {
        logoWidget = pw.Image(pw.MemoryImage(bytes), width: 60, height: 60);
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with Logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Row(
                    children: [
                      if (logoWidget != null) logoWidget,
                      if (logoWidget != null) pw.SizedBox(width: 12),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(settings.businessName,
                              style: pw.TextStyle(
                                  fontSize: 22,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text(settings.address),
                          pw.Text('GSTIN: ${settings.upiId ?? 'N/A'}'),
                          pw.Text('Phone: ${settings.phone}'),
                        ],
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('TAX INVOICE',
                          style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue)),
                      pw.Text(
                          'Invoice #: INV-${order.id.substring(0, 8).toUpperCase()}'),
                      pw.Text(
                          'Date: ${DateFormat('dd/MM/yyyy').format(order.date)}'),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),
              pw.Text('Bill To:',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text(order.customerName),
              pw.Text(
                  'GSTIN: ${order.customerGst.isNotEmpty ? order.customerGst : 'Not Registered'}'),
              pw.SizedBox(height: 15),
              // Table
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text('Item',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text('HSN',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text('Qty',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text('Rate',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text('Taxable',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text('CGST',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text('SGST',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text('Total',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(order.productName)),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(order.hsnCode)),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text('${order.quantity}')),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child:
                              pw.Text('Rs. ${order.price.toStringAsFixed(2)}')),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                              'Rs. ${order.taxableValue.toStringAsFixed(2)}')),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child:
                              pw.Text('Rs. ${order.cgst.toStringAsFixed(2)}')),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child:
                              pw.Text('Rs. ${order.sgst.toStringAsFixed(2)}')),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                              'Rs. ${order.grandTotal.toStringAsFixed(2)}')),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                          'Total: Rs. ${order.grandTotal.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Total in Words: $totalWords',
                          style: pw.TextStyle(fontSize: 12)),
                      pw.Text('Payment: ${order.paymentMethod}',
                          style: pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 20),
                      pw.Row(
                        children: [
                          pw.Text('Authorized Signatory',
                              style: pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(width: 100),
                          pw.Text('(Company Stamp)',
                              style: pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    await _downloadPdf(pdf, 'invoice_${order.id.substring(0, 8)}.pdf');
  }

  // 2. PAYMENT RECEIPT with Logo
  static Future<void> generateReceipt(
      Order order, BusinessSettings settings) async {
    final pdf = pw.Document();
    pw.Widget? logoWidget;
    if (settings.logoUrl.isNotEmpty) {
      final bytes = await _fetchImageBytes(settings.logoUrl);
      if (bytes != null) {
        logoWidget = pw.Image(pw.MemoryImage(bytes), width: 40, height: 40);
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logoWidget != null)
                pw.Row(
                  children: [
                    logoWidget,
                    pw.SizedBox(width: 8),
                    pw.Text(settings.businessName,
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              pw.SizedBox(height: 8),
              pw.Text('Payment Receipt',
                  style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green)),
              pw.Divider(),
              pw.Text(
                  'Receipt #: REC-${order.id.substring(0, 8).toUpperCase()}'),
              pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(order.date)}'),
              pw.Text('Customer: ${order.customerName}'),
              pw.Text(
                  'Amount Paid: Rs. ${order.grandTotal.toStringAsFixed(2)}'),
              pw.Text('Mode: ${order.paymentMethod}'),
              pw.Text('For: ${order.productName} (Qty: ${order.quantity})'),
              pw.Divider(),
              pw.Text('Thank you for your business!',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await _downloadPdf(pdf, 'receipt_${order.id.substring(0, 8)}.pdf');
  }

  // 3. FINANCIAL SUMMARY with Logo
  static Future<void> generateFinancialSummary(AppState appState) async {
    final pdf = pw.Document();
    final totalGstCollected =
        appState.orders.fold(0.0, (sum, o) => sum + o.totalGst);
    final totalRevenue = appState.totalRevenue;
    final totalOutstanding = appState.totalOutstanding;
    final overdueCount = appState.overdueCount;

    pw.Widget? logoWidget;
    if (appState.settings?.logoUrl.isNotEmpty ?? false) {
      final bytes = await _fetchImageBytes(appState.settings!.logoUrl);
      if (bytes != null) {
        logoWidget = pw.Image(pw.MemoryImage(bytes), width: 50, height: 50);
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logoWidget != null)
                pw.Row(
                  children: [
                    logoWidget,
                    pw.SizedBox(width: 12),
                    pw.Text('Financial Summary',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  ],
                )
              else
                pw.Text('Business Financial Summary',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text(appState.settings?.businessName ?? 'My Business'),
              pw.Text(
                  'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),
              pw.Text('Revenue & Sales',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'Total Revenue (Net): Rs. ${totalRevenue.toStringAsFixed(2)}'),
              pw.Text(
                  'Total GST Collected: Rs. ${totalGstCollected.toStringAsFixed(2)}'),
              pw.Text(
                  'Gross Revenue (Inc. GST): Rs. ${(totalRevenue + totalGstCollected).toStringAsFixed(2)}'),
              pw.SizedBox(height: 10),
              pw.Text('Receivables',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'Total Outstanding: Rs. ${totalOutstanding.toStringAsFixed(2)}'),
              pw.Text('Overdue Accounts: $overdueCount'),
              pw.SizedBox(height: 10),
              pw.Text('Orders Summary',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text('Total Orders: ${appState.totalOrders}'),
              pw.Text('Total Customers: ${appState.customers.length}'),
              pw.SizedBox(height: 20),
              pw.Text(
                  '* This is a system-generated report for management purposes.',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ],
          );
        },
      ),
    );

    await _downloadPdf(pdf, 'financial_summary.pdf');
  }

  // 4. COLLECTION REPORT with Logo
  static Future<void> generateCollectionReport(AppState appState) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final overdueTotal = appState.debtors
        .where((d) => d.dueDate.isBefore(now))
        .fold(0.0, (sum, d) => sum + d.outstanding);

    pw.Widget? logoWidget;
    if (appState.settings?.logoUrl.isNotEmpty ?? false) {
      final bytes = await _fetchImageBytes(appState.settings!.logoUrl);
      if (bytes != null) {
        logoWidget = pw.Image(pw.MemoryImage(bytes), width: 50, height: 50);
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logoWidget != null)
                pw.Row(
                  children: [
                    logoWidget,
                    pw.SizedBox(width: 12),
                    pw.Text('Collection Report',
                        style: pw.TextStyle(
                            fontSize: 28, fontWeight: pw.FontWeight.bold)),
                  ],
                )
              else
                pw.Text('Collection Report',
                    style: pw.TextStyle(
                        fontSize: 28, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text(appState.settings?.businessName ?? 'My Business',
                  style: pw.TextStyle(fontSize: 20)),
              pw.Text('Owner: ${appState.settings?.ownerName ?? ''}',
                  style: pw.TextStyle(fontSize: 14)),
              pw.Text('Date: ${DateTime.now().toString().substring(0, 10)}',
                  style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 16),
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(8),
                      color: PdfColors.green100,
                      child: pw.Column(
                        children: [
                          pw.Text(
                              'Rs. ${appState.totalOutstanding.toStringAsFixed(0)}',
                              style: pw.TextStyle(
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.Text('Total Outstanding'),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Expanded(
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(8),
                      color: PdfColors.red100,
                      child: pw.Column(
                        children: [
                          pw.Text('Rs. ${overdueTotal.toStringAsFixed(0)}',
                              style: pw.TextStyle(
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.red)),
                          pw.Text('Overdue Amount'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text('Debtors List',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Name')),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Shop')),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Due Date')),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Amount')),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Status')),
                    ],
                  ),
                  ...appState.debtors.map((d) {
                    final overdue = d.dueDate.isBefore(now);
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(d.name)),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(d.shopName)),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child:
                                pw.Text(d.dueDate.toString().substring(0, 10))),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                                'Rs. ${d.outstanding.toStringAsFixed(0)}')),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(overdue ? 'OVERDUE' : 'Active',
                              style: pw.TextStyle(
                                  color: overdue
                                      ? PdfColors.red
                                      : PdfColors.green)),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          );
        },
      ),
    );

    await _downloadPdf(pdf, 'collection_report.pdf');
  }

  // Helper download
  static Future<void> _downloadPdf(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = fileName;
    anchor.click();
    html.Url.revokeObjectUrl(url);
  }

  static String _numberToWords(double number) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ');
    return formatter.format(number);
  }
}
