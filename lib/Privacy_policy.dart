
// ═══════════════════════════════════════════════════════════════════════════
//  7.  PRIVACY POLICY SCREEN
// ═══════════════════════════════════════════════════════════════════════════
import 'package:chromadasher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CD.bg,
      body: NeonBg(
        child: SafeArea(
          child: Column(
            children: [
              // ── App bar ──
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: CD.cyan.withOpacity(0.2), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: CD.neonBox(CD.cyan, r: 12),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: CD.cyan, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PRIVACY POLICY',
                              style: CD.glow(18, CD.cyan, ls: 3)),
                          Text('ChromaDasher',
                              style: CD.body(
                                  11, Colors.white.withOpacity(0.4))),
                        ],
                      ),
                    ),
                    const Icon(Icons.shield_rounded,
                        color: CD.cyan, size: 24),
                  ],
                ),
              ),

              // ── Content ──
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  children: [
                    _PolicySection(
                      title: 'Last Updated',
                      color: CD.amber,
                      content: 'December 1, 2024',
                    ),
                    _PolicySection(
                      title: '1. Introduction',
                      color: CD.cyan,
                      content:
                      'Ahmad Asif ("Developer", "we", "us") built '
                          'ChromaDasher as a free Android game. This privacy '
                          'policy explains what information we collect, how we '
                          'use it, and your rights regarding that information.',
                    ),
                    _PolicySection(
                      title: '2. Information We Collect',
                      color: CD.cyan,
                      content:
                      'ChromaDasher does NOT collect any personally '
                          'identifiable information. All game data (scores, '
                          'settings) is stored locally on your device using '
                          'SharedPreferences and never transmitted to external '
                          'servers.',
                    ),
                    _PolicySection(
                      title: '3. Data Storage',
                      color: CD.cyan,
                      content:
                      'Your high scores and game preferences are saved '
                          'locally on your device only. We have no access to '
                          'this data. Uninstalling the app will permanently '
                          'remove all locally stored data.',
                    ),
                    _PolicySection(
                      title: '4. Third-Party Services',
                      color: CD.cyan,
                      content:
                      'ChromaDasher does not integrate with any '
                          'third-party analytics, advertising, or tracking '
                          'services. No data is shared with, sold to, or '
                          'disclosed to any third parties.',
                    ),
                    _PolicySection(
                      title: '5. Children\'s Privacy',
                      color: CD.cyan,
                      content:
                      'ChromaDasher is suitable for all ages. We do not '
                          'knowingly collect personal information from children '
                          'or any users. Since no data is collected at all, '
                          'COPPA and similar regulations are fully satisfied.',
                    ),
                    _PolicySection(
                      title: '6. Permissions',
                      color: CD.cyan,
                      content:
                      'The app may request vibration permission to '
                          'provide haptic feedback during gameplay. No other '
                          'device permissions (camera, microphone, location, '
                          'contacts) are requested or required.',
                    ),
                    _PolicySection(
                      title: '7. Changes to This Policy',
                      color: CD.cyan,
                      content:
                      'We may update this Privacy Policy from time to '
                          'time. Changes will be reflected with an updated '
                          '"Last Updated" date. Continued use of the app '
                          'constitutes acceptance of the revised policy.',
                    ),
                    _PolicySection(
                      title: '8. Contact Us',
                      color: CD.violet,
                      content:
                      'If you have any questions about this Privacy '
                          'Policy, please contact us at:\n\n'
                          'Developer: Ahmad Asif\n'
                          'Email: ahmad.asif.dev@gmail.com',
                    ),

                    const SizedBox(height: 12),
                    NeonDivider(color: CD.cyan),
                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        '© 2024 Ahmad Asif. All rights reserved.',
                        style: CD.body(11, Colors.white.withOpacity(0.25)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;
  final Color color;

  const _PolicySection({
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CD.label(13, color, ls: 1)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: color.withOpacity(0.2), width: 1),
            ),
            child: Text(content,
                style: CD.body(13, Colors.white.withOpacity(0.72))),
          ),
        ],
      ),
    );
  }
}
