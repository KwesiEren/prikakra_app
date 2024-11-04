import 'package:supabase_flutter/supabase_flutter.dart';

import 'task.dart';

//This is the codes to handle the Online database.
//The Supabase client was initialized in main.dart file so there
// is only the CRUD functions here.
class SupaDB {
  static Future<void> addtoSB(Todo todo) async {
    // push entry into the table
    final response =
        await Supabase.instance.client.from('todoTable').insert(todo.toJson());

    if (response.error != null) {
      throw Exception('Failed to add todo: ${response.error!.message}');
    }
  }

  static Future<List<Todo?>> getAllSB() async {
    // Get all elements in the table
    final response = await Supabase.instance.client
        .from('todoTable')
        .select('*'); // Use .execute() here

    final todos = response as List<dynamic>;
    return todos.map((json) => Todo.fromJson(json)).toList();
  }

  static Future<void> updateSB(Todo todo) async {
    //Updates element in the table by ID
    if (todo.id == null) {
      throw Exception('Todo ID cannot be null');
    }

    await Supabase.instance.client
        .from('todoTable')
        .update(todo.toJson())
        .eq('id', todo.id!);
  }

  static Future<void> deleteSB(int id) async {
    //Deletes element in table by ID
    final response =
        await Supabase.instance.client.from('todoTable').delete().eq('id', id);

    // Check for error
    if (response.error != null) {
      throw Exception('Failed to delete todo: ${response.error!.message}');
    }

    return response;
  }
}
