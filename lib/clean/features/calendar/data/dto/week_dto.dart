class WeekDto {
  WeekDto({
    required this.id,
    required this.yearId,
    required this.start,
    required this.end,
    required this.weekState,
    required this.assessment,
    this.goals = const [],
    this.events = const [],
    required this.resume,
    this.photos = const [],
  });

  int id;
  int yearId;
  int start;
  int end;
  String weekState;
  String assessment;
  List<Map<String, dynamic>> goals;
  List<Map<String, dynamic>> events;
  String resume;
  List<String> photos;
}