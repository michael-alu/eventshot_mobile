import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// Six-slot alphanumeric code entry (e.g. manual join code).
class ConfirmationCodeField extends StatefulWidget {
  const ConfirmationCodeField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
  });

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  @override
  State<ConfirmationCodeField> createState() => _ConfirmationCodeFieldState();
}

class _ConfirmationCodeFieldState extends State<ConfirmationCodeField> {
  final List<FocusNode> _focusNodes = [];
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.length; i++) {
      _focusNodes.add(FocusNode());
      _controllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final n in _focusNodes) {
      n.dispose();
    }
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  void _onChanged() {
    widget.onChanged?.call(_value);
    if (_value.length == widget.length) {
      widget.onCompleted?.call(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white24 : AppColors.borderLight;
    final focusColor = AppColors.primary;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.length, (index) {
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 8,
              right: index == widget.length - 1 ? 0 : 8,
            ),
            child: SizedBox(
              width: 48,
              height: 64,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    borderSide: BorderSide(color: borderColor, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    borderSide: BorderSide(color: focusColor, width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (value.length > 1) {
                    final pasteChars = value.toUpperCase().split('');
                    for (var i = 0; i < pasteChars.length; i++) {
                      final targetIndex = index + i;
                      if (targetIndex < widget.length) {
                        _controllers[targetIndex].text = pasteChars[i];
                      }
                    }
                    final nextFocusIndex = index + pasteChars.length;
                    if (nextFocusIndex < widget.length) {
                      FocusScope.of(
                        context,
                      ).requestFocus(_focusNodes[nextFocusIndex]);
                    } else {
                      FocusScope.of(
                        context,
                      ).requestFocus(_focusNodes[widget.length - 1]);
                    }
                    _onChanged();
                    return;
                  }

                  if (value.isNotEmpty) {
                    _controllers[index].text = value.toUpperCase();
                    if (index < widget.length - 1) {
                      FocusScope.of(
                        context,
                      ).requestFocus(_focusNodes[index + 1]);
                    }
                  } else if (index > 0) {
                    FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                  }
                  _onChanged();
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
