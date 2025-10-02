import '../models/database_helper.dart';
import '../models/item.dart';

class InventoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<bool> addItem(Item item) async {
    try {
      await _dbHelper.insertItem(item);
      return true;
    } catch (e) {
      print('Error adding item: $e');
      return false;
    }
  }

  Future<List<Item>> getBusinessItems(int businessId) async {
    return await _dbHelper.getItemsByBusinessId(businessId);
  }

  Future<bool> updateItem(Item item) async {
    try {
      // TODO: Implement update item functionality in DatabaseHelper
      return true;
    } catch (e) {
      print('Error updating item: $e');
      return false;
    }
  }

  Future<bool> deleteItem(int itemId) async {
    try {
      // TODO: Implement delete item functionality in DatabaseHelper
      return true;
    } catch (e) {
      print('Error deleting item: $e');
      return false;
    }
  }
} 