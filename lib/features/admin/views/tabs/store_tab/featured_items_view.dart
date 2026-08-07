import 'package:flutter/material.dart';

class FeaturedItemsView extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;
  final ValueChanged<int> onToggleFeatured;
  final Color primaryAccent;
  final bool isDarkMode;

  const FeaturedItemsView({
    super.key,
    required this.menuItems,
    required this.onToggleFeatured,
    required this.primaryAccent,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final featuredItems = menuItems.where((i) => i['isFeatured'] == true).toList();
    final cardBg = theme.cardColor.withOpacity(isDarkMode ? 0.65 : 0.85);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: primaryAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.stars_rounded, color: primaryAccent, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Featured items appear at the top of the customer homepage menu.'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: featuredItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = featuredItems[index];
            final actualIndex = menuItems.indexOf(item);

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: Text(item['icon'], style: const TextStyle(fontSize: 24)),
                title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${item['category']} • ${item['price']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.star_rounded, color: Colors.amber),
                  onPressed: () => onToggleFeatured(actualIndex),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}