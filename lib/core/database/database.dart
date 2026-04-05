import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../features/accounts/domain/account.dart';
import '../../features/currencies/domain/conversion_rate.dart';
import '../../features/transactions/domain/transaction.dart';
import '../../features/transactions/domain/category.dart';
import '../../features/transactions/domain/category_group.dart';
import '../../features/currencies/domain/currency.dart';

part 'database.g.dart'; // The generated code will go here

@DriftDatabase(tables: [Transactions, Categories, CategoryGroups, Currencies, ConversionRates, Accounts])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._internal();

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'financer.sqlite'));
    return NativeDatabase(file);
  });
}