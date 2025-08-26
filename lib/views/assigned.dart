import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/role.dart';
import '../model/todo.dart';
import '../provider/auth_provider.dart';
import '../utils/colors.dart' show AppColors, textWhite;
import '../view_model/todo.dart';

class AddEditTaskPage extends ConsumerStatefulWidget {
  final Task? task;
  final UserRole role;

  const AddEditTaskPage({super.key, this.task, required this.role});

  @override
  ConsumerState<AddEditTaskPage> createState() => _AddEditTaskPageState();
}

class _AddEditTaskPageState extends ConsumerState<AddEditTaskPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String? _assignedTo;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? "");
    _descController = TextEditingController(
      text: widget.task?.description ?? "",
    );
    _assignedTo = widget.task?.assignedTo;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.read(authRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: AppColors.textWhite),
        title: Text(
          widget.task == null ? "Add Task" : "Edit Task",
          style: TextStyle(color: AppColors.textWhite),
        ),
        backgroundColor: widget.role == UserRole.manager
            ? Colors.blueAccent
            : Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter a title" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Manager assigns task
              if (widget.role == UserRole.manager)
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
                          (_assignedTo != null &&
                              employees.any((doc) => doc.id == _assignedTo))
                          ? _assignedTo
                          : null,
                      decoration: const InputDecoration(
                        labelText: "Assign To",
                        border: OutlineInputBorder(),
                      ),
                      items: employees.map((doc) {
                        return DropdownMenuItem(
                          value: doc.id,
                          child: Text(doc["name"] ?? "Unknown"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _assignedTo = val);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.role == UserRole.manager
                  ? Colors.blueAccent
                  : Colors.teal,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newTask = Task(
                  id:
                      widget.task?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text.trim(),
                  description: _descController.text.trim(),
                  assignedTo: widget.role == UserRole.manager
                      ? (_assignedTo ?? "")
                      : null,
                  createdBy: widget.task?.createdBy ?? currentUser?.uid ?? "",
                  createdAt: widget.task?.createdAt ?? Timestamp.now(),
                  isCompleted: widget.task?.isCompleted ?? false,
                );

                if (widget.task == null) {
                  ref.read(todoProvider.notifier).addTask(newTask);
                } else {
                  ref.read(todoProvider.notifier).updateTask(newTask);
                }

                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.save, color: Colors.white),
            label: Text(
              widget.task == null ? "Add Task" : "Update Task",
              style: TextStyle(color: AppColors.textWhite),
            ),
          ),
        ),
      ),
    );
  }
}
