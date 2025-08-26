import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_simple/model/role.dart';
import 'package:todo_simple/model/todo.dart';
import 'package:todo_simple/repo/todo_repo.dart';
import 'package:todo_simple/views/employee.dart';
import '../provider/todo_provider.dart' show todoRepositoryProvider;
import 'assigned.dart';
import '../provider/auth_provider.dart' show authRepositoryProvider;
import '../utils/colors.dart';

/// 🔹 Provider to load all users at once
final usersProvider = StreamProvider<Map<String, String>>((ref) {
  return FirebaseFirestore.instance.collection("users").snapshots().map((
    snapshot,
  ) {
    final map = <String, String>{};
    for (var doc in snapshot.docs) {
      map[doc.id] = (doc.data()["email"] ?? "Unknown") as String;
    }
    return map;
  });
});

class HomeView extends ConsumerWidget {
  final UserRole role;
  const HomeView({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(todoRepositoryProvider);
    final currentUid = ref.read(authRepositoryProvider).currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: AppColors.textWhite,
      appBar: AppBar(
        title: Text(
          role == UserRole.manager ? "📊 Manager Dashboard" : "✅ My Tasks",
          style: const TextStyle(color: AppColors.textWhite),
        ),
        backgroundColor: role == UserRole.manager
            ? Colors.blueAccent
            : Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textWhite),
            tooltip: "Logout",
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmployeeListView()),
              );
            },
            icon: const Icon(Icons.person, color: AppColors.textWhite),
          ),
        ],
      ),

      /// 🔹 StreamBuilder for tasks
      body: StreamBuilder<List<Task>>(
        stream: repo.fetchTasks(currentUid, role),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "⚠️ Error: ${snapshot.error}",
                style: const TextStyle(color: AppColors.error),
              ),
            );
          }

          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                "✨ No tasks yet. Create one!",
                style: TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              // 🔹 Employees only see their own
              bool canSee =
                  role == UserRole.manager ||
                  task.createdBy == currentUid ||
                  task.assignedTo == currentUid;

              if (!canSee) return const SizedBox.shrink();

              return TaskCard(task: task, role: role);
            },
          );
        },
      ),

      // ✅ FAB
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditTaskPage(role: role)),
          );
        },
        icon: const Icon(Icons.add, color: AppColors.textWhite),
        label: const Text(
          "New Task",
          style: TextStyle(color: AppColors.textWhite),
        ),
      ),
    );
  }
}

class TaskCard extends ConsumerWidget {
  final Task task;
  final UserRole role;

  const TaskCard({super.key, required this.task, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = ref.read(authRepositoryProvider).currentUser?.uid;
    final usersAsync = ref.watch(usersProvider);

    return Card(
      color: AppColors.grey100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Title & Status
            Row(
              children: [
                Checkbox(
                  value: task.isCompleted,
                  activeColor: AppColors.success,
                  onChanged: (val) {
                    final updatedTask = task.copyWith(
                      isCompleted: val ?? false,
                    );
                    ref.read(todoRepositoryProvider).updateTask(updatedTask);
                  },
                ),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: task.isCompleted ? Colors.grey : Colors.black,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    task.isCompleted ? "Completed" : "Pending",
                    style: TextStyle(
                      color: task.isCompleted ? Colors.white : Colors.black87,
                    ),
                  ),
                  backgroundColor: task.isCompleted
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ],
            ),

            if (task.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(
                task.description!,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],

            const Divider(),

            usersAsync.when(
              data: (usersMap) {
                final assignedEmail = task.assignedTo != null
                    ? usersMap[task.assignedTo] ?? "null"
                    : "Unassigned";

                final createdByEmail = usersMap[task.createdBy] ?? "Unknown";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                );
              },
              loading: () => const Text("Loading users..."),
              error: (_, __) => const Text("⚠️ Failed to load users"),
            ),

            // ✅ Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!(role == UserRole.employee &&
                    task.assignedTo != currentUid))
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddEditTaskPage(task: task, role: role),
                        ),
                      );
                    },
                  ),
                if (role == UserRole.manager)
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () {
                      ref.read(todoRepositoryProvider).deleteTask(task.id);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
