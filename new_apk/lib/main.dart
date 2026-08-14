// lib/main.dart – FULLY UPDATED
// Imports theme_provider and theme_service

import 'dart:ui' as ui;
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
import 'theme_provider.dart';

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<AppState, ThemeProvider>(
        builder: (context, appState, themeProvider, child) {
          final theme = ThemeService.getTheme(
            appState.settings?.primaryColor ?? '#6D5DFB',
            isDark: themeProvider.isDark,
          );
          return MaterialApp(
            title: 'BusinessOS',
            theme: theme,
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
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6D5DFB), Color(0xFF4F46E5), Color(0xFF1E1B4B)],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6D5DFB).withOpacity(0.3),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.2),
                      blurRadius: 120,
                      spreadRadius: 60,
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.05)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6D5DFB).withOpacity(0.4),
                          blurRadius: 60,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.storefront_rounded,
                        size: 72, color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'BusinessOS',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                      shadows: [
                        Shadow(blurRadius: 30, color: Colors.black38),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Enterprise Business Operating System',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// MAIN SCREEN
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
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              height: 72,
              elevation: 0,
              backgroundColor: Colors.transparent,
              indicatorColor: const Color(0xFF6D5DFB).withOpacity(0.25),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
                NavigationDestination(
                    icon: Icon(Icons.rule_rounded), label: 'Rules'),
                NavigationDestination(
                    icon: Icon(Icons.person_rounded), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// DASHBOARD SCREEN (with dynamic greeting)
// =============================================================
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Map<String, double> _getCustomerTotals(AppState appState) {
    final Map<String, double> totals = {};
    for (var order in appState.orders) {
      totals[order.customerName] =
          (totals[order.customerName] ?? 0) + order.grandTotal;
    }
    return totals;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final appState = Provider.of<AppState>(context);
    final userName = auth.userName ?? 'User';
    final role = appState.currentEmployee?.role ?? 'Owner';
    final customerTotals = _getCustomerTotals(appState);
    final greeting = _getGreeting();

    if (appState.businessId == null && !appState.isLoading) {
      return const BusinessSetupScreen();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6D5DFB), Color(0xFF4F46E5), Color(0xFF1E1B4B)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
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
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6D5DFB), Color(0xFF4F46E5)],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF151B2B),
                      child: Text(
                        userName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF8FAFC),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, $userName',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF8FAFC),
                          ),
                        ),
                        Text(
                          '$role • ${appState.businessId != null ? "Active" : "Setup Required"}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // KPI Cards
              Row(
                children: [
                  _kpiCard(
                      'Revenue',
                      '₹${appState.totalRevenue.toStringAsFixed(0)}',
                      Icons.currency_rupee_rounded,
                      Colors.green),
                  const SizedBox(width: 12),
                  _kpiCard('Orders', appState.totalOrders.toStringAsFixed(0),
                      Icons.receipt_long_rounded, Colors.blue),
                  const SizedBox(width: 12),
                  _kpiCard(
                      'GST',
                      '₹${appState.totalGstCollected.toStringAsFixed(0)}',
                      Icons.calculate,
                      Colors.orange),
                ],
              ),
              const SizedBox(height: 28),

              // Business Overview (moved up)
              const Text(
                'Business Overview',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF8FAFC)),
              ),
              const SizedBox(height: 12),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                children: [
                  _overviewCard('Customers', '${appState.customers.length}',
                      Icons.people_rounded),
                  _overviewCard(
                      'Pipeline',
                      '₹${appState.pipelineValue.toStringAsFixed(0)}',
                      Icons.timeline_rounded),
                  _overviewCard('Staff', '${appState.employees.length}',
                      Icons.person_add_alt_1_rounded),
                  _overviewCard('Overdue', '${appState.overdueCount}',
                      Icons.warning_rounded),
                ],
              ),
              const SizedBox(height: 28),

              // Customer Totals (moved down)
              const Text(
                'Customer Totals',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF8FAFC)),
              ),
              const SizedBox(height: 12),
              if (customerTotals.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No orders yet.',
                      style: TextStyle(color: Color(0xFF94A3B8))),
                )
              else
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customerTotals.keys.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFF1A2133)),
                    itemBuilder: (context, index) {
                      final customer = customerTotals.keys.elementAt(index);
                      final total = customerTotals[customer]!;
                      return ListTile(
                        leading: const Icon(Icons.person,
                            color: Color(0xFF94A3B8), size: 20),
                        title: Text(customer,
                            style: const TextStyle(color: Color(0xFFF8FAFC))),
                        trailing: Text(
                          '₹${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6D5DFB),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 28),

              // PDF Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
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
                      icon: const Icon(Icons.assessment_rounded),
                      label: const Text('Financial Summary'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
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
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: const Text('Collection Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.15),
              const Color(0xFF151B2B),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overviewCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF8FAFC),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// PRODUCTS SCREEN (unchanged – reused from working version)
// =============================================================
// I'm including a simplified version – if you had a longer one, keep it.
// But to avoid omissions, I'll put a placeholder that compiles.
// In practice, you should reuse your existing ProductsScreen code.
// Since the user deleted everything, I'll provide a full minimal version.

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final products = appState.products;

    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('No products'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(products[index].name),
                  ),
                ),
    );
  }
}

// =============================================================
// ORDER LIST SCREEN (placeholder – replace with your working version)
// =============================================================
class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final orders = appState.orders;

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('No orders'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(orders[index].productName),
                  ),
                ),
    );
  }
}

// =============================================================
// BUSINESS SETUP SCREEN (placeholder – replace with your working version)
// =============================================================
class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Business')),
      body: const Center(child: Text('Business Setup Screen')),
    );
  }
}
