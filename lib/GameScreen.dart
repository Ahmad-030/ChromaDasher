import 'dart:async';
import 'dart:math';
import 'package:chromadasher/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Theme Definitions ───────────────────────────────────────────────────────

enum WorldTheme { darkForest, lightDesert, neonCity, snowTundra }

class WorldThemeData {
  final String name;
  final Color skyTop;
  final Color skyBottom;
  final Color groundColor;
  final Color groundAccent;
  final Color obstacleColor;
  final Color characterColor;
  final Color characterAccent;
  final Color uiColor;
  final Color uiAccent;
  final IconData icon;

  const WorldThemeData({
    required this.name,
    required this.skyTop,
    required this.skyBottom,
    required this.groundColor,
    required this.groundAccent,
    required this.obstacleColor,
    required this.characterColor,
    required this.characterAccent,
    required this.uiColor,
    required this.uiAccent,
    required this.icon,
  });
}

const Map<WorldTheme, WorldThemeData> kThemes = {
  WorldTheme.darkForest: WorldThemeData(
    name: 'Dark Forest',
    skyTop: Color(0xFF0A0E1A),
    skyBottom: Color(0xFF1A2A1A),
    groundColor: Color(0xFF1B4332),
    groundAccent: Color(0xFF2D6A4F),
    obstacleColor: Color(0xFF52B788),
    characterColor: Color(0xFF1B4332),
    characterAccent: Color(0xFF74C69D),
    uiColor: Color(0xFF74C69D),
    uiAccent: Color(0xFF40916C),
    icon: Icons.forest,
  ),
  WorldTheme.lightDesert: WorldThemeData(
    name: 'Light Desert',
    skyTop: Color(0xFFFFE5A0),
    skyBottom: Color(0xFFFFA500),
    groundColor: Color(0xFFD4A017),
    groundAccent: Color(0xFFE8C547),
    obstacleColor: Color(0xFFC77B3A),
    characterColor: Color(0xFFC77B3A),
    characterAccent: Color(0xFFFFD700),
    uiColor: Color(0xFF7B3F00),
    uiAccent: Color(0xFFC77B3A),
    icon: Icons.wb_sunny,
  ),
  WorldTheme.neonCity: WorldThemeData(
    name: 'Neon City',
    skyTop: Color(0xFF050510),
    skyBottom: Color(0xFF1A0030),
    groundColor: Color(0xFF0D0D2B),
    groundAccent: Color(0xFF1A1A4E),
    obstacleColor: Color(0xFFFF00FF),
    characterColor: Color(0xFF00FFFF),
    characterAccent: Color(0xFFFF00FF),
    uiColor: Color(0xFF00FFFF),
    uiAccent: Color(0xFFFF00FF),
    icon: Icons.location_city,
  ),
  WorldTheme.snowTundra: WorldThemeData(
    name: 'Snow Tundra',
    skyTop: Color(0xFFB0C8E8),
    skyBottom: Color(0xFFE8F4FD),
    groundColor: Color(0xFFDEEFF8),
    groundAccent: Color(0xFFB8D4E8),
    obstacleColor: Color(0xFF607D8B),
    characterColor: Color(0xFF37474F),
    characterAccent: Color(0xFF90CAF9),
    uiColor: Color(0xFF1565C0),
    uiAccent: Color(0xFF42A5F5),
    icon: Icons.ac_unit,
  ),
};

// ─── Game Models ─────────────────────────────────────────────────────────────

class Obstacle {
  double x;
  final double width;
  final double height;
  final bool isHighObstacle;

  Obstacle({
    required this.x,
    required this.width,
    required this.height,
    required this.isHighObstacle,
  });
}

class Particle {
  double x, y, vx, vy, life, maxLife, size;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.maxLife,
    required this.size,
    required this.color,
  });
}

// ─── Game State ───────────────────────────────────────────────────────────────

class GameState {
  double characterY = 0;
  double characterVY = 0;
  bool isJumping = false;
  bool isDucking = false;
  bool isAlive = true;
  bool isStarted = false;
  bool isPaused = false;

  int score = 0;
  double speed = 4.0;
  double timeToNextTheme = 10.0;
  double totalTime = 0.0;

  WorldTheme currentTheme = WorldTheme.darkForest;
  WorldTheme? pendingTheme;
  bool themeMismatched = false;

  List<Obstacle> obstacles = [];
  List<Particle> particles = [];

  double obstacleTimer = 0;
  double obstacleInterval = 2.5;

  WorldTheme playerTheme = WorldTheme.darkForest;

