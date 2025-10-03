import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';

class ImagePickerWidget extends StatelessWidget {
  final List<String> images;
  final Function() onAddImage;
  final Function(int) onRemoveImage;
  final int maxImages;
  final double aspectRatio;

  const ImagePickerWidget({
    Key? key,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
    this.maxImages = 5,
    this.aspectRatio = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isEmpty) _buildEmptyState(),
        if (images.isNotEmpty) _buildImageGrid(),
        const SizedBox(height: 12),
        if (images.length < maxImages) _buildAddButton(),
        if (images.isNotEmpty) _buildImageCounter(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: onAddImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_a_photo_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tambah Foto Produk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap untuk memilih foto dari galeri atau kamera',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Maksimal $maxImages foto',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.info,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: aspectRatio,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return _buildImageTile(index);
      },
    );
  }

  Widget _buildImageTile(int index) {
    final imagePath = images[index];
    final isNetworkImage = imagePath.startsWith('http');
    final isFirstImage = index == 0;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isFirstImage
                ? Border.all(color: AppColors.primary, width: 2)
                : Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: isNetworkImage
                  ? CachedNetworkImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surface,
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.error.withOpacity(0.1),
                        child: Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                        ),
                      ),
                    )
                  : Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.error.withOpacity(0.1),
                        child: Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        // Main photo indicator
        if (isFirstImage)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Utama',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => onRemoveImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: onAddImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Tambah Foto Lagi',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCounter() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Foto pertama akan menjadi foto utama',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            '${images.length}/$maxImages',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Reorderable image picker widget
class ReorderableImagePickerWidget extends StatefulWidget {
  final List<String> images;
  final Function() onAddImage;
  final Function(int) onRemoveImage;
  final Function(int, int) onReorderImage;
  final int maxImages;
  final double aspectRatio;

  const ReorderableImagePickerWidget({
    Key? key,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
    required this.onReorderImage,
    this.maxImages = 5,
    this.aspectRatio = 1.0,
  }) : super(key: key);

  @override
  State<ReorderableImagePickerWidget> createState() =>
      _ReorderableImagePickerWidgetState();
}

class _ReorderableImagePickerWidgetState
    extends State<ReorderableImagePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.images.isEmpty) _buildEmptyState(),
        if (widget.images.isNotEmpty) _buildReorderableGrid(),
        const SizedBox(height: 12),
        if (widget.images.length < widget.maxImages) _buildAddButton(),
        if (widget.images.isNotEmpty) _buildImageInfo(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ImagePickerWidget(
      images: widget.images,
      onAddImage: widget.onAddImage,
      onRemoveImage: widget.onRemoveImage,
      maxImages: widget.maxImages,
      aspectRatio: widget.aspectRatio,
    );
  }

  Widget _buildReorderableGrid() {
    return ReorderableWrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.images.asMap().entries.map((entry) {
        final index = entry.key;
        final imagePath = entry.value;
        return _buildReorderableImageTile(index, imagePath);
      }).toList(),
      onReorder: (oldIndex, newIndex) {
        widget.onReorderImage(oldIndex, newIndex);
      },
    );
  }

  Widget _buildReorderableImageTile(int index, String imagePath) {
    final isNetworkImage = imagePath.startsWith('http');
    final isFirstImage = index == 0;

    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 3,
      height: (MediaQuery.of(context).size.width - 48) / 3 / widget.aspectRatio,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isFirstImage
                  ? Border.all(color: AppColors.primary, width: 2)
                  : Border.all(color: AppColors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: isNetworkImage
                    ? CachedNetworkImage(
                        imageUrl: imagePath,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.surface,
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.error.withOpacity(0.1),
                          child: Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                          ),
                        ),
                      )
                    : Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.error.withOpacity(0.1),
                          child: Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          // Main photo indicator
          if (isFirstImage)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Utama',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          // Drag handle
          Positioned(
            top: 4,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.drag_handle,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => widget.onRemoveImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: widget.onAddImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Tambah Foto Lagi',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Tekan dan tahan untuk mengatur ulang foto',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '${widget.images.length}/${widget.maxImages}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 12,
                color: AppColors.info,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Foto pertama akan menjadi foto utama produk',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Simple reorderable wrap widget
class ReorderableWrap extends StatefulWidget {
  final List<Widget> children;
  final Function(int, int) onReorder;
  final double spacing;
  final double runSpacing;

  const ReorderableWrap({
    Key? key,
    required this.children,
    required this.onReorder,
    this.spacing = 0,
    this.runSpacing = 0,
  }) : super(key: key);

  @override
  State<ReorderableWrap> createState() => _ReorderableWrapState();
}

class _ReorderableWrapState extends State<ReorderableWrap> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return LongPressDraggable<int>(
          data: index,
          feedback: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Transform.scale(
              scale: 1.1,
              child: child,
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: child,
          ),
          child: DragTarget<int>(
            onAccept: (draggedIndex) {
              if (draggedIndex != index) {
                widget.onReorder(draggedIndex, index);
              }
            },
            builder: (context, candidateData, rejectedData) {
              return child;
            },
          ),
        );
      }).toList(),
    );
  }
}
