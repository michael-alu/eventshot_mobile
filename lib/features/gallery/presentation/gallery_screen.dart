import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/cards/info_banner.dart';
import '../../../shared/widgets/chips/filter_chip_row.dart';
import '../../../shared/widgets/chrome/es_app_bar.dart';
import '../../../shared/widgets/dialogs/qr_invite_dialog.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key, required this.eventId, this.eventTitle});

  final String eventId;
  final String? eventTitle;

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  int _filterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final title = widget.eventTitle ?? widget.eventId;
    return Scaffold(
      appBar: EsAppBar(
        title: title,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Export',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoBanner(
            title: 'Images will be deleted in 30 days',
            subtitle: 'Upgrade to Pro for \$2/mo to keep forever.',
            actionLabel: 'Upgrade',
            onAction: () {},
          ),
          FilterChipRow(
            labels: const ['All Photos', 'Latest', 'Most Popular', 'My Photos'],
            selectedIndex: _filterIndex,
            onSelected: (i) => setState(() => _filterIndex = i),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 1,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                return Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.image)),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: () =>
                    QrInviteDialog.show(context, joinCode: widget.eventId),
                child: const Icon(Icons.qr_code_2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Download All'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
