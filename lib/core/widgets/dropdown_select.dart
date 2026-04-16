import 'package:financer/core/util/has_id.dart';
import 'package:flutter/material.dart';

class DropdownSelect<T extends HasID<K>, K> extends FormField<K> {
  DropdownSelect({
    super.key,
    required ValueHolder<T, K> valueHolder,
    required String label,
    required Widget Function(T) dropDownItem,
    IconData? icon,
    super.onSaved,
    bool optional = false,
    super.initialValue}) :
        super(
          validator: (value) => _validate(value, optional),
          builder: (fieldState) =>
              _build<T, K>(fieldState, valueHolder, label, dropDownItem, icon));

  static String? _validate<K>(K? value, bool optional) {
    if (!optional && value == null) {
      return "This field is required";
    }
    return null;
  }

  static Widget _build<T extends HasID<K>, K>
      (FormFieldState<K> field,
      ValueHolder<T, K> valueHolder,
      String label,
      Widget Function(T) dropDownItem,
      IconData? icon) {
    return FutureBuilder<List<T>>(
      future: valueHolder.values,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return TextFormField(
            enabled: false,
            decoration: InputDecoration(
              labelText: label,
              suffixIcon: const CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final items = snapshot.data!;

        return DropdownButtonFormField<K>(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: icon != null ? Icon(icon) : null,
          ),
          items: items.map((item) {
            return DropdownMenuItem<K>(
              value: item.id,
              child: dropDownItem(item),
            );
          }).toList(),
          onChanged: (value) {
            field.didChange(value);
          },
        );
      },
    );
  }
}