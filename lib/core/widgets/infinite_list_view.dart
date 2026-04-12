import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

class InfiniteListView<T> extends StatefulWidget {
  final Widget Function(BuildContext, T) itemBuilder;
  final SimpleSelectStatement Function() loader;
  final int pageSize;

  const InfiniteListView({
    super.key,
    required this.itemBuilder,
    required this.loader,
    required this.pageSize
  });

  @override
  State<InfiniteListView<T>> createState() => _InfiniteListViewState<T>();
}

class _InfiniteListViewState<T> extends State<InfiniteListView<T>> {
  final ScrollController _scrollController = ScrollController();
  final List<T> _items = [];
  bool _hasMore = true;
  bool _isLoading = false;
  int _currentOffset = 0;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(InfiniteListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _refresh();
  }

  void _refresh() {
    _items.clear();
    _currentOffset = 0;
    _hasMore = true;
    _isLoading = false;
    _scrollController.jumpTo(0);
    _loadMore();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoading = true);
    final newItems = await (widget.loader()
      ..limit(widget.pageSize, offset: _currentOffset)).get();

    setState(() {
      _isLoading = false;
      if (newItems.length < widget.pageSize) {
        _hasMore = false;
      }
      _items.addAll(newItems as Iterable<T>);
      _currentOffset += newItems.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
      itemBuilder: (context, index) {
        if(_items.length <= index) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.itemBuilder(context, _items[index]);
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}