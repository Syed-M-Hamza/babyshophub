import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../theme/app_colors.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key, required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyle(category.id);
    return SizedBox(
      width: 108,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(color: style.background, borderRadius: BorderRadius.circular(22)),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.white,
                child: category.categoryImage.isEmpty
                    ? Icon(style.icon, color: AppColors.navy, size: 20)
                    : ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: category.categoryImage,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Icon(style.icon, color: AppColors.navy, size: 20),
                        ),
                      ),
              ),
              const Spacer(),
              Text(
                category.categoryName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, height: 1.15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryStyle {
  const CategoryStyle(this.background, this.icon);
  final Color background;
  final IconData icon;
}

CategoryStyle categoryStyle(String id) {
  switch (id) {
    case 'clothing':
      return const CategoryStyle(AppColors.babyPink, Icons.checkroom_outlined);
    case 'diapers':
      return const CategoryStyle(AppColors.babyBlue, Icons.baby_changing_station);
    case 'food':
      return const CategoryStyle(AppColors.mintGreen, Icons.restaurant_outlined);
    case 'toys':
      return const CategoryStyle(Color(0xFFFFF1D6), Icons.toys_outlined);
    case 'skincare':
      return const CategoryStyle(AppColors.babyPink, Icons.spa_outlined);
    case 'feeding':
      return const CategoryStyle(AppColors.babyBlue, Icons.local_drink_outlined);
    case 'bath':
      return const CategoryStyle(AppColors.mintGreen, Icons.bathtub_outlined);
    case 'accessories':
      return const CategoryStyle(Color(0xFFF3E8FF), Icons.diamond_outlined);
    case 'bedding':
      return const CategoryStyle(AppColors.babyBlue, Icons.bed_outlined);
    case 'health':
      return const CategoryStyle(AppColors.mintGreen, Icons.health_and_safety_outlined);
    default:
      return const CategoryStyle(AppColors.pastelPeach, Icons.child_care);
  }
}
