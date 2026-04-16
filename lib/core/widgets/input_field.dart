import 'package:flutter/material.dart';

class FieldController<T> {
  final bool isOptional;
  final void Function(T) onSave;
  final TextEditingController textController;

  FieldController({
    required this.onSave,
    this.isOptional = false,
    T? initialValue,
  }) : textController = TextEditingController(
    text: _formatInitial(initialValue),
  );

  static String _formatInitial(dynamic value) {
    if (value is DateTime) return "${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}";
    return value?.toString() ?? '';
  }

  bool get isInt => T == int || T == typeOf<int?>();
  bool get isDouble => T == double || T == typeOf<double?>();
  bool get isDate => T == DateTime || T == typeOf<DateTime?>();

  // Internal parser used for validation and saving
  T? parse() {
    final text = textController.text.trim();
    if (text.isEmpty) return null;

    if (isInt) return int.tryParse(text) as T?;
    if (isDouble) return double.tryParse(text) as T?;
    if (isDate) return DateTime.tryParse(text) as T?;
    return text as T?;
  }

  void dispose() => textController.dispose();
}

Type typeOf<T>() => T;

class InputField<T> extends StatelessWidget {
  final FieldController<T> controller;
  final String label;
  final IconData? icon;

  const InputField({super.key, required this.controller, required this.label, this.icon});

  Future<void> _handleDateSelection(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now().add(Duration(days: 365 * 100)),
    );

    if (picked != null) {
      // Format the date for the display
      controller.textController.text =
      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller.textController,
      readOnly: controller.isDate,
      onTap: controller.isDate ? () => _handleDateSelection(context) : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
      ),
      keyboardType: _getKeyboard(),
      // 1. VALIDATION LOGIC
      validator: (value) {
        final parsed = controller.parse();

        if (!controller.isOptional && (value == null || value.isEmpty)) {
          return '$label cannot be empty';
        }

        if (value != null && value.isNotEmpty && parsed == null) {
          return 'Please enter a valid ${label.toLowerCase()}';
        }

        return null;
      },
      // 2. SAFE SAVE LOGIC
      onSaved: (_) {
        final value = controller.parse();
        if (value != null) {
          controller.onSave(value);
        } else if (controller.isOptional) {
          // If optional and null, you might need a different callback or handle it
          // but per your requirement, onSave expects T, so we only call it when valid.
        }
      },
    );
  }

  TextInputType _getKeyboard() {
    if (controller.isInt) return TextInputType.number;
    if (controller.isDouble) return const TextInputType.numberWithOptions(decimal: true);
    return TextInputType.text;
  }
}