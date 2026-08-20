import 'class_slot.dart';
import 'subject.dart';

abstract class TimetableRepository {
  Stream<List<Subject>> watchSubjects();
  Future<String> addSubject({required String code, required String name});
  Future<void> deleteSubject(String subjectId);

  Stream<List<ClassSlot>> watchClassSlots();
  Future<void> addClassSlot(ClassSlot slot);
  Future<void> deleteClassSlot(String slotId);
}