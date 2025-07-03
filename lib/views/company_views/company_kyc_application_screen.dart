import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompanyKycApplicationScreen extends ConsumerWidget {
  const CompanyKycApplicationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [Text("Company Kyc Application Screen")]),
        
      ),
    );
  }
}
