import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/widgets/category_chip.dart';
import 'package:news_app/widgets/loading_shimmer.dart';
import 'package:news_app/widgets/news_card.dart';

class HomeView extends GetView<NewsController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(
      () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Curate'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                controller.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              onPressed: controller.toggleDarkMode,
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _showSearchDialog(context),
            ),
          ],
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Icon(
              Icons.newspaper_outlined,
              color: isDark ? Colors.white : AppColors.primary,
            ),
          ),
        ),
        body: IndexedStack(
          index: controller.selectedTab,
          children: [
            _buildHomeTab(context),
            _buildSavedTab(context),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: controller.selectedTab,
          onDestinationSelected: controller.setSelectedTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Saved',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return Obx(
                  () => CategoryChip(
                    label: category.capitalize ?? category,
                    isSelected: controller.selectedCategory == category,
                    onTap: () => controller.selectCategory(category),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading) {
              return const LoadingShimmer();
            }

            if (controller.error.isNotEmpty) {
              return _buildErrorWidget(context);
            }

            if (controller.articles.isEmpty) {
              return _buildEmptyWidget(context);
            }

            return RefreshIndicator(
              onRefresh: controller.refreshNews,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildHeroSection(controller.articles.first),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top stories',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'More',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.articles.length > 3 ? 3 : controller.articles.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final article = controller.articles[index + 1];
                        return _buildTrendingCard(context, article);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Latest',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    controller.articles.length > 4 ? controller.articles.length - 4 : 0,
                    (index) {
                      final article = controller.articles[index + 4];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NewsCard(
                          article: article,
                          onTap: () => Get.toNamed(Routes.NEWS_DETAIL, arguments: article),
                        ),
                      );
                    },
                  ),
                  if (controller.hasMore)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoadingMore ? null : controller.loadMoreNews,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primarySoft,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: controller.isLoadingMore
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  'Load more news',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSavedTab(BuildContext context) {
    return Obx(() {
      if (controller.savedArticles.isEmpty) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.bookmark_border, size: 56, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                Text(
                  'No saved articles yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the bookmark icon to keep reading later',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.savedArticles.length,
        itemBuilder: (context, index) {
          final article = controller.savedArticles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NewsCard(
              article: article,
              onTap: () => Get.toNamed(Routes.NEWS_DETAIL, arguments: article),
            ),
          );
        },
      );
    });
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: controller.refreshNews,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.newspaper_outlined, size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'No news available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(NewsArticle article) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.NEWS_DETAIL, arguments: article),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: article.urlToImage ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.divider,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.divider,
                  child: const Icon(Icons.newspaper, size: 42, color: AppColors.textHint),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Breaking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    article.title ?? 'Headline news',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingCard(BuildContext context, NewsArticle article) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.NEWS_DETAIL, arguments: article),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: CachedNetworkImage(
                imageUrl: article.urlToImage ?? '',
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 110,
                  color: AppColors.divider,
                ),
                errorWidget: (context, url, error) => Container(
                  height: 110,
                  color: AppColors.divider,
                  child: const Icon(Icons.image_not_supported, color: AppColors.textHint),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                article.title ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Search Curate',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 320,
          child: TextField(
            controller: searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search news, topics, or keywords',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurfaceElevated
                  : AppColors.surfaceAlt,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.08)
                      : AppColors.divider,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                controller.searchNews(value);
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                controller.searchNews(searchController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
