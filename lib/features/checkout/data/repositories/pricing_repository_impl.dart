import '../../domain/entities/tier.dart';
import '../../domain/repositories/pricing_repository.dart';

class PricingRepositoryImpl implements PricingRepository {
  static final List<Tier> _tiers = [
    const Tier(
      id: 'starter',
      name: 'Starter',
      description: 'Up to 100 photos',
      priceCents: 500,
      features: ['Standard QR sharing'],
    ),
    const Tier(
      id: 'pro',
      name: 'Pro',
      description: 'Up to 500 photos',
      priceCents: 1200,
      priceLabel: 'One-time',
      features: ['High-res downloads', 'Custom QR brand colors'],
      isPopular: true,
    ),
    const Tier(
      id: 'unlimited',
      name: 'Unlimited',
      description: 'Infinite storage',
      priceCents: 2900,
      features: ['All Pro features + Live Slideshow'],
    ),
  ];

  @override
  List<Tier> getTiers() => List.unmodifiable(_tiers);

  @override
  Tier? getTier(String tierId) {
    try {
      return _tiers.firstWhere((t) => t.id == tierId);
    } catch (_) {
      return null;
    }
  }
}
