import '../entities/tier.dart';

abstract class PricingRepository {
  List<Tier> getTiers();
  Tier? getTier(String tierId);
}
