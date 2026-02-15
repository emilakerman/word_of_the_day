import 'package:flutter/material.dart';
import '../models/word.dart';
import '../services/word_history_service.dart';

/// Screen displaying the history of previously viewed words.
///
/// Shows a paginated list of words with dates, supporting pull-to-refresh
/// and infinite scrolling. Tapping a word shows its details.
class WordHistoryScreen extends StatefulWidget {
  const WordHistoryScreen({
    super.key,
    this.onWordSelected,
  });

  /// Callback when a word is selected from the history.
  final void Function(Word word)? onWordSelected;

  @override
  State<WordHistoryScreen> createState() => _WordHistoryScreenState();
}

class _WordHistoryScreenState extends State<WordHistoryScreen> {
  final WordHistoryService _historyService = WordHistoryService();
  final ScrollController _scrollController = ScrollController();
  final List<WordHistoryEntry> _entries = [];

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadInitialHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final entries = await _historyService.getHistory(offset: 0, limit: _pageSize);
      if (mounted) {
        setState(() {
          _entries.clear();
          _entries.addAll(entries);
          _hasMore = entries.length >= _pageSize;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load history: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreHistory() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final entries = await _historyService.getHistory(
        offset: _entries.length,
        limit: _pageSize,
      );
      if (mounted) {
        setState(() {
          _entries.addAll(entries);
          _hasMore = entries.length >= _pageSize;
          _isLoadingMore = false;
        });
      }
    } on Exception {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Word History'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState(context);
    }

    if (_entries.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: _loadInitialHistory,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _entries.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _entries.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildHistoryItem(context, _entries[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_outlined,
              size: 80,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Word History',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Words you view will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadInitialHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, WordHistoryEntry entry) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => widget.onWordSelected?.call(entry.word),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getDayOfMonth(entry.date),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getMonthAbbreviation(entry.date),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Word details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.word.word,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            entry.word.partOfSpeech.value,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        if (entry.word.pronunciation != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.word.pronunciation!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.word.definition,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Chevron
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayOfMonth(DateTime date) {
    return date.day.toString();
  }

  String _getMonthAbbreviation(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[date.month - 1];
  }
}
