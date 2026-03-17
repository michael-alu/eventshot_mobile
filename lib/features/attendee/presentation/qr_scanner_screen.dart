import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  bool _flashOn = false;
  int _bottomIconIndex = 1; // 0=gallery, 1=qr(active), 2=history

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated camera background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f3460),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(Icons.camera_alt, size: 80, color: Colors.white12),
              ),
            ),
          ),

          // Dark overlay outside scan frame
          Positioned.fill(child: CustomPaint(painter: _ScanOverlayPainter())),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                const SizedBox(height: 8),
                _buildInstructionText(context),
                const Expanded(child: SizedBox()),
                _buildScanFrame(),
                const Expanded(child: SizedBox()),
                _buildBottomIcons(),
                const SizedBox(height: 24),
                _buildManualEntryButton(context),
                const SizedBox(height: 12),
                _buildTroubleText(context),
                const SizedBox(height: 16),
                _buildAccessTierBadge(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.close,
            onTap: () => context.go(AppRouter.welcome),
          ),
          const Expanded(
            child: Text(
              'Scan QR Code',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _CircleIconButton(
            icon: _flashOn ? Icons.flash_on : Icons.flash_off,
            onTap: () => setState(() => _flashOn = !_flashOn),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionText(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'Point your camera at the event QR code to start sharing photos',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  Widget _buildScanFrame() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        children: [
          // Blue bordered scan frame
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 2.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          // Scanning indicator in bottom-left area
          const Positioned(
            left: 20,
            bottom: 40,
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
                value: null,
              ),
            ),
          ),
          // Bottom icons inside frame
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: _buildFrameBottomIcons(),
          ),
        ],
      ),
    );
  }

  Widget _buildFrameBottomIcons() {
    final icons = [
      Icons.photo_library_outlined,
      Icons.qr_code_scanner,
      Icons.history,
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(icons.length, (i) {
        final isActive = i == _bottomIconIndex;
        return GestureDetector(
          onTap: () => setState(() => _bottomIconIndex = i),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(icons[i], color: Colors.white, size: 22),
          ),
        );
      }),
    );
  }

  Widget _buildBottomIcons() => const SizedBox.shrink();

  Widget _buildManualEntryButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: OutlinedButton(
        onPressed: () => context.go(AppRouter.attendeeManualCode),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Enter Code Manually',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildTroubleText(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        'Trouble scanning? Use the 6-digit code on the event banner.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white54, fontSize: 13),
      ),
    );
  }

  Widget _buildAccessTierBadge(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.verified, color: AppColors.primary, size: 18),
        SizedBox(width: 6),
        Text(
          'Attendee Access Tier',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

/// Paints a semi-transparent overlay with a transparent hole for the scan area.
class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    const frameSize = 280.0;
    const radius = 16.0;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final frameRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: frameSize,
      height: frameSize,
    );

    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(
        RRect.fromRectAndRadius(frameRect, const Radius.circular(radius)),
      );
    path.fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
