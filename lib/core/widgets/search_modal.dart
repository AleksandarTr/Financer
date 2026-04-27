import 'package:flutter/material.dart';

import '../util/has_id.dart';

class SearchModal<T extends HasID<K>, K> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T) dropDownItem;
  final String Function(T)? searchLabel;
  final String title;
  final ValueChanged<K> onSelected;

  const SearchModal({super.key,
    required this.items,
    required this.dropDownItem,
    this.searchLabel,
    required this.title,
    required this.onSelected,
  });

  @override
  State<SearchModal<T, K>> createState() => _SearchModalState<T, K>();
}

class _SearchModalState<T extends HasID<K>, K> extends State<SearchModal<T, K>> {
  late List<T> filtered;
  final TextEditingController _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    filtered = widget.items;
  }

  Set<String> _getTrigraphs(String s) {
    s = s.toLowerCase().replaceAll(' ', '');
    if (s.length < 3) return {s};
    return List.generate(s.length - 2, (i) => s.substring(i, i + 3)).toSet();
  }

  void _runFilter(String q) {
    final searchLabel = widget.searchLabel;
    if (q.isEmpty || searchLabel == null) {
      setState(() => filtered = widget.items);
      return;
    }

    final qTri = _getTrigraphs(q);

    final scored = widget.items.map((item) {
      final label = searchLabel(item);
      final itemTri = _getTrigraphs(label);
      int score = qTri.intersection(itemTri).length;
      if (label.toLowerCase().contains(q.toLowerCase())) score += 5;
      return (item: item, score: score);
    }).where((e) => e.score > 0).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    setState(() => filtered = scored.map((e) => e.item).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20, left: 20, right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          if (widget.searchLabel != null) ...[
            const SizedBox(height: 15),
            TextField(
              controller: _query,
              autofocus: true,
              decoration: const InputDecoration(hintText: "Search...", prefixIcon: Icon(Icons.search)),
              onChanged: _runFilter,
            ),
          ],
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) => ListTile(
                title: widget.dropDownItem(filtered[i]),
                onTap: () => widget.onSelected(filtered[i].id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}