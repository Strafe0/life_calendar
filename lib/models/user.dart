class User {
  User(this._birthday);

  String? _name;
  String? _mail;
  final DateTime _birthday;
  bool plusVersion = false;

  DateTime get birthday => _birthday;

  
}