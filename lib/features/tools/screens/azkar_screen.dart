import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/features/dua/data/dua_model.dart';
import 'package:kal_rasol_allah/features/tools/controllers/azkar_provider.dart';

class AzkarScreen extends ConsumerStatefulWidget {
  const AzkarScreen({super.key});

  @override
  ConsumerState<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends ConsumerState<AzkarScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _showResetButton =
      true; // Dynamically hides or shows the Reset button on list scroll

  // Stores the remaining counts for each Zikr (id -> remaining count)
  final Map<int, int> _zikrCounts = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper methods for search
  void _startSearch() => setState(() => _isSearching = true);
  void _stopSearch() => setState(() {
    _isSearching = false;
    _query = '';
    _searchController.clear();
  });
  void _onQueryChanged(String val) => setState(() => _query = val.trim());

  // Helper to get default repeat count for each zikr
  int _getDefaultRepeatCount(DuaModel zikr) {
    // Standard repeat count from typical Islamic Azkar
    // Certain standard phrases are repeated 3 times, others 33, 100, etc.
    // For simplicity, we default to 3 unless specified.
    if (zikr.text.contains('سبحان الله') ||
        zikr.text.contains('الحمد لله') ||
        zikr.text.contains('الله أكبر')) {
      return 33;
    }
    if (zikr.text.contains('لا إله إلا الله وحده لا شريك له') ||
        zikr.text.contains('أستغفر الله') ||
        zikr.text.contains('اللهم صلِّ على محمد')) {
      return 10;
    }
    return 3; // Standard repeat count
  }

  // Get current remaining count
  int _getRemainingCount(DuaModel zikr) {
    return _zikrCounts[zikr.id] ?? _getDefaultRepeatCount(zikr);
  }

  // Decrement counter
  void _decrementCount(DuaModel zikr) {
    final current = _getRemainingCount(zikr);
    if (current > 0) {
      setState(() {
        _zikrCounts[zikr.id] = current - 1;
      });
      HapticFeedback.lightImpact(); // Subtle vibration feedback
    }
  }

  // Reset all counts for the current category
  void _resetCounts(List<DuaModel> categoryAzkar) {
    setState(() {
      for (var zikr in categoryAzkar) {
        _zikrCounts[zikr.id] = _getDefaultRepeatCount(zikr);
      }
    });
    HapticFeedback.mediumImpact();
  }

