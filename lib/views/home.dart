import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_simple/model/role.dart';
import 'package:todo_simple/model/todo.dart';
import 'package:todo_simple/view_model/todo.dart';
import 'package:todo_simple/view_model/auth.dart';

class HomeView extends ConsumerWidget {
  final UserRole role;
  const HomeView({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          role == UserRole.manager ? "📊 Manager Dashboard" : "✅ My Tasks",
        ),
        backgroundColor: role == UserRole.manager
            ? Colors.blueGrey
            : Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "Logout",
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),

      body: todosAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                "✨ No tasks yet. Create one!",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("users")
                    .doc(task.assignedTo)
                    .get(),
                builder: (context, assignedSnap) {
                  final assignedEmail =
                      assignedSnap.data?["email"] ?? "Unknown";

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("users")
                        .doc(task.createdBy)
                        .get(),
                    builder: (context, creatorSnap) {
                      final createdByEmail =
                          creatorSnap.data?["email"] ?? "Unknown";

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ Title & Status
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: task.isCompleted,
                                    activeColor: Colors.green,
                                    onChanged: (val) {
                                      final updatedTask = task.copyWith(
                                        isCompleted: val ?? false,
                                      );
                                      ref
                                          .read(todoProvider.notifier)
                                          .updateTask(updatedTask);
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: task.isCompleted
                                            ? Colors.grey
                                            : Colors.black,
                                        decoration: task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      task.isCompleted
                                          ? "Completed"
                                          : "Pending",
                                      style: TextStyle(
                                        color: task.isCompleted
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    backgroundColor: task.isCompleted
                                        ? Colors.green
                                        : Colors.orange[200],
                                  ),
                                ],
                              ),

                              if (task.description?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 8),
                                Text(
                                  task.description!,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],

                              const Divider(height: 24),

                              // ✅ Assigned + Created By
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "👤 Assigned: $assignedEmail",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "📝 Created by: $createdByEmail",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // ✅ Actions
                                  Row(
                                    children: [
                                      if (!(role == UserRole.employee &&
                                          task.assignedTo !=
                                              ref
                                                  .read(authRepositoryProvider)
                                                  .currentUser
                                                  ?.uid))
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () {
                                            _showTaskDialog(
                                              context,
                                              ref,
                                              task: task,
                                              role: role,
                                            );
                                          },
                                        ),
                                      if (role == UserRole.manager)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            ref
                                                .read(todoProvider.notifier)
                                                .deleteTask(task.id);
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: Text(
            "⚠️ Error: $err",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          _showTaskDialog(context, ref, role: role);
        },
        icon: const Icon(Icons.add),
        label: const Text("New Task"),
      ),
    );
  }

  /// Task Add/Edit Dialog
  void _showTaskDialog(
    BuildContext context,
    WidgetRef ref, {
    Task? task,
    required UserRole role,
  }) {
    final titleController = TextEditingController(text: task?.title ?? "");
    final descController = TextEditingController(text: task?.description ?? "");
    final currentUser = ref.read(authRepositoryProvider).currentUser;

    String? assignedTo =
        task?.assignedTo ??
        (role == UserRole.employee ? currentUser?.uid : null);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(task == null ? Icons.add : Icons.edit, color: Colors.blue),
            const SizedBox(width: 8),
            Text(task == null ? "Add New Task" : "Edit Task"),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (role == UserRole.manager)
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .where("role", isEqualTo: "employee")
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    final employees = snapshot.data!.docs;

                    return DropdownButtonFormField<String>(
                      value:
                          (assignedTo != null &&
                              employees.any((doc) => doc.id == assignedTo))
                          ? assignedTo
                          : null,
                      decoration: InputDecoration(
                        labelText: "Assign To",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: employees.map((doc) {
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(doc["email"] ?? "Unknown"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        assignedTo = val;
                      },
                    );
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final newTask = Task(
                id:
                    task?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                description: descController.text,
                assignedTo: assignedTo ?? currentUser?.uid ?? "",
                createdBy: task?.createdBy ?? currentUser?.uid ?? "",
                isCompleted: task?.isCompleted ?? false,
              );

              if (task == null) {
                ref.read(todoProvider.notifier).addTask(newTask);
              } else {
                ref.read(todoProvider.notifier).updateTask(newTask);
              }
              Navigator.pop(context);
            },
            icon: const Icon(Icons.save, color: Colors.white),
            label: Text(task == null ? "Add Task" : "Update Task"),
          ),
        ],
      ),
    );
  }
}
