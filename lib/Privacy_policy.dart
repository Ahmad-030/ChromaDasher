import 'package:chromadasher/theme.dart' show CD, NeonBg;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/privacy_policy.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080F),
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

              // ── WebView Content ──
              Expanded(
                child: WebViewWidget(controller: _controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}