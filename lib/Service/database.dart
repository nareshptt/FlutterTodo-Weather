import 'package:firestore_ref/firestore_ref.dart';

class DatabaseMethos {
  Future addtaskDetails(Map<String, dynamic> TaskInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Task")
        .doc(id)
        .set(TaskInfoMap);
  }

  Future<Stream<QuerySnapshot>> gettaskDetails() async {
    return await FirebaseFirestore.instance.collection("Task").snapshots();
  }

  Future updatetaskDetails(String id, Map<String, dynamic> updateInfo) async {
    return await FirebaseFirestore.instance
        .collection("Task")
        .doc(id)
        .update(updateInfo);
  }

  Future deletetaskDetails(
    String id,
  ) async {
    return await FirebaseFirestore.instance.collection("Task").doc(id).delete();
  }
}
