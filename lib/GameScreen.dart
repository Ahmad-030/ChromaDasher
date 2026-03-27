import 'dart:async';
import 'dart:math';
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

  int score = 0;
  double speed = 5.0;
  double timeToNextTheme = 10.0;
  double totalTime = 0.0;

  WorldTheme currentTheme = WorldTheme.darkForest;
  WorldTheme? pendingTheme;
  bool themeMismatched = false;

  List<Obstacle> obstacles = [];
  List<Particle> particles = [];
  List<double> groundSegments = [];

  double obstacleTimer = 0;
  double obstacleInterval = 2.5;

  // Track which theme the player has matched
  WorldTheme playerTheme = WorldTheme.darkForest;

  void reset() {
    characterY = 0;
    characterVY = 0;
    isJumping = false;
    isDucking = false;
    isAlive = true;
    isStarted = false;
    score = 0;
    speed = 5.0;
    timeToNextTheme = 10.0;
    totalTime = 0.0;
    currentTheme = WorldTheme.darkForest;
    playerTheme = WorldTheme.darkForest;
    pendingTheme = null;
    themeMismatched = false;
    obstacles.clear();
    particles.clear();
    groundSegments.clear();
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

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  final GameState _state = GameState();
  final Random _random = Random();

  late AnimationController _themeController;
  late AnimationController _tickController;

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
  static const double kGravity = 0.018;
  static const double kJumpForce = -0.45;

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

    _themeController = AnimationController(
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
    _themeController.dispose();
    _tickController.dispose();
    super.dispose();
  }

  void _startGame() {
    _state.reset();
    _themeIndex = 0;
    _skyTop = kThemes[WorldTheme.darkForest]!.skyTop;
    _skyBottom = kThemes[WorldTheme.darkForest]!.skyBottom;
    _groundColor = kThemes[WorldTheme.darkForest]!.groundColor;
    _themeTransitionProgress = 1.0;
    _state.isStarted = true;
    _tickController.repeat();
  }

  void _jump() {
    if (!_state.isStarted) {
      _startGame();
      return;
    }
    if (!_state.isAlive) {
      _startGame();
      return;
    }
    if (!_state.isJumping) {
      _state.characterVY = kJumpForce;
      _state.isJumping = true;
      HapticFeedback.lightImpact();
    }
  }

  void _togglePlayerTheme() {
    if (!_state.isStarted || !_state.isAlive) return;

    final themes = WorldTheme.values;
    final currentIdx = themes.indexOf(_state.playerTheme);
    _state.playerTheme = themes[(currentIdx + 1) % themes.length];

    // Check if now matched
    _state.themeMismatched = _state.playerTheme != _state.currentTheme;
    HapticFeedback.selectionClick();
    setState(() {});
  }

  void _tick() {
    if (!_state.isStarted || !_state.isAlive) return;

    const double dt = 0.016;
    _state.totalTime += dt;
    _state.timeToNextTheme -= dt;
    _state.score = (_state.totalTime * 10).toInt();

    // Speed ramp
    _state.speed = 5.0 + _state.totalTime * 0.08;

    // Theme switch
    if (_state.timeToNextTheme <= 3.0 && !_showThemeWarning) {
      _showThemeWarning = true;
    }

    if (_state.timeToNextTheme <= 0) {
      _triggerThemeSwitch();
    }

    // Warning pulse
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

    // Move obstacles & check collision
    final obstSpeed = _state.speed * 0.006;
    _state.obstacles.removeWhere((o) => o.x < -0.1);
    for (final o in _state.obstacles) {
      o.x -= obstSpeed;
      if (_checkCollision(o)) {
        _die();
        return;
      }
    }

    // Mismatch damage: slow health drain
    if (_state.themeMismatched) {
      // Flash effect only; actual death on next theme switch if still mismatched
    }

    // Particles
    _spawnRunParticles();
    _updateParticles(dt);

    setState(() {});
  }

  bool _checkCollision(Obstacle o) {
    const charSize = 0.055;
    const charH = 0.10;
    final charX = kCharacterX;
    final charTop = kGroundY + _state.characterY - charH;
    final charRight = charX + charSize * 0.6;
    final charLeft = charX - charSize * 0.5;

    final obstLeft = o.x;
    final obstRight = o.x + o.width;
    final obstTop = kGroundY - o.height;

    if (charRight > obstLeft + 0.005 &&
        charLeft < obstRight - 0.005 &&
        charTop + charH > obstTop + 0.005) {
      return true;
    }
    return false;
  }

  void _die() {
    _state.isAlive = false;
    _tickController.stop();
    HapticFeedback.heavyImpact();

    // Burst particles
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

    // Check mismatch
    _state.themeMismatched = _state.playerTheme != _state.currentTheme;

    if (_state.themeMismatched) {
      // Penalty: instantly die after 3s (handled via a timer)
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
    const gravity = 0.012;
    _state.particles.removeWhere((p) => p.life <= 0);
    for (final p in _state.particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += gravity * dt;
      p.life -= dt / p.maxLife;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final td = kThemes[_state.currentTheme]!;
    final pd = kThemes[_state.playerTheme]!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _jump,
        child: Stack(
          children: [
            // Background gradient (animated)
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

            // Background details (stars/sun/snowflakes)
            CustomPaint(
              size: size,
              painter: BackgroundDetailPainter(
                theme: _state.currentTheme,
                time: _state.totalTime,
                themeData: td,
              ),
            ),

            // Ground
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

            // Ground detail lines
            CustomPaint(
              size: size,
              painter: GroundDetailPainter(
                theme: _state.currentTheme,
                time: _state.totalTime,
                speed: _state.speed,
                themeData: td,
              ),
            ),

            // Particles
            CustomPaint(
              size: size,
              painter: ParticlePainter(particles: _state.particles),
            ),

            // Obstacles
            CustomPaint(
              size: size,
              painter: ObstaclePainter(
                obstacles: _state.obstacles,
                themeData: td,
                groundY: kGroundY,
              ),
            ),

            // Character
            if (_state.isStarted)
              CustomPaint(
                size: size,
                painter: CharacterPainter(
                  x: kCharacterX,
                  y: kGroundY + _state.characterY,
                  isDucking: _state.isDucking,
                  isJumping: _state.isJumping,
                  time: _state.totalTime,
                  themeData: pd, // Use PLAYER theme for character
                  isAlive: _state.isAlive,
                  isMismatched: _state.themeMismatched,
                ),
              ),

            // Theme warning flash
            if (_showThemeWarning && _state.isStarted && _state.isAlive)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.orange.withOpacity(_warningAlpha * 0.3),
                  ),
                ),
              ),

            // Mismatch warning flash
            if (_state.themeMismatched && _state.isStarted && _state.isAlive)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.red.withOpacity(
                        (sin(_state.totalTime * 6) * 0.5 + 0.5) * 0.25),
                  ),
                ),
              ),

            // ── TOP UI ─────────────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(td, size),
                  if (_showThemeWarning && _state.isStarted && _state.isAlive)
                    _buildThemeWarning(td),
                  if (_state.themeMismatched && _state.isStarted && _state.isAlive)
                    _buildMismatchWarning(td),
                ],
              ),
            ),

            // ── BOTTOM THEME TOGGLE ────────────────────────────────────────
            if (_state.isStarted && _state.isAlive)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: _buildThemeToggle(td, pd, size),
                ),
              ),

            // ── START SCREEN ──────────────────────────────────────────────
            if (!_state.isStarted)
              _buildStartScreen(td, size),

            // ── GAME OVER ────────────────────────────────────────────────
            if (_state.isStarted && !_state.isAlive)
              _buildGameOver(td, size),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(WorldThemeData td, Size size) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: td.uiColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: td.uiColor.withOpacity(0.2), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SCORE',
                  style: TextStyle(
                    color: td.uiColor.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  )),
              Text(
                _state.score.toString().padLeft(6, '0'),
                style: TextStyle(
                  color: td.uiColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  shadows: [Shadow(color: td.uiColor.withOpacity(0.5), blurRadius: 8)],
                ),
              ),
            ],
          ),

          const Spacer(),

          // World theme indicator
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('WORLD',
                  style: TextStyle(
                    color: td.uiColor.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  )),
              Row(
                children: [
                  Icon(td.icon, color: td.uiColor, size: 16),
                  const SizedBox(width: 4),
                  Text(td.name,
                      style: TextStyle(
                        color: td.uiColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Timer
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('NEXT',
                  style: TextStyle(
                    color: td.uiColor.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  )),
              _buildTimerBar(td),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar(WorldThemeData td) {
    final progress = (_state.timeToNextTheme / 10.0).clamp(0.0, 1.0);
    final isWarning = _state.timeToNextTheme <= 3.0;

    return SizedBox(
      width: 70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_state.timeToNextTheme.toInt()}s',
            style: TextStyle(
              color: isWarning ? Colors.orange : td.uiColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(
                isWarning ? Colors.orange : td.uiColor,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeWarning(WorldThemeData td) {
    final nextIdx = (_themeIndex + 1) % _themeOrder.length;
    final nextTheme = _themeOrder[nextIdx];
    final nextTd = kThemes[nextTheme]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            'THEME CHANGING → ${nextTd.name.toUpperCase()}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 8),
          Icon(nextTd.icon, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  Widget _buildMismatchWarning(WorldThemeData td) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dangerous, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text(
            'MISMATCH! TAP SWITCH NOW!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(WorldThemeData td, WorldThemeData pd, Size size) {
    final isMatched = _state.playerTheme == _state.currentTheme;

    return GestureDetector(
      onTap: _togglePlayerTheme,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isMatched
                ? [pd.characterColor.withOpacity(0.9), pd.characterAccent.withOpacity(0.9)]
                : [Colors.red.withOpacity(0.85), Colors.redAccent.withOpacity(0.85)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isMatched ? pd.uiColor : Colors.red,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isMatched ? pd.uiColor : Colors.red).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Player theme
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: pd.characterAccent,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: pd.characterAccent.withOpacity(0.5), blurRadius: 8)],
                  ),
                  child: Icon(pd.icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('MY THEME',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        )),
                    Text(pd.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        )),
                  ],
                ),
              ],
            ),

            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMatched ? Icons.check_circle : Icons.sync,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isMatched ? 'SYNCED' : 'SWAP!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            // World theme
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('WORLD',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        )),
                    Text(td.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        )),
                  ],
                ),
                const SizedBox(width: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: td.uiColor,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: td.uiColor.withOpacity(0.5), blurRadius: 8)],
                  ),
                  child: Icon(td.icon, color: Colors.white, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartScreen(WorldThemeData td, Size size) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.65),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: td.uiColor, width: 2),
                    top: BorderSide(color: td.uiColor, width: 2),
                  ),
                ),
                child: Text(
                  'THEME SWAP\nRUNNER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: td.uiColor,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    height: 1.1,
                    shadows: [Shadow(color: td.uiColor.withOpacity(0.6), blurRadius: 20)],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Instructions
              _infoCard(td, Icons.swap_horiz, 'Match your theme to the world!'),
              const SizedBox(height: 12),
              _infoCard(td, Icons.touch_app, 'Tap screen to jump'),
              const SizedBox(height: 12),
              _infoCard(td, Icons.sync, 'Tap SWAP to change your theme'),
              const SizedBox(height: 48),
              // Start button
              GestureDetector(
                onTap: _startGame,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                  decoration: BoxDecoration(
                    color: td.uiColor,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(color: td.uiColor.withOpacity(0.5), blurRadius: 24, spreadRadius: 4),
                    ],
                  ),
                  child: const Text(
                    'TAP TO START',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(WorldThemeData td, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: td.uiColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: td.uiColor, size: 20),
          const SizedBox(width: 12),
          Text(text,
              style: TextStyle(
                color: td.uiColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  Widget _buildGameOver(WorldThemeData td, Size size) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.75),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.dangerous, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text('GAME OVER',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  )),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: td.uiColor.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Text('SCORE', style: TextStyle(color: td.uiColor.withOpacity(0.7), fontSize: 12, letterSpacing: 2)),
                    Text(
                      _state.score.toString().padLeft(6, '0'),
                      style: TextStyle(
                        color: td.uiColor,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(color: td.uiColor, blurRadius: 20)],
                      ),
                    ),
                    Text('TIME: ${_state.totalTime.toStringAsFixed(1)}s',
                        style: TextStyle(color: td.uiColor.withOpacity(0.7), fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _startGame,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                  decoration: BoxDecoration(
                    color: td.uiColor,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(color: td.uiColor.withOpacity(0.5), blurRadius: 20, spreadRadius: 2),
                    ],
                  ),
                  child: const Text('PLAY AGAIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Custom Painters ──────────────────────────────────────────────────────────

class BackgroundDetailPainter extends CustomPainter {
  final WorldTheme theme;
  final double time;
  final WorldThemeData themeData;

  BackgroundDetailPainter({required this.theme, required this.time, required this.themeData});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    switch (theme) {
      case WorldTheme.darkForest:
      // Stars
        final r = Random(42);
        paint.color = Colors.white.withOpacity(0.6);
        for (int i = 0; i < 60; i++) {
          final x = r.nextDouble() * size.width;
          final y = r.nextDouble() * size.height * 0.6;
          final s = r.nextDouble() * 2 + 0.5;
          final twinkle = (sin(time * 2 + i) * 0.3 + 0.7);
          paint.color = Colors.white.withOpacity(0.5 * twinkle);
          canvas.drawCircle(Offset(x, y), s, paint);
        }
        // Moon
        paint.color = Colors.white.withOpacity(0.9);
        canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.12), 24, paint);
        paint.color = themeData.skyTop;
        canvas.drawCircle(Offset(size.width * 0.87, size.height * 0.10), 20, paint);
        // Trees in bg
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
      // Sun
        final sunX = size.width * 0.82;
        final sunY = size.height * 0.15;
        paint.color = Colors.yellow.withOpacity(0.3);
        canvas.drawCircle(Offset(sunX, sunY), 55, paint);
        paint.color = Colors.yellow.withOpacity(0.6);
        canvas.drawCircle(Offset(sunX, sunY), 38, paint);
        paint.color = const Color(0xFFFFE55C);
        canvas.drawCircle(Offset(sunX, sunY), 26, paint);
        // Cacti silhouettes
        paint.color = const Color(0xFF8B6914).withOpacity(0.3);
        for (int i = 0; i < 5; i++) {
          final cx = size.width * (0.1 + i * 0.2);
          final ch = size.height * 0.08;
          final cy = size.height * 0.72 - ch;
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(cx - 4, cy, 8, ch), const Radius.circular(4)),
            paint,
          );
        }
        break;

      case WorldTheme.neonCity:
      // Stars/bokeh
        final r2 = Random(33);
        for (int i = 0; i < 80; i++) {
          final x = r2.nextDouble() * size.width;
          final y = r2.nextDouble() * size.height * 0.65;
          final s = r2.nextDouble() * 1.5 + 0.5;
          paint.color = (i % 2 == 0 ? themeData.uiColor : themeData.uiAccent)
              .withOpacity((sin(time * 3 + i) * 0.4 + 0.6) * 0.8);
          canvas.drawCircle(Offset(x, y), s, paint);
        }
        // Building silhouettes
        paint.color = Colors.black.withOpacity(0.6);
        final bR = Random(55);
        for (int i = 0; i < 10; i++) {
          final bx = bR.nextDouble() * size.width;
          final bw = 20 + bR.nextDouble() * 40;
          final bh = size.height * (0.1 + bR.nextDouble() * 0.2);
          canvas.drawRect(
            Rect.fromLTWH(bx, size.height * 0.72 - bh, bw, bh),
            paint,
          );
        }
        // Neon glow lines on ground
        paint.color = themeData.uiColor.withOpacity(0.15);
        paint.strokeWidth = 1;
        paint.style = PaintingStyle.stroke;
        for (int i = 0; i < 5; i++) {
          final lx = (time * 80 * (i + 1) * 0.5) % (size.width + 60) - 60;
          canvas.drawLine(
            Offset(lx, size.height * 0.72),
            Offset(lx - 30, size.height),
            paint,
          );
        }
        paint.style = PaintingStyle.fill;
        break;

      case WorldTheme.snowTundra:
      // Snowflakes
        final sr = Random(11);
        for (int i = 0; i < 40; i++) {
          final sx = (sr.nextDouble() * size.width + time * 20 * (i % 3 + 1)) % size.width;
          final sy = (sr.nextDouble() * size.height * 0.7 + time * 15 * (i % 2 + 1)) %
              (size.height * 0.7);
          paint.color = Colors.white.withOpacity(0.6);
          canvas.drawCircle(Offset(sx, sy), sr.nextDouble() * 2 + 1, paint);
        }
        // Mountain silhouettes
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

    // Dashes/lines on ground
    for (double x = -offset; x < size.width + 80; x += 80) {
      canvas.drawLine(
        Offset(x, groundTop + 12),
        Offset(x + 40, groundTop + 12),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GroundDetailPainter old) => old.time != old.time;
}

class ObstaclePainter extends CustomPainter {
  final List<Obstacle> obstacles;
  final WorldThemeData themeData;
  final double groundY;

  ObstaclePainter({
    required this.obstacles,
    required this.themeData,
    required this.groundY,
  });

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

      // Decorative top
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
    final bodyW = 0.045;

    final paint = Paint();

    // Glow
    paint
      ..color = themeData.characterAccent.withOpacity(isMismatched ? 0.8 : 0.35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isMismatched ? 16 : 10);
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
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy - bodyH * size.height * 0.5),
        width: bodyW * size.width,
        height: bodyH * size.height,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, paint);

    // Accent stripe
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
      Offset(cx + 6, cy - bodyH * size.height * 0.75),
      4,
      paint,
    );
    paint.color = themeData.characterColor;
    canvas.drawCircle(
      Offset(cx + 7, cy - bodyH * size.height * 0.75),
      2,
      paint,
    );

    // Running legs (animated)
    if (!isJumping) {
      final legAnim = sin(time * 12) * 6;
      paint.color = themeData.characterColor;
      paint.strokeWidth = 4;
      paint.strokeCap = StrokeCap.round;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(cx - 4, cy),
        Offset(cx - 8, cy + legAnim.abs() + 4),
        paint,
      );
      canvas.drawLine(
        Offset(cx + 4, cy),
        Offset(cx + 8, cy - legAnim.abs() + 8),
        paint,
      );
      paint.style = PaintingStyle.fill;
    }

    // Mismatch X indicator
    if (isMismatched) {
      paint.color = Colors.red.withOpacity(0.9);
      paint.strokeWidth = 3;
      paint.style = PaintingStyle.stroke;
      final mx = cx + 16;
      final my = cy - bodyH * size.height * 1.3;
      canvas.drawLine(Offset(mx - 6, my - 6), Offset(mx + 6, my + 6), paint);
      canvas.drawLine(Offset(mx + 6, my - 6), Offset(mx - 6, my + 6), paint);
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