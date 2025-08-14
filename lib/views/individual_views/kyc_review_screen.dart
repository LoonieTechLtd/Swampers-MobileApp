import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:swamper_solution/providers/all_providers.dart';

class KycReviewScreen extends ConsumerWidget {
  const KycReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kycAsync = ref.watch(getKycData);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Due Diligence Review'),
        actions: [
          TextButton(
            onPressed: () {
              context.pushNamed("edit_kyc");
            },
            child: Text("Edit Your Due Diligence details"),
          ),
        ],
      ),
      body: SafeArea(
        child: kycAsync.when(
          data: (kyc) {
            if (kyc == null) {
              return const Center(child: Text('No Due Diligence data found.'));
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Personal Info',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                _infoRow(
                  'Name',
                  '${kyc.userInfo.firstName} ${kyc.userInfo.lastName}',
                ),
                _infoRow('Email', kyc.userInfo.email),
                _infoRow('DOB', kyc.dob),
                _infoRow('Gender', kyc.gender),
                _infoRow('Status in Canada', kyc.statusInCanada),
                _infoRow('Mode of Travel', kyc.modeOfTravel),
                _infoRow('Address', kyc.userInfo.address),
                _infoRow('Postal Code', kyc.postalCode),
                _infoRow('APT/Suite No', kyc.aptNo),
                const Divider(),
                Text(
                  'Bank Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _infoRow('Institution No', kyc.institutionNumber),
                _infoRow('Institution Name', kyc.institutionName),
                _infoRow('Transit No', kyc.transitNumber),
                _infoRow('Account No', kyc.bankAccNumber),
                const Divider(),
                Text(
                  'Documents',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _infoRow('Gov Doc Image', kyc.govDocImage, isImage: true),
                _infoRow('Permit Image', kyc.permitImage, isImage: true),
                _infoRow('Void Cheque', kyc.voidCheque, isImage: true),
                const Divider(),
                Text(
                  'Emergency Contact',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _infoRow('Name', kyc.emergencyContactName),
                _infoRow('Number', kyc.emergencyContactNo),
                const Divider(),
                Text(
                  'SIN Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _infoRow('SIN Number', kyc.sinNumber),
                _infoRow('SIN Expiry', kyc.sinExpiry),
                const Divider(),
                Text(
                  'Criminal Record',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _infoRow(
                  'Has Criminal Record',
                  kyc.haveCriminalRecord ? 'Yes' : 'No',
                ),
                if (kyc.haveCriminalRecord &&
                    kyc.crimes != null &&
                    kyc.crimes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...kyc.crimes!.map(
                    (crime) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(crime.offence),
                        subtitle: Text(
                          'Date: \\${crime.dateOfSentence}\nCourt: \\${crime.courtLocation}',
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
          error: (e, st) => Center(child: Text('Error: $e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isImage = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          isImage
              ? SizedBox(
                height: 120,
                width: 120,
                child: ClipRRect(
                  child: CachedNetworkImage(imageUrl: value, fit: BoxFit.cover),
                ),
              )
              : Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
