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

  Widget _buildEmptyState(String text, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 64,
            color: isDark
                ? AppColors.lightGray.withOpacity(0.3)
                : AppColors.card.withOpacity(0.2),
          ),
          const Gap(16),
          Text(
            text,
            style: ArabicTextStyle(
              arabicFont: ArabicFont.cairo,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.lightGray.withOpacity(0.6)
                  : AppColors.card.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAhadithList(BuildContext context, WidgetRef ref, List<dynamic> items, bool isDark) {
    if (items.isEmpty) {
      return _buildEmptyState('لا توجد أحاديث في المفضلة حالياً', isDark);
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final hadith = items[index];
        final delay = (index % 8) * 80;
        return TweenAnimationBuilder<double>(
          key: ValueKey(hadith['id']),
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
                        ref.read(homeProvider.notifier).toggleFavorite(hadith['id']);
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
                    if (hadith['narrator'] != null && hadith['narrator'].toString().isNotEmpty)
                      Text(
                        'عن ${hadith['narrator']}',
                        style: ArabicTextStyle(
                          arabicFont: ArabicFont.cairo,
                          fontSize: 12,
                          color: isDark ? AppColors.mediumGray : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const Gap(10),
                Text(
                  hadith['text'],
                  style: ArabicTextStyle(
                    arabicFont: ArabicFont.amiri,
                    fontSize: 22,
                    color: isDark ? AppColors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (hadith['source'] != null && hadith['source'].toString().isNotEmpty) ...[
                  const Gap(15),
                  Text(
                    hadith['source'],
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

  Widget _buildAzkarList(BuildContext context, WidgetRef ref, List<dynamic> items, bool isDark) {
    if (items.isEmpty) {
      return _buildEmptyState('لا توجد أذكار في المفضلة حالياً', isDark);
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final zikr = items[index];
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
                    if (zikr.source != null && zikr.source.isNotEmpty)
                      Text(
                        zikr.source,
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

  Widget _buildDuasList(BuildContext context, WidgetRef ref, List<dynamic> items, DuaNotifier notifier, bool isDark) {
    if (items.isEmpty) {
      return _buildEmptyState('لا توجد أدعية في المفضلة حالياً', isDark);
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final dua = items[index];
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
                        notifier.toggleFavorite(dua.id);
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
                          color: AppColors.lightGray,
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

  Widget _buildNamesList(BuildContext context, WidgetRef ref, List<dynamic> items, NamesOfAllahNotifier notifier, bool isDark) {
    if (items.isEmpty) {
      return _buildEmptyState('لا توجد عناصر في المفضلة حالياً', isDark);
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final name = items[index];
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
                        color: AppColors.primaryGreen.withOpacity(0.2),
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
                              color: AppColors.white,
                            ),
                          ),
                          const Gap(3),
                          Text(
                            name.meaning,
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
                    IconButton(
                      icon: const Icon(Icons.favorite_rounded, color: Colors.red, size: 22),
                      onPressed: () {
                        notifier.toggleFavorite(name.id);
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
                    color: AppColors.lightGray,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);

    // Watch all favorite states
    final homeState = ref.watch(homeProvider);
    final azkarState = ref.watch(azkarProvider);
    final duaState = ref.watch(duaProvider);
    final duaNotifier = ref.read(duaProvider.notifier);
    final namesState = ref.watch(namesOfAllahProvider);
    final namesNotifier = ref.read(namesOfAllahProvider.notifier);

    // Filter favorite lists
    final favoriteAhadith = homeState.ahadith
        .where((h) => homeState.favoriteHadithIds.contains(h['id']))
        .toList();

    final favoriteAzkar = azkarState.allAzkar
        .where((z) => azkarState.favoriteZikrIds.contains(z.id))
        .toList();

    final favoriteDuas = duaState.allDuas
        .where((d) => duaState.favoriteDuaIds.contains(d.id))
        .toList();

    final favoriteNames = namesState.allNames
        .where((n) => namesState.favoriteIds.contains(n.id))
        .toList();

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
                    Tab(text: 'أحاديث'),
                    Tab(text: 'أذكار'),
                    Tab(text: 'أدعية'),
                    Tab(text: 'أسماء الله'),
                  ],
                ),
                const Gap(16),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildAhadithList(context, ref, favoriteAhadith, isDark),
                      _buildAzkarList(context, ref, favoriteAzkar, isDark),
                      _buildDuasList(context, ref, favoriteDuas, duaNotifier, isDark),
                      _buildNamesList(context, ref, favoriteNames, namesNotifier, isDark),
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