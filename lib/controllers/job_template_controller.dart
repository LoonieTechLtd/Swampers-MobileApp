import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swamper_solution/models/jobs_template_model.dart';

class JobTemplateController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<JobsTemplateModel>> fetchJobTemplates() async {
    final querySnap = await firestore.collection('jobRoles').get();

    return querySnap.docs
        .map((doc) => JobsTemplateModel.fromMap(doc.data()))
        .toList();
  }
}
