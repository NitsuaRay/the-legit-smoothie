import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../main.dart';
import '../../catalog/models/product_model.dart';
import '../../catalog/screens/product_detail_modal.dart';
import '../models/promotion_model.dart';
import '../widgets/promotion_card.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  List<PromotionModel> _promotions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  Future<void> _fetchPromotions() async {
    try {
      final res = await supabase.from('promotions').select().order('created_at');

      final list = (res as List)
          .map((item) => PromotionModel.fromJson(item))
          .toList();

      setState(() {
        _promotions = list;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePromotionClick(PromotionModel promo) async {
    if (promo.targetProductId == null) return;

    try {
      final productRes = await supabase
          .from('products')
          .select()
          .eq('id', promo.targetProductId!)
          .maybeSingle();

      if (productRes != null && mounted) {
        final product = ProductModel.fromJson(productRes);
        ProductDetailModal.show(context, product);
      }
    } catch (e) {
      debugPrint('Error fetching highlighted product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Deals & Highlights ✨'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _promotions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_offer_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        'No Active Deals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Check back later for fresh smoothie promos!',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  itemCount: _promotions.length,
                  itemBuilder: (context, index) {
                    final promo = _promotions[index];
                    return PromotionCard(
                      promotion: promo,
                      onTap: () => _handlePromotionClick(promo),
                    );
                  },
                ),
    );
  }
}