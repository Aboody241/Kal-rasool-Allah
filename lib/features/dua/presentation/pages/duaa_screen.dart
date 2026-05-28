import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/container_box.dart';
import 'package:kal_rasol_allah/features/dua/controller/dua_provider.dart';
import 'package:kal_rasol_allah/features/dua/data/dua_model.dart';

class DuaaScreen extends ConsumerWidget {
  const DuaaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);

    // Watch targeted slices of state to isolate rebuild boundaries
    final isLoading = ref.watch(duaProvider.select((s) => s.isLoading));
    final errorMessage = ref.watch(duaProvider.select((s) => s.errorMessage));
    final selectedCategory = ref.watch(duaProvider.select((s) => s.selectedCategory));
    final categories = ref.watch(duaProvider.select((s) => s.categories));
    final displayedDuas = ref.watch(duaProvider.select((s) => s.displayedDuas));

    final duaNotifier = ref.read(duaProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    'الأدعية',
                    style: AppTextStyles.title.copyWith(
                      color: isDark ? AppColors.white : AppColors.card,
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedCategory,
                    dropdownColor: isDark ? AppColors.card : AppColors.offWhite,
                    iconEnabledColor: isDark ? AppColors.white : AppColors.card,
                    style: ArabicTextStyle(
                      arabicFont: ArabicFont.cairo,
                      color: isDark ? AppColors.white : AppColors.card,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    underline: const SizedBox(),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newCategory) {
                      if (newCategory != null) {
                        duaNotifier.filterByCategory(newCategory);
                      }
                    },
                  ),
                ],
              ),
              const Gap(20),

              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: isDark
                              ? AppColors.gold
                              : AppColors.primaryGreen,
                        ),
                      )
                    : errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'حدث خطأ: $errorMessage',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : displayedDuas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selectedCategory == 'المفضلة'
                                  ? Icons.favorite_border_rounded
                                  : Icons.menu_book_rounded,
                              size: 64,
                              color: isDark
                                  ? AppColors.lightGray.withValues(alpha: 0.3)
                                  : AppColors.card.withValues(alpha: 0.2),
                            ),
                            const Gap(16),
                            Text(
                              selectedCategory == 'المفضلة'
                                  ? 'لا توجد أدعية في المفضلة حالياً'
                                  : 'لا توجد أدعية في هذا القسم',
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
                      )
                    : ListView.builder(
                        itemCount: displayedDuas.length,
                        cacheExtent: 300, // cache offscreen items for smoother scrolling
                        itemBuilder: (itemContext, index) {
                          final dua = displayedDuas[index];
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
                                  offset: Offset(
                                    0.0,
                                    (1.0 - value) * 24.0,
                                  ),
                                  child: child,
                                ),
                              );
                            },
                            child: _DuaCard(dua: dua),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Targeted isolated _DuaCard to prevent entire list rebuilds
// ============================================================
class _DuaCard extends ConsumerWidget {
  final DuaModel dua;
  const _DuaCard({required this.dua});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    
    // Select ONLY favorite status for this specific dua.id to isolate rebuilds!
    final isFavorite = ref.watch(
      duaProvider.select((s) => s.favoriteDuaIds.contains(dua.id)),
    );
    final duaNotifier = ref.read(duaProvider.notifier);

    return ContainerBox(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(bottom: 30),
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  duaNotifier.toggleFavorite(dua.id);

                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFavorite ? 'تمت الإزالة من المفضلة' : 'تمت الإضافة للمفضلة',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: isFavorite ? Colors.grey.shade800 : AppColors.primaryGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : (isDark ? AppColors.lightGray : AppColors.darkGray),
                ),
              ),

              IconButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: dua.text));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'تم نسخ الدعاء',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: AppColors.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: Icon(
                  Icons.copy_rounded,
                  color: isDark ? AppColors.lightGray : AppColors.darkGray,
                ),
              ),
            ],
          ),
          const Gap(10),
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
    );
  }
}
