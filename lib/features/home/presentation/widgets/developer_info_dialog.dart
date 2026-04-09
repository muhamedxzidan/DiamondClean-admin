import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:diamond_clean/core/constants/app_strings.dart';

void showDeveloperDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(AppStrings.developerTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'mohamed\nzidan',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.developerSubtitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _SocialAction(
                icon: Icons.facebook,
                label: AppStrings.developerFacebook,
                onTap: () => _openUrl(context, _developerFacebookUrl),
              ),
              _SocialAction(
                icon: Icons.chat,
                label: AppStrings.developerWhatsapp,
                onTap: () => _openUrl(context, _developerWhatsappUrl),
              ),
              _SocialAction(
                icon: Icons.work_outline,
                label: AppStrings.developerLinkedIn,
                onTap: () => _openUrl(context, _developerLinkedInUrl),
              ),
              _SocialAction(
                icon: Icons.email_outlined,
                label: AppStrings.developerEmail,
                onTap: () => _openUrl(context, _developerEmailUrl),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text(AppStrings.cancel),
        ),
      ],
    ),
  );
}

const _developerFacebookUrl = 'https://www.facebook.com/mohamedxzedan';
const _developerWhatsappUrl = 'https://wa.me/201070707781';
const _developerLinkedInUrl = 'https://www.linkedin.com/in/mohamedxzidan/';
const _developerEmailUrl = 'mailto:mc.oza012@gmail.com';

Future<void> _openUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط')));
  }
}

class _SocialAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
