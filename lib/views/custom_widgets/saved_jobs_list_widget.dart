import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swamper_solution/consts/custom_text_styles.dart';
import 'package:swamper_solution/models/job_model.dart';
import 'package:swamper_solution/providers/all_providers.dart';

class SavedJobsListWidget extends ConsumerWidget {
  final JobModel job;
  const SavedJobsListWidget({super.key, required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 0.6, color: Colors.black26),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: job.images[0],
              height: 80,
              width: 90,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  job.role,
                  style: CustomTextStyles.h4,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  job.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyles.description.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // remove from saved jobs
              ref.read(jobControllerProvider).saveJob(job.jobId);
              ref.invalidate(jobControllerProvider);
            },
            icon: Icon(FeatherIcons.trash2, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
