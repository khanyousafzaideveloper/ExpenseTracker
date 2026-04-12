import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = context.watch<ThemeProvider>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionLabel(context, 'Appearance'),
        const SizedBox(height: 8),

        Card(
          elevation: 0,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: SwitchListTile(
            secondary: Icon(
              themeProvider.isDark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            title: const Text('Dark Mode'),
            subtitle: Text(
              themeProvider.isDark ? 'On' : 'Off',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
        ),

        const SizedBox(height: 24),

        _sectionLabel(context, 'About'),
        const SizedBox(height: 8),

        Card(
          elevation: 0,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              _infoTile(context,
                  icon: Icons.info_outline,
                  label: 'App Name',
                  value: 'Expense Tracker'),
              Divider(
                  height: 1, indent: 56, color: colorScheme.outlineVariant),
              _infoTile(context,
                  icon: Icons.tag_outlined, label: 'Version', value: '1.0.0'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _infoTile(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}