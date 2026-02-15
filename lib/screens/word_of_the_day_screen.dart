import 'package:flutter/material.dart';
import '../models/word.dart';

/// A screen that displays the Word of the Day with its details.
class WordOfTheDayScreen extends StatelessWidget {
  /// The word to display
  final Word word;

  /// Callback when the share button is tapped
  final VoidCallback? onShare;

  /// Callback when the favorite button is tapped
  final VoidCallback? onFavorite;

  /// Callback when the settings button is tapped
  final VoidCallback? onSettings;

  /// Callback when the history button is tapped
  final VoidCallback? onHistory;

  /// Callback when the audio playback button is tapped
  final VoidCallback? onPlayAudio;

  /// Whether the word is marked as favorite
  final bool isFavorite;

  /// Whether audio is currently playing
  final bool isAudioPlaying;

  /// Whether audio is loading
  final bool isAudioLoading;

  const WordOfTheDayScreen({
    super.key,
    required this.word,
    this.onShare,
    this.onFavorite,
    this.onSettings,
    this.onHistory,
    this.onPlayAudio,
    this.isFavorite = false,
    this.isAudioPlaying = false,
    this.isAudioLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 60,
              floating: true,
              backgroundColor: colorScheme.surface,
              elevation: 0,
              title: Text(
                'Word of the Day',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: onFavorite,
                  tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: onShare,
                  tooltip: 'Share',
                ),
                IconButton(
                  icon: const Icon(Icons.history_outlined),
                  onPressed: onHistory,
                  tooltip: 'Word History',
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: onSettings,
                  tooltip: 'Settings',
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Date indicator
                  if (word.date != null) _buildDateIndicator(context),

                  const SizedBox(height: 16),

                  // Word Card
                  _buildWordCard(context),

                  const SizedBox(height: 24),

                  // Definition Section
                  _buildDefinitionSection(context),

                  if (word.exampleSentence != null) ...[
                    const SizedBox(height: 24),
                    _buildExampleSection(context),
                  ],

                  if (word.etymology != null) ...[
                    const SizedBox(height: 24),
                    _buildEtymologySection(context),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final date = word.date!;
    final formattedDate = _formatDate(date);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          formattedDate,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildWordCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Part of speech badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              word.partOfSpeech.value,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Word
          Text(
            word.word,
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),

          // Pronunciation
          if (word.pronunciation != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _buildAudioButton(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    word.pronunciation!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAudioButton() {
    final hasAudio = word.audioUrl != null && word.audioUrl!.isNotEmpty;

    if (isAudioLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      );
    }

    return GestureDetector(
      onTap: hasAudio ? onPlayAudio : null,
      child: Icon(
        isAudioPlaying ? Icons.stop_circle_outlined : Icons.volume_up_outlined,
        color: hasAudio
            ? Colors.white.withOpacity(0.9)
            : Colors.white.withOpacity(0.4),
        size: 24,
      ),
    );
  }

  Widget _buildDefinitionSection(BuildContext context) {
    final theme = Theme.of(context);

    return _buildSection(
      context: context,
      icon: Icons.menu_book_outlined,
      title: 'Definition',
      child: Text(
        word.definition,
        style: theme.textTheme.bodyLarge?.copyWith(
          height: 1.6,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildExampleSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildSection(
      context: context,
      icon: Icons.format_quote_outlined,
      title: 'Example',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Text(
          '"${word.exampleSentence}"',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEtymologySection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildSection(
      context: context,
      icon: Icons.history_edu_outlined,
      title: 'Etymology',
      child: Text(
        word.etymology!,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.8),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
