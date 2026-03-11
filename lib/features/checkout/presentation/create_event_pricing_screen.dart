import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/chrome/es_app_bar.dart';
import '../../../shared/widgets/inputs/es_text_field.dart';
import '../../../shared/widgets/cards/tier_card.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../../events/presentation/providers/event_providers.dart';
import 'providers/pricing_providers.dart';

class CreateEventPricingScreen extends ConsumerStatefulWidget {
  const CreateEventPricingScreen({super.key});

  @override
  ConsumerState<CreateEventPricingScreen> createState() => _CreateEventPricingScreenState();
}

class _CreateEventPricingScreenState extends ConsumerState<CreateEventPricingScreen> {
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final date = _selectedDate ?? DateTime.now();
    final tierId = ref.read(selectedTierIdProvider) ?? 'pro';
    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(eventRepositoryProvider);
      final event = await repo.createEvent(
        name: name,
        date: date,
        tierId: tierId,
        organizerId: auth.id,
      );
      ref.read(currentEventIdProvider.notifier).state = event.id;
      if (mounted) context.go(AppRouter.organizerDashboard);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiers = ref.watch(tiersProvider);
    final selectedTierId = ref.watch(selectedTierIdProvider) ?? 'pro';

    return Scaffold(
      appBar: const EsAppBar(title: 'Create Event'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'Event Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Fill in the basics to get started.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            EsTextField(
              controller: _nameController,
              label: 'Event Name',
              hint: 'e.g., Summer Gala 2024',
            ),
            const SizedBox(height: 16),
            _DateField(
              value: _selectedDate,
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (d != null) setState(() => _selectedDate = d);
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Select Photo Tier',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the capacity for your event.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            ...tiers.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TierCard(
                  title: t.name,
                  subtitle: t.description,
                  price: t.priceFormatted,
                  priceSuffix: t.priceLabel,
                  features: t.features,
                  isSelected: t.id == selectedTierId,
                  badge: t.isPopular ? 'Most Popular' : null,
                  onTap: () => ref.read(selectedTierIdProvider.notifier).state = t.id,
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Create & Generate QR',
              icon: const Icon(Icons.qr_code_2, color: Colors.white, size: 22),
              onPressed: _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({this.value, required this.onTap});

  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Date',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            ),
            child: Row(
              children: [
                Text(
                  value != null
                      ? '${value!.day}/${value!.month}/${value!.year}'
                      : 'Select Date',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: value != null
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_month, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
