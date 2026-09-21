import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../models/product_model.dart';
import 'product_card.dart';

class CatalogProductGrid
    extends StatelessWidget {
  final List<ProductModel> products;
  final ValueChanged<ProductModel>
      onProductTap;

  const CatalogProductGrid({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        0,
        AppConstants.defaultPadding,
        110,
      ),
      sliver: SliverGrid(
        delegate:
            SliverChildBuilderDelegate(
          (
            BuildContext context,
            int index,
          ) {
            final ProductModel product =
                products[index];

            return ProductCard(
              product: product,
              onTap: () {
                onProductTap(product);
              },
            );
          },
          childCount: products.length,
        ),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.70,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
      ),
    );
  }
}