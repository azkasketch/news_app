import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsController extends GetxController {
  final NewsService _newsService = NewsService();

  final _isLoading = false.obs;
  final _isLoadingMore = false.obs;
  final _articles = <NewsArticle>[].obs;
  final _selectedCategory = 'general'.obs;
  final _error = ''.obs;
  final _savedArticles = <NewsArticle>[].obs;
  final _selectedTab = 0.obs;
  final _isDarkMode = false.obs;
  final _currentPage = 1.obs;
  final _hasMore = true.obs;

  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  List<NewsArticle> get articles => _articles;
  String get selectedCategory => _selectedCategory.value;
  String get error => _error.value;
  List<NewsArticle> get savedArticles => _savedArticles;
  int get selectedTab => _selectedTab.value;
  bool get isDarkMode => _isDarkMode.value;
  bool get hasMore => _hasMore.value;
  List<String> get categories => Constants.categories;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    fetchTopHeadlines();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = prefs.getBool('dark_mode') ?? false;
    await _loadSavedArticles();
  }

  Future<void> _loadSavedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_articles') ?? <String>[];
    final parsed = saved
        .map((item) => NewsArticle.fromJson(json.decode(item)))
        .toList();
    _savedArticles.assignAll(parsed);
  }

  Future<void> _persistSavedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _savedArticles
        .map((article) => json.encode(article.toJson()))
        .toList();
    await prefs.setStringList('saved_articles', encoded);
  }

  Future<void> fetchTopHeadlines({
    String? category,
    bool append = false,
  }) async {
    try {
      if (append) {
        _isLoadingMore.value = true;
      } else {
        _isLoading.value = true;
        _currentPage.value = 1;
        _hasMore.value = true;
      }
      _error.value = '';

      final page = append ? _currentPage.value + 1 : 1;
      final response = await _newsService.getTopHeadlines(
        category: category ?? _selectedCategory.value,
        page: page,
      );

      if (append) {
        final existingUrls = _articles.map((article) => article.url).toSet();
        final uniqueArticles = response.articles
            .where(
              (article) =>
                  article.url != null && !existingUrls.contains(article.url),
            )
            .toList();
        _articles.addAll(uniqueArticles);
        _currentPage.value = page;
        _hasMore.value =
            uniqueArticles.length >= 20 &&
            response.totalResults > _articles.length;
      } else {
        _articles.assignAll(response.articles);
        _currentPage.value = 1;
        _hasMore.value = response.totalResults > _articles.length;
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load news: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
      _isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreNews() async {
    if (!hasMore || isLoading || isLoadingMore) return;
    await fetchTopHeadlines(category: _selectedCategory.value, append: true);
  }

  Future<void> refreshNews() async {
    await fetchTopHeadlines();
  }

  void selectCategory(String category) {
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;
      fetchTopHeadlines(category: category);
    }
  }

  Future<void> searchNews(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;

    try {
      _isLoading.value = true;
      _error.value = '';
      _hasMore.value = false;
      _currentPage.value = 1;

      final response = await _newsService.searchNews(query: normalizedQuery);
      _articles.assignAll(response.articles);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to search news: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void setSelectedTab(int index) {
    _selectedTab.value = index;
  }

  bool isArticleSaved(NewsArticle article) {
    return _savedArticles.any(
      (savedArticle) => savedArticle.url == article.url,
    );
  }

  Future<void> toggleSavedArticle(NewsArticle article) async {
    final isSaved = isArticleSaved(article);
    if (isSaved) {
      _savedArticles.removeWhere(
        (savedArticle) => savedArticle.url == article.url,
      );
    } else {
      _savedArticles.add(article);
    }
    await _persistSavedArticles();
    _savedArticles.refresh();
  }

  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = !_isDarkMode.value;
    await prefs.setBool('dark_mode', _isDarkMode.value);
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
