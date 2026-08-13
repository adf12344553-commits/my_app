import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';
import 'app_state.dart';
import 'create_order_screen.dart';
import 'credit_management_screen.dart';
import 'pdf_service.dart';
import 'ai_assistant_screen.dart';
import 'lead_screen.dart';
import 'employee_screen.dart';
import 'rule_screen.dart';
import 'profile_screen.dart';
import 'theme_service.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://qrmaypsrauywxnrzmpyi.supabase.co',
    anonKey: 'sb_publishable_nrq2FPX4ZP5e2eLR63qHvw_Nogslo61',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) => AppState(context.read<AuthProvider>()),
        ),
      ],
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'BusinessOS',
            theme: ThemeService.getTheme(
              appState.settings?.primaryColor ?? '#FFB300',
            ),
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

// =============================================================
// SPLASH SCREEN
// =============================================================
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              'Loading BusinessOS...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// MAIN SCREEN – 9 TABS (CORRECT ORDER)
// =============================================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ProductsScreen(),
    OrderListScreen(),
    CreditManagementScreen(),
    LeadScreen(),
    AIAssistantScreen(),
    EmployeeScreen(),
    RuleScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final primaryColor = ThemeService.getPrimaryColor(appState);

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.inventory_2_rounded), label: 'Products'),
          NavigationDestination(
              icon: Icon(Icons.receipt_rounded), label: 'Orders'),
          NavigationDestination(
              icon: Icon(Icons.payments_rounded), label: 'Udhār'),
          NavigationDestination(
              icon: Icon(Icons.people_rounded), label: 'Leads'),
          NavigationDestination(
              icon: Icon(Icons.auto_awesome_rounded), label: 'AI'),
          NavigationDestination(
              icon: Icon(Icons.person_add_alt_1_rounded), label: 'Staff'),
          NavigationDestination(icon: Icon(Icons.rule_rounded), label: 'Rules'),
          NavigationDestination(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
        backgroundColor: Colors.white,
        indicatorColor: primaryColor,
        elevation: 0,
      ),
    );
  }
}

// =============================================================
// BUSINESS SETUP SCREEN
// =============================================================
class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Business'),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.storefront, size: 64, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                'Welcome to BusinessOS!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please set up your business profile to continue.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    '❌ $_errorMessage',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ownerController,
                decoration: const InputDecoration(
                  labelText: 'Owner Name *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _upiController,
                decoration: const InputDecoration(
                  labelText: 'UPI ID (e.g., business@upi)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.payments),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveBusiness,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'CREATE BUSINESS',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveBusiness() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final appState = context.read<AppState>();
    final auth = context.read<AuthProvider>();

    try {
      final name = _nameController.text.trim();
      final ownerName = _ownerController.text.trim();

      if (name.isEmpty || ownerName.isEmpty) {
        setState(() {
          _errorMessage = 'Business Name and Owner Name are required';
          _isLoading = false;
        });
        return;
      }

      debugPrint('📝 Creating business: $name');
      final business = await appState.businessService.createBusiness(
        name: name,
        ownerName: ownerName,
        phone: _phoneController.text.trim(),
        email: auth.user?.email,
        address: _addressController.text.trim(),
        upiId: _upiController.text.trim(),
      );

      if (business != null) {
        debugPrint('✅ Business created: ${business['id']}');
        await appState.initialize();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Business created successfully!'),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to create business. Check terminal logs.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Business creation error: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5)),
      );
    }
    if (mounted) setState(() => _isLoading = false);
  }
}

// =============================================================
// DASHBOARD SCREEN
// =============================================================
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final appState = Provider.of<AppState>(context);
    final userName = auth.userName ?? 'User';
    final role = appState.currentEmployee?.role ?? 'Owner';
    final primaryColor = ThemeService.getPrimaryColor(appState);

    if (appState.businessId == null && !appState.isLoading) {
      return const BusinessSetupScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $userName! ($role)',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Here is your business at a glance.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              children: [
                _metricCard(
                    'Revenue (Net)',
                    '₹${appState.totalRevenue.toStringAsFixed(0)}',
                    Icons.trending_up,
                    Colors.green),
                _metricCard(
                    'GST Collected',
                    '₹${appState.totalGstCollected.toStringAsFixed(0)}',
                    Icons.receipt,
                    Colors.orange),
                _metricCard('Customers', '${appState.customers.length}',
                    Icons.people, Colors.blue),
                _metricCard(
                    'Orders',
                    '${appState.totalOrders.toStringAsFixed(0)}',
                    Icons.receipt_long,
                    Colors.purple),
                _metricCard(
                    '💰 Pipeline',
                    '₹${appState.pipelineValue.toStringAsFixed(0)}',
                    Icons.timeline,
                    Colors.indigo),
                _metricCard('🏆 Won Leads', '${appState.wonLeads}',
                    Icons.emoji_events, Colors.amber),
                _metricCard('👥 Staff', '${appState.employees.length}',
                    Icons.person_add_alt_1, Colors.teal),
                _metricCard('⚡ Rules', '${appState.rules.length}',
                    Icons.rule_rounded, Colors.deepPurple),
                _metricCard(
                    '💰 Recovery Potential',
                    '₹${(appState.totalOutstanding * 0.4 + appState.overdueCount * 50000).toStringAsFixed(0)}',
                    Icons.currency_rupee,
                    Colors.green.shade800),
                _metricCard('🚨 Overdue Defaulters', '${appState.overdueCount}',
                    Icons.warning_amber_rounded, Colors.red.shade700),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'finance_btn',
            onPressed: () async {
              try {
                await PdfService.generateFinancialSummary(appState);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: Colors.red),
                );
              }
            },
            icon: const Icon(Icons.assessment),
            label: const Text('Finance'),
            backgroundColor: Colors.purple,
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'report_btn',
            onPressed: () async {
              try {
                await PdfService.generateCollectionReport(appState);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('❌ Error: $e'),
                      backgroundColor: Colors.red),
                );
              }
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Report'),
            backgroundColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// PRODUCTS SCREEN
