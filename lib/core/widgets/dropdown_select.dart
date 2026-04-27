import 'package:financer/core/util/has_id.dart';
import 'package:financer/core/widgets/search_modal.dart';
import 'package:flutter/material.dart';

class DropdownSelect<T extends HasID<K>, K> extends FormField<K> {
  DropdownSelect({
    super.key,
    required ValueHolder<T, K> valueHolder,
    required String label,
    required Widget Function(T) dropDownItem,
    String Function(T)? searchLabel, // Needed for Trigraph matching
    IconData? icon,
    super.onSaved,
    bool optional = false,
    super.initialValue,
  }) : super(
    validator: (value) => _validate(value, optional),
    builder: (fieldState) => _build<T, K>(
      fieldState,
      valueHolder,
      label,
      dropDownItem,
      searchLabel,
      icon
    ),
  );

  static String? _validate<K>(K? value, bool optional) {
    if (!optional && value == null) return "This field is required";
    return null;
  }

  static Widget _build<T extends HasID<K>, K>(
      FormFieldState<K> field,
      ValueHolder<T, K> valueHolder,
      String label,
      Widget Function(T) dropDownItem,
      String Function(T)? searchLabel,
      IconData? icon,
      ) {
    return FutureBuilder<List<T>>(
      future: valueHolder.values,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return TextFormField(
            enabled: false,
            decoration: InputDecoration(
              labelText: label,
              suffixIcon: const SizedBox(
                width: 12, height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final items = snapshot.data!;
        // Find current selected item to display in the collapsed field
        final selectedItem = items.where((i) => i.id == field.value).firstOrNull;

        return InkWell(
          onTap: () => _showSearchModal(context, items, field, dropDownItem, searchLabel, label),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: icon != null ? Icon(icon) : null,
              errorText: field.errorText,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: selectedItem != null
                      ? dropDownItem(selectedItem)
                      : Text("Select $label...", style: TextStyle(color: Theme.of(context).hintColor)),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showSearchModal<T extends HasID<K>, K>(
      BuildContext context,
      List<T> items,
      FormFieldState<K> field,
      Widget Function(T) dropDownItem,
      String Function(T)? searchLabel,
      String label,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SearchModal<T, K>(
        items: items,
        dropDownItem: dropDownItem,
        searchLabel: searchLabel,
        title: label,
        onSelected: (val) {
          field.didChange(val);
          Navigator.pop(context);
        },
      ),
    );
  }
}