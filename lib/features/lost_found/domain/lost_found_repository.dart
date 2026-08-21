import 'lost_item.dart';

abstract class LostFoundRepository {
  Stream<List<LostItem>> watchItems();
  Future<void> addItem(LostItem item);
  Future<void> markResolved(String itemId, bool resolved);
  Future<void> deleteItem(String itemId);
}