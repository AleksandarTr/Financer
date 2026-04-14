import 'package:drift/drift.dart';

class Currencies extends Table {
  TextColumn get code => text()();
  TextColumn get name => text()();

  @override
  Set<Column<Object>> get primaryKey => {code};
}