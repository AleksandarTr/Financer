import 'package:drift/drift.dart';

class CategoryGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}