  void reset() {
    characterY = 0;
    characterVY = 0;
    isJumping = false;
    isDucking = false;
    isAlive = true;
    isStarted = false;
    isPaused = false;
    score = 0;
    speed = 4.0;
    timeToNextTheme = 10.0;
    totalTime = 0.0;
    currentTheme = WorldTheme.darkForest;
    playerTheme = WorldTheme.darkForest;
    pendingTheme = null;
    themeMismatched = false;
    obstacles.clear();
    particles.clear();
    obstacleTimer = 0;
    obstacleInterval = 2.5;
  }
}

// ─── Game Screen ──────────────────────────────────────────────────────────────

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final GameState _state = GameState();
  final Random _random = Random();

  late AnimationController _tickController;
  late AnimationController _themeTransitionCtrl;

  Color _skyTop = kThemes[WorldTheme.darkForest]!.skyTop;
  Color _skyBottom = kThemes[WorldTheme.darkForest]!.skyBottom;
  Color _groundColor = kThemes[WorldTheme.darkForest]!.groundColor;

  Color _targetSkyTop = kThemes[WorldTheme.darkForest]!.skyTop;
  Color _targetSkyBottom = kThemes[WorldTheme.darkForest]!.skyBottom;
  Color _targetGround = kThemes[WorldTheme.darkForest]!.groundColor;

  double _themeTransitionProgress = 1.0;
  bool _showThemeWarning = false;
  double _warningAlpha = 0;

  static const double kGroundY = 0.72;
  static const double kCharacterX = 0.18;

  // ── FIXED: Snappier jump — higher gravity, lower force ──
  static const double kGravity = 0.010;
  static const double kJumpForce = -0.20;

  final List<WorldTheme> _themeOrder = [
    WorldTheme.darkForest,
    WorldTheme.lightDesert,
    WorldTheme.neonCity,
    WorldTheme.snowTundra,
  ];
  int _themeIndex = 0;

  @override
  void initState() {
    super.initState();

    _themeTransitionCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_tick);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _tickController.dispose();
    _themeTransitionCtrl.dispose();
    super.dispose();
  }

  void _startGame() {
    _state.reset();
    _themeIndex = 0;
    _skyTop = kThemes[WorldTheme.darkForest]!.skyTop;
    _skyBottom = kThemes[WorldTheme.darkForest]!.skyBottom;
    _groundColor = kThemes[WorldTheme.darkForest]!.groundColor;
    _themeTransitionProgress = 1.0;
    _showThemeWarning = false;
    _state.isStarted = true;
    _tickController.repeat();
  }

  void _jump() {
    if (!_state.isStarted) {
      _startGame();
      return;
    }
    if (!_state.isAlive) return;
    if (_state.isPaused) return;
    if (!_state.isJumping) {
      _state.characterVY = kJumpForce;
      _state.isJumping = true;
      HapticFeedback.lightImpact();
    }
  }

  void _togglePause() {
    if (!_state.isStarted || !_state.isAlive) return;
    setState(() {
      _state.isPaused = !_state.isPaused;
      if (_state.isPaused) {
        _tickController.stop();
      } else {
        _tickController.repeat();
      }
    });
    HapticFeedback.selectionClick();
  }

  void _togglePlayerTheme() {
    if (!_state.isStarted || !_state.isAlive || _state.isPaused) return;
    final themes = WorldTheme.values;
    final currentIdx = themes.indexOf(_state.playerTheme);
    _state.playerTheme = themes[(currentIdx + 1) % themes.length];
    _state.themeMismatched = _state.playerTheme != _state.currentTheme;
    HapticFeedback.selectionClick();
    setState(() {});
  }

  void _tick() {
    if (!_state.isStarted || !_state.isAlive || _state.isPaused) return;

    const double dt = 0.016;
    _state.totalTime += dt;
    _state.timeToNextTheme -= dt;
    _state.score = (_state.totalTime * 10).toInt();
    _state.speed = 5.0 + _state.totalTime * 0.08;

    if (_state.timeToNextTheme <= 3.0 && !_showThemeWarning) {
      _showThemeWarning = true;
    }

    if (_state.timeToNextTheme <= 0) {
      _triggerThemeSwitch();
    }

    if (_showThemeWarning) {
      _warningAlpha = (sin(_state.totalTime * 8) * 0.5 + 0.5) * 0.6;
    } else {
      _warningAlpha = 0;
    }

    // Theme transition lerp
    if (_themeTransitionProgress < 1.0) {
      _themeTransitionProgress =
          (_themeTransitionProgress + dt / 1.5).clamp(0.0, 1.0);
      final t = Curves.easeInOut.transform(_themeTransitionProgress);
      _skyTop = Color.lerp(_skyTop, _targetSkyTop, t * 0.05)!;
      _skyBottom = Color.lerp(_skyBottom, _targetSkyBottom, t * 0.05)!;
      _groundColor = Color.lerp(_groundColor, _targetGround, t * 0.05)!;
    }

    // Gravity
    _state.characterVY += kGravity;
    _state.characterY += _state.characterVY;
    if (_state.characterY >= 0) {
      _state.characterY = 0;
      _state.characterVY = 0;
      _state.isJumping = false;
    }

    // Obstacles
    _state.obstacleTimer += dt;
    if (_state.obstacleTimer >= _state.obstacleInterval) {
      _state.obstacleTimer = 0;
      _state.obstacleInterval = 1.8 + _random.nextDouble() * 1.2;
      final isHigh = _random.nextBool();
      _state.obstacles.add(Obstacle(
        x: 1.05,
        width: 0.045 + _random.nextDouble() * 0.025,
        height: isHigh ? 0.14 : 0.08,
        isHighObstacle: isHigh,
      ));
    }

    final obstSpeed = _state.speed * 0.006;
    _state.obstacles.removeWhere((o) => o.x < -0.1);
    for (final o in _state.obstacles) {
      o.x -= obstSpeed;
      if (_checkCollision(o)) {
        _die();
        return;
      }
    }

    _spawnRunParticles();
    _updateParticles(dt);

    setState(() {});
  }

  bool _checkCollision(Obstacle o) {
    const charSize = 0.055;
    const charH = 0.10;
    final charTop = kGroundY + _state.characterY - charH;
    final charRight = kCharacterX + charSize * 0.6;
    final charLeft = kCharacterX - charSize * 0.5;
    final obstLeft = o.x;
    final obstRight = o.x + o.width;
    final obstTop = kGroundY - o.height;

    return charRight > obstLeft + 0.005 &&
        charLeft < obstRight - 0.005 &&
        charTop + charH > obstTop + 0.005;
  }

  void _die() {
    _state.isAlive = false;
    _tickController.stop();
    HapticFeedback.heavyImpact();

    for (int i = 0; i < 30; i++) {
      final angle = _random.nextDouble() * pi * 2;
      final speed = 0.02 + _random.nextDouble() * 0.04;
      _state.particles.add(Particle(
        x: kCharacterX,
        y: kGroundY,
        vx: cos(angle) * speed,
        vy: sin(angle) * speed - 0.05,
        life: 1.0,
        maxLife: 1.0,
        size: 4 + _random.nextDouble() * 8,
        color: kThemes[_state.currentTheme]!.characterAccent,
      ));
    }
    setState(() {});
  }

  void _triggerThemeSwitch() {
    _themeIndex = (_themeIndex + 1) % _themeOrder.length;
    _state.currentTheme = _themeOrder[_themeIndex];
    _state.timeToNextTheme = 10.0;
    _showThemeWarning = false;

    final td = kThemes[_state.currentTheme]!;
    _targetSkyTop = td.skyTop;
    _targetSkyBottom = td.skyBottom;
    _targetGround = td.groundColor;
    _themeTransitionProgress = 0.0;

    _state.themeMismatched = _state.playerTheme != _state.currentTheme;

    if (_state.themeMismatched) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_state.isAlive && _state.themeMismatched && mounted) {
          _die();
        }
      });
    }

    HapticFeedback.mediumImpact();
  }

  void _spawnRunParticles() {
    if (_random.nextDouble() > 0.3) return;
    final td = kThemes[_state.currentTheme]!;
    _state.particles.add(Particle(
      x: kCharacterX - 0.03,
      y: kGroundY + 0.01,
      vx: -0.003 - _random.nextDouble() * 0.004,
      vy: -0.005 - _random.nextDouble() * 0.01,
      life: 1.0,
      maxLife: 0.6 + _random.nextDouble() * 0.4,
      size: 2 + _random.nextDouble() * 3,
      color: td.groundAccent,
    ));
  }

  void _updateParticles(double dt) {
    _state.particles.removeWhere((p) => p.life <= 0);
    for (final p in _state.particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.012 * dt;
      p.life -= dt / p.maxLife;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final td = kThemes[_state.currentTheme]!;
    final pd = kThemes[_state.playerTheme]!;

    return Scaffold(
      backgroundColor: CD.bg,
      body: GestureDetector(
        onTap: _jump,
        child: Stack(
          children: [
            // ── Animated sky background ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_skyTop, _skyBottom],
                ),
              ),
            ),

            // ── Background detail ──
            CustomPaint(
              size: size,
              painter: BackgroundDetailPainter(
                theme: _state.currentTheme,
                time: _state.totalTime,
                themeData: td,
              ),
            ),

            // ── Ground ──
            Positioned(
              left: 0,
              right: 0,
              top: size.height * kGroundY,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                height: size.height * (1 - kGroundY),
                decoration: BoxDecoration(
                  color: _groundColor,
                  border: Border(
                    top: BorderSide(color: td.groundAccent, width: 3),
                  ),
                ),
              ),
            ),

            // ── Ground detail lines ──
            CustomPaint(
              size: size,
              painter: GroundDetailPainter(
                theme: _state.currentTheme,
                time: _state.totalTime,
                speed: _state.speed,
                themeData: td,
              ),
            ),

            // ── Particles ──
            CustomPaint(
              size: size,
              painter: ParticlePainter(particles: _state.particles),
            ),

            // ── Obstacles ──
            CustomPaint(
              size: size,
              painter: ObstaclePainter(
                obstacles: _state.obstacles,
                themeData: td,
                groundY: kGroundY,
              ),
            ),

            // ── Character ──
            if (_state.isStarted)
              CustomPaint(
                size: size,
                painter: CharacterPainter(
                  x: kCharacterX,
                  y: kGroundY + _state.characterY,
                  isDucking: _state.isDucking,
                  isJumping: _state.isJumping,
                  time: _state.totalTime,
                  themeData: pd,
                  isAlive: _state.isAlive,
                  isMismatched: _state.themeMismatched,
                ),
              ),

            // ── Theme change warning flash ──
            if (_showThemeWarning && _state.isStarted && _state.isAlive)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: CD.amber.withOpacity(_warningAlpha * 0.18),
                  ),
                ),
              ),

            // ── Mismatch warning flash ──
            if (_state.themeMismatched && _state.isStarted && _state.isAlive)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: CD.red.withOpacity(
                      (sin(_state.totalTime * 6) * 0.5 + 0.5) * 0.2,
                    ),
                  ),
                ),
              ),

            // ── TOP HUD ──
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(td),
                  if (_showThemeWarning && _state.isStarted && _state.isAlive)
                    _buildThemeWarning(),
                  if (_state.themeMismatched && _state.isStarted && _state.isAlive)
                    _buildMismatchWarning(),
                ],
              ),
            ),

            // ── BOTTOM SWAP BUTTON ──
            if (_state.isStarted && _state.isAlive && !_state.isPaused)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(child: _buildThemeToggle(td, pd)),
              ),

            // ── START SCREEN ──
            if (!_state.isStarted) _buildStartScreen(td),

            // ── PAUSE OVERLAY ──
            if (_state.isStarted && _state.isAlive && _state.isPaused)
              _buildPauseOverlay(td),

            // ── GAME OVER OVERLAY ──
            if (_state.isStarted && !_state.isAlive)
              _buildGameOver(td),
          ],
        ),
      ),
    );
  }

  // ── FIXED Top HUD bar ────────────────────────────────────────────────────

  Widget _buildTopBar(WorldThemeData td) {
    final progress = (_state.timeToNextTheme / 10.0).clamp(0.0, 1.0);
    final isWarning = _state.timeToNextTheme <= 3.0;
    final barColor = isWarning ? CD.amber : CD.cyan;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Row(
        children: [
          // ── Score (fixed width) ──
          Container(
            width: 108,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: CD.neonBox(CD.cyan, r: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('SCORE',
                    style: CD.label(8, CD.cyan.withOpacity(0.6), ls: 1.5)),
                Text(
                  _state.score.toString().padLeft(6, '0'),
                  style: CD.glow(18, CD.cyan, ls: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── World theme badge (Expanded = fills remaining space) ──
          Expanded(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration:
              CD.neonBox(Color(td.uiColor.value), r: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(td.icon,
                      color: Color(td.uiColor.value), size: 13),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      td.name.toUpperCase(),
                      style: CD.label(
                          9, Color(td.uiColor.value), ls: 0.8),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ── Timer (fixed width, compact) ──
          Container(
            width: 68,
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: CD.neonBox(barColor, r: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('NEXT',
                    style: CD.label(
                        8, barColor.withOpacity(0.6), ls: 1.5)),
                Text(
                  '${_state.timeToNextTheme.toInt()}s',
                  style: CD.glow(14, barColor, ls: 1),
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation(barColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Pause button ──
          GestureDetector(
            onTap: _togglePause,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: CD.neonBox(CD.violet, r: 12),
              child: const Icon(Icons.pause_rounded,
                  color: CD.violet, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ── Warning banners ──────────────────────────────────────────────────────

  Widget _buildThemeWarning() {
    final nextIdx = (_themeIndex + 1) % _themeOrder.length;
    final nextTd = kThemes[_themeOrder[nextIdx]]!;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: CD.neonBox(CD.amber, r: 12,
          fill: CD.amber.withOpacity(0.18)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: CD.amber, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'THEME → ${nextTd.name.toUpperCase()}',
              style: CD.label(11, CD.amber, ls: 1),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Icon(nextTd.icon, color: CD.amber, size: 16),
        ],
      ),
    );
  }

  Widget _buildMismatchWarning() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration:
      CD.neonBox(CD.red, r: 12, fill: CD.red.withOpacity(0.18)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dangerous_rounded, color: CD.red, size: 16),
          const SizedBox(width: 8),
          Text('MISMATCH! TAP SWAP NOW!',
              style: CD.label(11, CD.red, ls: 1)),
        ],
      ),
    );
  }


  // ── Bottom swap / theme toggle ───────────────────────────────────────────

  Widget _buildThemeToggle(WorldThemeData td, WorldThemeData pd) {
    final isMatched = _state.playerTheme == _state.currentTheme;
    final accent = isMatched ? CD.green : CD.red;

    return GestureDetector(
      onTap: _togglePlayerTheme,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: CD.neonBox(accent, r: 22,
            fill: Colors.black.withOpacity(0.70)),
        child: Row(
          children: [

            // ── Left: MY THEME ──────────────────────────────────────────
            ThemeSlot(
              label: 'MY THEME',
              name: pd.name,
              icon: pd.icon,
              color: Color(pd.characterAccent.value),
              align: CrossAxisAlignment.start,
              iconOnLeft: true,
            ),

            // ── Centre: SYNCED / SWAP badge ─────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: accent, width: 1.6),
                  boxShadow: [
                    BoxShadow(
                        color: accent.withOpacity(0.45),
                        blurRadius: 14,
                        spreadRadius: 1),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isMatched
                          ? Icons.check_circle_rounded
                          : Icons.sync_rounded,
                      color: accent,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isMatched ? 'SYNCED' : 'SWAP!',
                      style: CD.label(12, accent, ls: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            // ── Right: WORLD ─────────────────────────────────────────────
            ThemeSlot(
              label: 'WORLD',
              name: td.name,
              icon: td.icon,
              color: Color(td.uiColor.value),
              align: CrossAxisAlignment.end,
              iconOnLeft: false,
            ),
          ],
        ),
      ),
    );
  }
  // ── Start screen ─────────────────────────────────────────────────────────

  Widget _buildStartScreen(WorldThemeData td) {
    return Positioned.fill(
      child: NeonBg(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      CD.violet.withOpacity(0.6),
                      Colors.black
                    ]),
                    border: Border.all(
                        color: CD.cyan.withOpacity(0.6), width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: CD.cyan.withOpacity(0.3),
                          blurRadius: 30),
                    ],
                  ),
                  child: const Icon(Icons.speed_rounded,
                      color: CD.cyan, size: 44),
                ),

                const SizedBox(height: 16),
                Text('CHROMA', style: CD.glow(30, CD.cyan, ls: 8)),
                Text('DASHER', style: CD.glow(30, CD.magenta, ls: 8)),
                const SizedBox(height: 4),
                Text('ENDLESS THEME RUNNER',
                    style: CD.label(
                        10, Colors.white.withOpacity(0.4), ls: 3)),

                const SizedBox(height: 32),
                NeonDivider(color: CD.violet),
                const SizedBox(height: 24),

                _startInfoRow(Icons.swap_horiz_rounded, CD.cyan,
                    'Match your theme to the world!'),
                const SizedBox(height: 12),
                _startInfoRow(Icons.touch_app_rounded, CD.magenta,
                    'Tap screen to jump'),
                const SizedBox(height: 12),
                _startInfoRow(Icons.sync_rounded, CD.violet,
                    'Tap SWAP to change your theme'),
                const SizedBox(height: 12),
                _startInfoRow(Icons.timer_outlined, CD.amber,
                    'Stay mismatched 3s = Game Over'),

                const SizedBox(height: 36),

                NeonButton(
                  label: 'TAP TO START',
                  icon: Icons.play_arrow_rounded,
                  color: CD.cyan,
                  fontSize: 16,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 48, vertical: 18),
                  onTap: _startGame,
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, '/menu'),
                  child: Text('MAIN MENU',
                      style: CD.label(
                          12,
                          Colors.white.withOpacity(0.4),
                          ls: 2)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _startInfoRow(IconData icon, Color color, String text) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration:
      CD.neonBox(color, r: 14, fill: color.withOpacity(0.06)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text,
                style: CD.body(
                    13, Colors.white.withOpacity(0.75))),
          ),
        ],
      ),
    );
  }

  // ── Pause overlay ────────────────────────────────────────────────────────

  Widget _buildPauseOverlay(WorldThemeData td) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.78),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.symmetric(
                horizontal: 32, vertical: 36),
            decoration: CD.neonBox(CD.cyan, r: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pause_circle_outline_rounded,
                    color: CD.cyan, size: 52),
                const SizedBox(height: 12),
                Text('PAUSED', style: CD.glow(30, CD.cyan, ls: 8)),
                const SizedBox(height: 4),
                Text('Game is on hold',
                    style: CD.body(
                        13, Colors.white.withOpacity(0.4))),
                const SizedBox(height: 24),
                NeonDivider(color: CD.cyan),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: CD.neonBox(CD.violet, r: 14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('SCORE  ',
                          style: CD.label(11,
                              CD.violet.withOpacity(0.7), ls: 2)),
                      Text(
                        _state.score.toString().padLeft(6, '0'),
                        style: CD.glow(18, CD.violet, ls: 2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                NeonButton(
                  label: 'RESUME',
                  icon: Icons.play_arrow_rounded,
                  color: CD.cyan,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 48, vertical: 16),
                  onTap: _togglePause,
                ),
                const SizedBox(height: 14),
                NeonButton(
                  label: 'RESTART',
                  icon: Icons.replay_rounded,
                  color: CD.amber,
                  onTap: _startGame,
                ),
                const SizedBox(height: 14),
                NeonButton(
                  label: 'MAIN MENU',
                  icon: Icons.home_rounded,
                  color: CD.red,
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/menu', (_) => false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Game over overlay ────────────────────────────────────────────────────

  Widget _buildGameOver(WorldThemeData td) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.80),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('GAME OVER',
                    style: CD.glow(36, CD.red, ls: 6)),
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 28),
                  decoration: CD.neonBox(CD.cyan, r: 20),
                  child: Column(
                    children: [
                      Text('SCORE',
                          style: CD.label(11,
                              CD.cyan.withOpacity(0.6), ls: 4)),
                      const SizedBox(height: 6),
                      Text(
                        _state.score.toString().padLeft(6, '0'),
                        style: CD.glow(52, CD.cyan, ls: 4),
                      ),
                      const SizedBox(height: 18),
                      NeonDivider(color: CD.cyan),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        children: [
                          _statChip(
                              'TIME',
                              '${_state.totalTime.toStringAsFixed(1)}s',
                              CD.violet),
                          _statChip(
                              'THEME',
                              kThemes[_state.currentTheme]!
                                  .name
                                  .split(' ')
                                  .first
                                  .toUpperCase(),
                              CD.amber),
                          _statChip(
                              'SPEED',
                              '${_state.speed.toStringAsFixed(1)}x',
                              CD.green),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                NeonButton(
                  label: 'PLAY AGAIN',
                  icon: Icons.replay_rounded,
                  color: CD.cyan,
                  fontSize: 16,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 48, vertical: 18),
                  onTap: _startGame,
                ),
                const SizedBox(height: 14),
                NeonButton(
                  label: 'LEADERBOARD',
                  icon: Icons.leaderboard_rounded,
                  color: CD.violet,
                  onTap: () =>
                      Navigator.pushNamed(context, '/highscore'),
                ),
                const SizedBox(height: 14),
                NeonButton(
                  label: 'MAIN MENU',
                  icon: Icons.home_rounded,
                  color: Colors.white38,
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/menu', (_) => false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: CD.label(9, color.withOpacity(0.6), ls: 2)),
        const SizedBox(height: 4),
        Text(value, style: CD.label(13, color, ls: 1)),
      ],
    );
  }
}

// ─── Custom Painters ──────────────────────────────────────────────────────────

class BackgroundDetailPainter extends CustomPainter {
  final WorldTheme theme;
  final double time;
  final WorldThemeData themeData;

  BackgroundDetailPainter(
      {required this.theme,
        required this.time,
        required this.themeData});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    switch (theme) {
      case WorldTheme.darkForest:
        final r = Random(42);
        for (int i = 0; i < 60; i++) {
          final x = r.nextDouble() * size.width;
          final y = r.nextDouble() * size.height * 0.6;
          final s = r.nextDouble() * 2 + 0.5;
          final twinkle = (sin(time * 2 + i) * 0.3 + 0.7);
          paint.color = Colors.white.withOpacity(0.5 * twinkle);
          canvas.drawCircle(Offset(x, y), s, paint);
        }
        paint.color = Colors.white.withOpacity(0.9);
        canvas.drawCircle(
            Offset(size.width * 0.85, size.height * 0.12), 24, paint);
        paint.color = themeData.skyTop;
        canvas.drawCircle(
            Offset(size.width * 0.87, size.height * 0.10), 20, paint);
        paint.color = themeData.groundColor.withOpacity(0.4);
        final treeR = Random(77);
        for (int i = 0; i < 12; i++) {
          final tx = treeR.nextDouble() * size.width;
          final th = size.height * (0.08 + treeR.nextDouble() * 0.1);
          final ty = size.height * 0.72 - th;
          final path = Path()
            ..moveTo(tx, ty)
            ..lineTo(tx - th * 0.35, ty + th)
            ..lineTo(tx + th * 0.35, ty + th)
            ..close();
          canvas.drawPath(path, paint);
        }
        break;

      case WorldTheme.lightDesert:
        final sunX = size.width * 0.82;
        final sunY = size.height * 0.15;
        paint.color = Colors.yellow.withOpacity(0.3);
        canvas.drawCircle(Offset(sunX, sunY), 55, paint);
        paint.color = Colors.yellow.withOpacity(0.6);
        canvas.drawCircle(Offset(sunX, sunY), 38, paint);
        paint.color = const Color(0xFFFFE55C);
        canvas.drawCircle(Offset(sunX, sunY), 26, paint);
        paint.color = const Color(0xFF8B6914).withOpacity(0.3);
        for (int i = 0; i < 5; i++) {
          final cx = size.width * (0.1 + i * 0.2);
          final ch = size.height * 0.08;
          final cy = size.height * 0.72 - ch;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(cx - 4, cy, 8, ch),
                const Radius.circular(4)),
            paint,
          );
        }
        break;

      case WorldTheme.neonCity:
        final r2 = Random(33);
        for (int i = 0; i < 80; i++) {
          final x = r2.nextDouble() * size.width;
          final y = r2.nextDouble() * size.height * 0.65;
          final s = r2.nextDouble() * 1.5 + 0.5;
          paint.color =
              (i % 2 == 0 ? themeData.uiColor : themeData.uiAccent)
                  .withOpacity(
                  (sin(time * 3 + i) * 0.4 + 0.6) * 0.8);
          canvas.drawCircle(Offset(x, y), s, paint);
        }
        paint.color = Colors.black.withOpacity(0.6);
        final bR = Random(55);
        for (int i = 0; i < 10; i++) {
          final bx = bR.nextDouble() * size.width;
          final bw = 20 + bR.nextDouble() * 40;
          final bh = size.height * (0.1 + bR.nextDouble() * 0.2);
          canvas.drawRect(
              Rect.fromLTWH(
                  bx, size.height * 0.72 - bh, bw, bh),
              paint);
        }
        paint.color = themeData.uiColor.withOpacity(0.15);
        paint.strokeWidth = 1;
        paint.style = PaintingStyle.stroke;
        for (int i = 0; i < 5; i++) {
          final lx =
              (time * 80 * (i + 1) * 0.5) % (size.width + 60) - 60;
          canvas.drawLine(Offset(lx, size.height * 0.72),
              Offset(lx - 30, size.height), paint);
        }
        paint.style = PaintingStyle.fill;
        break;

      case WorldTheme.snowTundra:
        final sr = Random(11);
        for (int i = 0; i < 40; i++) {
          final sx =
              (sr.nextDouble() * size.width +
                  time * 20 * (i % 3 + 1)) %
                  size.width;
          final sy = (sr.nextDouble() * size.height * 0.7 +
              time * 15 * (i % 2 + 1)) %
              (size.height * 0.7);
          paint.color = Colors.white.withOpacity(0.6);
          canvas.drawCircle(
              Offset(sx, sy), sr.nextDouble() * 2 + 1, paint);
        }
        paint.color = const Color(0xFF90AFC5).withOpacity(0.4);
        final mPath = Path();
        mPath.moveTo(0, size.height * 0.72);
        mPath.lineTo(size.width * 0.1, size.height * 0.45);
        mPath.lineTo(size.width * 0.2, size.height * 0.6);
        mPath.lineTo(size.width * 0.35, size.height * 0.38);
        mPath.lineTo(size.width * 0.5, size.height * 0.55);
        mPath.lineTo(size.width * 0.65, size.height * 0.42);
        mPath.lineTo(size.width * 0.8, size.height * 0.58);
        mPath.lineTo(size.width, size.height * 0.48);
        mPath.lineTo(size.width, size.height * 0.72);
        mPath.close();
        canvas.drawPath(mPath, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundDetailPainter old) =>
      old.time != time || old.theme != theme;
}

class GroundDetailPainter extends CustomPainter {
  final WorldTheme theme;
  final double time;
  final double speed;
  final WorldThemeData themeData;

  GroundDetailPainter({
    required this.theme,
    required this.time,
    required this.speed,
    required this.themeData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = themeData.groundAccent.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final groundTop = size.height * 0.72;
    final offset = (time * speed * 36) % 80;
    for (double x = -offset; x < size.width + 80; x += 80) {
      canvas.drawLine(
        Offset(x, groundTop + 12),
        Offset(x + 40, groundTop + 12),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GroundDetailPainter old) =>
      old.time != time;
}

class ObstaclePainter extends CustomPainter {
  final List<Obstacle> obstacles;
  final WorldThemeData themeData;
  final double groundY;

  ObstaclePainter(
      {required this.obstacles,
        required this.themeData,
        required this.groundY});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = themeData.obstacleColor;
    final glowPaint = Paint()
      ..color = themeData.obstacleColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (final o in obstacles) {
      final left = o.x * size.width;
      final top = groundY * size.height - o.height * size.height;
      final right = left + o.width * size.width;
      final bottom = groundY * size.height;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(left, top, right, bottom),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, glowPaint);
      canvas.drawRRect(rect, paint);

      paint.color = themeData.obstacleColor.withOpacity(0.7);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(left - 4, top - 6, right + 4, top + 4),
          const Radius.circular(3),
        ),
        paint,
      );
      paint.color = themeData.obstacleColor;
    }
  }

  @override
  bool shouldRepaint(covariant ObstaclePainter old) => true;
}

