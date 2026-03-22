import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/event_model.dart';
import '../models/app_models.dart';
import 'package:flutter/material.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // In-memory fallbacks for Flutter Web
  final List<Event> _webEvents = [];
  final List<AppTransaction> _webTransactions = [];
  final List<SavingsGoal> _webGoals = [];
  final List<Subscription> _webSubs = [];
  final List<Debt> _webDebts = [];
  int _webIdCounter = 1;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) throw UnsupportedError('SQLite not supported on Web');
    if (_database != null) return _database!;
    _database = await _initDB('vello.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        spentAmount REAL NOT NULL,
        budgetAmount REAL NOT NULL,
        icon INTEGER NOT NULL,
        iconColor INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        iconFontFamily TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE savings_goals(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL,
        iconStr TEXT NOT NULL,
        colorValue INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE subscriptions(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        cost REAL NOT NULL,
        billingCycle TEXT NOT NULL,
        nextBillingDate TEXT NOT NULL,
        logoUrl TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE debts(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        paidAmount REAL NOT NULL,
        dueDate TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add all new tables if upgrading from version 1
      await db.execute('''
        CREATE TABLE IF NOT EXISTS transactions(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          category TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          type TEXT NOT NULL,
          iconCodePoint INTEGER NOT NULL,
          iconFontFamily TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS savings_goals(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          targetAmount REAL NOT NULL,
          currentAmount REAL NOT NULL,
          iconStr TEXT NOT NULL,
          colorValue INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS subscriptions(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          cost REAL NOT NULL,
          billingCycle TEXT NOT NULL,
          nextBillingDate TEXT NOT NULL,
          logoUrl TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS debts(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          totalAmount REAL NOT NULL,
          paidAmount REAL NOT NULL,
          dueDate TEXT NOT NULL
        )
      ''');
    }
  }

  // ─── EVENTS ──────────────────────────────────────────────────────────────

  Future<Event> createEvent(Event event) async {
    if (kIsWeb) {
      event.id = _webIdCounter++;
      _webEvents.add(event);
      return event;
    }
    final db = await database;
    final id = await db.insert('events', event.toMap());
    event.id = id;
    return event;
  }

  Future<List<Event>> readAllEvents() async {
    if (kIsWeb) return List.from(_webEvents);
    final db = await database;
    final result = await db.query('events', orderBy: 'id DESC');
    return result.map((json) => Event.fromMap(json)).toList();
  }

  Future<int> deleteEvent(int id) async {
    if (kIsWeb) {
      final before = _webEvents.length;
      _webEvents.removeWhere((e) => e.id == id);
      return before - _webEvents.length;
    }
    final db = await database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  // ─── TRANSACTIONS ─────────────────────────────────────────────────────────

  Future<void> insertTransaction(AppTransaction tx) async {
    if (kIsWeb) { _webTransactions.add(tx); return; }
    final db = await database;
    await db.insert('transactions', {
      'id': tx.id,
      'title': tx.title,
      'category': tx.category,
      'amount': tx.amount,
      'date': tx.date.toIso8601String(),
      'type': tx.type == TransactionType.income ? 'income' : 'expense',
      'iconCodePoint': tx.icon.codePoint,
      'iconFontFamily': tx.icon.fontFamily,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AppTransaction>> readAllTransactions() async {
    if (kIsWeb) return List.from(_webTransactions);
    final db = await database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((row) => AppTransaction(
      id: row['id'] as String,
      title: row['title'] as String,
      category: row['category'] as String,
      amount: row['amount'] as double,
      date: DateTime.parse(row['date'] as String),
      type: row['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      icon: IconData(row['iconCodePoint'] as int, fontFamily: row['iconFontFamily'] as String?),
    )).toList();
  }

  Future<void> deleteTransaction(String id) async {
    if (kIsWeb) { _webTransactions.removeWhere((t) => t.id == id); return; }
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // ─── SAVINGS GOALS ────────────────────────────────────────────────────────

  Future<void> insertSavingsGoal(SavingsGoal goal) async {
    if (kIsWeb) { _webGoals.add(goal); return; }
    final db = await database;
    await db.insert('savings_goals', {
      'id': goal.id,
      'title': goal.title,
      'targetAmount': goal.targetAmount,
      'currentAmount': goal.currentAmount,
      'iconStr': goal.iconStr,
      'colorValue': goal.color.value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    if (kIsWeb) {
      final i = _webGoals.indexWhere((g) => g.id == goal.id);
      if (i != -1) _webGoals[i] = goal;
      return;
    }
    final db = await database;
    await db.update('savings_goals', {'currentAmount': goal.currentAmount},
        where: 'id = ?', whereArgs: [goal.id]);
  }

  Future<List<SavingsGoal>> readAllSavingsGoals() async {
    if (kIsWeb) return List.from(_webGoals);
    final db = await database;
    final result = await db.query('savings_goals');
    return result.map((row) => SavingsGoal(
      id: row['id'] as String,
      title: row['title'] as String,
      targetAmount: row['targetAmount'] as double,
      currentAmount: row['currentAmount'] as double,
      iconStr: row['iconStr'] as String,
      color: Color(row['colorValue'] as int),
    )).toList();
  }

  // ─── SUBSCRIPTIONS ────────────────────────────────────────────────────────

  Future<void> insertSubscription(Subscription sub) async {
    if (kIsWeb) { _webSubs.add(sub); return; }
    final db = await database;
    await db.insert('subscriptions', {
      'id': sub.id,
      'name': sub.name,
      'cost': sub.cost,
      'billingCycle': sub.billingCycle,
      'nextBillingDate': sub.nextBillingDate.toIso8601String(),
      'logoUrl': sub.logoUrl,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Subscription>> readAllSubscriptions() async {
    if (kIsWeb) return List.from(_webSubs);
    final db = await database;
    final result = await db.query('subscriptions', orderBy: 'nextBillingDate ASC');
    return result.map((row) => Subscription(
      id: row['id'] as String,
      name: row['name'] as String,
      cost: row['cost'] as double,
      billingCycle: row['billingCycle'] as String,
      nextBillingDate: DateTime.parse(row['nextBillingDate'] as String),
      logoUrl: row['logoUrl'] as String,
    )).toList();
  }

  Future<void> deleteSubscription(String id) async {
    if (kIsWeb) { _webSubs.removeWhere((s) => s.id == id); return; }
    final db = await database;
    await db.delete('subscriptions', where: 'id = ?', whereArgs: [id]);
  }

  // ─── DEBTS ────────────────────────────────────────────────────────────────

  Future<void> insertDebt(Debt debt) async {
    if (kIsWeb) { _webDebts.add(debt); return; }
    final db = await database;
    await db.insert('debts', {
      'id': debt.id,
      'name': debt.name,
      'totalAmount': debt.totalAmount,
      'paidAmount': debt.paidAmount,
      'dueDate': debt.dueDate.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateDebtPaid(String id, double paidAmount) async {
    if (kIsWeb) {
      final i = _webDebts.indexWhere((d) => d.id == id);
      if (i != -1) _webDebts[i].paidAmount = paidAmount;
      return;
    }
    final db = await database;
    await db.update('debts', {'paidAmount': paidAmount},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Debt>> readAllDebts() async {
    if (kIsWeb) return List.from(_webDebts);
    final db = await database;
    final result = await db.query('debts', orderBy: 'dueDate ASC');
    return result.map((row) => Debt(
      id: row['id'] as String,
      name: row['name'] as String,
      totalAmount: row['totalAmount'] as double,
      paidAmount: row['paidAmount'] as double,
      dueDate: DateTime.parse(row['dueDate'] as String),
    )).toList();
  }

  Future<void> close() async {
    if (kIsWeb) return;
    final db = await database;
    db.close();
  }
}
