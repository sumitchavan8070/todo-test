import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/utilities/box_decoration.dart';

class ToDoListScreen extends StatefulWidget {
  const ToDoListScreen({Key? key}) : super(key: key);

  @override
  ToDoListScreenState createState() => ToDoListScreenState();
}

class ToDoListScreenState extends State<ToDoListScreen> with TickerProviderStateMixin {
  List<Task> tasks = [];
  TextEditingController taskController = TextEditingController();
  late SharedPreferences prefs;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // adjust the duration as needed
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadTasks() async {
    prefs = await SharedPreferences.getInstance();
    final List<String>? taskList = prefs.getStringList('tasks');
    if (taskList != null) {
      setState(() {
        tasks = taskList.map((String taskJson) => Task.fromJson(taskJson)).toList();
      });
    }
  }

  void _saveTasks() {
    final List<String> taskList = tasks.map((Task task) => task.toJson()).toList();
    prefs.setStringList('tasks', taskList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FE),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'To-Do List',
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/profile.jpg'), // Replace with your image asset
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            tasks.isEmpty
                ? _buildWelcomeContainer()
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskContainer(tasks[index], index);
                    },
                  ),
            const SizedBox(height: 150)
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Add Task"),
                  content: TextField(
                    controller: taskController,
                    decoration: const InputDecoration(hintText: "Enter task title"),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("Add"),
                      onPressed: () {
                        if (taskController.text.trim().isNotEmpty) {
                          addTask(taskController.text.trim());
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Task cannot be empty'),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: const Text('Add Task'),
        ),
      ),
    );
  }

  Widget _buildWelcomeContainer() {
    return Container(
      height: 200.0,
      alignment: Alignment.center,
      child: Text('Oops, you have empty tasks',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              )),
    );
  }

  Widget _buildTaskContainer(Task task, int index) {
    TextEditingController taskEditingController = TextEditingController(
      text: task.title,
    );

    return GestureDetector(
      onTap: () {
        if (!task.isCompleted) {
          markTaskComplete(index);
        } else {
          _editTaskTitle(index);
        }
      },
      // onLongPress: () {
      //   if (!task.isCompleted) {
      //     _editTaskTitle(index);
      //   } else {
      //     deleteTask(index);
      //   }
      // },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: AppBoxDecoration.getBoxDecoration(
          showShadow: false,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextField(
              readOnly: task.isCompleted,
              maxLines: null,
              // Allow unlimited lines
              controller: taskEditingController,
              cursorColor: Colors.amber,
              onChanged: (newText) {
                setState(() {
                  tasks[index].title = newText;
                });
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusColor: Colors.green,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: task.isCompleted
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                        )
                      : const Icon(Icons.check),
                  onPressed: () {
                    markTaskComplete(index);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _editTaskTitle(index);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    deleteTask(index);
                  },
                ),
              ],
            ),
            Text(
              'Created: ${task.createdDate.toString()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void addTask(String title) {
    setState(() {
      tasks.add(
        Task(
          title: title,
          createdDate: DateTime.now(),
        ),
      );
      taskController.clear();
      _saveTasks();
    });
  }

  void markTaskComplete(int index) {
    setState(() {
      tasks[index].isCompleted = true;
      _saveTasks();
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      _saveTasks();
    });
  }

  void _editTaskTitle(int index) {
    String currentTitle = tasks[index].title;
    TextEditingController editingController = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: TextField(
            controller: editingController,
            decoration: const InputDecoration(
              hintText: "Enter new task title",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Save"),
              onPressed: () {
                setState(() {
                  tasks[index].title = editingController.text.trim();
                  _saveTasks(); // Save tasks after editing a task
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class Task {
  String title;
  bool isCompleted;
  DateTime createdDate;

  Task({
    required this.title,
    this.isCompleted = false,
    required this.createdDate,
  });

  // Convert Task to JSON
  String toJson() {
    return '{"title": "$title", "isCompleted": $isCompleted, "createdDate": "${createdDate.toIso8601String()}"}';
  }

  // Create Task from JSON
  factory Task.fromJson(String json) {
    Map<String, dynamic> data = jsonDecode(json);
    return Task(
      title: data['title'],
      isCompleted: data['isCompleted'],
      createdDate: DateTime.parse(data['createdDate']),
    );
  }
}
