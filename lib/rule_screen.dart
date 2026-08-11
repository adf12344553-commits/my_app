// lib/rule_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class RuleScreen extends StatefulWidget {
  const RuleScreen({super.key});

  @override
  State<RuleScreen> createState() => _RuleScreenState();
}

class _RuleScreenState extends State<RuleScreen> {
  final List<String> _triggerTypes = [
    'order_created',
    'lead_created',
    'debtor_overdue'
  ];
  final List<String> _actionTypes = ['send_reminder', 'notify_manager', 'log'];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final rules = appState.rules;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Automation Rules'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddRuleDialog(context),
          ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : rules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rule, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No rules yet',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Text(
                          'Create automation rules (e.g., "if invoice overdue, send reminder")',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[400])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    final rule = rules[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: rule.enabled ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          rule.enabled
                              ? Icons.check_circle
                              : Icons.pause_circle,
                          color: rule.enabled ? Colors.green : Colors.grey,
                        ),
                        title: Text(rule.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Trigger: ${rule.triggerType}'),
                            Text('Actions: ${rule.actions['type'] ?? 'None'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                rule.enabled ? Icons.pause : Icons.play_arrow,
                                color:
                                    rule.enabled ? Colors.orange : Colors.green,
                              ),
                              onPressed: () {
                                final updated = Rule(
                                  id: rule.id,
                                  businessId: rule.businessId,
                                  name: rule.name,
                                  triggerType: rule.triggerType,
                                  conditions: rule.conditions,
                                  actions: rule.actions,
                                  enabled: !rule.enabled,
                                  createdAt: rule.createdAt,
                                  updatedAt: DateTime.now(),
                                );
                                context.read<AppState>().updateRule(updated);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _showEditRuleDialog(context, rule),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Rule'),
                                    content: Text('Delete "${rule.name}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<AppState>()
                                              .deleteRule(rule.id);
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text('Rule deleted'),
                                                backgroundColor: Colors.red),
                                          );
                                        },
                                        child: const Text('Delete',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddRuleDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    String selectedTrigger = _triggerTypes.first;
    String selectedAction = _actionTypes.first;
    final TextEditingController conditionKeyController =
        TextEditingController();
    final TextEditingController conditionValueController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Rule'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Rule Name *')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedTrigger,
                decoration: const InputDecoration(labelText: 'Trigger'),
                items: _triggerTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => selectedTrigger = v!,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedAction,
                decoration: const InputDecoration(labelText: 'Action'),
                items: _actionTypes
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) => selectedAction = v!,
              ),
              const SizedBox(height: 8),
              TextField(
                  controller: conditionKeyController,
                  decoration: const InputDecoration(
                      labelText: 'Condition Key (e.g., status)')),
              TextField(
                  controller: conditionValueController,
                  decoration: const InputDecoration(
                      labelText: 'Condition Value (e.g., pending)')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter a name'),
                      backgroundColor: Colors.red),
                );
                return;
              }
              final conditions = {
                conditionKeyController.text.trim():
                    conditionValueController.text.trim()
              };
              final actions = {'type': selectedAction};
              await context.read<AppState>().addRule(
                    name: name,
                    triggerType: selectedTrigger,
                    conditions: conditions,
                    actions: actions,
                    enabled: true,
                  );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Rule added!'),
                    backgroundColor: Colors.green),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditRuleDialog(BuildContext context, Rule rule) {
    final TextEditingController nameController =
        TextEditingController(text: rule.name);
    String selectedTrigger = rule.triggerType;
    String selectedAction = rule.actions['type'] ?? _actionTypes.first;
    // For simplicity, we don't edit conditions fully here; you can expand.

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Rule'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Rule Name *')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedTrigger,
                decoration: const InputDecoration(labelText: 'Trigger'),
                items: _triggerTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => selectedTrigger = v!,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedAction,
                decoration: const InputDecoration(labelText: 'Action'),
                items: _actionTypes
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) => selectedAction = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter a name'),
                      backgroundColor: Colors.red),
                );
                return;
              }
              final updated = Rule(
                id: rule.id,
                businessId: rule.businessId,
                name: name,
                triggerType: selectedTrigger,
                conditions: rule.conditions,
                actions: {'type': selectedAction},
                enabled: rule.enabled,
                createdAt: rule.createdAt,
                updatedAt: DateTime.now(),
              );
              await context.read<AppState>().updateRule(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Rule updated!'),
                    backgroundColor: Colors.blue),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
