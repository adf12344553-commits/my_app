// lib/app_state.dart – FULLY UPDATED (with negative stock prevention, stock restore, and error handling)
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';
import 'business_service.dart';

// ============================================================
// MODELS (unchanged)
// ============================================================

class Customer {
  final String id;
  final String businessId;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String type;

  Customer({
    required this.id,
    required this.businessId,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.city = '',
    this.type = 'regular',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'city': city,
        'type': type,
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'],
        businessId: json['business_id'],
        name: json['name'],
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        address: json['address'] ?? '',
        city: json['city'] ?? '',
        type: json['type'] ?? 'regular',
      );
}

class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String category;
  final String description;
  final String imageUrl;
  final String userId;
  final String hsnCode;
  final double gstRate;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.userId,
    this.hsnCode = '9980',
    this.gstRate = 18.0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
        'category': category,
        'description': description,
        'image_url': imageUrl,
        'user_id': userId,
        'hsn_code': hsnCode,
        'gst_rate': gstRate,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        price: (json['selling_price'] ?? json['price'] ?? 0).toDouble(),
        stock: json['stock'] ?? 0,
        category: json['category'] ?? '',
        description: json['description'] ?? '',
        imageUrl: json['image_url'] ?? '',
        userId: json['business_id'] ?? json['user_id'] ?? '',
        hsnCode: json['hsn_code'] ?? '9980',
        gstRate: (json['gst_rate'] ?? 18.0).toDouble(),
      );
}

class Order {
  final String id;
  final String productName;
  final double price;
  final int quantity;
  final String customerName;
  final String customerGst;
  final String paymentMethod;
  final DateTime date;
  final String userId;
  final double gstRate;
  final String hsnCode;

  Order({
    required this.id,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.customerName,
    this.customerGst = '',
    required this.paymentMethod,
    required this.date,
    required this.userId,
    this.gstRate = 18.0,
    this.hsnCode = '9980',
  });

  double get taxableValue => price * quantity;
  double get cgst => taxableValue * (gstRate / 200);
  double get sgst => taxableValue * (gstRate / 200);
  double get totalGst => cgst + sgst;
  double get grandTotal => taxableValue + totalGst;
  double get total => grandTotal;

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_name': productName,
        'price': price,
        'quantity': quantity,
        'customer_name': customerName,
        'customer_gst': customerGst,
        'payment_method': paymentMethod,
        'created_at': date.toIso8601String(),
        'user_id': userId,
        'gst_rate': gstRate,
        'hsn_code': hsnCode,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        productName: json['product_name'] ?? json['customer_name'] ?? 'Order',
        price: (json['total_amount'] ?? json['price'] ?? 0).toDouble(),
        quantity: json['quantity'] ?? 1,
        customerName: json['customer_name'] ?? 'Customer',
        customerGst: json['customer_gst'] ?? '',
        paymentMethod: json['payment_method'] ?? 'Cash',
        date: DateTime.parse(json['created_at']),
        userId: json['business_id'] ?? json['user_id'] ?? '',
        gstRate: (json['gst_rate'] ?? 18.0).toDouble(),
        hsnCode: json['hsn_code'] ?? '9980',
      );
}

class Debtor {
  final String id;
  final String name;
  final String phone;
  final String shopName;
  final double outstanding;
  final DateTime dueDate;
  final String userId;

  Debtor({
    required this.id,
    required this.name,
    required this.phone,
    required this.shopName,
    required this.outstanding,
    required this.dueDate,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'shop_name': shopName,
        'outstanding': outstanding,
        'due_date': dueDate.toIso8601String().substring(0, 10),
        'user_id': userId,
      };

  factory Debtor.fromJson(Map<String, dynamic> json) => Debtor(
        id: json['id'],
        name: json['name'],
        phone: json['phone'] ?? '',
        shopName: json['shop_name'] ?? '',
        outstanding: (json['outstanding'] as num).toDouble(),
        dueDate: DateTime.parse(json['due_date']),
        userId: json['business_id'] ?? json['user_id'] ?? '',
      );
}

class BusinessSettings {
  final String id;
  final String userId;
  final String businessName;
  final String ownerName;
  final String phone;
  final String upiId;
  final String address;
  final String logoUrl;
  final String primaryColor;

