import 'package:drift/drift.dart';

import '../../../core/util/has_id.dart';
import 'category_group.dart';

@UseRowClass(Category)
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get group => integer().references(CategoryGroups, #id)();
}

class Category implements HasID<int> {
  @override
  final int id;
  final String name;
  final int group;
  
  Category({
    required this.id,
    required this.name,
    required this.group,
  });
}