import 'assignment.dart';

abstract class AssignmentRepository {
  Stream<List<Assignment>> watchAssignments();
  Future<void> addAssignment(Assignment assignment);
  Future<void> toggleDone(String assignmentId, bool done);
  Future<void> deleteAssignment(String assignmentId);
}