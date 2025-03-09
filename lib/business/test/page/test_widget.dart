import 'package:eeg/business/assess/page/assess_upload_page.dart';
import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: AssessUploadPage(patientId: 1, patientEvaluationId: 1),
      ),
    );
  }
}
