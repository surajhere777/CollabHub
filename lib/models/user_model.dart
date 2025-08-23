import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String firstname;
  final String lastname;
  final String token;
  final String rating;
  final String education;
  final String stream;
  final String info;
  final int totalprojects;
  final int completedprojects;
  final List<String> skills;

  UserModel({
    required this.uid,
    required this.firstname,
    required this.lastname,
    required this.token,
    required this.rating,
    required this.info,
    required this.totalprojects,
    required this.completedprojects,
    required this.education,
    required this.stream,
    required this.skills,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      firstname: data['firstname'] ?? ' ',
      lastname: data['lastname'] ?? ' ',
      token: data['token'] ?? ' ',
      rating: data['rating'] ?? ' ',
      info: data['info'] ?? ' ',
      totalprojects: data['totalprojects'] ?? 0,
      completedprojects: data['completedproject'] ?? 0,
      education: data['education'] ?? ' ',
      stream: data['stream'] ?? ' ',
      skills: List<String>.from(data['skills']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'token': token,
      'rating': rating,
      'info': info,
      'totalprojects': totalprojects,
      'completedproject': completedprojects,
      'education': education,
      'stream': stream,
      'skills': skills,
    };
  }
}
