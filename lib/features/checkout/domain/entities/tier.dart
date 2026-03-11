import 'package:equatable/equatable.dart';

class Tier extends Equatable {
  const Tier({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCents,
    this.priceLabel = 'One-time',
    this.features = const [],
    this.isPopular = false,
  });

  final String id;
  final String name;
  final String description;
  final int priceCents;
  final String priceLabel;
  final List<String> features;
  final bool isPopular;

  String get priceFormatted => '\$${(priceCents / 100).toStringAsFixed(0)}';

  @override
  List<Object?> get props => [id, name, description, priceCents, priceLabel, features, isPopular];
}
