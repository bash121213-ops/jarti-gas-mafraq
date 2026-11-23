import '../models/pricing.dart';

/// Reads official prices from the backend.
///
/// Production implementation: `Supabase.instance.client.from('pricing')
/// .select().eq('active', true).single()` (public read-only table). The fallback
/// keeps the demo working offline and is replaced as soon as the row is loaded.
class PricingRepository {
  Future<Pricing> fetch() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return Pricing.fallback;
  }
}
