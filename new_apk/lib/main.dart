// =============================================================
// lib/main.dart – PREMIUM FUTURISTIC EDITION
// ✅ Added import 'dart:ui' as ui; to fix ImageFilter
// All fixes included – Delete Product/Order working
// =============================================================

import 'dart:ui' as ui; // ✅ THIS FIXES THE ERROR

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
            theme: _buildPremiumTheme(appState),
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  // 🔥 Premium dark theme – ultra polished
  ThemeData _buildPremiumTheme(AppState appState) {
    final primaryColor = ThemeService.getPrimaryColor(appState);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: const Color(0xFF151B2B),
        background: const Color(0xFF080B14),
        onPrimary: Colors.white,
        onSurface: const Color(0xFFF8FAFC),
        onBackground: const Color(0xFFF8FAFC),
        error: const Color(0xFFEF4444),
      ),
      scaffoldBackgroundColor: const Color(0xFF080B14),
      cardTheme: CardThemeData(
        color: const Color(0xFF151B2B),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF8FAFC),
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF94A3B8)),
        actionsIconTheme: const IconThemeData(color: Color(0xFF94A3B8)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xFF94A3B8),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF8FAFC)),
        headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF8FAFC)),
        titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF8FAFC)),
        bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFF8FAFC)),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
        labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFF8FAFC)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF151B2B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1A2133),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        titleTextStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFF8FAFC)),
        contentTextStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),
    );
  }
}

