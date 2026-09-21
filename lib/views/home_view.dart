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
    return Obx(
      () => Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('News App'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                controller.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              onPressed: controller.toggleDarkMode,
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () => _showSearchDialog(context),
            ),
          ],
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
          color: Theme.of(context).cardColor,
          padding: EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.categories.length,
              separatorBuilder: (context, index) => SizedBox(width: 8),
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
              return LoadingShimmer();
            }

            if (controller.error.isNotEmpty) {
              return _buildErrorWidget();
            }

            if (controller.articles.isEmpty) {
              return _buildEmptyWidget();
            }

            return RefreshIndicator(
              onRefresh: controller.refreshNews,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  _buildHeroSection(controller.articles.first),
                  SizedBox(height: 24),
                  Text(
                    'Top stories',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.articles.length > 3 ? 3 : controller.articles.length,
                      separatorBuilder: (context, index) => SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final article = controller.articles[index + 1];
                        return _buildTrendingCard(article);
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Latest',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  ...List.generate(
                    controller.articles.length > 4 ? controller.articles.length - 4 : 0,
                    (index) {
                      final article = controller.articles[index + 4];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: NewsCard(
                          article: article,
                          onTap: () => Get.toNamed(Routes.NEWS_DETAIL, arguments: article),
                        ),
                      );
                    },
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_border, size: 64, color: AppColors.textHint),
              SizedBox(height: 16),
              Text(
                'No saved articles yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tap the bookmark icon to keep reading later',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: controller.savedArticles.length,
        itemBuilder: (context, index) {
          final article = controller.savedArticles[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: NewsCard(
              article: article,
              onTap: () => Get.toNamed(Routes.NEWS_DETAIL, arguments: article),
            ),
          );
        },
      );
    });
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please check your internet connection',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.refreshNews,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.newspaper, size: 64, color: AppColors.textHint),
          SizedBox(height: 16),
          Text(
            'No news available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(NewsArticle article) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.NEWS_DETAIL, arguments: article),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: article.urlToImage ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.divider,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.divider,
                  child: Icon(Icons.newspaper, size: 42, color: AppColors.textHint),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
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
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Breaking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    article.title ?? 'Headline news',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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

  Widget _buildTrendingCard(NewsArticle article) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.NEWS_DETAIL, arguments: article),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(Get.context!).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  child: Icon(Icons.image_not_supported, color: AppColors.textHint),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                article.title ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
        title: Text('Search News'),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Enter search term...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              controller.searchNews(value);
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                controller.searchNews(searchController.text);
                Navigator.of(context).pop();
              }
            },
            child: Text('Search'),
          ),
        ],
      ),
    );
  }
}
