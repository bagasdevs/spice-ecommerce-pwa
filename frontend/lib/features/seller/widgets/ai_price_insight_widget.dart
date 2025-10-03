import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../products/providers/product_provider.dart';
import '../../products/services/product_service.dart';

class AiPriceInsightWidget extends ConsumerStatefulWidget {
  final String spiceType;
  final String quality;
  final String origin;
  final bool isOrganic;
  final Map<String, dynamic> specifications;
  final Function(double) onPriceSelected;

  const AiPriceInsightWidget({
    Key? key,
    required this.spiceType,
    required this.quality,
    required this.origin,
    required this.isOrganic,
    required this.specifications,
    required this.onPriceSelected,
  }) : super(key: key);

  @override
  ConsumerState<AiPriceInsightWidget> createState() =>
      _AiPriceInsightWidgetState();
}

class _AiPriceInsightWidgetState extends ConsumerState<AiPriceInsightWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _canGetInsight {
    return widget.spiceType.isNotEmpty &&
        widget.origin.isNotEmpty &&
        widget.quality.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(productFormProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            if (!_canGetInsight) _buildRequirementsInfo(),
            if (_canGetInsight && formState.aiInsight == null)
              _buildGetInsightButton(formState),
            if (formState.loadingAiInsight) _buildLoadingState(),
            if (formState.aiInsight != null) _buildInsightContent(formState),
            if (formState.error != null && !formState.loadingAiInsight)
              _buildErrorState(formState.error!),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.smart_toy_outlined,
            color: AppColors.info,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Analisis Harga AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Dapatkan rekomendasi harga optimal',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsInfo() {
    final missing = <String>[];
    if (widget.spiceType.isEmpty) missing.add('Jenis Rempah');
    if (widget.origin.isEmpty) missing.add('Asal Daerah');
    if (widget.quality.isEmpty) missing.add('Kualitas');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Text(
                'Informasi Diperlukan',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Lengkapi informasi berikut untuk mendapatkan analisis harga AI:',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...missing.map((item) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      item,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGetInsightButton(ProductFormState formState) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Analisis Harga dengan AI',
        onPressed: () => _getAiInsight(),
        variant: CustomButtonVariant.outlined,
        icon: Icons.psychology_outlined,
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                Icon(
                  Icons.smart_toy,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI sedang menganalisis...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Menganalisis data pasar dan kondisi produk',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightContent(ProductFormState formState) {
    final insight = formState.aiInsight!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildPriceRecommendation(insight),
            const SizedBox(height: 16),
            _buildPriceChart(insight),
            const SizedBox(height: 16),
            _buildConfidenceIndicator(insight),
            const SizedBox(height: 16),
            _buildReasoningSection(insight),
            const SizedBox(height: 16),
            _buildRecommendations(insight),
            const SizedBox(height: 16),
            _buildActionButtons(insight),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRecommendation(AiPriceInsight insight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withOpacity(0.1),
            AppColors.success.withOpacity(0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.success, size: 24),
              const SizedBox(width: 8),
              Text(
                'Harga Rekomendasi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Rp ${_formatPrice(insight.suggestedPrice)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPriceRange(
                'Min',
                insight.minPrice,
                AppColors.warning,
              ),
              _buildPriceRange(
                'Max',
                insight.maxPrice,
                AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRange(String label, double price, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rp ${_formatPrice(price)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceChart(AiPriceInsight insight) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: insight.maxPrice * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return Text('Min',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary));
                    case 1:
                      return Text('Rekomendasi',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary));
                    case 2:
                      return Text('Max',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary));
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: insight.minPrice,
                  color: AppColors.warning,
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: insight.suggestedPrice,
                  color: AppColors.success,
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: insight.maxPrice,
                  color: AppColors.info,
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator(AiPriceInsight insight) {
    final confidence = insight.confidence;
    final confidenceColor = _getConfidenceColor(confidence);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: confidenceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: confidenceColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getConfidenceIcon(confidence),
            color: confidenceColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tingkat Kepercayaan: ${(confidence * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: confidence,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation(confidenceColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasoningSection(AiPriceInsight insight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_outlined, color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Text(
                'Analisis AI',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight.reasoning,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(AiPriceInsight insight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rekomendasi Tambahan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...insight.recommendations.map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildActionButtons(AiPriceInsight insight) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Gunakan Harga Min',
            onPressed: () => widget.onPriceSelected(insight.minPrice),
            variant: CustomButtonVariant.outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: CustomButton(
            text: 'Gunakan Rekomendasi',
            onPressed: () => widget.onPriceSelected(insight.suggestedPrice),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomButton(
            text: 'Gunakan Harga Max',
            onPressed: () => widget.onPriceSelected(insight.maxPrice),
            variant: CustomButtonVariant.outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 8),
          Text(
            'Gagal mendapatkan analisis',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Coba Lagi',
            onPressed: () => _getAiInsight(),
            variant: CustomButtonVariant.outlined,
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.success;
    if (confidence >= 0.6) return AppColors.warning;
    return AppColors.error;
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.8) return Icons.check_circle_outline;
    if (confidence >= 0.6) return Icons.warning_amber_outlined;
    return Icons.error_outline;
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Future<void> _getAiInsight() async {
    _animationController.reset();
    await ref.read(productFormProvider.notifier).getAiPriceInsight();
    _animationController.forward();
  }
}
