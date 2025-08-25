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
                _infoRow('Gov Doc Image', kyc.govDocImage, isDocument: true),
                _infoRow('Permit Image', kyc.permitImage, isDocument: true),
                _infoRow('Void Cheque', kyc.voidCheque, isDocument: true),
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

  // Helper method to determine if URL is an image
  bool _isImageFile(String url) {
    if (url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.jpg') ||
        lowerUrl.contains('.jpeg') ||
        lowerUrl.contains('.png') ||
        lowerUrl.contains('.gif') ||
        !lowerUrl.contains('.pdf') && !lowerUrl.contains('.doc');
  }

  // Helper method to get file name from URL
  String _getFileName(String url) {
    if (url.isEmpty) return 'Unknown file';
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return segments.last;
      }
    } catch (e) {
      // Fallback to basic extraction
      final parts = url.split('/');
      if (parts.isNotEmpty) {
        return parts.last.split('?').first; // Remove query parameters
      }
    }
    return 'Document file';
  }

  Widget _infoRow(String label, String value, {bool isDocument = false}) {
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
          isDocument
              ? _buildDocumentWidget(value)
              : Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDocumentWidget(String url) {
    if (url.isEmpty) {
      return const SizedBox(
        height: 120,
        width: 120,
        child: Center(child: Text('No document uploaded')),
      );
    }

    // Check if it's an image file
    if (_isImageFile(url)) {
      return SizedBox(
        height: 120,
        width: 120,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder:
                (context, url) =>
                    const Center(child: CircularProgressIndicator()),
            errorWidget:
                (context, url, error) => const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    Text('Error loading image'),
                  ],
                ),
          ),
        ),
      );
    } else {
      // It's a document (PDF/DOC)
      return SizedBox(
        height: 120,
        width: 130,
        child: Card(
          elevation: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description, size: 40, color: Colors.blue[600]),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  _getFileName(url),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
