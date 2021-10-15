import 'dart:io';

import 'package:child_vaccination/Services/NotificationScheduler.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper with ChangeNotifier {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  static final table = 'ChildrenTable';

  static final columnId = 'Id';
  static final columnName = 'Name';
  static final columnGender = 'Gender';
  static final columnDate = 'Date';
  // static final columnPhoneNumber = 'Number';
  // static final columnEmail = 'Email';
  // static final columnAge = 'age';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database!;
  }

  DatabaseHelper() {
    _initDatabase();
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  //  $columnPhoneNumber TEXT NOT NULL,
  //           $columnEmail TEXT NOT NULL
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            $columnName TEXT NOT NULL,
            $columnDate TEXT NOT NULL,
            $columnGender TEXT NOT NULL
          )
          ''');
    notifyListeners();
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insertChildren(Map<String, dynamic> row) async {
    Database db = await instance.database;
    var rowId = await db.insert(table, row);

    createVaccineTable(row['Name'].replaceAll(' ', '') + rowId.toString(),
        row['Name'], row['Date']);

    return rowId;
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllChildrenRows() async {
    Database db = await instance.database;

    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int?> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> updateChildren(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    var updateChild =
        await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);

    return updateChild;
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> deleteChildren(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  var cColumnId = 'Cid';
  var cColumnVaccine = 'Vaccine';
  var cColumnScheduled = 'Scheduled';
  var cColumnGiven = 'Given';
  var cColumnStatus = 'Status';
  var cColumnHospital = 'Hospital';
  var cColumnCharges = 'Charges';
  var cColumnNotes = 'Notes';

  createVaccineTable(String tableName, String childName, String dob) async {
    Database db = await instance.database;
    //  var rowId = await db.insert(table, row);
    await db.execute('''
          CREATE TABLE $tableName (
            $cColumnId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            $cColumnVaccine TEXT NOT NULL,
            $cColumnScheduled TEXT NOT NULL,
            $cColumnGiven TEXT,
            $cColumnStatus TEXT,
            $cColumnHospital TEXT,
            $cColumnCharges TEXT,
            $cColumnNotes TEXT
          )
          ''');

    for (var i in vaccines) {
      var scheduled = Calculator.vaccineDateCalculator(i, dob, childName);
      Map<String, dynamic> row = {
        "Vaccine": i,
        "Scheduled": scheduled,
        "Given": "",
        "Status": "",
        "Hospital": "",
        "Charges": "",
        "Notes": ""
      };
      await db.insert(tableName, row);
    }
  }

  updateVaccineTable(var tableName, Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[cColumnId];
    // print("column id is $id");
    return await db
        .update(tableName, row, where: '$cColumnId = ?', whereArgs: [id]);
  }

  deleteVaccineTable(var tableName) async {
    Database db = await instance.database;
    await db.execute('''
          DROP TABLE IF EXISTS $tableName
          ''');
  }

  Future<List<Map<String, dynamic>>> queryAllVaccineRows(tableName) async {
    Database db = await instance.database;
    return await db.query(tableName);
  }

  List vaccines = [
    'BCG',
    'Hep B-0',
    'OPV-0',


    'OPV-1',
    'PCV-1',
    'penta-1',
    'IPV-1',


    'OPV-2',
    'PCV-2',
    'penta-2',
    'Rota-2',


    'OPV-3',
    'PCV-3',
    'penta-2',
    'IPV-2',

    'Vitamin A',


    'Measles 1',
    'Yellow Fever',
    'Meningitis A',


    'Vitamin A-2',


    'Measles-2',


    'Vitamin A-3',


    'Vitamin A-4',

    'Vitamin A-5',

    'Vitamin A-6',

    'Vitamin A-7',

    'Vitamin A-8',

    'Vitamin A-9',

    'Vitamin A-10',
  ];
}

class Calculator {
  static dateCalculator(var dateTime1,
      {int? days, int? months, int? years, var childName}) {
    // print('the initial:  ' + dateTime1.toString());
    // var dateTime2 = dateTime1.add(Duration(
    //   days: days,
    // ));
    var dateTime2 = DateTime(
        dateTime1.year + years, dateTime1.month + months, dateTime1.day + days);

    // if (dateTime2.compareTo(dateTime1) == 0) {

    if (childName != null) {
      NotificationScheduler.schedule(
          scheduledNotificationDateTime: dateTime2,
          notificationBody: childName + " needs to be vaccinated.");

      print('the vaccine on:    ' + dateTime2.toString());
    }
    // }

    //  print('the calculated:  ' + dateTime2.toString());

    var vaccineDate =
        "${dateTime2.year}-${dateTime2.month.toString().padLeft(2, '0')}-${dateTime2.day.toString().padLeft(2, '0')}";
    // print(vaccineDate);

    return vaccineDate;
  }

  static vaccineDateCalculator(var vaccine, var birthDate, var childName) {
    var dateTime1 = DateTime.parse(birthDate);

    if (vaccine == 'OPV-0' || vaccine == 'Hep B-0' || vaccine == 'BCG') {
      return dateCalculator(dateTime1, days: 0, months: 0, years: 0);
    } 
    
    


    else if (vaccine == 'OPV-1' ||
        vaccine == 'PCV-1' ||
        vaccine == 'penta-1' ||
        vaccine == 'IPV-1') {
      return dateCalculator(dateTime1,
          days: 6 * 7, months: 0, years: 0, childName: childName);
    }
    
    
    
    
     else if (vaccine == 'OPV-2' ||
        vaccine == 'PCV-2' ||
        vaccine == 'penta-2' ||
        vaccine == 'Rota-2') {
      return dateCalculator(dateTime1,
          days: 10 * 7, months: 0, years: 0, childName: childName);
    } 
    
    
    
    
    else if (vaccine == 'OPV-3' ||vaccine == 'PCV-3' ||
        vaccine == 'penta-2' ||
        vaccine == 'IPV-2') {
      return dateCalculator(dateTime1,
          days: 14 * 7, months: 0, years: 0, childName: childName);
    }
    
    
    
    
     else if (vaccine == 'Vitamin A') {
      return dateCalculator(dateTime1,
          days: 0, months: 6, years: 0, childName: childName);
    }
    
    
    
    
     else if (vaccine == 'Measles 1' || vaccine == 'Yellow Fever'|| vaccine == 'Meningitis A') {
      return dateCalculator(dateTime1,
          days: 0, months: 9, years: 0, childName: childName);
    } 





     else if (vaccine == 'Vitamin A-2') {
      return dateCalculator(dateTime1,
          days: 0, months: 12, years: 0, childName: childName);
    }



     else if (vaccine == 'Measles-2') {
      return dateCalculator(dateTime1,
          days: 0, months: 15, years: 0, childName: childName);
    }
    
    
    
    
    else if (
        vaccine == 'Vitamin A-3') {
      return dateCalculator(dateTime1,
          days: 0, months: 18, years: 0, childName: childName);
    }
    
    
    
    
     else if (vaccine == 'Vitamin A-4' ) {
      return dateCalculator(dateTime1,
          days: 0, months: 24, years: 0, childName: childName);
    }
    
    
    
    
     else if (vaccine == 'Vitamin A-5') {
      return dateCalculator(dateTime1,
          days: 0, months: 30, years: 0, childName: childName);
    } 
    
    
    
    
    else if (vaccine == 'Vitamin A-6') {
      return dateCalculator(dateTime1,
          days: 0, months: 36, years: 0, childName: childName);
    }




    else if (vaccine == 'Vitamin A-7') {
      return dateCalculator(dateTime1,
          days: 0, months: 42, years: 0, childName: childName);
    }



    else if (vaccine == 'Vitamin A-8') {
      return dateCalculator(dateTime1,
          days: 0, months: 48, years: 0, childName: childName);
    }


    else if (vaccine == 'Vitamin A-9') {
      return dateCalculator(dateTime1,
          days: 0, months: 54, years: 0, childName: childName);
    }

    else if (vaccine == 'Vitamin A-10') {
      return dateCalculator(dateTime1,
          days: 0, months: 60, years: 0, childName: childName);
    }
  }
}
