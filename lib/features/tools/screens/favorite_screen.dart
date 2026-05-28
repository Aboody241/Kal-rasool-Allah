import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/container_box.dart';
import 'package:kal_rasol_allah/features/dua/controller/dua_provider.dart';
import 'package:kal_rasol_allah/features/tools/controllers/azkar_provider.dart';
import 'package:kal_rasol_allah/features/tools/controllers/names_of_allah_provider.dart';
import 'package:kal_rasol_allah/features/home/controllers/home_provider.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              children: [
                Row(
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
                      'قائمة المفضلة',
                      style: AppTextStyles.title.copyWith(
                        color: isDark ? AppColors.white : AppColors.card,
                      ),
                    ),
                    const SizedBox(width: 48), // alignment helper
                  ],
                ),
                const Gap(10),
                TabBar(
                  dividerColor: Colors.transparent,
                  labelColor: isDark ? AppColors.gold : AppColors.primaryGreen,
                  unselectedLabelColor: AppColors.mediumGray,
                  indicatorColor: isDark ? AppColors.gold : AppColors.primaryGreen,
                  labelStyle: const TextStyle(
                    fontFamily: ArabicFont.cairo,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: 'سنن'),
                    Tab(text: 'أذكار'),
                    Tab(text: 'أدعية'),
                    Tab(text: 'أسماء الله'),
                  ],
                ),
                const Gap(16),
                const Expanded(
                  child: TabBarView(
                    children: [
                      SunnahFavoritesTab(),
                      AzkarFavoritesTab(),
                      DuaFavoritesTab(),
                      NamesFavoritesTab(),
                    ],
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

// ============================================================
// 1. Reusable Empty State Widget
// ============================================================
class _EmptyFavoriteState extends StatelessWidget {
  final String text;
  final bool isDark;

  const _EmptyFavoriteState({
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: isDark
                ? AppColors.lightGray.withValues(alpha: 0.3)
                : AppColors.card.withValues(alpha: 0.2),
          ),
          const Gap(16),
          Text(
            text,
            style: ArabicTextStyle(
              arabicFont: ArabicFont.cairo,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightGray.withValues(alpha: 0.6)
                  : AppColors.card.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 2. Tab standalone components for performance isolation
// ============================================================

class SunnahFavoritesTab extends ConsumerWidget {
  const SunnahFavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    
    // Select only the favorited sunnah list
    final favoriteSunnahs = ref.watch(
      homeProvider.select((s) => s.allSunnahs
          .where((item) => s.favoriteHadithIds.contains(item.id))
          .toList()),
    );

    if (favoriteSunnahs.isEmpty) {
      return _EmptyFavoriteState(text: 'لا توجد سنن في المفضلة حالياً', isDark: isDark);
    }

    return ListView.builder(
      itemCount: favoriteSunnahs.length,
      cacheExtent: 300,
      itemBuilder: (context, index) {
        final sunnah = favoriteSunnahs[index];
        final delay = (index % 8) * 80;
        return TweenAnimationBuilder<double>(
          key: ValueKey(sunnah.id),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 350 + delay),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0.0, (1.0 - value) * 24.0),
                child: child,
              ),
            );
          },
          child: ContainerBox(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_rounded, color: Colors.red, size: 22),
                      onPressed: () {
                        ref.read(homeProvider.notifier).toggleFavorite(sunnah.id);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'تمت الإزالة من المفضلة',
                              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            backgroundColor: Colors.grey.shade800,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    if (sunnah.category.isNotEmpty)
                      Text(
                        sunnah.category,
                        style: ArabicTextStyle(
                          arabicFont: ArabicFont.cairo,
                          fontSize: 12,
                          color: isDark ? AppColors.mediumGray : AppColors.mutedGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const Gap(10),
                Text(
                  sunnah.title,
                  style: ArabicTextStyle(
                    arabicFont: ArabicFont.amiri,
                    fontSize: 22,
                    color: isDark ? AppColors.white : AppColors.card,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (sunnah.description.isNotEmpty) ...[
                  const Gap(15),
                  Text(
                    sunnah.description,
                    style: ArabicTextStyle(
                      arabicFont: ArabicFont.amiri,
                      fontSize: 18,
                      color: isDark ? AppColors.offWhite : AppColors.card,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (sunnah.source.isNotEmpty) ...[
                  const Gap(15),
                  Text(
                    sunnah.source,
                    style: const TextStyle(
                      fontFamily: ArabicFont.amiri,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class AzkarFavoritesTab extends ConsumerWidget {
  const AzkarFavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    
    // Select only the favorited zikr list
    final favoriteAzkar = ref.watch(
      azkarProvider.select((s) => s.allAzkar
          .where((item) => s.favoriteZikrIds.contains(item.id))
          .toList()),
    );

    if (favoriteAzkar.isEmpty) {
      return _EmptyFavoriteState(text: 'لا توجد أذكار في المفضلة حالياً', isDark: isDark);
    }

    return ListView.builder(
      itemCount: favoriteAzkar.length,
      cacheExtent: 300,
      itemBuilder: (context, index) {
        final zikr = favoriteAzkar[index];
        final delay = (index % 8) * 80;
        return TweenAnimationBuilder<double>(
          key: ValueKey(zikr.id),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 350 + delay),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0.0, (1.0 - value) * 24.0),
                child: child,
              ),
            );
          },
          child: ContainerBox(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  zikr.text,
                  style: ArabicTextStyle(
                    arabicFont: ArabicFont.amiri,
                    fontSize: 19,
                    color: isDark ? AppColors.white : AppColors.card,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_rounded, color: Colors.red, size: 22),
                      onPressed: () {
                        ref.read(azkarProvider.notifier).toggleFavorite(zikr.id);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'تمت الإزالة من المفضلة',
                              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            backgroundColor: Colors.grey.shade800,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    if (zikr.source != null && zikr.source!.isNotEmpty)
                      Text(
                        zikr.source!,
                        style: TextStyle(
                          fontFamily: ArabicFont.cairo,
                          fontSize: 12,
                          color: isDark ? AppColors.gold : AppColors.darkGreen,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DuaFavoritesTab extends ConsumerWidget {
  const DuaFavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    
    // Select only the favorited dua list
    final favoriteDuas = ref.watch(
      duaProvider.select((s) => s.allDuas
          .where((item) => s.favoriteDuaIds.contains(item.id))
          .toList()),
    );
    final duaNotifier = ref.read(duaProvider.notifier);

    if (favoriteDuas.isEmpty) {
      return _EmptyFavoriteState(text: 'لا توجد أدعية في المفضلة حالياً', isDark: isDark);
    }

    return ListView.builder(
      itemCount: favoriteDuas.length,
      cacheExtent: 300,
      itemBuilder: (context, index) {
        final dua = favoriteDuas[index];
        final delay = (index % 8) * 80;
        return TweenAnimationBuilder<double>(
          key: ValueKey(dua.id),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 350 + delay),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0.0, (1.0 - value) * 24.0),
                child: child,
              ),
            );
          },
          child: ContainerBox(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16, top: 8),
            borderRadius: BorderRadius.circular(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_rounded, color: Colors.red, size: 22),
                      onPressed: () {
                        duaNotifier.toggleFavorite(dua.id);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'تمت الإزالة من المفضلة',
                              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            backgroundColor: Colors.grey.shade800,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        dua.text,
                        textAlign: TextAlign.start,
                        style: ArabicTextStyle(
                          arabicFont: ArabicFont.dubai,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.lightGray : AppColors.card,
                        ),
                      ),
                      if (dua.source != null) ...[
                        const Gap(15),
                        Text(
                          dua.source!,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: ArabicFont.amiri,
                            color: AppColors.gold,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NamesFavoritesTab extends ConsumerWidget {
  const NamesFavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    
    // Select only the favorited names list
    final favoriteNames = ref.watch(
      namesOfAllahProvider.select((s) => s.allNames
          .where((item) => s.favoriteIds.contains(item.id))
          .toList()),
    );
    final namesNotifier = ref.read(namesOfAllahProvider.notifier);

    if (favoriteNames.isEmpty) {
      return _EmptyFavoriteState(text: 'لا توجد عناصر في المفضلة حالياً', isDark: isDark);
    }

    return ListView.builder(
      itemCount: favoriteNames.length,
      cacheExtent: 300,
      itemBuilder: (context, index) {
        final name = favoriteNames[index];
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
                offset: Offset(0.0, (1.0 - value) * 24.0),
                child: child,
              ),
            );
          },
          child: ContainerBox(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${name.id}',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.name,
                            style: ArabicTextStyle(
                              arabicFont: ArabicFont.amiri,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : AppColors.card,
                            ),
                          ),
                          const Gap(3),
                          Text(
                            name.meaning,
                            style: ArabicTextStyle(
                              arabicFont: ArabicFont.cairo,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: isDark ? AppColors.mediumGray : AppColors.mutedGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_rounded, color: Colors.red, size: 22),
                      onPressed: () {
                        namesNotifier.toggleFavorite(name.id);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'تمت الإزالة من المفضلة',
                              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            backgroundColor: Colors.grey.shade800,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const Gap(12),
                const Divider(color: AppColors.secondary, height: 1),
                const Gap(10),
                Text(
                  name.description,
                  style: ArabicTextStyle(
                    arabicFont: ArabicFont.cairo,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.lightGray : AppColors.card,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}