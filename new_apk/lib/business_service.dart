// lib/business_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // <-- ADD THIS LINE

class BusinessService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String?> getCurrentBusinessId() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('❌ getCurrentBusinessId: User not logged in');
      return null;
    }

    try {
      final response = await _supabase
          .from('business_memberships')
          .select('business_id')
          .eq('user_id', user.id)
          .limit(1)
          .maybeSingle();
      final businessId = response?['business_id'] as String?;
      debugPrint('✅ Current business ID: $businessId');
      return businessId;
    } catch (e) {
      debugPrint('❌ getCurrentBusinessId ERROR: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createBusiness({
    required String name,
    required String ownerName,
    String? phone,
    String? email,
    String? address,
    String? upiId,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('❌ createBusiness: User not logged in');
      return null;
    }

    try {
      debugPrint('📝 Creating business: $name for user: ${user.id}');

      final business = {
        'name': name,
        'owner_name': ownerName,
        'phone': phone ?? '',
        'email': email ?? user.email,
        'address': address ?? '',
        'upi_id': upiId ?? '',
      };

      final businessResponse =
          await _supabase.from('businesses').insert(business).select().single();
      debugPrint('✅ Business created with ID: ${businessResponse['id']}');

      final businessId = businessResponse['id'];

      await _supabase.from('business_memberships').insert({
        'user_id': user.id,
        'business_id': businessId,
        'role': 'owner',
      });
      debugPrint('✅ User ${user.id} added as owner of business $businessId');

      return businessResponse;
    } catch (e) {
      debugPrint('❌ createBusiness ERROR: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getBusiness() async {
    final businessId = await getCurrentBusinessId();
    if (businessId == null) return null;

    try {
      return await _supabase
          .from('businesses')
          .select()
          .eq('id', businessId)
          .single();
    } catch (e) {
      debugPrint('❌ getBusiness ERROR: $e');
      return null;
    }
  }

  Future<void> updateBusiness(Map<String, dynamic> data) async {
    final businessId = await getCurrentBusinessId();
    if (businessId == null) {
      debugPrint('❌ updateBusiness: No business ID found');
      return;
    }

    try {
      await _supabase.from('businesses').update(data).eq('id', businessId);
      debugPrint('✅ Business updated: $businessId');
    } catch (e) {
      debugPrint('❌ updateBusiness ERROR: $e');
      rethrow;
    }
  }
}
