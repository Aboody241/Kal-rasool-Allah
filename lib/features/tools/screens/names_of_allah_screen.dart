import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/container_box.dart';
import 'package:kal_rasol_allah/features/tools/controllers/names_of_allah_provider.dart';

// ================================================================
// ✅ NamesOfAllahScreen — Screen
// ================================================================
class NamesOfAllahScreen extends ConsumerStatefulWidget {
  const NamesOfAllahScreen({super.key});

  @override
  ConsumerState<NamesOfAllahScreen> createState() => _NamesOfAllahScreenState();
}

class _NamesOfAllahScreenState extends ConsumerState<NamesOfAllahScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---- Helpers ----
  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() => setState(() {
    _isSearching = false;
    _query = '';
    _searchController.clear();
  });

  void _onQueryChanged(String val) => setState(() => _query = val.trim());

  // ---- Widgets ----
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
            style: TextStyle(
              fontFamily: ArabicFont.cairo,
              color: isDark ? AppColors.white : AppColors.card,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'ابحث باسم أو بالمعنى...',
              hintStyle: const TextStyle(
                fontFamily: ArabicFont.cairo,
                color: AppColors.mediumGray,
              ),
              border: InputBorder.none,
            ),
            onChanged: _onQueryChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleBar(bool isDark) {
    final namesState = ref.watch(namesOfAllahProvider);
    final showOnlyFavorites = namesState.showOnlyFavorites;

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
          'أسماء الله الحسنى',
          style: AppTextStyles.title.copyWith(
            color: isDark ? AppColors.white : AppColors.card,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                ref
                    .read(namesOfAllahProvider.notifier)
                    .toggleShowOnlyFavorites();
              },
              icon: Icon(
                showOnlyFavorites
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 28,
                color: showOnlyFavorites
                    ? Colors.red
                    : (isDark ? AppColors.white : AppColors.card),
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
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool forFavorites) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            forFavorites
                ? Icons.favorite_border_rounded
                : Icons.search_off_rounded,
            size: 60,
            color: AppColors.mediumGray,
          ),
          const Gap(12),
          Text(
            forFavorites ? 'لا توجد عناصر في المفضلة حالياً' : 'لا توجد نتائج',
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

  Widget _buildList(NamesOfAllahState namesState) {
    final allNames = namesState.allNames;

    // 1. Filter by favorites if showOnlyFavorites is true
    final baseNames = namesState.showOnlyFavorites
        ? allNames.where((n) => namesState.favoriteIds.contains(n.id)).toList()
        : allNames;

    // 2. Filter by search query
    final filtered = _query.isEmpty
        ? baseNames
        : baseNames
              .where(
                (n) =>
                    n.name.contains(_query) ||
                    n.meaning.contains(_query) ||
                    n.description.contains(_query),
              )
              .toList();

    if (filtered.isEmpty) return _buildEmptyState(namesState.showOnlyFavorites);

    return ListView.builder(
      itemCount: filtered.length,
      cacheExtent: 300,
      itemBuilder: (context, index) {
        final name = filtered[index];
        final delay = (index % 8) * 80;
        return TweenAnimationBuilder<double>(
          key: ValueKey(name.id),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 350 + delay),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(
                  0.0,
                  (1.0 - value) * 24.0, // Elegant 24px float up
                ),
                child: child,
              ),
            );
          },
          child: _AllahNameItem(
            id: name.id,
            name: name.name,
            meaning: name.meaning,
            description: name.description,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(ThemeRiverPod);
    final namesState = ref.watch(namesOfAllahProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              // ===== AppBar =====
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isSearching
                    ? _buildSearchBar(isDark)
                    : _buildTitleBar(isDark),
              ),

              const Gap(12),

              // ===== القائمة =====
              Expanded(
                child: namesState.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: isDark
                              ? AppColors.gold
                              : AppColors.primaryGreen,
                        ),
                      )
                    : namesState.errorMessage != null
                    ? const Center(
                        child: Text(
                          'حدث خطأ في تحميل البيانات',
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: ArabicFont.cairo,
                          ),
                        ),
                      )
                    : _buildList(namesState),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ✅ _AllahNameItem — Item Widget
// ================================================================
class _AllahNameItem extends ConsumerStatefulWidget {
  final int id;
  final String name;
  final String meaning;
  final String description;

  const _AllahNameItem({
    required this.id,
    required this.name,
    required this.meaning,
    required this.description,
  });

  @override
  ConsumerState<_AllahNameItem> createState() => _AllahNameItemState();
}

class _AllahNameItemState extends ConsumerState<_AllahNameItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = ref.watch(
      namesOfAllahProvider.select((s) => s.favoriteIds.contains(widget.id)),
    );
    final isDark = ref.watch(ThemeRiverPod);

    return GestureDetector(
      onTap: _toggle,
      child: ContainerBox(
        borderRadius: BorderRadius.circular(12),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Header row ----
            Row(
              children: [
                _NumberBadge(number: widget.id),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: ArabicTextStyle(
                          arabicFont: ArabicFont.amiri,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark? AppColors.white : AppColors.card,
                        ),
                      ),
                      const Gap(3),
                      Text(
                        widget.meaning,
                        style: ArabicTextStyle(
                          arabicFont: ArabicFont.cairo,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isDark? AppColors.mediumGray : AppColors.mutedGray,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref
                        .read(namesOfAllahProvider.notifier)
                        .toggleFavorite(widget.id);

                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.red : AppColors.mediumGray,
                    size: 24,
                  ),
                ),
                const Gap(8),
                AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 280),
                  child: const Icon(
                    Icons.keyboard_arrow_right_rounded,
                    size: 28,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),

            // ---- Expandable description ----
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: FadeTransition(
                opacity: _expandAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(12),
                    const Divider(color: AppColors.secondary, height: 1),
                    const Gap(10),
                    Text(
                      widget.description,
                      style: ArabicTextStyle(
                        arabicFont: ArabicFont.cairo,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark? AppColors.lightGray : AppColors.card,
                      ),
                    ),
                    const Gap(4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ✅ _NumberBadge — Reusable small widget
// ================================================================
class _NumberBadge extends StatelessWidget {
  final int number;

  const _NumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: const TextStyle(
          color: AppColors.primaryGreen,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
