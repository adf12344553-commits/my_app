// lib/lead_screen.dart – COMPLETE with debug prints
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'auth_provider.dart';
import 'theme_service.dart';

class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen> {
  final List<String> _statuses = [
    'new',
    'contacted',
    'qualified',
    'meeting',
    'quote',
    'negotiation',
    'won',
    'lost'
  ];
  final Map<String, Color> _statusColors = {
    'new': Colors.grey,
    'contacted': Colors.blue,
    'qualified': Colors.green,
    'meeting': Colors.orange,
    'quote': Colors.purple,
    'negotiation': Colors.deepPurple,
    'won': Colors.green.shade700,
    'lost': Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final auth = Provider.of<AuthProvider>(context);
    final leads = appState.leads;
    final isStaff = appState.isStaff;
    final currentUserId = auth.user?.id;

    final displayLeads = isStaff
        ? leads.where((l) => l.assignedTo == currentUserId).toList()
        : leads;

    return Scaffold(
      appBar: AppBar(
        title: isStaff ? const Text('My Leads') : const Text('Leads & Deals'),
        backgroundColor: ThemeService.getPrimaryColor(appState),
        foregroundColor: Colors.white,
        actions: [
          if (!isStaff)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                debugPrint('🔘 Plus button pressed!');
                _showAddLeadDialog(context);
              },
            ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : displayLeads.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        isStaff ? 'No leads assigned to you' : 'No leads yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isStaff
                            ? 'Ask your manager to assign leads'
                            : 'Tap the + button to add your first lead',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: displayLeads.length,
                  itemBuilder: (context, index) {
                    final lead = displayLeads[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _statusColors[lead.status] ?? Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _statusColors[lead.status] ?? Colors.grey,
                          child: Text(
                            lead.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(lead.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (lead.company.isNotEmpty)
                              Text('🏢 ${lead.company}'),
                            Text(
                                '📞 ${lead.phone.isNotEmpty ? lead.phone : 'No phone'}'),
                            Text(
                                '💰 ₹${lead.value.toStringAsFixed(0)} • ${lead.probability}%'),
                            if (lead.nextFollowUp != null)
                              Text(
                                  '📅 Follow-up: ${lead.nextFollowUp!.toString().substring(0, 10)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isStaff)
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    size: 20, color: Colors.indigo),
                                onPressed: () =>
                                    _showEditLeadDialog(context, lead),
                              ),
                            if (!isStaff)
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    size: 20, color: Colors.red),
                                onPressed: () =>
                                    _confirmDelete(context, lead.id, lead.name),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    _statusColors[lead.status] ?? Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                lead.status.toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showLeadDetails(context, lead),
                      ),
                    );
                  },
                ),
    );
  }

  // ============================================================
  // 🔥 SHOW ADD LEAD DIALOG (SIMPLIFIED)
  // ============================================================
  void _showAddLeadDialog(BuildContext context) {
    debugPrint('📝 Opening Add Lead dialog...');

    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController companyController = TextEditingController();
    final TextEditingController sourceController = TextEditingController();
    final TextEditingController valueController = TextEditingController();
    final TextEditingController probabilityController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    String selectedStatus = 'new';
    DateTime? selectedFollowUp;

    showDialog(
      context: context,
      builder: (ctx) {
        debugPrint('🔵 Dialog builder called');
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Add Lead'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name *'),
                      autofocus: true,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: companyController,
                      decoration: const InputDecoration(labelText: 'Company'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: sourceController,
                      decoration: const InputDecoration(labelText: 'Source'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: valueController,
                      decoration: const InputDecoration(
                          labelText: 'Expected Value (₹)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: probabilityController,
                      decoration:
                          const InputDecoration(labelText: 'Probability (%)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: _statuses.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          selectedStatus = value;
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Next Follow-up: ${selectedFollowUp != null ? selectedFollowUp!.toString().substring(0, 10) : 'Not set'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today, size: 20),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: dialogContext,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setDialogState(() {
                                selectedFollowUp = date;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                      maxLines: 2,
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
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                            content: Text('Please enter a name'),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }

                    final value =
                        double.tryParse(valueController.text.trim()) ?? 0.0;
                    final probability =
                        int.tryParse(probabilityController.text.trim()) ?? 0;

                    debugPrint('📤 Saving lead: $name, value: $value');

                    try {
                      await context.read<AppState>().addLead(
                            name: name,
                            phone: phoneController.text.trim(),
                            email: emailController.text.trim(),
                            company: companyController.text.trim(),
                            source: sourceController.text.trim(),
                            status: selectedStatus,
                            value: value,
                            probability: probability,
                            notes: notesController.text.trim(),
                            nextFollowUp: selectedFollowUp,
                          );
                      debugPrint('✅ Lead saved successfully!');
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                            content: Text('Lead added!'),
                            backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      debugPrint('❌ Error saving lead: $e');
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                            content: Text('❌ Error: $e'),
                            backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // DELETE CONFIRMATION
  // ============================================================
  void _confirmDelete(BuildContext context, String leadId, String leadName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Lead'),
        content: Text('Are you sure you want to delete "$leadName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context.read<AppState>().deleteLead(leadId);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Lead deleted!'),
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

  // ============================================================
  // EDIT LEAD DIALOG
  // ============================================================
  void _showEditLeadDialog(BuildContext context, Lead lead) {
    final TextEditingController nameController =
        TextEditingController(text: lead.name);
    final TextEditingController phoneController =
        TextEditingController(text: lead.phone);
    final TextEditingController emailController =
        TextEditingController(text: lead.email);
    final TextEditingController companyController =
        TextEditingController(text: lead.company);
    final TextEditingController sourceController =
        TextEditingController(text: lead.source);
    final TextEditingController valueController =
        TextEditingController(text: lead.value.toString());
    final TextEditingController probabilityController =
        TextEditingController(text: lead.probability.toString());
    final TextEditingController notesController =
        TextEditingController(text: lead.notes);
    String selectedStatus = lead.status;
    DateTime? selectedFollowUp = lead.nextFollowUp;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            title: const Text('Edit Lead'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name *')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: companyController,
                      decoration: const InputDecoration(labelText: 'Company')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: sourceController,
                      decoration: const InputDecoration(labelText: 'Source')),
                  const SizedBox(height: 8),
                  TextField(
                    controller: valueController,
                    decoration:
                        const InputDecoration(labelText: 'Expected Value (₹)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: probabilityController,
                    decoration:
                        const InputDecoration(labelText: 'Probability (%)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: _statuses.map((status) {
                      return DropdownMenuItem(
                          value: status, child: Text(status.toUpperCase()));
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) selectedStatus = value;
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Next Follow-up: ${selectedFollowUp != null ? selectedFollowUp!.toString().substring(0, 10) : 'Not set'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today, size: 20),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedFollowUp ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setDialogState(() {
                              selectedFollowUp = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                          content: Text('Please enter a name'),
                          backgroundColor: Colors.red),
                    );
                    return;
                  }
                  final updatedLead = Lead(
                    id: lead.id,
                    businessId: lead.businessId,
                    name: name,
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    company: companyController.text.trim(),
                    source: sourceController.text.trim(),
                    status: selectedStatus,
                    value: double.tryParse(valueController.text.trim()) ?? 0.0,
                    probability:
                        int.tryParse(probabilityController.text.trim()) ?? 0,
                    notes: notesController.text.trim(),
                    nextFollowUp: selectedFollowUp,
                    createdAt: lead.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  try {
                    await context.read<AppState>().updateLead(updatedLead);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                          content: Text('Lead updated!'),
                          backgroundColor: Colors.blue),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                          content: Text('❌ Error: $e'),
                          backgroundColor: Colors.red),
                    );
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // SHOW LEAD DETAILS
  // ============================================================
  void _showLeadDetails(BuildContext context, Lead lead) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lead.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lead.company.isNotEmpty) Text('🏢 Company: ${lead.company}'),
            if (lead.phone.isNotEmpty) Text('📞 Phone: ${lead.phone}'),
            if (lead.email.isNotEmpty) Text('📧 Email: ${lead.email}'),
            if (lead.source.isNotEmpty) Text('📥 Source: ${lead.source}'),
            Text('💰 Value: ₹${lead.value.toStringAsFixed(0)}'),
            Text('📊 Probability: ${lead.probability}%'),
            Text('📌 Status: ${lead.status.toUpperCase()}'),
            if (lead.nextFollowUp != null)
              Text(
                  '📅 Follow-up: ${lead.nextFollowUp!.toString().substring(0, 10)}'),
            if (lead.notes.isNotEmpty) Text('📝 Notes: ${lead.notes}'),
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
}