  BusinessSettings({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.ownerName,
    required this.phone,
    required this.upiId,
    required this.address,
    this.logoUrl = '',
    this.primaryColor = '#FFB300',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'business_name': businessName,
        'owner_name': ownerName,
        'phone': phone,
        'upi_id': upiId,
        'address': address,
        'logo_url': logoUrl,
        'primary_color': primaryColor,
      };

  factory BusinessSettings.fromJson(Map<String, dynamic> json) =>
      BusinessSettings(
        id: json['id'],
        userId: json['user_id'] ?? json['business_id'] ?? '',
        businessName: json['business_name'] ?? json['name'] ?? '',
        ownerName: json['owner_name'] ?? '',
        phone: json['phone'] ?? '',
        upiId: json['upi_id'] ?? '',
        address: json['address'] ?? '',
        logoUrl: json['logo_url'] ?? '',
        primaryColor: json['primary_color'] ?? '#FFB300',
      );
}

class Lead {
  final String id;
  final String businessId;
  final String name;
  final String phone;
  final String email;
  final String company;
  final String source;
  final String status;
  final double value;
  final int probability;
  final String? assignedTo;
  final String notes;
  final DateTime? nextFollowUp;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lead({
    required this.id,
    required this.businessId,
    required this.name,
    this.phone = '',
    this.email = '',
    this.company = '',
    this.source = '',
    this.status = 'new',
    this.value = 0.0,
    this.probability = 0,
    this.assignedTo,
    this.notes = '',
    this.nextFollowUp,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'name': name,
        'phone': phone,
        'email': email,
        'company': company,
        'source': source,
        'status': status,
        'value': value,
        'probability': probability,
        'assigned_to': assignedTo,
        'notes': notes,
        'next_follow_up': nextFollowUp?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
        id: json['id'],
        businessId: json['business_id'],
        name: json['name'],
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        company: json['company'] ?? '',
        source: json['source'] ?? '',
        status: json['status'] ?? 'new',
        value: (json['value'] as num?)?.toDouble() ?? 0.0,
        probability: json['probability'] ?? 0,
        assignedTo: json['assigned_to'],
        notes: json['notes'] ?? '',
        nextFollowUp: json['next_follow_up'] != null
            ? DateTime.parse(json['next_follow_up'])
            : null,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );
}

class Employee {
  final String id;
  final String businessId;
  final String name;
  final String phone;
  final String email;
  final String role;
  final Map<String, dynamic> permissions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Employee({
    required this.id,
    required this.businessId,
    required this.name,
    this.phone = '',
    this.email = '',
    this.role = 'staff',
    this.permissions = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
        'permissions': permissions,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'],
        businessId: json['business_id'],
        name: json['name'],
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        role: json['role'] ?? 'staff',
        permissions: json['permissions'] ?? {},
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );
}

class Rule {
  final String id;
  final String businessId;
  final String name;
  final String triggerType;
  final Map<String, dynamic> conditions;
  final Map<String, dynamic> actions;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  Rule({
    required this.id,
    required this.businessId,
    required this.name,
    required this.triggerType,
    required this.conditions,
    required this.actions,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'business_id': businessId,
        'name': name,
        'trigger_type': triggerType,
        'conditions': conditions,
        'actions': actions,
        'enabled': enabled,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Rule.fromJson(Map<String, dynamic> json) => Rule(
        id: json['id'],
        businessId: json['business_id'],
        name: json['name'],
        triggerType: json['trigger_type'],
        conditions: json['conditions'] ?? {},
        actions: json['actions'] ?? {},
        enabled: json['enabled'] ?? true,
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );
}

// ============================================================
// APP STATE – FULLY UPDATED
// ============================================================
class AppState extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AuthProvider _auth;
  final BusinessService businessService = BusinessService();

  String? _businessId;
  List<Customer> _customers = [];
  List<Product> _products = [];
  List<Order> _orders = [];
  List<Debtor> _debtors = [];
  List<Lead> _leads = [];
  List<Employee> _employees = [];
  List<Rule> _rules = [];
  BusinessSettings? _settings;
  Employee? _currentEmployee;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isSeeding = false;
  bool _initializing = false;

  // Getters
  String? get businessId => _businessId;
  List<Customer> get customers => _customers;
  List<Product> get products => _products;
  List<Order> get orders => _orders;
  List<Debtor> get debtors => _debtors;
  List<Lead> get leads => _leads;
  List<Employee> get employees => _employees;
  List<Rule> get rules => _rules;
  BusinessSettings? get settings => _settings;
  Employee? get currentEmployee => _currentEmployee;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Role helpers
  bool get isOwner => _currentEmployee?.role == 'owner';
  bool get isManager => _currentEmployee?.role == 'manager' || isOwner;
  bool get isStaff => _currentEmployee?.role == 'staff' && !isManager;
  bool hasPermission(String permission) =>
      isOwner || (_currentEmployee?.permissions[permission] ?? false);

  // Metrics
  double get totalRevenue => _orders.fold(0, (sum, o) => sum + o.taxableValue);
  double get totalGstCollected => _orders.fold(0, (sum, o) => sum + o.totalGst);
  double get totalOrders => _orders.length.toDouble();
  double get totalOutstanding =>
      _debtors.fold(0, (sum, d) => sum + d.outstanding);
  int get overdueCount =>
      _debtors.where((d) => d.dueDate.isBefore(DateTime.now())).length;
  double get pipelineValue => _leads.fold(0.0, (sum, l) => sum + l.value);
  int get wonLeads => _leads.where((l) => l.status == 'won').length;
  int get lostLeads => _leads.where((l) => l.status == 'lost').length;

  AppState(this._auth) {
    _auth.addListener(_onAuthChanged);
    if (_auth.isLoggedIn) initialize();
  }

  void _onAuthChanged() {
    if (_auth.isLoggedIn)
      initialize();
    else
      _clearData();
  }

  Future<void> initialize() async {
    if (_initializing || _isInitialized || !_auth.isLoggedIn) return;
    _initializing = true;
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🔍 Initializing AppState...');
      await Future.delayed(const Duration(milliseconds: 300));
      await _auth.refreshUser();
      _businessId = await businessService.getCurrentBusinessId();
      debugPrint('📦 Business ID: $_businessId');

      if (_businessId == null) {
        debugPrint('🏢 Creating new business...');
        final biz = await businessService.createBusiness(
          name: 'My Business',
          ownerName: _auth.userName ?? 'Owner',
          phone: '',
          email: _auth.user?.email,
        );
        _businessId = biz?['id'] as String?;
        debugPrint('✅ Business created: $_businessId');
      }

      if (_businessId != null) {
        debugPrint('📊 Loading data for business: $_businessId');
        await Future.wait([
          loadCustomers(),
          loadProducts(),
          loadOrders(),
          loadDebtors(),
          loadLeads(),
          loadEmployees(),
          loadRules(),
          loadSettings(),
          _loadCurrentEmployee(),
        ]);
        debugPrint(
            '📦 Products: ${_products.length}, Debtors: ${_debtors.length}, Leads: ${_leads.length}');
        if (_products.isEmpty && _debtors.isEmpty) {
          debugPrint('🔥 Seeding beast data...');
          await _seedBeastData();
          await Future.wait([
            loadProducts(),
            loadDebtors(),
            loadLeads(),
            loadEmployees(),
            loadRules()
          ]);
          await _loadCurrentEmployee();
        }
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('❌ Initialize ERROR: $e');
    }
    _isLoading = false;
    _initializing = false;
    notifyListeners();
  }

  Future<void> _loadCurrentEmployee() async {
    if (_businessId == null || _auth.user == null) return;
    try {
      final response = await _supabase
          .from('employees')
          .select()
          .eq('business_id', _businessId!)
          .eq('email', _auth.user!.email!)
          .maybeSingle();
      if (response != null) {
        _currentEmployee = Employee.fromJson(response);
        debugPrint(
            '👤 Current employee: ${_currentEmployee?.name} (${_currentEmployee?.role})');
      } else {
        _currentEmployee = null;
      }
    } catch (e) {
      debugPrint('❌ loadCurrentEmployee error: $e');
    }
  }

  Future<void> _seedBeastData() async {
    if (_businessId == null || _isSeeding) return;
    _isSeeding = true;
    try {
      final now = DateTime.now();

      final productList = [
        {
          'name': 'Premium Basmati Rice (50kg)',
          'selling_price': 2200,
          'stock': 150,
          'category': 'Grocery',
          'description': 'High quality long grain rice',
          'image_url':
              'https://via.placeholder.com/150/FFA500/000000?text=Rice',
          'hsn_code': '1006',
          'gst_rate': 5.0
        },
        {
          'name': 'TMT Steel Bars (Fe-500)',
          'selling_price': 58000,
          'stock': 45,
          'category': 'Construction',
          'description': '12mm & 16mm rods',
          'image_url':
              'https://via.placeholder.com/150/FFA500/000000?text=Steel',
          'hsn_code': '7214',
          'gst_rate': 18.0
        },
        {
          'name': 'Premium Wheat Flour (50kg)',
          'selling_price': 1600,
          'stock': 200,
          'category': 'Grocery',
          'description': 'Chakki fresh atta',
          'image_url':
              'https://via.placeholder.com/150/FFA500/000000?text=Flour',
          'hsn_code': '1101',
          'gst_rate': 5.0
        },
        {
          'name': 'Cement Bag (OPC 53 Grade)',
          'selling_price': 380,
          'stock': 500,
          'category': 'Construction',
          'description': 'Birla Super Cement',
          'image_url':
              'https://via.placeholder.com/150/FFA500/000000?text=Cement',
          'hsn_code': '2523',
          'gst_rate': 28.0
        },
        {
          'name': 'Mustard Oil (15L Tin)',
          'selling_price': 2100,
          'stock': 80,
          'category': 'Grocery',
          'description': 'Pure Kachi Ghani',
          'image_url': 'https://via.placeholder.com/150/FFA500/000000?text=Oil',
          'hsn_code': '1514',
          'gst_rate': 5.0
        },
      ];
      for (var p in productList) {
        await _supabase.from('products').insert({
          ...p,
          'business_id': _businessId!,
        });
      }

      final debtorList = [
        {
          'name': 'Rajesh Traders',
          'phone': '9876543210',
          'shop_name': 'Rajesh Kirana',
          'outstanding': 450000,
          'due_date': now
              .add(const Duration(days: 5))
              .toIso8601String()
              .substring(0, 10)
        },
        {
          'name': 'Vikram Steel House',
          'phone': '9876543211',
          'shop_name': 'Vikram Steels',
          'outstanding': 1250000,
          'due_date': now
              .subtract(const Duration(days: 10))
              .toIso8601String()
              .substring(0, 10)
        },
        {
          'name': 'Priya Enterprises',
          'phone': '9876543212',
          'shop_name': 'Priya Construction',
          'outstanding': 750000,
          'due_date': now
              .add(const Duration(days: 15))
              .toIso8601String()
              .substring(0, 10)
        },
        {
          'name': 'Amit Grocery Mart',
          'phone': '9876543213',
          'shop_name': 'Amit Mart',
          'outstanding': 180000,
          'due_date': now
              .subtract(const Duration(days: 3))
              .toIso8601String()
              .substring(0, 10)
        },
        {
          'name': 'Sunil Cement Agency',
          'phone': '9876543214',
          'shop_name': 'Sunil Cement',
          'outstanding': 920000,
          'due_date': now
              .add(const Duration(days: 2))
              .toIso8601String()
              .substring(0, 10)
        },
      ];
      for (var d in debtorList) {
        await _supabase.from('debtors').insert({
          ...d,
          'business_id': _businessId!,
        });
      }

      final leadList = [
        {
          'name': 'Mohan Steel Traders',
          'phone': '9876543220',
          'company': 'Mohan Steels',
          'source': 'Referral',
          'status': 'qualified',
          'value': 1200000,
          'probability': 70
        },
        {
          'name': 'Neha Fashion House',
          'phone': '9876543221',
          'company': 'Neha Textiles',
          'source': 'Website',
          'status': 'new',
          'value': 350000,
          'probability': 40
        },
        {
          'name': 'Ram Construction Co.',
          'phone': '9876543222',
          'company': 'Ram Builders',
          'source': 'Cold Call',
          'status': 'meeting',
          'value': 2500000,
          'probability': 60
        },
        {
          'name': 'Sharma Electronics',
          'phone': '9876543223',
          'company': 'Sharma E-Shop',
          'source': 'Referral',
          'status': 'negotiation',
          'value': 800000,
          'probability': 85
        },
        {
          'name': 'Ravi Auto Parts',
          'phone': '9876543224',
          'company': 'Ravi Motors',
          'source': 'Instagram',
          'status': 'won',
          'value': 150000,
          'probability': 100
        },
      ];
      for (var l in leadList) {
        await _supabase.from('leads').insert({
          'business_id': _businessId!,
          'name': l['name'],
          'phone': l['phone'],
          'company': l['company'],
          'source': l['source'],
          'status': l['status'],
          'value': l['value'],
          'probability': l['probability'],
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
      }

      final employeeList = [
        {
          'name': 'Rahul Sharma',
          'phone': '9876543301',
          'email': 'rahul@business.com',
          'role': 'manager'
        },
        {
          'name': 'Priya Singh',
          'phone': '9876543302',
          'email': 'priya@business.com',
          'role': 'staff'
        },
        {
          'name': 'Amit Verma',
          'phone': '9876543303',
          'email': 'amit@business.com',
          'role': 'staff'
        },
      ];
      for (var e in employeeList) {
        await _supabase.from('employees').insert({
          'business_id': _businessId!,
          'name': e['name'],
          'phone': e['phone'],
          'email': e['email'],
          'role': e['role'],
          'permissions': {},
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
      }

      final ruleList = [
        {
          'name': 'Overdue Invoice Reminder',
          'trigger_type': 'order_created',
          'conditions': {'status': 'pending'},
          'actions': {
            'type': 'send_reminder',
            'message': 'Payment reminder sent'
          },
          'enabled': true
        },
        {
          'name': 'High Value Lead Alert',
          'trigger_type': 'lead_created',
          'conditions': {
            'value': {'gt': 1000000}
          },
          'actions': {'type': 'notify_manager'},
          'enabled': true
        },
      ];
      for (var r in ruleList) {
        await _supabase.from('rules').insert({
          'business_id': _businessId!,
          'name': r['name'],
          'trigger_type': r['trigger_type'],
          'conditions': r['conditions'],
          'actions': r['actions'],
          'enabled': r['enabled'],
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
      }

      final user = _auth.user;
      if (user != null) {
        final existing = await _supabase
            .from('employees')
            .select()
            .eq('business_id', _businessId!)
            .eq('email', user.email!)
            .maybeSingle();
        if (existing == null) {
          await _supabase.from('employees').insert({
            'business_id': _businessId!,
            'name': _auth.userName ?? 'Owner',
            'phone': '',
            'email': user.email,
            'role': 'owner',
            'permissions': {},
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          });
        }
      }

      debugPrint('🔥 Beast data seeded');
    } catch (e) {
      debugPrint('❌ Seed error: $e');
    }
    _isSeeding = false;
  }

  void _clearData() {
    _businessId = null;
    _customers.clear();
    _products.clear();
    _orders.clear();
    _debtors.clear();
    _leads.clear();
    _employees.clear();
    _rules.clear();
    _settings = null;
    _currentEmployee = null;
    _isInitialized = false;
    _isSeeding = false;
    notifyListeners();
  }

  // ============================================================
  // CUSTOMERS
  // ============================================================
  Future<void> loadCustomers() async {
    if (_businessId == null) return;
    try {
      final response = await _supabase
          .from('customers')
          .select()
          .eq('business_id', _businessId!)
          .order('name');
      _customers =
          (response as List).map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ loadCustomers error: $e');
    }
  }

  Future<void> addCustomer(String name,
      {String phone = '', String email = '', String address = ''}) async {
    if (_businessId == null) throw Exception('Business not initialized.');
    try {
      await _supabase.from('customers').insert({
        'business_id': _businessId!,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
      });
      await loadCustomers();
    } catch (e) {
      debugPrint('❌ addCustomer error: $e');
      rethrow;
    }
  }

  // ============================================================
  // PRODUCTS
  // ============================================================
  Future<void> loadProducts() async {
    if (_businessId == null) return;
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('business_id', _businessId!)
          .order('name');
      _products =
          (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ loadProducts error: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    if (_businessId == null) throw Exception('Business not initialized.');
    try {
      await _supabase.from('products').insert({
        'business_id': _businessId!,
        'name': product.name,
        'selling_price': product.price,
        'stock': product.stock,
        'category': product.category,
        'description': product.description,
        'image_url': product.imageUrl,
        'hsn_code': product.hsnCode ?? '9980',
        'gst_rate': product.gstRate ?? 18.0,
      });
      await loadProducts();
    } catch (e) {
      debugPrint('❌ addProduct error: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    if (_businessId == null) return;
    try {
      await _supabase
          .from('products')
          .delete()
          .eq('id', id)
          .eq('business_id', _businessId!);
      await loadProducts();
    } catch (e) {
      debugPrint('❌ deleteProduct error: $e');
    }
  }

  // ============================================================
  // 🔥 ORDERS – WITH NEGATIVE STOCK PREVENTION
  // ============================================================
  Future<void> loadOrders() async {
    if (_businessId == null) return;
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('business_id', _businessId!)
          .order('created_at', ascending: false);
      _orders = (response as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ loadOrders error: $e');
    }
  }

  // 🔥🔥 UPDATED: Prevents negative stock
  Future<void> addOrder({
    required String productId,
    required String customerName,
    String customerGst = '',
    required String paymentMethod,
    required int quantity,
  }) async {
    if (_businessId == null) throw Exception('Business not initialized.');

    try {
      // Load the latest product data (to ensure we have current stock)
      await loadProducts();
      final product = _products.firstWhere((p) => p.id == productId);

      // 🔥🔥 CHECK: Is there enough stock?
      if (product.stock < quantity) {
        throw Exception(
            '❌ Insufficient stock. Only ${product.stock} units available.');
      }

      final taxable = product.price * quantity;
      final cgst = taxable * (product.gstRate / 200);
      final sgst = taxable * (product.gstRate / 200);
      final grandTotal = taxable + cgst + sgst;

      final orderData = {
        'business_id': _businessId!,
        'customer_name': customerName,
        'customer_gst': customerGst,
        'total_amount': taxable,
        'grand_total': grandTotal,
        'paid_amount': grandTotal,
        'payment_method': paymentMethod,
        'payment_status': 'paid',
        'status': 'completed',
        'gst_rate': product.gstRate,
        'hsn_code': product.hsnCode,
        'created_at': DateTime.now().toIso8601String(),
      };

      final orderResponse =
          await _supabase.from('orders').insert(orderData).select().single();
      final orderId = orderResponse['id'];

      await _supabase.from('order_items').insert({
        'order_id': orderId,
        'product_id': productId,
        'product_name': product.name,
        'quantity': quantity,
        'price': product.price,
        'total': taxable,
      });

      // 🔥 Deduct stock (only after confirming stock > quantity)
      final newStock = product.stock - quantity;
      await _supabase
          .from('products')
          .update({'stock': newStock})
          .eq('id', productId)
          .eq('business_id', _businessId!);

      // Reload products to update the UI
      await loadProducts();
      await loadOrders();
      await checkRulesForTrigger('order_created',
          context: {'order': orderData});
    } catch (e) {
      debugPrint('❌ addOrder error: $e');
      rethrow;
    }
  }

  // 🔥 NEW: Delete Order with Stock Restore
  Future<void> deleteOrder(String id) async {
    if (_businessId == null) return;
    try {
      // Get the order details first (so we know what stock to restore)
      final order = _orders.firstWhere((o) => o.id == id);

      // Find the product
      await loadProducts();
      final product = _products.firstWhere((p) => p.name == order.productName);

      // Restore stock
      await _supabase
          .from('products')
          .update({'stock': product.stock + order.quantity})
          .eq('id', product.id)
          .eq('business_id', _businessId!);

      // Delete the order
      await _supabase
          .from('orders')
          .delete()
          .eq('id', id)
          .eq('business_id', _businessId!);

      await loadProducts();
      await loadOrders();
    } catch (e) {
      debugPrint('❌ deleteOrder error: $e');
      rethrow;
    }
  }

  // ============================================================
  // DEBTORS
  // ============================================================
  Future<void> loadDebtors() async {
    if (_businessId == null) return;
    try {
      final response = await _supabase
          .from('debtors')
          .select()
          .eq('business_id', _businessId!)
          .order('due_date', ascending: true);
      _debtors =
          (response as List).map((json) => Debtor.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ loadDebtors error: $e');
    }
  }

  Future<void> addDebtor({
    required String name,
    required String phone,
    required String shopName,
    required double outstanding,
    required DateTime dueDate,
  }) async {
    if (_businessId == null) throw Exception('Business not initialized.');
    try {
      await _supabase.from('debtors').insert({
        'business_id': _businessId!,
        'name': name,
        'phone': phone,
        'shop_name': shopName,
        'outstanding': outstanding,
        'due_date': dueDate.toIso8601String().substring(0, 10),
      });
      await loadDebtors();
    } catch (e) {
      debugPrint('❌ addDebtor error: $e');
      rethrow;
    }
  }

  Future<void> updateDebtor(Debtor debtor) async {
    if (_businessId == null) return;
    try {
      await _supabase
          .from('debtors')
          .update({
            'name': debtor.name,
            'phone': debtor.phone,
            'shop_name': debtor.shopName,
            'outstanding': debtor.outstanding,
            'due_date': debtor.dueDate.toIso8601String().substring(0, 10),
          })
          .eq('id', debtor.id)
          .eq('business_id', _businessId!);
      await loadDebtors();
    } catch (e) {
      debugPrint('❌ updateDebtor error: $e');
    }
  }

  Future<void> deleteDebtor(String id) async {
    if (_businessId == null) return;
    try {
      await _supabase
          .from('debtors')
          .delete()
          .eq('id', id)
          .eq('business_id', _businessId!);
      await loadDebtors();
    } catch (e) {
      debugPrint('❌ deleteDebtor error: $e');
      rethrow;
    }
  }

  // ============================================================
  // LEADS
  // ============================================================
  Future<void> loadLeads() async {
    if (_businessId == null) return;
    try {
      final response = await _supabase
          .from('leads')
          .select()
          .eq('business_id', _businessId!)
          .order('created_at', ascending: false);
      _leads = (response as List).map((json) => Lead.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ loadLeads error: $e');
    }
  }

  Future<void> addLead({
    required String name,
    String phone = '',
    String email = '',
    String company = '',
    String source = '',
    String status = 'new',
    double value = 0.0,
    int probability = 0,
    String notes = '',
    DateTime? nextFollowUp,
  }) async {
    if (_businessId == null) {
      debugPrint('❌ addLead: businessId is null!');
      throw Exception(
          'Business not initialized. Please create a business first.');
    }
    try {
      final now = DateTime.now().toIso8601String();
      await _supabase.from('leads').insert({
        'business_id': _businessId!,
        'name': name,
        'phone': phone,
        'email': email,
        'company': company,
        'source': source,
        'status': status,
        'value': value,
        'probability': probability,
        'notes': notes,
        'next_follow_up': nextFollowUp?.toIso8601String(),
        'created_at': now,
        'updated_at': now,
      });
      await loadLeads();
      await checkRulesForTrigger('lead_created', context: {'lead': name});
    } catch (e) {
      debugPrint('❌ addLead ERROR: $e');
      rethrow;
    }
  }

  Future<void> updateLead(Lead lead) async {
    if (_businessId == null) return;
    try {
      final now = DateTime.now().toIso8601String();
      await _supabase
          .from('leads')
          .update({
            'name': lead.name,
            'phone': lead.phone,
            'email': lead.email,
            'company': lead.company,
            'source': lead.source,
            'status': lead.status,
            'value': lead.value,
            'probability': lead.probability,
            'notes': lead.notes,
            'next_follow_up': lead.nextFollowUp?.toIso8601String(),
            'updated_at': now,
          })
          .eq('id', lead.id)
          .eq('business_id', _businessId!);
      await loadLeads();
    } catch (e) {
      debugPrint('❌ updateLead error: $e');
    }
  }

  Future<void> deleteLead(String id) async {
    if (_businessId == null) return;
    try {
      await _supabase
          .from('leads')
          .delete()
          .eq('id', id)
          .eq('business_id', _businessId!);
      await loadLeads();
    } catch (e) {
      debugPrint('❌ deleteLead error: $e');
      rethrow;
    }
  }

  // ============================================================
  // EMPLOYEES
  // ============================================================
  Future<void> loadEmployees() async {
    if (_businessId == null) return;
    try {
      final response = await _supabase
          .from('employees')
          .select()
          .eq('business_id', _businessId!)
          .order('created_at', ascending: false);
      _employees =
          (response as List).map((json) => Employee.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ loadEmployees error: $e');
    }
  }

  Future<void> addEmployee({
    required String name,
    String phone = '',
    String email = '',
    String role = 'staff',
    Map<String, dynamic> permissions = const {},
  }) async {
    if (_businessId == null) throw Exception('Business not initialized.');
    try {
      final now = DateTime.now().toIso8601String();
      await _supabase.from('employees').insert({
        'business_id': _businessId!,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
        'permissions': permissions,
        'created_at': now,
        'updated_at': now,
      });
      await loadEmployees();
    } catch (e) {
      debugPrint('❌ addEmployee error: $e');
      rethrow;
    }
  }

  Future<void> updateEmployee(Employee employee) async {
    if (_businessId == null) return;
    try {
      final now = DateTime.now().toIso8601String();
      await _supabase
          .from('employees')
          .update({
            'name': employee.name,
            'phone': employee.phone,
            'email': employee.email,
            'role': employee.role,
            'permissions': employee.permissions,
            'updated_at': now,
          })
          .eq('id', employee.id)
          .eq('business_id', _businessId!);
      await loadEmployees();
    } catch (e) {
      debugPrint('❌ updateEmployee error: $e');
    }
  }

  Future<void> deleteEmployee(String id) async {
    if (_businessId == null) return;
    try {
      await _supabase
          .from('employees')
          .delete()
          .eq('id', id)
          .eq('business_id', _businessId!);
      await loadEmployees();
    } catch (e) {
      debugPrint('❌ deleteEmployee error: $e');
    }
  }

  // ============================================================
  // RULES
  // ============================================================
  Future<void> loadRules() async {
    if (_businessId == null) return;
    try {
      final response = await _supabase
          .from('rules')
          .select()
          .eq('business_id', _businessId!)
          .order('created_at', ascending: false);
      _rules = (response as List).map((json) => Rule.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ loadRules error: $e');
    }
  }

  Future<void> addRule({
    required String name,
    required String triggerType,
    required Map<String, dynamic> conditions,
    required Map<String, dynamic> actions,
    bool enabled = true,
  }) async {
    if (_businessId == null) throw Exception('Business not initialized.');
    try {
      final now = DateTime.now().toIso8601String();
      await _supabase.from('rules').insert({
        'business_id': _businessId!,
        'name': name,
        'trigger_type': triggerType,
        'conditions': conditions,
        'actions': actions,
        'enabled': enabled,
        'created_at': now,
        'updated_at': now,
      });
      await loadRules();
    } catch (e) {
      debugPrint('❌ addRule error: $e');
      rethrow;
    }
  }

  Future<void> updateRule(Rule rule) async {
    if (_businessId == null) return;
    try {
      final now = DateTime.now().toIso8601String();
      await _supabase
          .from('rules')
          .update({
            'name': rule.name,
            'trigger_type': rule.triggerType,
            'conditions': rule.conditions,
            'actions': rule.actions,
            'enabled': rule.enabled,
            'updated_at': now,
          })
          .eq('id', rule.id)
          .eq('business_id', _businessId!);
      await loadRules();
    } catch (e) {
      debugPrint('❌ updateRule error: $e');
    }
  }

  Future<void> deleteRule(String id) async {
    if (_businessId == null) return;
    try {
      await _supabase
          .from('rules')
          .delete()
          .eq('id', id)
          .eq('business_id', _businessId!);
      await loadRules();
    } catch (e) {
      debugPrint('❌ deleteRule error: $e');
    }
  }

  // ============================================================
  // RULE EXECUTION
  // ============================================================
  Future<void> checkRulesForTrigger(String triggerType,
      {dynamic context}) async {
    final matchingRules =
        _rules.where((r) => r.triggerType == triggerType && r.enabled).toList();
    for (var rule in matchingRules) {
      debugPrint('⚡ Rule "${rule.name}" triggered!');
      final action = rule.actions;
      if (action['type'] == 'send_reminder') {
        debugPrint('📱 Sending reminder: ${action['message']}');
      } else if (action['type'] == 'notify_manager') {
        debugPrint('📢 Notifying manager about high-value lead');
      }
    }
  }

  // ============================================================
  // SETTINGS
  // ============================================================
  Future<void> loadSettings() async {
    if (_businessId == null) return;
    try {
      final response = await _supabase
          .from('businesses')
          .select()
          .eq('id', _businessId!)
          .single();
      _settings = BusinessSettings(
        id: response['id'],
        userId: response['id'],
        businessName: response['name'] ?? '',
        ownerName: response['owner_name'] ?? '',
        phone: response['phone'] ?? '',
        upiId: response['upi_id'] ?? '',
        address: response['address'] ?? '',
        logoUrl: response['logo_url'] ?? '',
        primaryColor: response['primary_color'] ?? '#FFB300',
      );
    } catch (e) {
      debugPrint('❌ loadSettings error: $e');
    }
  }

  Future<void> updateSettings(BusinessSettings newSettings) async {
    if (_businessId == null) return;
    try {
      await _supabase.from('businesses').update({
        'name': newSettings.businessName,
        'owner_name': newSettings.ownerName,
        'phone': newSettings.phone,
        'upi_id': newSettings.upiId,
        'address': newSettings.address,
        'logo_url': newSettings.logoUrl,
        'primary_color': newSettings.primaryColor,
      }).eq('id', _businessId!);
      _settings = newSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ updateSettings error: $e');
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
