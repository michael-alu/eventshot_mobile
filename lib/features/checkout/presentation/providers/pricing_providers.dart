import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/pricing_repository_impl.dart';
import '../../domain/entities/tier.dart';
import '../../domain/repositories/pricing_repository.dart';

final pricingRepositoryProvider = Provider<PricingRepository>((ref) {
  return PricingRepositoryImpl();
});

final tiersProvider = Provider<List<Tier>>((ref) {
  return ref.watch(pricingRepositoryProvider).getTiers();
});

final selectedTierIdProvider = StateProvider<String?>((ref) => 'pro');
