import 'dart:convert';
import 'package:http/http.dart' as http;

class Todo {
  final int? id;
  final String todo;
  final bool completed;

  Todo({
    this.id,
    required this.todo,
    required this.completed,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      todo: json['todo'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo': todo,
      'completed': completed,
    };
  }
}

class ApiService {
  final String baseUrl = 'https://dummyjson.com';

  // Fetch all todos
  Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse('$baseUrl/todos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['todos'];
      return data.map((todo) => Todo.fromJson(todo)).toList();
    } else {
      throw Exception('Failed to load todos');
    }
  }

  // Add a new todo
  Future<Todo> addTodo(Todo todo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(todo.toJson()),
    );
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add todo');
    }
  }

  // Update a todo
  Future<Todo> updateTodo(int id, Todo todo) async {
    final response = await http.put(
      Uri.parse('$baseUrl/todos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(todo.toJson()),
    );
    if (response.statusCode == 200) {
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update todo');
    }
  }

  // Delete a todo
  Future<void> deleteTodo(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/todos/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo');
    }
  }
}
