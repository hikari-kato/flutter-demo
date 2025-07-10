import 'package:flutter/material.dart';

void main() {
  runApp(const SimpleTodoApp());
}

class SimpleTodoApp extends StatelessWidget {
  const SimpleTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '今日やることリスト',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SimpleTodoHomePage(),
    );
  }
}

class TodoItem {
  String id;
  String title;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

class SimpleTodoHomePage extends StatefulWidget {
  const SimpleTodoHomePage({super.key});

  @override
  State<SimpleTodoHomePage> createState() => _SimpleTodoHomePageState();
}

class _SimpleTodoHomePageState extends State<SimpleTodoHomePage> {
  List<TodoItem> _todos = [];
  final TextEditingController _textController = TextEditingController();
  String? _editingId;
  final TextEditingController _editController = TextEditingController();

  void _addTodo() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _todos.add(TodoItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _textController.text,
        ));
        _textController.clear();
      });
    }
  }

  void _toggleTodo(String id) {
    setState(() {
      final todoIndex = _todos.indexWhere((todo) => todo.id == id);
      if (todoIndex != -1) {
        _todos[todoIndex].isCompleted = !_todos[todoIndex].isCompleted;
      }
    });
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
  }

  void _reorderTodos(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _todos.removeAt(oldIndex);
      _todos.insert(newIndex, item);
    });
  }

  void _startEditing(String id, String currentTitle) {
    setState(() {
      _editingId = id;
      _editController.text = currentTitle;
    });
  }

  void _saveEdit() {
    if (_editingId != null && _editController.text.isNotEmpty) {
      setState(() {
        final todoIndex = _todos.indexWhere((todo) => todo.id == _editingId);
        if (todoIndex != -1) {
          _todos[todoIndex].title = _editController.text;
        }
        _editingId = null;
        _editController.clear();
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _editingId = null;
      _editController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('今日やることリスト'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: '新しいタスクを入力',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: _todos.isEmpty
                ? const Center(
                    child: Text(
                      'タスクがありません\n上の入力欄から追加してください',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ReorderableListView(
                    onReorder: _reorderTodos,
                    children: _todos.map((todo) {
                      return ListTile(
                        key: Key(todo.id),
                        leading: Checkbox(
                          value: todo.isCompleted,
                          onChanged: (bool? value) {
                            _toggleTodo(todo.id);
                          },
                        ),
                        title: _editingId == todo.id
                            ? TextField(
                                controller: _editController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                onSubmitted: (_) => _saveEdit(),
                                autofocus: true,
                              )
                            : GestureDetector(
                                onTap: () => _startEditing(todo.id, todo.title),
                                child: Text(
                                  todo.title,
                                  style: TextStyle(
                                    decoration: todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: todo.isCompleted
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                              ),
                        trailing: _editingId == todo.id
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    onPressed: _saveEdit,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                    onPressed: _cancelEdit,
                                  ),
                                ],
                              )
                            : IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteTodo(todo.id),
                              ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _editController.dispose();
    super.dispose();
  }
}