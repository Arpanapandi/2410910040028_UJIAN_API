import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/todo_model.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<TodoModel> todos = [];
  bool isLoading = true;

  Future<void> getTodos() async {
    try {
      final url = Uri.parse("https://dummyjson.com/todos");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Parsing JSON ke List<TodoModel>
        List<TodoModel> loadedTodos = (data["todos"] as List)
            .map((json) => TodoModel.fromJson(json))
            .toList();

        setState(() {
          todos = loadedTodos;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengambil data todos")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo List"),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : RefreshIndicator(
              onRefresh: getTodos,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        todo.todo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        "User ID: ${todo.userId}",
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: Icon(
                        todo.completed
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: todo.completed ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
