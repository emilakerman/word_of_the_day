import 'package:flutter/material.dart';
import '../services/notification_preference_service.dart';
import '../services/word_history_service.dart';

/// Settings screen for user preferences.
///
/// Provides options for:
/// - Theme selection (light/dark/system)
/// - Notification time preference
/// - Clear history option
/// - About section with app version
/// - Privacy policy and terms links
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
    this.appVersion = '0.1.0',
  });

  /// The current theme mode
  final ThemeMode currentThemeMode;

  /// Callback when the user changes the theme
  final void Function(ThemeMode mode) onThemeChanged;

  /// The app version to display in the About section
  final String appVersion;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationPreferenceService _notificationService =
      NotificationPreferenceService();
  final WordHistoryService _historyService = WordHistoryService();

  TimeOfDay _notificationTime = NotificationPreferenceService.defaultTime;
  bool _notificationsEnabled = true;
  int _historyCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final time = await _notificationService.getNotificationTime();
    final enabled = await _notificationService.getNotificationsEnabled();
    final count = await _historyService.historyCount;

    if (mounted) {
      setState(() {
        _notificationTime = time;
        _notificationsEnabled = enabled;
        _historyCount = count;
        _isLoading = false;
      });
    }
  }

  Future<void> _onNotificationTimeChanged(TimeOfDay time) async {
    try {
      await _notificationService.setNotificationTime(time);
      if (mounted) {
        setState(() => _notificationTime = time);
      }
    } on NotificationPreferenceException catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to save notification time: $e');
      }
    }
  }

  Future<void> _onNotificationsEnabledChanged(bool enabled) async {
    try {
      await _notificationService.setNotificationsEnabled(enabled);
      if (mounted) {
        setState(() => _notificationsEnabled = enabled);
      }
    } on NotificationPreferenceException catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to save notification preference: $e');
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all word history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _historyService.clearHistory();
        if (mounted) {
          setState(() => _historyCount = 0);
          _showSuccessSnackBar('History cleared successfully');
        }
      } on WordHistoryException catch (e) {
        if (mounted) {
          _showErrorSnackBar('Failed to clear history: $e');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      helpText: 'Select notification time',
    );

    if (picked != null && mounted) {
      await _onNotificationTimeChanged(picked);
    }
  }

  void _showThemePicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Select Theme',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _ThemeOption(
                  label: 'System default',
                  icon: Icons.phone_android_outlined,
                  isSelected: widget.currentThemeMode == ThemeMode.system,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onThemeChanged(ThemeMode.system);
                  },
                ),
                _ThemeOption(
                  label: 'Light',
                  icon: Icons.light_mode_outlined,
                  isSelected: widget.currentThemeMode == ThemeMode.light,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onThemeChanged(ThemeMode.light);
                  },
                ),
                _ThemeOption(
                  label: 'Dark',
                  icon: Icons.dark_mode_outlined,
                  isSelected: widget.currentThemeMode == ThemeMode.dark,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onThemeChanged(ThemeMode.dark);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openPrivacyPolicy() {
    _showPlaceholderDialog(
      title: 'Privacy Policy',
      message: 'Privacy policy content will be displayed here.',
    );
  }

  void _openTermsOfService() {
    _showPlaceholderDialog(
      title: 'Terms of Service',
      message: 'Terms of service content will be displayed here.',
    );
  }

  void _showPlaceholderDialog({required String title, required String message}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final materialLocalizations = MaterialLocalizations.of(context);
    final use24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    return materialLocalizations.formatTimeOfDay(
      time,
      alwaysUse24HourFormat: use24HourFormat,
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Appearance Section
                _buildSectionHeader(context, 'Appearance'),
                _buildSettingsTile(
                  context,
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: _getThemeModeLabel(widget.currentThemeMode),
                  onTap: _showThemePicker,
                ),
                const Divider(height: 1),

                // Notifications Section
                _buildSectionHeader(context, 'Notifications'),
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_outlined,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Daily Notifications'),
                  subtitle: const Text('Get notified about the word of the day'),
                  value: _notificationsEnabled,
                  onChanged: _onNotificationsEnabledChanged,
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.access_time_outlined,
                  title: 'Notification Time',
                  subtitle: _formatTime(_notificationTime),
                  onTap: _notificationsEnabled ? _showTimePicker : null,
                  enabled: _notificationsEnabled,
                ),
                const Divider(height: 1),

                // Data Section
                _buildSectionHeader(context, 'Data'),
                _buildSettingsTile(
                  context,
                  icon: Icons.delete_outline,
                  title: 'Clear History',
                  subtitle: _historyCount > 0
                      ? '$_historyCount ${_historyCount == 1 ? 'word' : 'words'} in history'
                      : 'No history',
                  onTap: _historyCount > 0 ? _clearHistory : null,
                  enabled: _historyCount > 0,
                  iconColor: _historyCount > 0 ? colorScheme.error : null,
                ),
                const Divider(height: 1),

                // About Section
                _buildSectionHeader(context, 'About'),
                _buildSettingsTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'App Version',
                  subtitle: widget.appVersion,
                  onTap: null,
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: _openPrivacyPolicy,
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: _openTermsOfService,
                ),

                const SizedBox(height: 32),

                // Footer
                Center(
                  child: Text(
                    'Word of the Day',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Made with ❤️',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool enabled = true,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: enabled
            ? (iconColor ?? colorScheme.primary)
            : colorScheme.onSurface.withOpacity(0.38),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? null : colorScheme.onSurface.withOpacity(0.38),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: enabled
                    ? colorScheme.onSurface.withOpacity(0.6)
                    : colorScheme.onSurface.withOpacity(0.38),
              ),
            )
          : null,
      trailing: onTap != null && enabled
          ? Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withOpacity(0.38),
            )
          : null,
      onTap: enabled ? onTap : null,
      enabled: enabled,
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? colorScheme.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
