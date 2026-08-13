// lib/ai_service.dart – Pure Mock AI (No Gemini, No API)
import 'app_state.dart';

class AIService {
  // ============================================================
  // 🧠 CONVERSATION MEMORY
  // ============================================================
  static final List<Map<String, String>> _conversationHistory = [];
  static const int _maxHistory = 10;

  // ============================================================
  // 🔥 MAIN ENTRY POINT
  // ============================================================
  static Future<String> processQuery(String query, AppState appState) async {
    // Add user query to history
    _addToHistory('user', query);

    // Try smart actions
    final actionResult = _tryAction(query, appState);
    if (actionResult != null) {
      _addToHistory('assistant', actionResult);
      return actionResult;
    }

    // Generate smart response
    final response = _generateResponse(query, appState);
    _addToHistory('assistant', response);
    return response;
  }

  // ============================================================
  // 🧠 SMART ACTIONS
  // ============================================================
  static String? _tryAction(String query, AppState appState) {
    final lower = query.toLowerCase();

    if (lower.contains('create') && lower.contains('follow-up')) {
      final nameMatch =
          RegExp(r'(?:for|with)\s+([A-Za-z\s]+)').firstMatch(query);
      if (nameMatch != null) {
        final name = nameMatch.group(1)!.trim();
        return '✅ Follow-up created for $name! (Simulation)';
      }
      return '✅ Follow-up task created! (Simulation)';
    }

    if (lower.contains('remind') &&
        (lower.contains('defaulter') || lower.contains('overdue'))) {
      final overdue = appState.debtors
          .where((d) => d.dueDate.isBefore(DateTime.now()))
          .toList();
      if (overdue.isEmpty) return '🎉 No overdue debtors. Great job!';
      final top = overdue.first;
      return '✅ Reminder sent to ${top.name} (${top.phone}) about ₹${top.outstanding.toStringAsFixed(0)}. (Simulation)';
    }

    if (lower.contains('summary') || lower.contains('overview')) {
      return _generateSummary(appState);
    }

    return null;
  }

  // ============================================================
  // 📊 SUMMARY GENERATOR
  // ============================================================
  static String _generateSummary(AppState appState) {
    final buffer = StringBuffer();
    buffer.writeln('📊 *BUSINESS SUMMARY*');
    buffer.writeln('━'.padRight(30, '━'));
    buffer.writeln('💰 Revenue: ₹${appState.totalRevenue.toStringAsFixed(0)}');
    buffer.writeln(
        '🧾 GST Collected: ₹${appState.totalGstCollected.toStringAsFixed(0)}');
    buffer.writeln('📦 Orders: ${appState.totalOrders}');
    buffer.writeln('👥 Customers: ${appState.customers.length}');
    buffer.writeln('━'.padRight(30, '━'));
    buffer.writeln('📒 *Udhār / Credit*');
    buffer.writeln(
        '   Total Outstanding: ₹${appState.totalOutstanding.toStringAsFixed(0)}');
    buffer.writeln('   Overdue Defaulters: ${appState.overdueCount}');
    if (appState.debtors.isNotEmpty) {
      final top = appState.debtors.first;
      buffer.writeln(
          '   Highest: ${top.name} (₹${top.outstanding.toStringAsFixed(0)})');
    }
    buffer.writeln('━'.padRight(30, '━'));
    buffer.writeln('🎯 *Sales Pipeline*');
    buffer.writeln(
        '   Pipeline Value: ₹${appState.pipelineValue.toStringAsFixed(0)}');
    buffer.writeln('   Won Leads: ${appState.wonLeads}');
    buffer.writeln('   Lost Leads: ${appState.lostLeads}');
    buffer.writeln('━'.padRight(30, '━'));
    buffer.writeln('👨‍💼 *Team*');
    buffer.writeln('   Staff: ${appState.employees.length}');
    buffer.writeln(
        '   Active Rules: ${appState.rules.where((r) => r.enabled).length}');
    buffer.writeln('━'.padRight(30, '━'));
    if (appState.overdueCount > 2) {
      buffer.writeln(
          '💡 *Recommendation*: ${appState.overdueCount} overdue defaulters. Call them today!');
    }
    if (appState.leads.where((l) => l.status == 'negotiation').isNotEmpty) {
      buffer.writeln(
          '💡 *Opportunity*: ${appState.leads.where((l) => l.status == 'negotiation').length} leads in negotiation. Follow up!');
    }
    return buffer.toString();
  }

