import 'study_session.dart';

abstract class StudyRepository {
  Stream<List<StudySession>> watchSessions();
  Future<void> addSession(StudySession session);
  Future<void> toggleDone(String sessionId, bool done);
  Future<void> deleteSession(String sessionId);

  Stream<List<StudyGoal>> watchGoals();
  Future<void> setGoal(String subjectId, int weeklyHours);
}