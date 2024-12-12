import 'package:flutter/material.dart';
import 'package:to_do_list/service/service_for_get.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Todo>> todosFuture;

  @override
  void initState() {
    super.initState();
    todosFuture = apiService.fetchTodos();
  }

  void refreshTodos() {
    setState(() {
      todosFuture = apiService.fetchTodos();
    });
  }

  Future<void> _addTodo() async {
    final TextEditingController todoController = TextEditingController();
    bool isCompleted = false;

    await showDialog(
      context: context,
      builder: (context) {
        // ... your dialog code
        return AlertDialog(
          // ...
          actions: [
            // ...
            ElevatedButton(
              onPressed: () async {
                if (todoController.text.isNotEmpty) {
                  try {
                    await apiService.addTodo(
                      Todo(
                        todo: todoController.text,
                        completed: isCompleted,
                      ),
                    );
                    refreshTodos();
                    Navigator.pop(context);
                  } catch (error) {
                    // Handle error, e.g., show a snackbar with error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error adding todo: $error'),
                      ),
                    );
                  }
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editTodoDialog(Todo todo) async {
    final TextEditingController todoController =
        TextEditingController(text: todo.todo);
    bool isCompleted = todo.completed;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text('Edit Todo', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: todoController,
                decoration: InputDecoration(
                  labelText: 'Todo Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: isCompleted,
                    onChanged: (value) {
                      setState(() {
                        isCompleted = value ?? false;
                      });
                    },
                  ),
                  Text('Mark as Completed', style: TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (todoController.text.isNotEmpty) {
                  await apiService.updateTodo(
                    todo.id!,
                    Todo(
                      id: todo.id,
                      todo: todoController.text,
                      completed: isCompleted,
                    ),
                  );
                  refreshTodos();
                  Navigator.pop(context);
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTodoDialog(int id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Todo', style: TextStyle(color: Colors.red)),
          content: Text('Are you sure you want to delete this todo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await apiService.deleteTodo(id);
                refreshTodos();
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todo List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addTodo,
          ),
        ],
      ),
      body: FutureBuilder<List<Todo>>(
        future: todosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final todos = snapshot.data!;
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      todo.todo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: todo.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: todo.completed
                        ? Chip(
                            label: Text('Completed'),
                            backgroundColor: Colors.green.shade100,
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: todo.completed,
                          onChanged: (bool? value) async {
                            await apiService.updateTodo(
                              todo.id!,
                              Todo(
                                id: todo.id,
                                todo: todo.todo,
                                completed: value ?? false,
                              ),
                            );
                            refreshTodos();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editTodoDialog(todo),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTodoDialog(todo.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