// =============================================================
// SPLASH SCREEN – Futuristic glow
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
            // Glowing orbs
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
// MAIN SCREEN – Glassmorphism Bottom Nav
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
// DASHBOARD SCREEN – Premium KPI + Customer Totals
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final appState = Provider.of<AppState>(context);
    final userName = auth.userName ?? 'User';
    final role = appState.currentEmployee?.role ?? 'Owner';
    final customerTotals = _getCustomerTotals(appState);

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
                          'Good morning, $userName',
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

              // KPI Cards – Gradient background
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

              // Customer Totals
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

              // Business Overview
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
              const SizedBox(height: 20),

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
// PRODUCTS SCREEN – Glass Cards, Full CRUD
// =============================================================
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  void _confirmDeleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
            'Are you sure you want to delete "${product.name}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await context.read<AppState>().deleteProduct(product.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('✅ Product deleted!'),
                      backgroundColor: Colors.green),
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('❌ ${e.toString()}'),
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
    final products = appState.products;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Products'),
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
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProductDialog(context),
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
            : products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_rounded,
                            size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        const Text('No products yet',
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
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  product.imageUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 64,
                                    height: 64,
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.image,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFFF8FAFC),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product.category} • GST: ${product.gstRate}% • HSN: ${product.hsnCode}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF94A3B8)),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          '₹${product.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF6D5DFB),
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: product.stock > 10
                                                ? Colors.green
                                                : product.stock > 0
                                                    ? Colors.orange
                                                    : Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            product.stock > 10
                                                ? 'In Stock'
                                                : product.stock > 0
                                                    ? 'Low Stock'
                                                    : 'Out of Stock',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Stock: ${product.stock}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF94A3B8)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue, size: 22),
                                    onPressed: () => _showEditProductDialog(
                                        context, product),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red, size: 22),
                                    onPressed: () =>
                                        _confirmDeleteProduct(context, product),
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

  // ----- Add/Edit Dialogs (Glass style) -----
  void _showAddProductDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController stockController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController gstController =
        TextEditingController(text: '18');
    final TextEditingController hsnController =
        TextEditingController(text: '9980');

    showDialog(
      context: context,
      builder: (ctx) => _glassDialog(
        title: 'Add Product',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInput(nameController, 'Product Name *'),
            _buildInput(priceController, 'Price *', TextInputType.number),
            _buildInput(stockController, 'Stock *', TextInputType.number),
            _buildInput(categoryController, 'Category'),
            _buildInput(gstController, 'GST Rate % *', TextInputType.number),
            _buildInput(hsnController, 'HSN Code'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0;
              final stock = int.tryParse(stockController.text.trim()) ?? 0;
              final gst = double.tryParse(gstController.text.trim()) ?? 18;
              final hsn = hsnController.text.trim().isEmpty
                  ? '9980'
                  : hsnController.text.trim();

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
                      'https://via.placeholder.com/150/6D5DFB/FFFFFF?text=Product',
                  userId: '',
                  hsnCode: hsn,
                  gstRate: gst,
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('✅ Product added!'),
                      backgroundColor: Colors.green),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('❌ ${e.toString()}'),
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

  void _showEditProductDialog(BuildContext context, Product product) {
    final TextEditingController nameController =
        TextEditingController(text: product.name);
    final TextEditingController priceController =
        TextEditingController(text: product.price.toString());
    final TextEditingController stockController =
        TextEditingController(text: product.stock.toString());
    final TextEditingController categoryController =
        TextEditingController(text: product.category);
    final TextEditingController gstController =
        TextEditingController(text: product.gstRate.toString());
    final TextEditingController hsnController =
        TextEditingController(text: product.hsnCode);

    showDialog(
      context: context,
      builder: (ctx) => _glassDialog(
        title: 'Edit Product',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInput(nameController, 'Product Name *'),
            _buildInput(priceController, 'Price *', TextInputType.number),
            _buildInput(stockController, 'Stock *', TextInputType.number),
            _buildInput(categoryController, 'Category'),
            _buildInput(gstController, 'GST Rate % *', TextInputType.number),
            _buildInput(hsnController, 'HSN Code'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0;
              final stock = int.tryParse(stockController.text.trim()) ?? 0;
              final gst = double.tryParse(gstController.text.trim()) ?? 18;
              final hsn = hsnController.text.trim().isEmpty
                  ? '9980'
                  : hsnController.text.trim();

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
                await appState.updateProduct(Product(
                  id: product.id,
                  name: name,
                  price: price,
                  stock: stock,
                  category: categoryController.text.trim(),
                  description: product.description,
                  imageUrl: product.imageUrl,
                  userId: product.userId,
                  hsnCode: hsn,
                  gstRate: gst,
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('✅ Product updated!'),
                      backgroundColor: Colors.blue),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('❌ ${e.toString()}'),
                      backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label,
      [TextInputType? type]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Color(0xFFF8FAFC)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  // Glass dialog helper
  Widget _glassDialog(
      {required String title,
      required Widget content,
      required List<Widget> actions}) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A2133).withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 40,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF8FAFC)),
                  ),
                  const SizedBox(height: 16),
                  content,
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// ORDER LIST SCREEN – Glass Cards, Full CRUD
// =============================================================
class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  void _confirmDeleteOrder(
      BuildContext context, String orderId, String productName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text(
          'Are you sure you want to delete the order for "$productName"?\n\n⚠️ Stock will be restored automatically.',
        ),
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
                    content: Text('✅ Order deleted! Stock restored.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('❌ ${e.toString()}'),
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Orders'),
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
            : orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_rounded,
                            size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        const Text('No orders yet',
                            style: TextStyle(color: Color(0xFF94A3B8))),
                        const SizedBox(height: 8),
                        const Text('Tap the + button to create one',
                            style: TextStyle(color: Color(0xFF64748B))),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                        top: 100, left: 16, right: 16, bottom: 16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.amber.shade800,
                                    radius: 22,
                                    child: Text(
                                      order.productName[0],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.productName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFFF8FAFC)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Customer: ${order.customerName} • ${order.paymentMethod}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF94A3B8)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${order.grandTotal.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6D5DFB),
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: order.paymentMethod == 'Cash' ||
                                              order.paymentMethod == 'UPI'
                                          ? Colors.green
                                          : Colors.orange,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      order.paymentMethod,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'GST: ₹${order.totalGst.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Color(0xFF94A3B8)),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Qty: ${order.quantity}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Color(0xFF94A3B8)),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.receipt,
                                        color: Colors.blue, size: 22),
                                    onPressed: () {
                                      if (appState.settings != null) {
                                        PdfService.generateInvoice(
                                            order, appState.settings!);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Business settings not loaded.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.credit_card,
                                        color: Colors.green, size: 22),
                                    onPressed: () {
                                      if (appState.settings != null) {
                                        PdfService.generateReceipt(
                                            order, appState.settings!);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Business settings not loaded.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red, size: 22),
                                    onPressed: () => _confirmDeleteOrder(
                                        context, order.id, order.productName),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Setup Your Business'),
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
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.storefront_rounded,
                  size: 64, color: Color(0xFF6D5DFB)),
              const SizedBox(height: 16),
              const Text(
                'Welcome to BusinessOS!',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF8FAFC)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please set up your business profile to continue.',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 32),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text('❌ $_errorMessage',
                      style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              _buildSetupInput(_nameController, 'Business Name *', Icons.store),
              const SizedBox(height: 16),
              _buildSetupInput(_ownerController, 'Owner Name *', Icons.person),
              const SizedBox(height: 16),
              _buildSetupInput(_phoneController, 'Phone Number', Icons.phone,
                  TextInputType.phone),
              const SizedBox(height: 16),
              _buildSetupInput(_upiController, 'UPI ID (e.g., business@upi)',
                  Icons.payments),
              const SizedBox(height: 16),
              _buildSetupInput(_addressController, 'Address', Icons.location_on,
                  TextInputType.text, 2),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveBusiness,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D5DFB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
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

  Widget _buildSetupInput(
      TextEditingController controller, String label, IconData icon,
      [TextInputType? type, int lines = 1]) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: lines,
      style: const TextStyle(color: Color(0xFFF8FAFC)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        prefixIcon: Icon(icon, color: Color(0xFF94A3B8)),
        border: const OutlineInputBorder(),
        isDense: true,
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

      final business = await appState.businessService.createBusiness(
        name: name,
        ownerName: ownerName,
        phone: _phoneController.text.trim(),
        email: auth.user?.email,
        address: _addressController.text.trim(),
        upiId: _upiController.text.trim(),
      );

      if (business != null) {
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
