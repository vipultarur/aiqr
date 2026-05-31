import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aiqr_app/features/generator/screens/string_qr_creator_screen.dart';
import 'package:aiqr_app/core/theme/app_theme.dart';
import 'package:aiqr_app/core/ads/banner_ad_widget.dart';

class AllQrTypesScreen extends StatelessWidget {
  const AllQrTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final List<Map<String, dynamic>> allOptions = [
      {'title': 'Website URL', 'subtitle': 'Link to any webpage or portfolio', 'icon': Icons.language, 'isBinary': false, 'type': 'URL'},
      {'title': 'WiFi Network', 'subtitle': 'Share your network credentials', 'icon': Icons.wifi, 'isBinary': false, 'type': 'Wi-Fi'},
      {'title': 'Email', 'subtitle': 'Pre-filled email message', 'icon': Icons.email, 'isBinary': false, 'type': 'Email'},
      {'title': 'Phone Number', 'subtitle': 'Call or message a contact', 'icon': Icons.phone, 'isBinary': false, 'type': 'Number'},
      {'title': 'Location / Map', 'subtitle': 'Share a geographic location', 'icon': Icons.map, 'isBinary': false, 'type': 'Map'},
      {'title': 'vCard Contact', 'subtitle': 'Share phone and social profiles', 'icon': Icons.contact_page, 'isBinary': false, 'type': 'vCard'},
      {'title': 'Social Media', 'subtitle': 'Direct link to your social profiles', 'icon': Icons.share, 'isBinary': false, 'type': 'URL'},
      {'title': 'Plain Text', 'subtitle': 'Simple text messages or notes', 'icon': Icons.notes, 'isBinary': false, 'type': 'Text'},
      {'title': 'UPI Payment', 'subtitle': 'Receive fast payments', 'icon': Icons.currency_rupee, 'isBinary': false, 'type': 'UPI'},
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Create New QR'),
        centerTitle: true,
        backgroundColor: bgColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: isDark ? Theme.of(context).colorScheme.tertiary : Colors.white,
              child: Icon(Icons.person, color: Theme.of(context).primaryColor),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Banner Ad
            const BannerAdWidget(),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Text(
                'Choose a destination for your new QR code. You can customize the look in the next step.',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: isDark ? Border.all(color: Theme.of(context).colorScheme.tertiary) : null,
                  boxShadow: [
                    if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                    hintText: 'Search QR types (WiFi, URL, Social)...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(24.0),
                itemCount: allOptions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final option = allOptions[index];
                  return _buildActionButton(
                    context, 
                    option,
                    () {
                      Get.to<void>(() => StringQrCreatorScreen(initialType: option['type'] as String));
                    }
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, Map<String, dynamic> option, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    // Get color based on type, fallback to primary
    Color baseColor = AppTheme.formatColors[option['type']] ?? theme.primaryColor;
    // For pastel effect, light mode needs the background to be very light and icon dark.
    // Dark mode can use the base color but dimmed.
    Color iconBgColor = isDark ? baseColor.withValues(alpha: 0.2) : baseColor.withValues(alpha: 0.2);
    Color iconColor = isDark ? baseColor : baseColor.withValues(alpha: 1.0); // Keep it vibrant
    
    // If baseColor is too light in light mode (like FDE68A), we need to manually pick a darker shade for the icon
    if (!isDark && option['type'] == 'Text') iconColor = Colors.orange;
    if (!isDark && option['type'] == 'vCard') iconColor = Colors.deepOrange;
    if (!isDark && option['type'] == 'Wi-Fi') iconColor = Colors.teal;
    if (!isDark && option['type'] == 'Email') iconColor = Colors.blue;
    if (!isDark && option['type'] == 'Number') iconColor = Colors.green;
    if (!isDark && option['type'] == 'Map') iconColor = Colors.red;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                option['icon'] as IconData,
                color: iconColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['title'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    option['subtitle'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Theme.of(context).colorScheme.tertiary : const Color(0xFFF3F0FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right,
                color: isDark ? Colors.grey[400] : theme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
