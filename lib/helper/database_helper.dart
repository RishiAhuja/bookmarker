import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/data.dart';

class DatabaseHelper {

  final _databaseName = "MyDedBase699696.db";
  static final _databaseVersion = 1;

  // static final table = 'my_table';

  static final columnId = '_id';
  static final columnName = 'name';
  static final columnAuthor = 'author';
  static final columnThumbnail = 'thumb';
  static final columnTotal = 'total';
  static final columnDone = 'done';
  static final columnLove = 'love';
  static final columnMAF = 'maf';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE current_books (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnAuthor TEXT NOT NULL,
            $columnTotal TEXT NOT NULL,
            $columnDone TEXT NOT NULL,
            $columnThumbnail TEXT NOT NULL,
            $columnMAF INTEGER NOT NULL
          )
          ''').then((value) async{
            print('books_created');

            await db.execute('''
          CREATE TABLE wishlist (
            $columnId INTEGER PRIMARY KEY,
            $columnName TEXT NOT NULL,
            $columnAuthor TEXT NOT NULL,
            $columnTotal TEXT NOT NULL,
            $columnLove TEXT NOT NULL,
            $columnThumbnail TEXT NOT NULL
          )
          ''').then((value) async{
              print('wishlist_created');
            });
    });
    
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  //The data present in the table is returned as a List of Map, where each
  // row is of type map
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}