import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../products/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final Function(ProductStatus)? onStatusChange;
  final VoidCallback? onDelete;
  final bool showActions;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onStatusChange,
    this.onDelete,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildProductInfo(),
            if (showActions) _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductHeader(),
                const SizedBox(height: 8),
                _buildProductDetails(),
                const SizedBox(height: 8),
                _buildProductStats(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: product.images.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: product.images.first,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surface,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surface,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                ),
              )
            : Container(
                color: AppColors.surface,
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.textSecondary,
                  size: 32,
                ),
              ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            product.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    switch (product.status) {
      case ProductStatus.active:
        color = AppColors.success;
        text = 'Aktif';
        break;
      case ProductStatus.draft:
        color = AppColors.warning;
        text = 'Draft';
        break;
      case ProductStatus.pendingReview:
        color = AppColors.info;
        text = 'Review';
        break;
      case ProductStatus.inactive:
        color = AppColors.textSecondary;
        text = 'Nonaktif';
        break;
      case ProductStatus.rejected:
        color = AppColors.error;
        text = 'Ditolak';
        break;
      case ProductStatus.soldOut:
        color = AppColors.error;
        text = 'Habis';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${product.displayPrice}/${product.unit}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Stok: ${product.stock} ${product.unit}',
              style: TextStyle(
                fontSize: 12,
                color: product.isLowStock
                    ? AppColors.warning
                    : AppColors.textSecondary,
                fontWeight:
                    product.isLowStock ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (product.isLowStock) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: AppColors.warning,
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                product.origin,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductStats() {
    return Row(
      children: [
        _buildStatChip(
          Icons.visibility_outlined,
          '${product.viewCount}',
          'Views',
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          Icons.shopping_cart_outlined,
          '${product.salesCount}',
          'Terjual',
        ),
        if (product.averageRating != null && product.averageRating! > 0) ...[
          const SizedBox(width: 8),
          _buildStatChip(
            Icons.star_outline,
            product.averageRating!.toStringAsFixed(1),
            'Rating',
          ),
        ],
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              'Edit',
              Icons.edit_outlined,
              AppColors.info,
              onTap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionButton(
              'Status',
              Icons.swap_horiz,
              AppColors.warning,
              () => _showStatusChangeDialog(context),
            ),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            '',
            Icons.delete_outline,
            AppColors.error,
            () => _showDeleteDialog(context),
            isIconOnly: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback? onPressed, {
    bool isIconOnly = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isIconOnly ? 8 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            if (!isIconOnly) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showStatusChangeDialog(BuildContext context) {
    if (onStatusChange == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Status Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ProductStatus.values.map((status) {
            if (status == product.status) return const SizedBox.shrink();

            return ListTile(
              leading: Icon(_getStatusIcon(status)),
              title: Text(status.displayName),
              onTap: () {
                Navigator.of(context).pop();
                onStatusChange!(status);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    if (onDelete == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text(
          'Yakin ingin menghapus "${product.name}"?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(ProductStatus status) {
    switch (status) {
      case ProductStatus.active:
        return Icons.check_circle_outline;
      case ProductStatus.draft:
        return Icons.edit_outlined;
      case ProductStatus.pendingReview:
        return Icons.pending_outlined;
      case ProductStatus.inactive:
        return Icons.visibility_off_outlined;
      case ProductStatus.rejected:
        return Icons.cancel_outlined;
      case ProductStatus.soldOut:
        return Icons.inventory_outlined;
    }
  }
}

// Compact product card for grid view
class CompactProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const CompactProductCard({
    Key? key,
    required this.product,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCompactImage(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.displayPrice,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stok: ${product.stock}',
                          style: TextStyle(
                            fontSize: 10,
                            color: product.isLowStock
                                ? AppColors.warning
                                : AppColors.textSecondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.status.displayName,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactImage() {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(11),
            topRight: Radius.circular(11),
          ),
          child: product.images.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: product.images.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surface,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surface,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : Container(
                  color: AppColors.surface,
                  child: Icon(
                    Icons.image_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (product.status) {
      case ProductStatus.active:
        return AppColors.success;
      case ProductStatus.draft:
        return AppColors.warning;
      case ProductStatus.pendingReview:
        return AppColors.info;
      case ProductStatus.inactive:
        return AppColors.textSecondary;
      case ProductStatus.rejected:
        return AppColors.error;
      case ProductStatus.soldOut:
        return AppColors.error;
    }
  }
}
