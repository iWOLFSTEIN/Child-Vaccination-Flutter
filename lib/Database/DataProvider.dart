import 'package:child_vaccination/Database/DatabaseHelper.dart';
import 'package:flutter/cupertino.dart';

class DataProvider with ChangeNotifier {
  DataProvider(this._items, this._itemsVaccine, this.db) {
    fetchAndSetData();
  }
  DatabaseHelper db;

  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => [..._items];
  static final table = 'ChildrenTable';
  Future<void> fetchAndSetData() async {
    final dataList = await db.queryAllChildrenRows();
    _items = dataList;
    notifyListeners();
  }

  addChildrenTableRow(row) async {
    await db.insertChildren(row);
    fetchAndSetData();
    notifyListeners();
  }

  deleteChildrenTableRow(int id, var name) async {
    await db.deleteChildren(id);
    fetchAndSetData();
    notifyListeners();
    await db.deleteVaccineTable(name + id.toString());
  }

  updateChildrenTableRow(row) async {
    await db.updateChildren(row);
    fetchAndSetData();
    notifyListeners();
  }

  List<Map<String, dynamic>> _itemsVaccine = [];
  List<Map<String, dynamic>> get itemsVaccine => [..._itemsVaccine];

  set itemsVaccine(var value) {
    fetchAndSetVaccineData(value);
  }

  Future<void> fetchAndSetVaccineData(value) async {
    final dataList = await db.queryAllVaccineRows(value);
    _itemsVaccine = dataList;
    notifyListeners();
  }

  updateVaccineTableRow(tableName, row) async {
    await db.updateVaccineTable(tableName, row);
    fetchAndSetVaccineData(tableName);
    notifyListeners();
  }
}