  // ============================================================
  // 🔮 PREDICTIONS
  // ============================================================
  static String _getPrediction(AppState appState) {
    final buffer = StringBuffer();
    buffer.writeln('🔮 *AI Recommendations*');
    if (appState.overdueCount > 0) {
      buffer.writeln(
          '⚠️ You have ${appState.overdueCount} overdue defaulters. Send reminders today.');
      final top = appState.debtors.firstWhere(
          (d) => d.dueDate.isBefore(DateTime.now()),
          orElse: () => appState.debtors.first);
      buffer.writeln(
          '   Priority: Call ${top.name} (₹${top.outstanding.toStringAsFixed(0)})');
    }
    if (appState.leads.where((l) => l.status == 'new').length > 0) {
      buffer.writeln(
          '📌 You have ${appState.leads.where((l) => l.status == 'new').length} new leads. Contact them!');
    }
    if (appState.products.where((p) => p.stock < 10).length > 0) {
      buffer.writeln(
          '📦 Low stock alert: ${appState.products.where((p) => p.stock < 10).length} products below 10 units.');
    }
    if (buffer.toString() == '🔮 *AI Recommendations*\n') {
      return '🔮 Everything looks great! Keep up the good work. 🎉';
    }
    return buffer.toString();
  }

  // ============================================================
  // 🧩 SMART RESPONSE GENERATOR
  // ============================================================
  static String _generateResponse(String query, AppState appState) {
    final lower = query.toLowerCase();

    if (lower.contains('summary') || lower.contains('overview')) {
      return _generateSummary(appState);
    }
    if (lower.contains('predict') ||
        lower.contains('recommend') ||
        lower.contains('suggest')) {
      return _getPrediction(appState);
    }
    if (lower.contains('overdue') || lower.contains('udhar')) {
      final overdue = appState.debtors
          .where((d) => d.dueDate.isBefore(DateTime.now()))
          .toList();
      if (overdue.isEmpty) return '🎉 No overdue debtors. Great job!';
      final total = overdue.fold(0.0, (sum, d) => sum + d.outstanding);
      return '🚨 You have ${overdue.length} overdue debtors totaling ₹${total.toStringAsFixed(0)}.\nTop defaulters:\n${overdue.take(3).map((d) => '  • ${d.name}: ₹${d.outstanding.toStringAsFixed(0)}').join('\n')}';
    }
    if (lower.contains('revenue') || lower.contains('sales')) {
      return '📊 Revenue: ₹${appState.totalRevenue.toStringAsFixed(0)}\n📦 Orders: ${appState.totalOrders}';
    }
    if (lower.contains('product') || lower.contains('stock')) {
      if (appState.products.isEmpty) return 'No products yet.';
      final sorted = List<Product>.from(appState.products)
        ..sort((a, b) => b.stock.compareTo(a.stock));
      return '📦 ${appState.products.length} products. Top stock: ${sorted.first.name} (${sorted.first.stock} units)';
    }
    if (lower.contains('customer')) {
      return '👥 You have ${appState.customers.length} customers.';
    }
    if (lower.contains('today')) {
      final now = DateTime.now();
      final todayOrders = appState.orders
          .where((o) =>
              o.date.year == now.year &&
              o.date.month == now.month &&
              o.date.day == now.day)
          .toList();
      if (todayOrders.isEmpty) return 'No orders today.';
      final total = todayOrders.fold(0.0, (sum, o) => sum + o.grandTotal);
      return '📅 ${todayOrders.length} orders today. Total: ₹${total.toStringAsFixed(0)}.';
    }
    return _getPrediction(appState);
  }

  // ============================================================
  // 🛠 HELPERS
  // ============================================================
  static void _addToHistory(String role, String content) {
    _conversationHistory.add({'role': role, 'content': content});
    if (_conversationHistory.length > _maxHistory * 2) {
      _conversationHistory.removeRange(0, 2);
    }
  }
}