  Widget _buildSearchBar(bool isDark) {
    return Row(
      key: const ValueKey('search'),
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? AppColors.white : AppColors.card,
          ),
          onPressed: _stopSearch,
        ),
        Expanded(
          child: TextField(
            controller: _searchController,
            autofocus: true,
            textDirection: TextDirection.rtl,
            textInputAction:
                TextInputAction.search, // Shows "Search" on keyboard
            onSubmitted: (_) => FocusScope.of(
              context,
            ).unfocus(), // Dismisses keyboard on submit
            style: TextStyle(
              fontFamily: ArabicFont.cairo,
              color: isDark ? AppColors.white : AppColors.card,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'ابحث في الأذكار...',
              hintStyle: const TextStyle(
                fontFamily: ArabicFont.cairo,
                color: AppColors.mediumGray,
              ),
              prefixIcon: const Icon(Icons.search, color: AppColors.mediumGray),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.mediumGray,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _onQueryChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
            ),
            onChanged: _onQueryChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleBar(bool isDark) {
    return Row(
      key: const ValueKey('title'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? AppColors.white : AppColors.card,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          'الأذكار اليومية',
          style: AppTextStyles.title.copyWith(
            color: isDark ? AppColors.white : AppColors.card,
          ),
        ),
        IconButton(
          onPressed: _startSearch,
          icon: Icon(
            Icons.search,
            size: 32,
            color: isDark ? AppColors.white : AppColors.card,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 60,
            color: AppColors.mediumGray,
          ),
          const Gap(12),
          Text(
            'لا توجد نتائج',
            style: const TextStyle(
              fontFamily: ArabicFont.cairo,
              color: AppColors.mediumGray,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAzkarList(
    List<DuaModel> rawAzkar,
    bool isDark,
    AzkarState azkarState,
  ) {
    // Filter by search query if any
    final filtered = _query.isEmpty
        ? rawAzkar
        : rawAzkar
              .where(
                (z) =>
                    z.text.contains(_query) ||
                    (z.source?.contains(_query) ?? false),
              )
              .toList();

    if (filtered.isEmpty) return _buildEmptyState();

    return Column(
      children: [
        // Reset option - Animates height and opacity on scroll up/down
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: _showResetButton ? 36.0 : 0.0,
          curve: Curves.easeInOut,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(), // Fixes the AssertionError
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _showResetButton ? 1.0 : 0.0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _resetCounts(rawAzkar),
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: AppColors.gold,
                ),
                label: const Text(
                  'إعادة تعيين العدادات',
                  style: TextStyle(
                    fontFamily: ArabicFont.cairo,
                    fontSize: 12,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
          ),
        ),
        Gap(10),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollUpdateNotification) {
                final scrollDelta = notification.scrollDelta;
                if (scrollDelta != null) {
                  // Hide when scrolling down, show when scrolling up
                  if (scrollDelta > 3.0 && _showResetButton) {
                    setState(() {
                      _showResetButton = false;
                    });
                  } else if (scrollDelta < -3.0 && !_showResetButton) {
                    setState(() {
                      _showResetButton = true;
                    });
                  }
                }
              }
              return false; // Allow scroll notification to bubble up
            },
            child: ListView.builder(
              itemCount: filtered.length,
              cacheExtent: 300,
              itemBuilder: (context, index) {
                final zikr = filtered[index];
                final remaining = _getRemainingCount(zikr);
                final isCompleted = remaining == 0;
                final defaultCount = _getDefaultRepeatCount(zikr);
                final isFavorite = azkarState.favoriteZikrIds.contains(zikr.id);

                final delay = (index % 8) * 80;
                return TweenAnimationBuilder<double>(
                  key: ValueKey(
                    zikr.id,
                  ), // Resets stagger on search/filter/tab switch
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 350 + delay),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(
                          0.0,
                          (1.0 - value) * 24.0,
                        ), // Elegant 24px float up
                        child: child,
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: () => _decrementCount(zikr),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.card : AppColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.primaryGreen
                              : (isDark
                                    ? AppColors.secondary
                                    : AppColors.mediumGray),
                          width: 2.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Text and source
                          Text(
                            zikr.text,
                            style: ArabicTextStyle(
                              arabicFont: ArabicFont.amiri,
                              fontSize: 19,
                              fontWeight: FontWeight.normal,
                              color: isDark ? AppColors.white : AppColors.card,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                          ),
                          if (zikr.source != null &&
                              zikr.source!.isNotEmpty) ...[
                            const Gap(10),
                            Text(
                              zikr.source!,
                              style: TextStyle(
                                fontFamily: ArabicFont.cairo,
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.gold
                                    : AppColors.darkGreen,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                          const Gap(16),
                          const Divider(color: AppColors.secondary, height: 1),
                          const Gap(12),

                          // Repetition Control bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left side: Favorite heart and Status Indicator
                              Row(
                                children: [
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      color: isFavorite
                                          ? Colors.red
                                          : AppColors.mediumGray,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      ref
                                          .read(azkarProvider.notifier)
                                          .toggleFavorite(zikr.id);



                                          
                                          ScaffoldMessenger.of(
                                            context,
                                          ).clearSnackBars();
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                isFavorite
                                                    ? 'تمت الإزالة من المفضلة'
                                                    : 'تمت الإضافة للمفضلة',
                                                style: const TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              backgroundColor: isFavorite
                                                  ? Colors.grey.shade800
                                                  : AppColors.primaryGreen,
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                    },
                                  ),
                                  const Gap(8),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: isCompleted
                                        ? const Row(
                                            key: ValueKey('completed'),
                                            children: [
                                              Icon(
                                                Icons.check_circle_rounded,
                                                color: AppColors.primaryGreen,
                                                size: 20,
                                              ),
                                              Gap(6),
                                              Text(
                                                'تم الأكتمال',
                                                style: TextStyle(
                                                  fontFamily: ArabicFont.cairo,
                                                  color: AppColors.primaryGreen,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            'المتبقي: $remaining من $defaultCount',
                                            style: const TextStyle(
                                              fontFamily: ArabicFont.cairo,
                                              color: AppColors.mediumGray,
                                              fontSize: 13,
                                            ),
                                          ),
                                  ),
                                ],
                              ),

                              // Round interactive button
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? AppColors.primaryGreen.withOpacity(0.1)
                                      : AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: isCompleted
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: AppColors.primaryGreen,
                                        size: 22,
                                      )
                                    : Text(
                                        '$remaining',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(ThemeRiverPod);
    final azkarState = ref.watch(azkarProvider);

    if (azkarState.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: isDark ? AppColors.gold : AppColors.primaryGreen,
          ),
        ),
      );
    }

    if (azkarState.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const Gap(16),
              Text(
                'حدث خطأ في تحميل الأذكار: ${azkarState.errorMessage}',
                style: const TextStyle(fontFamily: ArabicFont.cairo),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              ElevatedButton(
                onPressed: () => ref.read(azkarProvider.notifier).loadAzkar(),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    // Append 'المفضلة' to categories for UI TabBar
    final categoriesWithFavorites = [...azkarState.categories, 'المفضلة'];

    // Filter dynamic lists for each category
    final Map<String, List<DuaModel>> categorizedAzkar = {};
    for (var cat in azkarState.categories) {
      categorizedAzkar[cat] = azkarState.allAzkar
          .where((z) => z.category == cat)
          .toList();
    }
    // Set favorite items list for 'المفضلة' tab
    categorizedAzkar['المفضلة'] = azkarState.allAzkar
        .where((z) => azkarState.favoriteZikrIds.contains(z.id))
        .toList();

    final allCategoriesAzkar = azkarState.allAzkar
        .where((z) => azkarState.categories.contains(z.category))
        .toList();

    return DefaultTabController(
      length: categoriesWithFavorites.length,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Column(
              children: [
                // ===== AppBar =====
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isSearching
                      ? _buildSearchBar(isDark)
                      : _buildTitleBar(isDark),
                ),
                const Gap(6), // Reduced from 12 to 6
                // ===== TabBar =====
                if (!_isSearching) ...[
                  TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    dividerColor: Colors
                        .transparent, // Removes the default bottom divider line completely
                    labelColor: isDark
                        ? AppColors.gold
                        : AppColors.primaryGreen,
                    unselectedLabelColor: AppColors.mediumGray,
                    indicatorColor: isDark
                        ? AppColors.gold
                        : AppColors.primaryGreen,
                    labelStyle: const TextStyle(
                      fontFamily: ArabicFont.cairo,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: categoriesWithFavorites
                        .map((cat) => Tab(text: cat))
                        .toList(),
                  ),
                  const Gap(6), // Reduced from 12 to 6
                ],

                // ===== TabView =====
                Expanded(
                  child: _isSearching
                      ? _buildAzkarList(allCategoriesAzkar, isDark, azkarState)
                      : TabBarView(
                          children: categoriesWithFavorites
                              .map(
                                (cat) => _buildAzkarList(
                                  categorizedAzkar[cat] ?? [],
                                  isDark,
                                  azkarState,
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
