import 'package:flutter/material.dart';

import 'package:Myapp/Service/database.dart';
import 'package:random_string/random_string.dart';

class addTaskPage extends StatefulWidget {
  const addTaskPage({super.key});

  @override
  State<addTaskPage> createState() => _addTaskPageState();
}

class _addTaskPageState extends State<addTaskPage> {
  TextEditingController titleControler = TextEditingController();

  TextEditingController decControler = TextEditingController();

  addData(String title, String description) async {
    if (title == "" || description == "") {
      print(Text("Please Enter Data"));
    } else {
      String Id = randomAlphaNumeric(10);
      Map<String, dynamic> taskInfoMap = {
        "Title": titleControler.text,
        "Id": Id,
        "Description": decControler.text
      };
      await DatabaseMethos().addtaskDetails(taskInfoMap, Id).then((value) {
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Add",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Task",
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          centerTitle: true,
        ),
        body: ListView(children: [
          Container(
            margin: EdgeInsets.only(left: 20, top: 30, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Title",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: titleControler,
                    decoration: InputDecoration(
                        hintText: "Enter title", border: InputBorder.none),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "Description",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    controller: decControler,
                    decoration: InputDecoration(
                        hintText: "Enter Description",
                        border: InputBorder.none),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                    child: Container(
                        width: 150,
                        child: ElevatedButton(
                            onPressed: () async {
                              addData(
                                titleControler.text.toString(),
                                decControler.text.toString(),
                              );
                            },
                            child: Text("Add"))))
              ],
            ),
          ),
        ]));
  }
}
