import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final user = authProvider.user;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSectionTitle('ACCOUNT'),
          _buildCard([
            _buildInfoRow(Icons.person_outline, 'Logged in as', user?.username ?? '—'),
            const Divider(color: Color(0xFF1a1a1a)),
            _buildInfoRow(Icons.calendar_today, 'Subscription expires', _formatExpiryDate(user)),
          ]),
          const SizedBox(height: 20),
          
          // Decoder Section
          _buildSectionTitle('DECODER'),
          _buildCard([
            _buildToggleRow(
              icon: settingsProvider.forceSoftwareDecoder ? Icons.code : Icons.memory,
              title: settingsProvider.forceSoftwareDecoder ? 'Software Decoder' : 'Hardware Decoder',
              subtitle: settingsProvider.forceSoftwareDecoder
                  ? 'Software (MediaPlayer) · CPU · Works on all devices'
                  : 'Hardware (ExoPlayer) · GPU · Faster, may crash on some devices',
              value: settingsProvider.forceSoftwareDecoder,
              onChanged: (value) => settingsProvider.updateSetting('forceSoftwareDecoder', value),
            ),
          ]),
          const SizedBox(height: 20),
          
          // Playback Mode Section
          _buildSectionTitle('PLAYBACK MODE'),
          _buildCard([
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                'Choose how channels are streamed. Direct is faster when your network allows it. Proxy routes the stream through your server.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
            _buildRadioRow(
              icon: Icons.flash_on,
              title: 'Direct Stream',
              subtitle: 'ExoPlayer + VLC headers. Fastest, no server load.',
              selected: settingsProvider.isDirectMode,
              onTap: () => settingsProvider.updateSetting('playbackMode', 'direct'),
            ),
            _buildRadioRow(
              icon: Icons.swap_horiz,
              title: 'Proxy Stream',
              subtitle: 'Routes via your backend server. Better for restricted channels.',
              selected: settingsProvider.isProxyMode,
              onTap: () => settingsProvider.updateSetting('playbackMode', 'proxy'),
            ),
          ]),
          const SizedBox(height: 20),
          
          // Fallback Section
          _buildSectionTitle('FALLBACK'),
          _buildCard([
            _buildToggleRow(
              icon: Icons.autorenew,
              title: 'Auto-fallback to Proxy',
              subtitle: 'If Direct fails, automatically retry with Proxy.',
              value: settingsProvider.autoFallbackToProxy,
              onChanged: (value) => settingsProvider.updateSetting('autoFallbackToProxy', value),
            ),
          ]),
          const SizedBox(height: 20),
          
          // Actions Section
          _buildSectionTitle('ACTIONS'),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.grey),
              title: const Text('Reset Settings to Default'),
              onTap: () => settingsProvider.resetSettings(),
            ),
            const Divider(color: Color(0xFF1a1a1a)),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFe50914)),
              title: const Text('Logout', style: TextStyle(color: Color(0xFFe50914))),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Logout', style: TextStyle(color: Color(0xFFe50914))),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await authProvider.logout();
                  if (mounted) context.go('/login');
                }
              },
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFe50914),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1e1e1e)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[500])),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: value ? const Color(0xFFe50914) : Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFe50914),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFe50914) : const Color(0xFF1e1e1e),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: selected ? Colors.white : Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: selected ? Colors.white : Colors.grey, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? const Color(0xFFe50914) : Colors.grey[800]!),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFe50914),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _formatExpiryDate(User? user) {
    if (user?.expiryDate == null) return 'Not set';
    try {
      final date = DateTime.parse(user!.expiryDate!);
      return '${date.month}/${date.day}/${date.year}';
    } catch (_) {
      return user!.expiryDate!;
    }
  }
}