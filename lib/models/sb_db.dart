import 'package:supabase_flutter/supabase_flutter.dart';

import 'task.dart';

class SupaDB {
  static Future<void> addtoSB(Todo todo) async {
    final response =
        await Supabase.instance.client.from('todoTable').insert(todo.toJson());

    if (response.error != null) {
      throw Exception('Failed to add todo: ${response.error!.message}');
    }
  }

  static Future<List<Todo?>> getAllSB() async {
    final response = await Supabase.instance.client
        .from('todoTable')
        .select('*'); // Use .execute() here

    final todos = response as List<dynamic>;
    return todos.map((json) => Todo.fromJson(json)).toList();
  }

  static Future<void> updateSB(Todo todo) async {
    if (todo.id == null) {
      throw Exception('Todo ID cannot be null');
    }

    final response = await Supabase.instance.client
            .from('todoTable')
            .update(todo.toJson())
            .eq('id', todo.id!) // Use non-null assertion here
        ;

    // Check for error
    if (response.error != null) {
      throw Exception('Failed to update todo: ${response.error!.message}');
    }
  }

  static Future<void> deleteSB(int id) async {
    final response =
        await Supabase.instance.client.from('todoTable').delete().eq('id', id);

    // Check for error
    if (response.error != null) {
      throw Exception('Failed to delete todo: ${response.error!.message}');
    }

    return response;
  }
}
