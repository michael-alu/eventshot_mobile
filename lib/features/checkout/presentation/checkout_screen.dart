import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/preferences_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/chrome/es_app_bar.dart';
import '../../../shared/widgets/inputs/es_text_field.dart';
import 'providers/pricing_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _isLoading = false;

  final _nameNode = FocusNode();
  final _cardNode = FocusNode();
  final _expiryNode = FocusNode();
  final _cvcNode = FocusNode();
  final _zipNode = FocusNode();

  @override
  void dispose() {
    _nameNode.dispose();
    _cardNode.dispose();
    _expiryNode.dispose();
    _cvcNode.dispose();
    _zipNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      // Save the last event ID to preferences so the app remembers their context
      ref.read(lastEventIdProvider.notifier).state = widget.eventId;
      
      setState(() => _isLoading = false);
      context.go(AppRouter.organizerDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tierId = ref.watch(selectedTierIdProvider) ?? 'pro';
    final tier = ref.watch(pricingRepositoryProvider).getTier(tierId);
    final price = tier?.priceFormatted ?? '\$12';

    return Scaffold(
      appBar: const EsAppBar(title: 'Checkout'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier?.name ?? 'Pro',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tier?.description ?? 'Up to 500 photos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(price, style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            EsTextField(
              label: 'Cardholder Name', 
              hint: 'John Doe',
              focusNode: _nameNode,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _cardNode.requestFocus(),
            ),
            const SizedBox(height: 12),
            EsTextField(
              label: 'Card Number', 
              hint: '0000 0000 0000 0000', 
              keyboardType: TextInputType.number,
              focusNode: _cardNode,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _expiryNode.requestFocus(),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                CreditCardFormatter(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: EsTextField(
                    label: 'Expiry Date',
                    hint: 'MM/YY',
                    keyboardType: TextInputType.datetime,
                    focusNode: _expiryNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _cvcNode.requestFocus(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      ExpiryDateFormatter(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EsTextField(
                    label: 'CVC',
                    hint: '123',
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    focusNode: _cvcNode,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _zipNode.requestFocus(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            EsTextField(
              label: 'Zip / Postal Code',
              hint: '10001',
              keyboardType: TextInputType.number,
              focusNode: _zipNode,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Pay & Create QR',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
