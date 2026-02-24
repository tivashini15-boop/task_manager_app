import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Task> taskBox;
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box<Task>('tasks');
    tasks = taskBox.values.toList();
  }

  void addTask(String title, String desc, DateTime date) {
    final task = Task(title: title, description: desc, date: date);
    taskBox.add(task);
    setState(() {
      tasks = taskBox.values.toList();
    });
  }

  void deleteTask(int index) {
    taskBox.deleteAt(index);
    setState(() {
      tasks = taskBox.values.toList();
    });
  }

  void toggleTask(int index) {
    final task = taskBox.getAt(index);
    task!.isDone = !task.isDone;
    task.save();
    setState(() {
      tasks = taskBox.values.toList();
    });
  }

  void showAddDialog() {
    TextEditingController title = TextEditingController();
    TextEditingController desc = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Add Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: desc,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? "No date chosen"
                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    ),
                  ),
                  TextButton(
                    child: const Text("Pick Date"),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setStateDialog(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedDate != null && title.text.isNotEmpty) {
                  addTask(title.text, desc.text, selectedDate!);
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  void confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              deleteTask(index);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task Manager")),
      body: tasks.isEmpty
          ? const Center(child: Text("No tasks yet"))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, i) => TaskTile(
                task: tasks[i],
                onToggle: () => toggleTask(i),
                onDelete: () => confirmDelete(i),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
