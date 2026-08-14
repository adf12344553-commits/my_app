// lib/credit_management_screen.dart – Premium Refined
// (same as earlier – no changes needed)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'app_state.dart';
import 'theme_service.dart';

class CreditManagementScreen extends StatefulWidget {
  const CreditManagementScreen({super.key});

  @override
  State<CreditManagementScreen> createState() => _CreditManagementScreenState();
}

class _CreditManagementScreenState extends State<CreditManagementScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _shopController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  Future<void> _sendWhatsAppReminder(
      BuildContext context, Debtor debtor) async {
    String message = "📢 *PAYMENT REMINDER - URGENT*\n\n"
        "Dear ${debtor.name} (${debtor.shopName}),\n\n"
        "This is a gentle but urgent reminder regarding your outstanding payment of "
        "*₹${debtor.outstanding.toStringAsFixed(0)}* which was due on *${debtor.dueDate.toString().substring(0, 10)}*.\n\n"
        "Please clear the dues immediately to maintain a healthy business relationship. "
        "We accept UPI, Cash, or Bank Transfer.\n\n"
        "⚠️ *Note:* If payment is not received within 2 days, your name will be moved to the Legal Recovery list.\n\n"
        "Thank you for your cooperation.\n"
        "- *BusinessOS* (Collection Dept)";

    await Clipboard.setData(ClipboardData(text: message));

    String phone = debtor.phone.trim();
    if (phone.startsWith('0')) phone = phone.substring(1);
    if (!phone.startsWith('91')) phone = '91$phone';

    final Uri whatsappUri =
        Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '✅ WhatsApp opened! Message copied to clipboard as backup.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) _showCopyDialog(context, message);
      }
    } catch (e) {
      if (mounted) _showCopyDialog(context, message);
    }
  }

  void _showCopyDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📋 WhatsApp not installed?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'The reminder message has been copied to your clipboard.'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Text(message, style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 10),
            const Text('You can paste it into any messaging app.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, String debtorId, String debtorName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Debtor'),
        content: Text('Are you sure you want to delete "$debtorName"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await context.read<AppState>().deleteDebtor(debtorId);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Debtor deleted!'),
                      backgroundColor: Colors.red),
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: Colors.red),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    _nameController.clear();
    _phoneController.clear();
    _shopController.clear();
    _amountController.clear();
    _dueDateController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Debtor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration:
                    const InputDecoration(labelText: 'Phone (10 digit) *'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _shopController,
                decoration: const InputDecoration(labelText: 'Shop Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                decoration:
                    const InputDecoration(labelText: 'Outstanding Amount *'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dueDateController,
                decoration: const InputDecoration(
                  labelText: 'Due Date (YYYY-MM-DD) *',
                  hintText: '2026-12-31',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              final phone = _phoneController.text.trim();
              final shop = _shopController.text.trim();
              final amount =
                  double.tryParse(_amountController.text.trim()) ?? 0;
              final dueDate =
                  DateTime.tryParse(_dueDateController.text.trim()) ??
                      DateTime.now();

              if (name.isEmpty || phone.isEmpty || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all required fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await context.read<AppState>().addDebtor(
                      name: name,
                      phone: phone,
                      shopName: shop,
                      outstanding: amount,
                      dueDate: dueDate,
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debtor added!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Debtor debtor) {
    _nameController.text = debtor.name;
    _phoneController.text = debtor.phone;
    _shopController.text = debtor.shopName;
    _amountController.text = debtor.outstanding.toString();
    _dueDateController.text = debtor.dueDate.toString().substring(0, 10);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Debtor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration:
                    const InputDecoration(labelText: 'Phone (10 digit) *'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _shopController,
                decoration: const InputDecoration(labelText: 'Shop Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                decoration:
                    const InputDecoration(labelText: 'Outstanding Amount *'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dueDateController,
                decoration: const InputDecoration(
                  labelText: 'Due Date (YYYY-MM-DD) *',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updated = Debtor(
                id: debtor.id,
                name: _nameController.text.trim(),
                phone: _phoneController.text.trim(),
                shopName: _shopController.text.trim(),
                outstanding: double.tryParse(_amountController.text.trim()) ??
                    debtor.outstanding,
                dueDate: DateTime.tryParse(_dueDateController.text.trim()) ??
                    debtor.dueDate,
                userId: debtor.userId,
              );
              try {
                await context.read<AppState>().updateDebtor(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debtor updated!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final debtors = appState.debtors;
    final primaryColor = ThemeService.getPrimaryColor(appState);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Udhār Recovery'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                const Color(0xFF4F46E5),
                const Color(0xFF1E1B4B)
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [Color(0xFF0F0A2A), Color(0xFF080B14)],
            stops: [0.0, 1.0],
          ),
        ),
        child: appState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : debtors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payments_outlined,
                            size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        const Text('No debtors yet',
                            style: TextStyle(color: Color(0xFF94A3B8))),
                        const SizedBox(height: 8),
                        const Text('Tap the + button to add one',
                            style: TextStyle(color: Color(0xFF64748B))),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                        top: 100, left: 16, right: 16, bottom: 16),
                    itemCount: debtors.length,
                    itemBuilder: (context, index) {
                      final debtor = debtors[index];
                      final overdue = debtor.dueDate.isBefore(DateTime.now());
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: overdue
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: overdue
                                        ? Colors.red.shade800
                                        : Colors.green.shade800,
                                    radius: 22,
                                    child: Text(
                                      debtor.name[0].toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          debtor.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFF8FAFC),
                                          ),
                                        ),
                                        Text(
                                          '🏪 ${debtor.shopName} • 📞 ${debtor.phone}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: overdue
                                          ? Colors.red.shade700
                                          : Colors.green.shade700,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      overdue ? 'OVERDUE' : 'ON TIME',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 16, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Due: ${debtor.dueDate.toString().substring(0, 10)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: overdue
                                          ? Colors.red.shade300
                                          : Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '₹${debtor.outstanding.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: overdue
                                          ? Colors.red.shade400
                                          : Colors.amber.shade400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _showEditDialog(context, debtor),
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('Edit'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.blue.shade300,
                                        side: BorderSide(
                                            color: Colors.blue.shade300),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _sendWhatsAppReminder(
                                          context, debtor),
                                      icon: const Icon(Icons.message, size: 18),
                                      label: const Text('SEND REMINDER'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red, size: 22),
                                    onPressed: () => _confirmDelete(
                                        context, debtor.id, debtor.name),
                                  ),
                                ],
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
