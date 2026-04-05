import 'package:drift/drift.dart';

import 'category_group.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get group => integer().references(CategoryGroups, #id)();
}