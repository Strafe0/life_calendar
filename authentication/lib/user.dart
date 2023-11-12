import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({required this.id, this.birthday, this.name = '', this.email = ''});

  final String id;
  final String? name;
  final String? email;
  final DateTime? birthday;

  static const empty = User(id: '');

  bool get isEmpty => this == User.empty;
  bool get isNotEmpty => this != User.empty;

  @override
  List<Object?> get props => [id];
}