import 'package:flutter/material.dart';
import 'package:news_app/utils/app_colors.dart';

class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({super.key});

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2A2A2A) : AppColors.divider;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.divider,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    height: 190,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          baseColor,
                          baseColor.withValues(alpha: 0.55),
                          baseColor,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        transform: GradientRotation(_animation.value * 3.14159),
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Container(
                          height: 12,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: baseColor,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 16,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: baseColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 16,
                              width: MediaQuery.of(context).size.width * 0.7,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: baseColor,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: baseColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 14,
                              width: MediaQuery.of(context).size.width * 0.52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(7),
                                color: baseColor,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
