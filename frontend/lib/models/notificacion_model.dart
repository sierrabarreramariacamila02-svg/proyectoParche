class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime date;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.isRead = false,
  });
}