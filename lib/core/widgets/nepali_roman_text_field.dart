import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:krishi_smart/core/utils/nepali_transliterator.dart';

/// Type in Roman letters; field shows live Devanagari conversion.
class NepaliRomanTextField extends StatefulWidget {
  const NepaliRomanTextField({
    super.key,
    required this.label,
    this.hint,
    this.onNepaliChanged,
    this.initialNepali,
  });

  final String label;
  final String? hint;
  final ValueChanged<String>? onNepaliChanged;
  final String? initialNepali;

  @override
  State<NepaliRomanTextField> createState() => _NepaliRomanTextFieldState();
}

class _NepaliRomanTextFieldState extends State<NepaliRomanTextField> {
  final _romanController = TextEditingController();
  final _focusNode = FocusNode();
  String _roman = '';
  String _nepali = '';
  @override
  void initState() {
    super.initState();
    if (widget.initialNepali != null && widget.initialNepali!.isNotEmpty) {
      _nepali = widget.initialNepali!;
    }
    _romanController.addListener(_onRomanChanged);
  }

  void _onRomanChanged() {
    _roman = _romanController.text;
    _nepali = NepaliTransliterator.fromRoman(_roman);
    widget.onNepaliChanged?.call(_nepali);
    setState(() {});
  }

  @override
  void dispose() {
    _romanController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get nepaliValue => _nepali;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _romanController,
          focusNode: _focusNode,
          style: theme.textTheme.titleMedium,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint ?? 'Type in Roman (e.g. golbheda)',
            suffixIcon: _nepali.isNotEmpty
                ? Icon(Icons.translate, color: theme.colorScheme.primary, size: 20)
                : null,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
          textInputAction: TextInputAction.next,
        ),
        if (_nepali.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              _nepali,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
