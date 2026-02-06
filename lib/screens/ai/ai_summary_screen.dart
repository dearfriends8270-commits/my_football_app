import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/athlete_provider.dart';
import '../../models/athlete.dart';
import '../../models/sport_type.dart';
import '../../utils/app_colors.dart';

class AISummaryScreen extends ConsumerStatefulWidget {
  const AISummaryScreen({super.key});

  @override
  ConsumerState<AISummaryScreen> createState() => _AISummaryScreenState();
}

class _AISummaryScreenState extends ConsumerState<AISummaryScreen> {
  SportType? _filterSport;

  @override
  Widget build(BuildContext context) {
    final athleteState = ref.watch(athleteProvider);
    final favoriteAthletes = athleteState.favoriteAthletes;
    final selectedAthlete = athleteState.selectedAthlete ?? (favoriteAthletes.isNotEmpty ? favoriteAthletes.first : null);
    final followedSports = ref.watch(followedSportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopHeader(),
              const SizedBox(height: 12),
              if (favoriteAthletes.isNotEmpty)
                _buildAthleteSelector(favoriteAthletes, selectedAthlete),
              const SizedBox(height: 16),
              _buildSportFilterBar(followedSports),
              const SizedBox(height: 20),
              _buildRecentMatchSection(selectedAthlete),
              const SizedBox(height: 20),
              _buildMatchResultCard(selectedAthlete),
              const SizedBox(height: 16),
              _buildViewSummaryButton(),
              const SizedBox(height: 28),
              _buildAIFeaturesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textSecondary, size: 16),
              ),
              const Spacer(),
              const Text('\uC18C\uC2DD', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const Spacer(),
              // 우측 빈 공간 밸런스
              const SizedBox(width: 36),
            ],
          ),
          const SizedBox(height: 10),
          _buildAIPremiumBadge(),
        ],
      ),
    );
  }

  Widget _buildAIPremiumBadge() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            const Color(0xFF7C3AED).withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.accent, size: 14),
              const SizedBox(width: 4),
              Text('AI \uC218\uB824\uD55C \uC774\uB984', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 4),
          Text('AI \uC694\uC57D \uC794\uC5EC \uD3EC\uC778\uD2B8: 100P', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
          Text('\uD504\uB9AC\uBBF8\uC5C4 \uAD6C\uB3C5\uC2DC \uBB34\uC81C\uD55C', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(6)),
            child: const Text('\uD504\uB9AC\uBBF8\uC5C4 \uC2DC\uC791', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAthleteSelector(List<Athlete> favorites, Athlete? selected) {
    final currentIndex = selected != null ? favorites.indexWhere((a) => a.id == selected.id) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (favorites.length <= 1) return;
              final prevIndex = (currentIndex - 1 + favorites.length) % favorites.length;
              ref.read(athleteProvider.notifier).selectAthlete(favorites[prevIndex]);
            },
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.backgroundCard, shape: BoxShape.circle, border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
              child: const Icon(Icons.chevron_left, color: AppColors.textSecondary, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Text(selected?.nameKr ?? '\uC120\uC218 \uC5C6\uC74C', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              if (favorites.length <= 1) return;
              final nextIndex = (currentIndex + 1) % favorites.length;
              ref.read(athleteProvider.notifier).selectAthlete(favorites[nextIndex]);
            },
            child: Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.backgroundCard, shape: BoxShape.circle, border: Border.all(color: AppColors.border.withValues(alpha: 0.5))),
              child: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () { ref.read(mainTabIndexProvider.notifier).state = 1; },
            child: const Text('\uD3B8\uC9D1', style: TextStyle(fontSize: 13, color: AppColors.primary, decoration: TextDecoration.underline, decorationColor: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildSportFilterBar(Set<SportType> followedSports) {
    final sportsList = followedSports.toList();
    final allItems = <SportType?>[null, ...sportsList];

    Widget buildTab(SportType? sport, bool isSelected) {
      return GestureDetector(
        onTap: () { setState(() { _filterSport = sport; }); },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(sport?.icon ?? '\uD83C\uDF10', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                sport?.displayName ?? '\uC804\uCCB4',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (allItems.length <= 4) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.border.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: allItems.map((sport) {
            final isSelected = _filterSport == sport;
            return Expanded(child: buildTab(sport, isSelected));
          }).toList(),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: allItems.length,
        itemBuilder: (context, index) {
          final sport = allItems[index];
          final isSelected = _filterSport == sport;
          return buildTab(sport, isSelected);
        },
      ),
    );
  }

  Widget _buildRecentMatchSection(Athlete? athlete) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_filled, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text('\uCD5C\uADFC \uACBD\uAE30 \uC601\uC0C1 \uBC0F \uC815\uBCF4', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildVideoThumbnailCard(
                title: '${athlete?.nameKr ?? "\uC774\uAC15\uC778"} \uB3D9\uC810\uACE8',
                subtitle: '78\uBD84 | \uD504\uB9AC\uD0A5',
                gradientColors: [const Color(0xFF001C58), const Color(0xFF0D47A1)],
                icon: Icons.sports_soccer,
              ),
              _buildVideoThumbnailCard(
                title: 'PSG 3-1',
                subtitle: 'MVP | ${athlete?.nameKr ?? "\uC774\uAC15\uC778"} 9.5',
                gradientColors: [const Color(0xFF1A237E), const Color(0xFF283593)],
                icon: Icons.emoji_events,
              ),
              _buildVideoThumbnailCard(
                title: '\uD504\uB9AC\uD0A5 \uB9DE\uB300\uACB0',
                subtitle: 'PSG vs FC M...',
                gradientColors: [const Color(0xFF004D40), const Color(0xFF00695C)],
                icon: Icons.sports,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoThumbnailCard({
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required IconData icon,
  }) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Stack(
        children: [
          Positioned(right: -10, top: -10, child: Icon(icon, size: 80, color: Colors.white.withValues(alpha: 0.08))),
          Positioned(
            top: 10, right: 10,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
            ),
          ),
          Positioned(
            left: 10, right: 10, bottom: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchResultCard(Athlete? athlete) {
    final teamName = athlete?.team ?? 'PSG';
    final shortTeam = teamName.length > 3 ? teamName.substring(0, 3).toUpperCase() : teamName.toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft, end: Alignment.centerRight,
                colors: [(athlete?.teamColor ?? const Color(0xFF001C58)), (athlete?.teamColor ?? const Color(0xFF001C58)).withValues(alpha: 0.7)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: Center(child: Text(shortTeam.isNotEmpty ? shortTeam[0] : 'P', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$shortTeam 3-1 Marseille', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('2028.02.06 | Ligue 1', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
                  child: const Text('5P', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  '\uD30C\uB9AC \uC0DD\uC81C\uB974\uB9F9\uC774 \uB77C\uC774\uC5B8\uB4DC \uBCF4 \uD1A0\uC2A4\uC640\uC758 \uB974 \uD074\uB77C\uC2DC\uD06C \uB9AC\uADF8 1 36\uB77C\uC6B4\uB4DC \uACBD\uAE30\uB97C \uC9C4\uD589\uD588\uB2E4. UEFA \uCC54\uD53C\uC5B8\uC2A4 \uB9AC\uADF8 36\uB77C\uC6B4\uB4DC \uACBD\uAE30\uB97C \uC9C4\uD589\uD588\uB2E4.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withValues(alpha: 0.6), height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [AppColors.backgroundCard.withValues(alpha: 0), AppColors.backgroundCard.withValues(alpha: 0.85), AppColors.backgroundCard],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewSummaryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundCard,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4), width: 1)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('\uC804\uCCB4 \uC694\uC57D \uBCF4\uAE30', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text('5 \uD3EC\uC778\uD2B8 \uC0AC\uC6A9 \uB610\uB294 \uD504\uB9AC\uBBF8\uC5C4 \uAD6C\uB3C5', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildAIFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              const Text('AI\uAE30\uB2A5', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.3), const Color(0xFF7C3AED).withValues(alpha: 0.3)]),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('AI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryLight)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAIFeatureItem(title: '\uACBD\uAE30 \uC2A4\uD1A0\uB9AC \uC694\uC57D', description: '\uACBD\uAE30\uC758 \uAE30\uC2B9\uC804\uACB0\uC744 3~5\uC904\uB85C \uC694\uC57D', points: '5P', icon: Icons.summarize_outlined),
          _buildAIFeatureItem(title: '\uD575\uC2EC \uC7A5\uBA74 \uD0C0\uC784\uB77C\uC778', description: '\uC8FC\uC694 \uC7A5\uBA74\uC744 \uC2DC\uAC01\uC801\uC73C\uB85C \uC815\uB9AC', points: '20P', icon: Icons.timeline_outlined),
          _buildAIFeatureItem(title: '\uD604\uC9C0 \uC5B8\uB860 \uAE30\uC0AC \uC81C\uACF5', description: '\uD574\uC678 \uAE30\uC0AC \uC694\uC57D \uBC0F \uBC88\uC5ED', points: '20P', icon: Icons.translate_outlined),
          _buildAIFeatureItem(title: '\uB8E8\uBA38 \uC2E0\uB8B0\uB3C4 \uBD84\uC11D', description: '\uC774\uC801 \uB8E8\uBA38\uC758 \uC2E0\uB8B0\uB3C4\uB97C AI\uAC00 \uBD84\uC11D', points: '30P', icon: Icons.analytics_outlined),
        ],
      ),
    );
  }

  Widget _buildAIFeatureItem({
    required String title,
    required String description,
    required String points,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
            ),
            child: Text(points, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
