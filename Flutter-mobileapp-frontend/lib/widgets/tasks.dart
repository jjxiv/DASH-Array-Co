import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/todo_provider.dart';

class TasksWidget extends StatefulWidget {
  const TasksWidget({Key? key}) : super(key: key);

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
  TextEditingController newTaskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: newTaskController,
                  decoration: InputDecoration(
                    labelText: 'New Task',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 10,),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.amberAccent),
                      foregroundColor: MaterialStateProperty.all(Colors.purple)
                  ),
                  child: Text("Add"),
                  onPressed: () {
                    Provider.of<TodoProvider>(context, listen: false).addTodo(newTaskController.text);
                    newTaskController.clear();
                  }
              )
            ],
          ),
          FutureBuilder(
            future: Provider.of<TodoProvider>(context, listen: false).getTodos,
            builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                :
            Consumer<TodoProvider>(
              child: Center(
                heightFactor: MediaQuery.of(context).size.height * 0.03,
                child: const Text('You have no tasks.', style: TextStyle(fontSize: 18),),
              ),
              builder: (ctx, todoProvider, child) => todoProvider.items.isEmpty
                  ?  child as Widget
                  : Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: ListView.builder(
                      itemCount: todoProvider.items.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: ListTile(
                          tileColor: Colors.black12,
                          leading: Checkbox(
                              value: todoProvider.items[i].isExecuted,
                              activeColor: Colors.purple,
                              onChanged:(newValue) {
                                Provider.of<TodoProvider>(context, listen: false).executeTask(todoProvider.items[i].id);
                              }
                          ),
                          title: Text(todoProvider.items[i].itemName),
                          trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: ()  {
                                Provider.of<TodoProvider>(context, listen: false).deleteTodo(todoProvider.items[i].id);
                              }
                          ) ,
                          onTap: () {},
                        ),
                      )
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}