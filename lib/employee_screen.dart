// lib/employee_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final List<String> _roles = ['owner', 'manager', 'staff'];
  final Map<String, Color> _roleColors = {
    'owner': Colors.amber,
    'manager': Colors.blue,
    'staff': Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final employees = appState.employees;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEmployeeDialog(context),
          ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : employees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No employees yet',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Text('Tap the + button to add staff',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[400])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    final emp = employees[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _roleColors[emp.role] ?? Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _roleColors[emp.role] ?? Colors.grey,
                          child: Text(
                            emp.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(emp.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (emp.email.isNotEmpty) Text('📧 ${emp.email}'),
                            if (emp.phone.isNotEmpty) Text('📞 ${emp.phone}'),
                            Text('🔑 Role: ${emp.role.toUpperCase()}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.teal),
                              onPressed: () =>
                                  _showEditEmployeeDialog(context, emp),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Employee'),
                                    content: Text(
                                        'Are you sure you want to delete ${emp.name}?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await context
                                              .read<AppState>()
                                              .deleteEmployee(emp.id);
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('Employee deleted!'),
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

  void _showAddEmployeeDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    String selectedRole = 'staff';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Employee'),
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
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                      value: role, child: Text(role.toUpperCase()));
                }).toList(),
                onChanged: (value) => selectedRole = value!,
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
              await context.read<AppState>().addEmployee(
                    name: name,
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    role: selectedRole,
                  );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Employee added!'),
                    backgroundColor: Colors.green),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditEmployeeDialog(BuildContext context, Employee employee) {
    final TextEditingController nameController =
        TextEditingController(text: employee.name);
    final TextEditingController phoneController =
        TextEditingController(text: employee.phone);
    final TextEditingController emailController =
        TextEditingController(text: employee.email);
    String selectedRole = employee.role;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Employee'),
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
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                      value: role, child: Text(role.toUpperCase()));
                }).toList(),
                onChanged: (value) => selectedRole = value!,
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
              final updated = Employee(
                id: employee.id,
                businessId: employee.businessId,
                name: name,
                phone: phoneController.text.trim(),
                email: emailController.text.trim(),
                role: selectedRole,
                permissions: employee.permissions,
                createdAt: employee.createdAt,
                updatedAt: DateTime.now(),
              );
              await context.read<AppState>().updateEmployee(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Employee updated!'),
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
