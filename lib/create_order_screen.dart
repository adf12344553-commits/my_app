// lib/create_order_screen.dart – COMPLETE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'theme_service.dart'; // ✅ ADDED

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  String? _selectedProductId;
  String? _selectedCustomerId;
  String _selectedPayment = 'Cash';
  int _quantity = 1;
  final List<String> _paymentMethods = ['Cash', 'UPI', 'Card', 'Credit'];
  bool _isLoading = false;
  final TextEditingController _customerGstController = TextEditingController();

  @override
  void dispose() {
    _customerGstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final products = appState.products;
    final customers = appState.customers;

    final selectedProduct = products.firstWhere(
      (p) => p.id == _selectedProductId,
      orElse: () => Product(
        id: '',
        name: 'Select a product',
        price: 0,
        stock: 0,
        category: '',
        description: '',
        imageUrl: '',
        userId: '',
        hsnCode: '9980',
        gstRate: 18.0,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
        backgroundColor: ThemeService.getPrimaryColor(appState),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Product',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    value: _selectedProductId,
                    hint: const Text('Choose a product'),
                    items: products.isEmpty
                        ? [
                            const DropdownMenuItem(
                              value: null,
                              child:
                                  Text('No products available - add one first'),
                            )
                          ]
                        : products.map((product) {
                            return DropdownMenuItem(
                              value: product.id,
                              child: Text(
                                  '${product.name} (₹${product.price}) - Stock: ${product.stock}'),
                            );
                          }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedProductId = value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Show product details if selected
                  if (_selectedProductId != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Price per unit:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '₹${selectedProduct.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[800]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('GST Rate:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '${selectedProduct.gstRate}%',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700]),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('HSN Code:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                selectedProduct.hsnCode,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Customer dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Customer',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    value: _selectedCustomerId,
                    hint: const Text('Select or add customer'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Select Customer')),
                      ...customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer.id,
                          child: Text(customer.name),
                        );
                      }).toList(),
                      const DropdownMenuItem(
                          value: 'new', child: Text('+ Add New Customer')),
                    ],
                    onChanged: (value) {
                      if (value == 'new') {
                        _showAddCustomerDialog(context);
                      } else {
                        setState(() => _selectedCustomerId = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Customer GST
                  TextField(
                    controller: _customerGstController,
                    decoration: const InputDecoration(
                      labelText: 'Customer GSTIN (Optional)',
                      hintText: 'e.g. 22AAAAA0000A1Z5',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment method
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    value: _selectedPayment,
                    items: _paymentMethods.map((method) {
                      return DropdownMenuItem(
                          value: method, child: Text(method));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedPayment = value!);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Quantity
                  Row(
                    children: [
                      const Text('Quantity:', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                      ),
                      Text('$_quantity',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() => _quantity++);
                        },
                      ),
                      const Spacer(),
                      if (_selectedProductId != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total: ₹${(selectedProduct.price * _quantity).toStringAsFixed(0)}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[800]),
                            ),
                            Text(
                              'GST: ₹${(selectedProduct.price * _quantity * selectedProduct.gstRate / 100).toStringAsFixed(0)}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Create Order Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _selectedProductId != null &&
                              _selectedCustomerId != null
                          ? () async {
                              setState(() => _isLoading = true);
                              try {
                                final customerName = customers
                                    .firstWhere(
                                        (c) => c.id == _selectedCustomerId)
                                    .name;
                                await appState.addOrder(
                                  productId: _selectedProductId!,
                                  customerName: customerName,
                                  customerGst:
                                      _customerGstController.text.trim(),
                                  paymentMethod: _selectedPayment,
                                  quantity: _quantity,
                                );
                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Order created successfully!'),
                                        backgroundColor: Colors.green),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('❌ Error: $e'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 4)),
                                  );
                                }
                              }
                              if (mounted) setState(() => _isLoading = false);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeService.getPrimaryColor(appState),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('CREATE ORDER',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Customer Name *'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                try {
                  await context
                      .read<AppState>()
                      .addCustomer(name, phone: phoneController.text.trim());
                  if (mounted) Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Customer added!'),
                        backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('❌ Error: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter a name'),
                      backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
