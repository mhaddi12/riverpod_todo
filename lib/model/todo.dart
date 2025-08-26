// lib/model/task.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String? assignedTo; // uid of employee
  final String? createdBy; // uid of manager
  final bool isCompleted;
  final String? description; // optional description
  final Timestamp? createdAt;

  Task({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.createdBy,
    this.isCompleted = false,
    this.description,
    this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json, String id) {
    return Task(
      id: id,
      title: json['title'] ?? '',
      assignedTo: json['assignedTo'] ?? null,
      createdBy: json['createdBy'] ?? null,
      isCompleted: json['isCompleted'] ?? false,
      description: json['description'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'isCompleted': isCompleted,
      'description': description,
      "createdAt": createdAt,
    };
  }

  factory Task.fromDoc(DocumentSnapshot doc) {
    return Task.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }
  Task copyWith({
    String? id,
    String? title,
    String? assignedTo,
    String? createdBy,
    bool? isCompleted,
    String? description,
    Timestamp? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      isCompleted: isCompleted ?? this.isCompleted,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
