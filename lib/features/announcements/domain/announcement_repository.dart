import 'announcement.dart';

abstract class AnnouncementRepository {

  Stream<List<Announcement>> watchAnnouncements();


  Stream<Set<String>> watchReadIds();

  Future<void> markRead(String announcementId);
}