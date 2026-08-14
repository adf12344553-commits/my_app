class SearchResult {
  final String type;
  final String id;
  final String title;
  final String subtitle;
  final Map<String, dynamic> data;

  const SearchResult({
    required this.type,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.data,
  });
}

class GlobalSearchService {
  static List<SearchResult> search({
    required String query,
    List<Map<String, dynamic>> customers = const [],
    List<Map<String, dynamic>> leads = const [],
    List<Map<String, dynamic>> products = const [],
    List<Map<String, dynamic>> orders = const [],
    List<Map<String, dynamic>> debtors = const [],
  }) {
    final text = query.trim().toLowerCase();

    if (text.isEmpty) {
      return [];
    }

    final results = <SearchResult>[];

    // Customers
    for (final customer in customers) {
      if (_matches(customer, text)) {
        results.add(
          SearchResult(
            type: 'Customer',
            id: _id(customer),
            title: _firstText(
              customer,
              ['name', 'customer_name', 'full_name'],
              'Customer',
            ),
            subtitle: _firstText(
              customer,
              ['phone', 'mobile', 'email'],
              '',
            ),
            data: customer,
          ),
        );
      }
    }

    // Leads
    for (final lead in leads) {
      if (_matches(lead, text)) {
        results.add(
          SearchResult(
            type: 'Lead',
            id: _id(lead),
            title: _firstText(
              lead,
              ['name', 'lead_name', 'full_name', 'company_name'],
              'Lead',
            ),
            subtitle: _firstText(
              lead,
              ['phone', 'mobile', 'email', 'status'],
              '',
            ),
            data: lead,
          ),
        );
      }
    }

    // Products
    for (final product in products) {
      if (_matches(product, text)) {
        results.add(
          SearchResult(
            type: 'Product',
            id: _id(product),
            title: _firstText(
              product,
              ['name', 'product_name', 'title'],
              'Product',
            ),
            subtitle: _firstText(
              product,
              ['sku', 'code', 'category'],
              '',
            ),
            data: product,
          ),
        );
      }
    }

    // Orders
    for (final order in orders) {
      if (_matches(order, text)) {
        results.add(
          SearchResult(
            type: 'Order',
            id: _id(order),
            title: _firstText(
              order,
              ['order_number', 'order_no', 'name', 'id'],
              'Order',
            ),
            subtitle: _firstText(
              order,
              ['status', 'customer_name', 'total'],
              '',
            ),
            data: order,
          ),
        );
      }
    }

    // Debtors
    for (final debtor in debtors) {
      if (_matches(debtor, text)) {
        results.add(
          SearchResult(
            type: 'Debtor',
            id: _id(debtor),
            title: _firstText(
              debtor,
              ['name', 'customer_name', 'full_name'],
              'Debtor',
            ),
            subtitle: _firstText(
              debtor,
              ['phone', 'mobile', 'amount', 'balance'],
              '',
            ),
            data: debtor,
          ),
        );
      }
    }

    return results;
  }

  static bool _matches(
    Map<String, dynamic> item,
    String query,
  ) {
    for (final value in item.values) {
      if (value == null) {
        continue;
      }

      if (value.toString().toLowerCase().contains(query)) {
        return true;
      }
    }

    return false;
  }

  static String _id(Map<String, dynamic> item) {
    final value = item['id'];

    if (value == null) {
      return '';
    }

    return value.toString();
  }

  static String _firstText(
    Map<String, dynamic> item,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = item[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }
}