class CharacterPainter extends CustomPainter {
  final double x, y;
  final bool isDucking, isJumping, isAlive, isMismatched;
  final double time;
  final WorldThemeData themeData;

  CharacterPainter({
    required this.x,
    required this.y,
    required this.isDucking,
    required this.isJumping,
    required this.time,
    required this.themeData,
    required this.isAlive,
    required this.isMismatched,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isAlive) return;

    final cx = x * size.width;
    final cy = y * size.height;
    final bodyH = isDucking ? 0.05 : 0.10;
    const bodyW = 0.045;

    final paint = Paint();

    // Glow
    paint
      ..color = themeData.characterAccent
          .withOpacity(isMismatched ? 0.8 : 0.35)
      ..maskFilter =
      MaskFilter.blur(BlurStyle.normal, isMismatched ? 16 : 10);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - bodyH * size.height * 0.5),
        width: bodyW * size.width * 2.5,
        height: bodyH * size.height * 1.8,
      ),
      paint,
    );
    paint.maskFilter = null;

    // Body
    paint.color = themeData.characterColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy - bodyH * size.height * 0.5),
          width: bodyW * size.width,
          height: bodyH * size.height,
        ),
        const Radius.circular(8),
      ),
      paint,
    );

    // Stripe
    paint.color = themeData.characterAccent;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy - bodyH * size.height * 0.5),
          width: bodyW * size.width * 0.35,
          height: bodyH * size.height * 0.6,
        ),
        const Radius.circular(4),
      ),
      paint,
    );

    // Eyes
    paint.color = Colors.white;
    canvas.drawCircle(
        Offset(cx + 6, cy - bodyH * size.height * 0.75), 4, paint);
    paint.color = themeData.characterColor;
    canvas.drawCircle(
        Offset(cx + 7, cy - bodyH * size.height * 0.75), 2, paint);

    // Legs
    if (!isJumping) {
      final legAnim = sin(time * 12) * 6;
      paint
        ..color = themeData.characterColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - 4, cy),
          Offset(cx - 8, cy + legAnim.abs() + 4), paint);
      canvas.drawLine(Offset(cx + 4, cy),
          Offset(cx + 8, cy - legAnim.abs() + 8), paint);
      paint.style = PaintingStyle.fill;
    }

    // Mismatch X
    if (isMismatched) {
      paint
        ..color = CD.red.withOpacity(0.9)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      final mx = cx + 16;
      final my = cy - bodyH * size.height * 1.3;
      canvas.drawLine(
          Offset(mx - 6, my - 6), Offset(mx + 6, my + 6), paint);
      canvas.drawLine(
          Offset(mx + 6, my - 6), Offset(mx - 6, my + 6), paint);
      paint.style = PaintingStyle.fill;
    }
  }

  @override
  bool shouldRepaint(covariant CharacterPainter old) =>
      old.time != time || old.isMismatched != isMismatched;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      paint.color = p.color.withOpacity(p.life.clamp(0.0, 1.0));
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size * p.life,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter old) => true;
}