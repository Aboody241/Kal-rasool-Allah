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
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDark ? AppColors.white : AppColors.card),
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
    return Row(
      key: const ValueKey('title'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDark ? AppColors.white : AppColors.card),
          onPressed: () => Navigator.pop(context),
        ),
        Text(
          'أسماء الله الحسنى',
          style: AppTextStyles.title.copyWith(
            color: isDark ? AppColors.white : AppColors.card,
          ),
        ),
        IconButton(
          onPressed: _startSearch,
          icon: Icon(Icons.search,
              size: 32,
              color: isDark ? AppColors.white : AppColors.card),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 60, color: AppColors.mediumGray),
          const Gap(12),
          Text(
            'لا توجد نتائج لـ "$_query"',
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

  Widget _buildList(List<AllahName> names) {
    final filtered = _query.isEmpty
        ? names
        : names
            .where((n) =>
                n.name.contains(_query) ||
                n.meaning.contains(_query) ||
                n.description.contains(_query))
            .toList();

    if (filtered.isEmpty) return _buildEmptyState();

    return ListView.builder(
      itemCount: filtered.length,
      // ✅ cacheExtent يخلي Flutter يجهز الـ items اللي فوق وتحت الشاشة مسبقاً
      cacheExtent: 300,
      itemBuilder: (context, index) {
        final name = filtered[index];
        return _AllahNameItem(
          id: name.id,
          name: name.name,
          meaning: name.meaning,
          description: name.description,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(ThemeRiverPod);
    final namesAsync = ref.watch(namesOfAllahProvider);

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
                child: namesAsync.when(
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: isDark ? AppColors.gold : AppColors.primaryGreen,
                    ),
                  ),
                  error: (e, _) => const Center(
                    child: Text(
                      'حدث خطأ في تحميل البيانات',
                      style: TextStyle(
                        color: Colors.red,
                        fontFamily: ArabicFont.cairo,
                      ),
                    ),
                  ),
                  data: _buildList,
                ),
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
class _AllahNameItem extends StatefulWidget {
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
  State<_AllahNameItem> createState() => _AllahNameItemState();
}

class _AllahNameItemState extends State<_AllahNameItem>
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
                          color: AppColors.white,
                        ),
                      ),
                      const Gap(3),
                      Text(
                        widget.meaning,
                        style: ArabicTextStyle(
                          arabicFont: ArabicFont.cairo,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
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
            // ✅ SizeTransition + FadeTransition معاً = أنيميشن ناعم وحقيقي
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: FadeTransition(
                opacity: _expandAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(12),
                    const Divider(
                      color: AppColors.secondary,
                      height: 1,
                    ),
                    const Gap(10),
                    Text(
                      widget.description,
                      style: ArabicTextStyle(
                        arabicFont: ArabicFont.cairo,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightGray,
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
