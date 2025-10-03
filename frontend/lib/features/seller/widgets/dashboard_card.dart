import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Animated dashboard card with loading state
class AnimatedDashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;
  final String? trend; // '+10%', '-5%', etc.
  final bool isTrendPositive;

  const AnimatedDashboardCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.isLoading = false,
    this.trend,
    this.isTrendPositive = true,
  }) : super(key: key);

  @override
  State<AnimatedDashboardCard> createState() => _AnimatedDashboardCardState();
}

class _AnimatedDashboardCardState extends State<AnimatedDashboardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              onTapDown: (_) {
                _animationController.reverse();
              },
              onTapUp: (_) {
                _animationController.forward();
              },
              onTapCancel: () {
                _animationController.forward();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: widget.isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(widget.color),
                                  ),
                                )
                              : Icon(
                                  widget.icon,
                                  color: widget.color,
                                  size: 20,
                                ),
                        ),
                        if (widget.trend != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (widget.isTrendPositive
                                      ? AppColors.success
                                      : AppColors.error)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.isTrendPositive
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  size: 12,
                                  color: widget.isTrendPositive
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  widget.trend!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: widget.isTrendPositive
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.onTap != null && widget.trend == null)
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    widget.isLoading
                        ? Container(
                            height: 24,
                            width: 80,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : Text(
                            widget.value,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                    const SizedBox(height: 4),
                    widget.isLoading
                        ? Container(
                            height: 14,
                            width: 100,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                    const SizedBox(height: 2),
                    widget.isLoading
                        ? Container(
                            height: 12,
                            width: 120,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        : Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Grid dashboard cards layout
class DashboardCardsGrid extends StatelessWidget {
  final List<DashboardCardData> cards;
  final int crossAxisCount;
  final double childAspectRatio;
  final bool isLoading;

  const DashboardCardsGrid({
    Key? key,
    required this.cards,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.5,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return AnimatedDashboardCard(
          title: card.title,
          value: card.value,
          subtitle: card.subtitle,
          icon: card.icon,
          color: card.color,
          onTap: card.onTap,
          isLoading: isLoading,
          trend: card.trend,
          isTrendPositive: card.isTrendPositive,
        );
      },
    );
  }
}

// Data class for dashboard cards
class DashboardCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? trend;
  final bool isTrendPositive;

  const DashboardCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.trend,
    this.isTrendPositive = true,
  });
}