// =============================================================
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final products = appState.products;
    final primaryColor = ThemeService.getPrimaryColor(appState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_rounded,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No products yet',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Text('Tap the + button to add your first product',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[400])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 50,
                              height: 50,
                              color: Colors.amber[100],
                              child:
                                  Icon(Icons.image, color: Colors.amber[700]),
                            ),
                          ),
                        ),
                        title: Text(product.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${product.category} • Stock: ${product.stock}'),
                        trailing: Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailScreen(product: product)),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController stockController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: 'Product Name *')),
              const SizedBox(height: 8),
              TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price *'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock *'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0;
              final stock = int.tryParse(stockController.text.trim()) ?? 0;

              if (name.isEmpty || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please enter a valid name and price'),
                      backgroundColor: Colors.red),
                );
                return;
              }

              try {
                final appState = context.read<AppState>();
                await appState.addProduct(Product(
                  id: '',
                  name: name,
                  price: price,
                  stock: stock,
                  category: categoryController.text.trim(),
                  description: '',
                  imageUrl:
                      'https://via.placeholder.com/150/FFA500/000000?text=Product',
                  userId: '',
                  hsnCode: '9980',
                  gstRate: 18.0,
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Product added!'),
                      backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error adding product: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
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
}

// =============================================================
// PRODUCT DETAIL SCREEN
// =============================================================
class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final primaryColor = ThemeService.getPrimaryColor(appState);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  product.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.amber[100],
                    child:
                        Icon(Icons.image, size: 64, color: Colors.amber[700]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(product.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Category: ${product.category}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Price: ₹${product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber)),
            const SizedBox(height: 8),
            Text('Stock: ${product.stock} units',
                style: TextStyle(
                    fontSize: 16,
                    color: product.stock > 0 ? Colors.green : Colors.red)),
            const SizedBox(height: 16),
            const Text('Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(product.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Edit product coming soon!')),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      appState.deleteProduct(product.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Product deleted!')),
                      );
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style:
                        OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// ORDER LIST SCREEN
// =============================================================
class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  void _confirmDeleteOrder(
      BuildContext context, String orderId, String productName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Order'),
        content:
            Text('Are you sure you want to delete order for "$productName"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await context.read<AppState>().deleteOrder(orderId);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Order deleted!'),
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

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final orders = appState.orders;
    final primaryColor = ThemeService.getPrimaryColor(appState);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
              );
            },
          ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No orders yet',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Text('Tap the + button to create one',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[400])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.amber[100],
                          child: Text(
                            order.productName[0],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber),
                          ),
                        ),
                        title: Text(order.productName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${order.customerName} • ${order.paymentMethod} • ${order.date.toString().substring(0, 10)} • GST: ₹${order.totalGst.toStringAsFixed(0)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.receipt, color: Colors.blue),
                              onPressed: () {
                                if (appState.settings != null) {
                                  PdfService.generateInvoice(
                                      order, appState.settings!);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Business settings not loaded.'),
                                        backgroundColor: Colors.red),
                                  );
                                }
                              },
                              tooltip: 'Invoice',
                            ),
                            IconButton(
                              icon: const Icon(Icons.credit_card,
                                  color: Colors.green),
                              onPressed: () {
                                if (appState.settings != null) {
                                  PdfService.generateReceipt(
                                      order, appState.settings!);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Business settings not loaded.'),
                                        backgroundColor: Colors.red),
                                  );
                                }
                              },
                              tooltip: 'Receipt',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteOrder(
                                  context, order.id, order.productName),
                            ),
                          ],
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Order ${order.id.substring(0, 8)} – Total: ₹${order.grandTotal.toStringAsFixed(0)}'),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
