import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CharToonApp());
}

// ===================================================================
// THEME
// ===================================================================
class AppTheme {
  static const bg = Color(0xFF0A0A0F);
  static const surface = Color(0xFF15151E);
  static const surfaceAlt = Color(0xFF1E1E2A);
  static const border = Color(0xFF2A2A38);
  static const primary = Color(0xFF7C4DFF);
  static const primaryLight = Color(0xFFB388FF);
  static const accent = Color(0xFFFF4081);
  static const success = Color(0xFF00E676);
  static const warning = Color(0xFFFFAB40);
  static const danger = Color(0xFFFF5252);
  static const textPrimary = Color(0xFFE6EDF3);
  static const textMuted = Color(0xFF8B95A5);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: accent,
          surface: surface,
          error: danger,
          onPrimary: Colors.white,
          onSurface: textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: surface),
      );
}

// ===================================================================
// CHARACTER MODEL
// ===================================================================
enum Series {
  naruto, onePiece, dragonBall, demonSlayer, mha, jjk,
  bleach, aot, fairyTail, blackClover, hxh, other,
}

enum Hair { spiky, long, ponytail, bob, bald, helmet, twinTail, bangs }

enum Eyes { normal, sharingan, rinnegan, byakugan, mangekyou, closed, wink, spiral }

enum Outfit { ninja, kimono, school, cape, tank, jacket, armor, robe, hoodie }

class Character {
  final String id;
  final String name;
  final Series series;
  final Color skin;
  final Color hair;
  final Color outfit;
  final Color accent;
  final Hair hairStyle;
  final Eyes eyeStyle;
  final Outfit outfitStyle;

  const Character({
    required this.id,
    required this.name,
    required this.series,
    required this.skin,
    required this.hair,
    required this.outfit,
    required this.accent,
    required this.hairStyle,
    required this.eyeStyle,
    required this.outfitStyle,
  });
}

String seriesLabel(Series s) => switch (s) {
      Series.naruto => 'ناروتو',
      Series.onePiece => 'ون بيس',
      Series.dragonBall => 'دراغون بول',
      Series.demonSlayer => 'قاتل الشياطين',
      Series.mha => 'أكاديمية الأبطال',
      Series.jjk => 'جوجوتسو',
      Series.bleach => 'بليتش',
      Series.aot => 'هجوم العمالقة',
      Series.fairyTail => 'فيري تيل',
      Series.blackClover => 'بلاك كلوفر',
      Series.hxh => 'هنتر',
      Series.other => 'أخرى',
    };

// ===================================================================
// CATALOG (220 karakter)
// ===================================================================
const Map<Series, List<String>> _names = {
  Series.naruto: [
    'Naruto','Sasuke','Sakura','Kakashi','Itachi','Madara','Obito','Pain','Konan',
    'Jiraiya','Tsunade','Orochimaru','Hinata','Neji','Rock Lee','Tenten','Might Guy',
    'Kiba','Shino','Shikamaru','Ino','Choji','Kurenai','Asuma','Gaara','Temari',
    'Kankuro','Deidara','Sasori','Hidan','Kakuzu','Kisame','Zetsu','Tobi','Minato',
    'Kushina','Hashirama','Tobirama','Sarada','Boruto',
  ],
  Series.onePiece: [
    'Luffy','Zoro','Nami','Usopp','Sanji','Chopper','Robin','Franky','Brook','Jinbe',
    'Shanks','Mihawk','Ace','Sabo','Law','Kid','Kaido','Big Mom','Whitebeard',
    'Blackbeard','Doflamingo','Crocodile','Hancock','Rayleigh','Marco','Katakuri',
    'Yamato','Vivi','Smoker','Tashigi',
  ],
  Series.dragonBall: [
    'Goku','Vegeta','Gohan','Piccolo','Bulma','Krillin','Trunks','Goten','Frieza',
    'Cell','Buu','Beerus','Whis','Broly','Raditz','Nappa','Android 18','Android 17',
    'Roshi','Chichi',
  ],
  Series.demonSlayer: [
    'Tanjiro','Nezuko','Zenitsu','Inosuke','Giyu','Shinobu','Rengoku','Mitsuri',
    'Obanai','Sanemi','Muichiro','Gyomei','Tengen','Akaza','Doma','Kokushibo',
    'Muzan','Genya','Kanao','Aoi',
  ],
  Series.mha: [
    'Deku','Bakugo','Todoroki','Uraraka','Iida','Asui','Kirishima','Kaminari',
    'Jiro','Momo','Tokoyami','All Might','Aizawa','Endeavor','Shigaraki','Dabi',
    'Toga','Twice','Hawks','Mirko',
  ],
  Series.jjk: [
    'Yuji','Megumi','Nobara','Gojo','Sukuna','Maki','Toge','Panda','Nanami','Yaga',
    'Geto','Mahito','Choso','Jogo','Hanami','Dagon','Yuta','Hakari','Toji','Kenjaku',
  ],
  Series.bleach: [
    'Ichigo','Rukia','Orihime','Uryu','Chad','Byakuya','Kenpachi','Toshiro',
    'Rangiku','Yoruichi','Urahara','Aizen','Grimmjow','Ulquiorra','Yamamoto',
  ],
  Series.aot: [
    'Eren','Mikasa','Armin','Levi','Erwin','Hange','Jean','Sasha','Connie',
    'Historia','Reiner','Bertholdt','Annie','Zeke','Pieck',
  ],
  Series.fairyTail: [
    'Natsu','Lucy','Erza','Gray','Wendy','Happy','Gajeel','Juvia','Laxus','Mirajane',
  ],
  Series.blackClover: [
    'Asta','Yuno','Noelle','Yami','Luck','Mereoleona','Julius','Licht','Nero','Charmy',
  ],
  Series.hxh: [
    'Gon','Killua','Kurapika','Leorio','Hisoka','Chrollo','Illumi','Netero',
    'Meruem','Bisky',
  ],
  Series.other: [
    'Light Yagami','L','Edward Elric','Alphonse Elric','Saitama','Genos','Guts',
    'Lelouch','Kenshin','Spike Spiegel',
  ],
};

const List<int> _skins = [0xFFFFD9B0, 0xFFFADCB0, 0xFFE8C29A, 0xFFF5F5F5];
const List<int> _hairColors = [
  0xFFFFD23F, 0xFF1A1A2E, 0xFFE53935, 0xFF6D4C41, 0xFF9E9E9E,
  0xFF7CB342, 0xFF6A1B9A, 0xFFF57C00, 0xFFF5F5F5, 0xFF283593,
];
const List<int> _outfitColors = [
  0xFFF57C00, 0xFF283593, 0xFF6A1B9A, 0xFF1B5E20, 0xFFB71C1C,
  0xFF1A1A2E, 0xFF7CB342, 0xFFE53935,
];
const List<int> _accentColors = [
  0xFFFFE082, 0xFF90CAF9, 0xFFCE93D8, 0xFFFFD180, 0xFFE53935,
  0xFFFFE082, 0xFF80DEEA,
];

class _Override {
  final int hairColor;
  final int outfitColor;
  final int accentColor;
  final Hair hairStyle;
  final Eyes eyeStyle;
  final Outfit outfitStyle;
  const _Override(
    this.hairColor,
    this.outfitColor,
    this.accentColor,
    this.hairStyle,
    this.eyeStyle,
    this.outfitStyle,
  );
}

const Map<String, _Override> _overrides = {
  'Naruto': _Override(0xFFFFD23F, 0xFFF57C00, 0xFF1A1A2E, Hair.spiky, Eyes.normal, Outfit.ninja),
  'Sasuke': _Override(0xFF1A1A2E, 0xFF283593, 0xFFE53935, Hair.spiky, Eyes.sharingan, Outfit.ninja),
  'Sakura': _Override(0xFFE91E63, 0xFFB71C1C, 0xFFFFE082, Hair.bangs, Eyes.normal, Outfit.ninja),
  'Kakashi': _Override(0xFF9E9E9E, 0xFF1A1A2E, 0xFF90CAF9, Hair.spiky, Eyes.sharingan, Outfit.ninja),
  'Itachi': _Override(0xFF1A1A2E, 0xFF1A1A2E, 0xFFE53935, Hair.long, Eyes.mangekyou, Outfit.cape),
  'Madara': _Override(0xFF1A1A2E, 0xFF6A1B9A, 0xFFE53935, Hair.long, Eyes.rinnegan, Outfit.armor),
  'Pain': _Override(0xFFF57C00, 0xFF6A1B9A, 0xFF9E9E9E, Hair.spiky, Eyes.rinnegan, Outfit.cape),
  'Gaara': _Override(0xFFB71C1C, 0xFF6A1B9A, 0xFFFFE082, Hair.spiky, Eyes.closed, Outfit.ninja),
  'Hinata': _Override(0xFF283593, 0xFF6A1B9A, 0xFFE0D8E8, Hair.bob, Eyes.byakugan, Outfit.jacket),
  'Minato': _Override(0xFFFFD23F, 0xFF1A1A2E, 0xFF90CAF9, Hair.spiky, Eyes.normal, Outfit.cape),
  'Luffy': _Override(0xFF1A1A2E, 0xFFB71C1C, 0xFFFFE082, Hair.spiky, Eyes.normal, Outfit.tank),
  'Zoro': _Override(0xFF2E7D32, 0xFF1A1A2E, 0xFF90CAF9, Hair.spiky, Eyes.normal, Outfit.ninja),
  'Nami': _Override(0xFFFF8A50, 0xFF7BC67E, 0xFFFFD180, Hair.long, Eyes.normal, Outfit.tank),
  'Sanji': _Override(0xFFFFD23F, 0xFF1A1A2E, 0xFFFFE082, Hair.bangs, Eyes.normal, Outfit.school),
  'Ace': _Override(0xFF1A1A2E, 0xFFF57C00, 0xFFE53935, Hair.spiky, Eyes.normal, Outfit.tank),
  'Goku': _Override(0xFF1A1A2E, 0xFFF57C00, 0xFF283593, Hair.spiky, Eyes.normal, Outfit.kimono),
  'Vegeta': _Override(0xFF1A1A2E, 0xFF283593, 0xFFFFE082, Hair.spiky, Eyes.normal, Outfit.armor),
  'Piccolo': _Override(0xFF7CB342, 0xFF6A1B9A, 0xFFFFE082, Hair.bald, Eyes.normal, Outfit.cape),
  'Frieza': _Override(0xFFF5F5F5, 0xFF6A1B9A, 0xFFE53935, Hair.bald, Eyes.normal, Outfit.armor),
  'Tanjiro': _Override(0xFFB71C1C, 0xFF1A1A2E, 0xFF283593, Hair.bangs, Eyes.normal, Outfit.robe),
  'Nezuko': _Override(0xFF1A1A2E, 0xFFE91E63, 0xFFE0D8E8, Hair.long, Eyes.normal, Outfit.kimono),
  'Zenitsu': _Override(0xFFFFD23F, 0xFFFFE082, 0xFF283593, Hair.bangs, Eyes.closed, Outfit.robe),
  'Rengoku': _Override(0xFFFFD23F, 0xFFF57C00, 0xFFFFE082, Hair.spiky, Eyes.normal, Outfit.robe),
  'Deku': _Override(0xFF2E7D32, 0xFF283593, 0xFFE53935, Hair.spiky, Eyes.normal, Outfit.jacket),
  'Bakugo': _Override(0xFFFFD23F, 0xFF1A1A2E, 0xFFF57C00, Hair.spiky, Eyes.normal, Outfit.armor),
  'Todoroki': _Override(0xFFE53935, 0xFF1A1A2E, 0xFF90CAF9, Hair.spiky, Eyes.normal, Outfit.jacket),
  'Gojo': _Override(0xFFF5F5F5, 0xFF1A1A2E, 0xFF90CAF9, Hair.spiky, Eyes.byakugan, Outfit.jacket),
  'Sukuna': _Override(0xFF1A1A2E, 0xFFE53935, 0xFF1A1A2E, Hair.spiky, Eyes.sharingan, Outfit.kimono),
  'Ichigo': _Override(0xFFF57C00, 0xFF1A1A2E, 0xFF90CAF9, Hair.spiky, Eyes.normal, Outfit.robe),
  'Eren': _Override(0xFF6D4C41, 0xFF283593, 0xFF7CB342, Hair.long, Eyes.normal, Outfit.jacket),
  'Levi': _Override(0xFF1A1A2E, 0xFF1A1A2E, 0xFF90CAF9, Hair.bangs, Eyes.normal, Outfit.jacket),
  'Saitama': _Override(0xFF1A1A2E, 0xFFF57C00, 0xFFE53935, Hair.bald, Eyes.normal, Outfit.cape),
  'Gon': _Override(0xFF1A1A2E, 0xFF7CB342, 0xFFE53935, Hair.spiky, Eyes.normal, Outfit.tank),
  'Killua': _Override(0xFFF5F5F5, 0xFF283593, 0xFF90CAF9, Hair.spiky, Eyes.normal, Outfit.tank),
};

Character _makeChar(String name, Series series, int seed) {
  final ov = _overrides[name];
  int h(int salt, int mod) => (name.hashCode * 31 + salt + seed * 7).abs() % mod;
  return Character(
    id: '${series.name}_${name.toLowerCase().replaceAll(' ', '_')}',
    name: name,
    series: series,
    skin: Color(_skins[h(1, _skins.length)]),
    hair: Color(ov?.hairColor ?? _hairColors[h(2, _hairColors.length)]),
    outfit: Color(ov?.outfitColor ?? _outfitColors[h(3, _outfitColors.length)]),
    accent: Color(ov?.accentColor ?? _accentColors[h(4, _accentColors.length)]),
    hairStyle: ov?.hairStyle ?? Hair.values[h(5, Hair.values.length)],
    eyeStyle: ov?.eyeStyle ?? Eyes.values[h(6, Eyes.values.length)],
    outfitStyle: ov?.outfitStyle ?? Outfit.values[h(7, Outfit.values.length)],
  );
}

final List<Character> catalog = () {
  final out = <Character>[];
  int seed = 0;
  for (final entry in _names.entries) {
    for (final name in entry.value) {
      out.add(_makeChar(name, entry.key, seed++));
    }
  }
  return List.unmodifiable(out);
}();

// ===================================================================
// BATTERY (simulated, hook untuk asli via channel)
// ===================================================================
enum ThermalState { normal, warm, hot, critical }

class BatteryService extends ChangeNotifier {
  int _level = 82;
  bool _charging = true;
  ThermalState _thermal = ThermalState.normal;
  double _thermalC = 31.0;
  Timer? _timer;
  final math.Random _rng = math.Random();

  int get level => _level;
  bool get charging => _charging;
  ThermalState get thermalState => _thermal;
  double get thermalC => _thermalC;

  BatteryService() {
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _tick());
  }

  void _tick() {
    _level = (_level + (_charging ? 1 : -1) + _rng.nextInt(3) - 1).clamp(5, 100);
    _thermalC = (_thermalC + _rng.nextDouble() * 1.4 - 0.5).clamp(28.0, 48.0);
    if (_level >= 100) _charging = false;
    if (_level <= 5) _charging = true;
    if (_rng.nextInt(20) == 0) _charging = !_charging;
    _thermal = _classify(_thermalC);
    notifyListeners();
  }

  ThermalState _classify(double c) {
    if (c >= 45) return ThermalState.critical;
    if (c >= 40) return ThermalState.hot;
    if (c >= 35) return ThermalState.warm;
    return ThermalState.normal;
  }

  // Manual override untuk demo
  void setLevel(int v) {
    _level = v.clamp(0, 100);
    notifyListeners();
  }

  void setThermal(ThermalState s) {
    _thermal = s;
    _thermalC = switch (s) {
      ThermalState.normal => 32,
      ThermalState.warm => 37,
      ThermalState.hot => 42,
      ThermalState.critical => 47,
    };
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// ===================================================================
// CHARACTER PAINTER (procedural SVG-like rendering)
// ===================================================================
enum PoseMode { idle, sit, dance }

class CharacterPainter extends CustomPainter {
  final Character character;
  final double bob;
  final double sway;
  final double armSwing;
  final double legLift;
  final double mouthOpen;
  final double blink;
  final PoseMode pose;
  final double glowIntensity;
  final bool isHot;

  CharacterPainter({
    required this.character,
    this.bob = 0,
    this.sway = 0,
    this.armSwing = 0,
    this.legLift = 0,
    this.mouthOpen = 0.15,
    this.blink = 0,
    this.pose = PoseMode.idle,
    this.glowIntensity = 0.5,
    this.isHot = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 200.0, size.height / 300.0);
    canvas.translate(100, 290);
    canvas.rotate(sway * 0.06);
    canvas.translate(-100, -290);
    canvas.translate(0, bob * 4);

    _drawGround(canvas);
    _drawBody(canvas);

    canvas.restore();
  }

  void _drawGround(Canvas c) {
    c.drawOval(
      const Rect.fromLTWH(55, 288, 90, 14),
      Paint()..color = Colors.black.withValues(alpha: 0.32),
    );
    if (isHot || glowIntensity > 0.6) {
      final color = isHot ? const Color(0xFFFF4E50) : character.accent;
      c.drawOval(
        const Rect.fromLTWH(40, 285, 120, 20),
        Paint()
          ..color = color.withValues(alpha: 0.15 + 0.25 * glowIntensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
  }

  void _drawBody(Canvas c) {
    final standing = pose != PoseMode.sit;
    final footY = standing ? 288.0 : 268.0;
    final legTopY = footY - (standing ? 52 : 18);
    final torsoTopY = legTopY - 82;
    final headCY = torsoTopY - 56;
    const headCX = 100.0;

    if (standing) {
      _legsStanding(c, legTopY, liftRight: legLift);
    } else {
      _legsSitting(c, legTopY);
    }
    _torso(c, torsoTopY);
    _arms(c, torsoTopY + 8, armSwing);

    c.drawRect(
      Rect.fromLTWH(92, torsoTopY - 10, 16, 14),
      Paint()..color = character.skin,
    );

    _head(c, Offset(headCX, headCY));
  }

  void _legsStanding(Canvas c, double topY, {double liftRight = 0}) {
    final pants = Paint()..color = character.outfit;
    final shoes = Paint()..color = const Color(0xFF1A1A2E);

    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(78, topY, 18, 52),
        const Radius.circular(6),
      ),
      pants,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(76, topY + 46, 22, 10),
        const Radius.circular(4),
      ),
      shoes,
    );

    final lift = -liftRight * 18;
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(104, topY + lift, 18, 52),
        const Radius.circular(6),
      ),
      pants,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(102, topY + 46 + lift, 22, 10),
        const Radius.circular(4),
      ),
      shoes,
    );
  }

  void _legsSitting(Canvas c, double topY) {
    final pants = Paint()..color = character.outfit;
    final shoes = Paint()..color = const Color(0xFF1A1A2E);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(58, topY + 30, 44, 18),
        const Radius.circular(8),
      ),
      pants,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(98, topY + 30, 44, 18),
        const Radius.circular(8),
      ),
      pants,
    );
    c.drawOval(
      Rect.fromCenter(center: Offset(56, topY + 40), width: 22, height: 14),
      shoes,
    );
    c.drawOval(
      Rect.fromCenter(center: Offset(144, topY + 40), width: 22, height: 14),
      shoes,
    );
  }

  void _torso(Canvas c, double topY) {
    final outfit = Paint()..color = character.outfit;
    final accent = Paint()..color = character.accent;

    if (character.outfitStyle == Outfit.cape) {
      final cape = Path()
        ..moveTo(70, topY)
        ..lineTo(130, topY)
        ..lineTo(140, topY + 90)
        ..lineTo(60, topY + 90)
        ..close();
      c.drawPath(
        cape,
        Paint()..color = character.accent.withValues(alpha: 0.85),
      );
    }

    final torso = Path()
      ..moveTo(72, topY)
      ..lineTo(128, topY)
      ..quadraticBezierTo(134, topY + 40, 128, topY + 82)
      ..lineTo(72, topY + 82)
      ..quadraticBezierTo(66, topY + 40, 72, topY);
    c.drawPath(torso, outfit);

    switch (character.outfitStyle) {
      case Outfit.ninja:
        c.drawRect(Rect.fromLTWH(94, topY, 12, 82), accent);
        c.drawRect(Rect.fromLTWH(72, topY + 60, 56, 6), accent);
        break;
      case Outfit.kimono:
        final collar = Path()
          ..moveTo(72, topY)
          ..lineTo(100, topY + 20)
          ..lineTo(100, topY + 82)
          ..lineTo(72, topY + 82)
          ..close();
        c.drawPath(collar, Paint()..color = Colors.white70);
        c.drawRect(Rect.fromLTWH(72, topY + 58, 56, 8), accent);
        break;
      case Outfit.school:
        c.drawRect(
          Rect.fromLTWH(95, topY, 10, 82),
          Paint()..color = Colors.white70,
        );
        final tie = Path()
          ..moveTo(95, topY + 18)
          ..lineTo(105, topY + 18)
          ..lineTo(100, topY + 48)
          ..close();
        c.drawPath(tie, accent);
        break;
      case Outfit.cape:
        c.drawRect(Rect.fromLTWH(68, topY, 64, 16), accent);
        break;
      case Outfit.jacket:
        c.drawRect(Rect.fromLTWH(88, topY, 24, 82), accent);
        break;
      case Outfit.tank:
        c.drawRect(Rect.fromLTWH(72, topY + 60, 56, 6), accent);
        break;
      case Outfit.armor:
        c.drawRect(Rect.fromLTWH(68, topY + 6, 64, 34), accent);
        c.drawRect(Rect.fromLTWH(72, topY + 60, 56, 6), accent);
        break;
      case Outfit.robe:
        c.drawRect(Rect.fromLTWH(72, topY + 60, 56, 8), accent);
        c.drawRect(Rect.fromLTWH(94, topY, 12, 60), accent);
        break;
      case Outfit.hoodie:
        c.drawCircle(Offset(100, topY + 6), 22, accent);
        break;
    }
  }

  void _arms(Canvas c, double topY, double swing) {
    final sleeve = Paint()..color = character.outfit;
    final skin = Paint()..color = character.skin;

    c.save();
    c.translate(72, topY);
    c.rotate(-0.25 + swing * 0.55);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, 0, 16, 54),
        const Radius.circular(8),
      ),
      sleeve,
    );
    c.drawCircle(const Offset(0, 54), 8, skin);
    c.restore();

    c.save();
    c.translate(128, topY);
    c.rotate(0.25 - swing * 0.55);
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, 0, 16, 54),
        const Radius.circular(8),
      ),
      sleeve,
    );
    c.drawCircle(const Offset(0, 54), 8, skin);
    c.restore();
  }

  void _head(Canvas c, Offset center) {
    final skin = Paint()..color = character.skin;
    _hairBack(c, center);
    c.drawOval(
      Rect.fromCenter(center: center, width: 88, height: 98),
      skin,
    );
    c.drawCircle(center + const Offset(-46, 4), 9, skin);
    c.drawCircle(center + const Offset(46, 4), 9, skin);
    _hairFront(c, center);
    _eyes(c, center);

    final blush = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.35);
    c.drawOval(
      Rect.fromCenter(center: center + const Offset(-26, 20), width: 16, height: 8),
      blush,
    );
    c.drawOval(
      Rect.fromCenter(center: center + const Offset(26, 20), width: 16, height: 8),
      blush,
    );
    _mouth(c, center);
    _accessory(c, center);
  }

  void _hairBack(Canvas c, Offset center) {
    final hp = Paint()..color = character.hair;
    final hl = Paint()..color = _lighten(character.hair);

    switch (character.hairStyle) {
      case Hair.long:
        c.drawOval(
          Rect.fromCenter(center: center + const Offset(0, 30), width: 100, height: 200),
          hp,
        );
        c.drawOval(
          Rect.fromCenter(center: center + const Offset(-40, 60), width: 24, height: 130),
          hp,
        );
        c.drawOval(
          Rect.fromCenter(center: center + const Offset(40, 60), width: 24, height: 130),
          hp,
        );
        c.drawOval(
          Rect.fromCenter(center: center + const Offset(0, 30), width: 30, height: 180),
          hl,
        );
        break;
      case Hair.ponytail:
        c.drawOval(
          Rect.fromCenter(center: center + const Offset(52, 22), width: 26, height: 100),
          hp,
        );
        break;
      case Hair.twinTail:
        c.drawOval(
          Rect.fromCenter(center: center + const Offset(-58, 30), width: 24, height: 110),
          hp,
        );
        c.drawOval(
          Rect.fromCenter(center: center + const Offset(58, 30), width: 24, height: 110),
          hp,
        );
        break;
      case Hair.bob:
        c.drawOval(
          Rect.fromCenter(center: center + const Offset(0, 20), width: 105, height: 130),
          hp,
        );
        break;
      default:
        break;
    }
  }

  void _hairFront(Canvas c, Offset center) {
    final hp = Paint()..color = character.hair;
    final hl = Paint()..color = _lighten(character.hair);

    final cap = Path()
      ..moveTo(center.dx - 46, center.dy - 20)
      ..quadraticBezierTo(center.dx - 46, center.dy - 55, center.dx, center.dy - 55)
      ..quadraticBezierTo(center.dx + 46, center.dy - 55, center.dx + 46, center.dy - 20)
      ..quadraticBezierTo(center.dx + 30, center.dy - 30, center.dx, center.dy - 35)
      ..quadraticBezierTo(center.dx - 30, center.dy - 30, center.dx - 46, center.dy - 20)
      ..close();

    switch (character.hairStyle) {
      case Hair.spiky:
        c.drawPath(cap, hp);
        for (int i = 0; i < 7; i++) {
          final a = -math.pi + (i / 6) * math.pi;
          final base = center + Offset(math.cos(a) * 42, math.sin(a) * 46 - 8);
          final tip = center + Offset(math.cos(a) * 62, math.sin(a) * 72 - 8);
          final perp = Offset(-math.sin(a), math.cos(a)) * 10;
          c.drawPath(
            Path()
              ..moveTo(base.dx + perp.dx, base.dy + perp.dy)
              ..lineTo(tip.dx, tip.dy)
              ..lineTo(base.dx - perp.dx, base.dy - perp.dy)
              ..close(),
            hp,
          );
        }
        c.drawPath(cap, hl);
        break;
      case Hair.long:
        c.drawPath(cap, hp);
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center + const Offset(-44, 40), width: 18, height: 80),
            const Radius.circular(8),
          ),
          hp,
        );
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center + const Offset(44, 40), width: 18, height: 80),
            const Radius.circular(8),
          ),
          hp,
        );
        break;
      case Hair.ponytail:
        c.drawPath(cap, hp);
        c.drawCircle(center + const Offset(42, -30), 10, hl);
        break;
      case Hair.bob:
        c.drawPath(cap, hp);
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center + const Offset(-48, 15), width: 14, height: 50),
            const Radius.circular(6),
          ),
          hp,
        );
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center + const Offset(48, 15), width: 14, height: 50),
            const Radius.circular(6),
          ),
          hp,
        );
        break;
      case Hair.bangs:
        c.drawPath(cap, hp);
        final fringe = Path()
          ..moveTo(center.dx - 44, center.dy - 22)
          ..lineTo(center.dx - 22, center.dy + 2)
          ..lineTo(center.dx - 8, center.dy - 20)
          ..lineTo(center.dx + 4, center.dy + 2)
          ..lineTo(center.dx + 20, center.dy - 20)
          ..lineTo(center.dx + 34, center.dy + 2)
          ..lineTo(center.dx + 44, center.dy - 22)
          ..close();
        c.drawPath(fringe, hp);
        break;
      case Hair.twinTail:
        c.drawPath(cap, hp);
        c.drawCircle(center + const Offset(-42, -28), 9, hl);
        c.drawCircle(center + const Offset(42, -28), 9, hl);
        break;
      case Hair.helmet:
        c.drawOval(
          Rect.fromCenter(center: center + const Offset(0, -6), width: 100, height: 90),
          hp,
        );
        c.drawRect(Rect.fromLTWH(center.dx - 44, center.dy + 4, 88, 22), hl);
        break;
      case Hair.bald:
        break;
    }
  }

  void _eyes(Canvas c, Offset center) {
    final left = center + const Offset(-20, 4);
    final right = center + const Offset(20, 4);
    final stroke = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (blink > 0.6 || character.eyeStyle == Eyes.closed) {
      c.drawArc(Rect.fromCenter(center: left, width: 14, height: 8), 0, math.pi, false, stroke);
      c.drawArc(Rect.fromCenter(center: right, width: 14, height: 8), 0, math.pi, false, stroke);
      return;
    }

    final white = Paint()..color = Colors.white;
    final black = Paint()..color = Colors.black;

    c.drawOval(Rect.fromCenter(center: left, width: 18, height: 20), white);
    c.drawOval(Rect.fromCenter(center: right, width: 18, height: 20), white);

    switch (character.eyeStyle) {
      case Eyes.sharingan:
        final red = Paint()..color = const Color(0xFFD32F2F);
        c.drawCircle(left, 7, red);
        c.drawCircle(right, 7, red);
        for (int i = 0; i < 3; i++) {
          final a = i * 2.09;
          c.drawCircle(left + Offset(math.cos(a) * 4, math.sin(a) * 4), 1.3, black);
          c.drawCircle(right + Offset(math.cos(a) * 4, math.sin(a) * 4), 1.3, black);
        }
        break;
      case Eyes.rinnegan:
        final purple = Paint()..color = const Color(0xFF7B1FA2);
        c.drawCircle(left, 7, purple);
        c.drawCircle(right, 7, purple);
        final ring = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9;
        for (int i = 1; i < 4; i++) {
          c.drawCircle(left, i * 1.8, ring);
          c.drawCircle(right, i * 1.8, ring);
        }
        break;
      case Eyes.byakugan:
        final pale = Paint()..color = const Color(0xFFE8E0F0);
        c.drawCircle(left, 7, pale);
        c.drawCircle(right, 7, pale);
        break;
      case Eyes.mangekyou:
        final red = Paint()..color = const Color(0xFFB71C1C);
        c.drawCircle(left, 7, red);
        c.drawCircle(right, 7, red);
        final spike = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        for (int i = 0; i < 3; i++) {
          final a = i * 2.09 - 1.57;
          c.drawLine(left, left + Offset(math.cos(a) * 7, math.sin(a) * 7), spike);
          c.drawLine(right, right + Offset(math.cos(a) * 7, math.sin(a) * 7), spike);
        }
        break;
      case Eyes.wink:
        c.drawCircle(left, 5, black);
        c.drawArc(Rect.fromCenter(center: right, width: 14, height: 8), 0, math.pi, false, stroke);
        break;
      case Eyes.spiral:
        c.drawCircle(left, 7, black);
        c.drawCircle(right, 7, black);
        final spiral = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
        c.drawArc(Rect.fromCenter(center: left, width: 9, height: 9), 0, 4.7, false, spiral);
        c.drawArc(Rect.fromCenter(center: right, width: 9, height: 9), 0, 4.7, false, spiral);
        break;
      case Eyes.closed:
        break;
      case Eyes.normal:
        c.drawCircle(left, 5, black);
        c.drawCircle(right, 5, black);
        c.drawCircle(left + const Offset(-1.4, -1.4), 1.6, white);
        c.drawCircle(right + const Offset(-1.4, -1.4), 1.6, white);
        break;
    }
  }

  void _mouth(Canvas c, Offset center) {
    final mp = center + const Offset(0, 32);
    final stroke = Paint()
      ..color = const Color(0xFF3A1515)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (mouthOpen > 0.35) {
      final open = Paint()..color = const Color(0xFF4A1515);
      c.drawOval(
        Rect.fromCenter(
          center: mp,
          width: 12 + mouthOpen * 5,
          height: 5 + mouthOpen * 9,
        ),
        open,
      );
    } else {
      c.drawArc(Rect.fromCenter(center: mp, width: 14, height: 8), 0, math.pi, false, stroke);
    }
  }

  void _accessory(Canvas c, Offset center) {
    if (character.outfitStyle == Outfit.ninja) {
      c.drawRect(
        Rect.fromLTWH(center.dx - 46, center.dy - 32, 92, 14),
        Paint()..color = character.accent,
      );
      c.drawRect(
        Rect.fromLTWH(center.dx - 10, center.dy - 34, 20, 18),
        Paint()..color = const Color(0xFF1A1A2E),
      );
    }
  }

  Color _lighten(Color c) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + 0.18).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant CharacterPainter old) =>
      old.bob != bob ||
      old.sway != sway ||
      old.armSwing != armSwing ||
      old.legLift != legLift ||
      old.mouthOpen != mouthOpen ||
      old.blink != blink ||
      old.pose != pose ||
      old.glowIntensity != glowIntensity ||
      old.isHot != isHot ||
      old.character.id != character.id;
}

class StaticCharacterPainter extends CharacterPainter {
  StaticCharacterPainter({required super.character});
  @override
  bool shouldRepaint(covariant CharacterPainter old) =>
      old.character.id != character.id;
}

// ===================================================================
// CHARACTER AVATAR (animated)
// ===================================================================
class CharacterAvatar extends StatefulWidget {
  final Character character;
  final BatteryService battery;
  final double size;

  const CharacterAvatar({
    super.key,
    required this.character,
    required this.battery,
    this.size = 260,
  });

  @override
  State<CharacterAvatar> createState() => _CharacterAvatarState();
}

class _CharacterAvatarState extends State<CharacterAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  PoseMode _pose = PoseMode.idle;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    widget.battery.addListener(_onBattery);
  }

  void _onBattery() {
    if (!mounted) return;
    final low = widget.battery.level < 20 && !widget.battery.charging;
    final hot = widget.battery.thermalState != ThermalState.normal;
    final target = _pose == PoseMode.dance
        ? Duration(milliseconds: hot ? 400 : 620)
        : _pose == PoseMode.sit
            ? const Duration(milliseconds: 3400)
            : Duration(milliseconds: low ? 4000 : 2400);
    if (target != _ctrl.duration) {
      final progress = _ctrl.value;
      _ctrl.duration = target;
      _ctrl.value = progress;
      _ctrl.repeat();
    }
    setState(() {});
  }

  void _cyclePose() {
    setState(() {
      _pose = PoseMode.values[(_pose.index + 1) % PoseMode.values.length];
    });
    _onBattery();
  }

  @override
  void dispose() {
    widget.battery.removeListener(_onBattery);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHot = widget.battery.thermalState != ThermalState.normal;
    final glow = (widget.battery.level / 100.0).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: _cyclePose,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (ctx, _) {
          final t = _ctrl.value;
          final phase = t * 2 * math.pi;
          double bob = 0, sway = 0, armSwing = 0, legLift = 0;
          double mouthOpen = 0.15, blink = 0;

          switch (_pose) {
            case PoseMode.idle:
              bob = math.sin(phase);
              sway = math.sin(phase) * 0.3;
              armSwing = math.sin(phase) * 0.25;
              blink = (t * 4) % 1 > 0.94 ? 1 : 0;
              break;
            case PoseMode.sit:
              bob = math.sin(phase) * 0.4;
              armSwing = math.sin(phase) * 0.15;
              blink = (t * 4) % 1 > 0.94 ? 1 : 0;
              break;
            case PoseMode.dance:
              bob = math.sin(phase * 2);
              sway = math.sin(phase) * 1.5;
              armSwing = math.sin(phase * 2) * 1.4;
              legLift = (math.sin(phase * 2) + 1) / 2;
              mouthOpen = 0.55 + 0.35 * math.sin(phase * 3);
              break;
          }

          return CustomPaint(
            size: Size(widget.size, widget.size * 1.5),
            painter: CharacterPainter(
              character: widget.character,
              bob: bob,
              sway: sway,
              armSwing: armSwing,
              legLift: legLift,
              mouthOpen: mouthOpen,
              blink: blink,
              pose: _pose,
              glowIntensity: glow,
              isHot: isHot,
            ),
          );
        },
      ),
    );
  }
}

// ===================================================================
// CHARACTER PICKER
// ===================================================================
class CharacterPicker extends StatefulWidget {
  final ValueChanged<Character> onSelect;
  final bool compact;

  const CharacterPicker({
    super.key,
    required this.onSelect,
    this.compact = false,
  });

  @override
  State<CharacterPicker> createState() => _CharacterPickerState();
}

class _CharacterPickerState extends State<CharacterPicker> {
  Series? _filter;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = catalog.where((c) {
      if (_filter != null && c.series != _filter) return false;
      if (_search.isNotEmpty &&
          !c.name.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
              hintText: 'ابحث بالاسم...',
              hintStyle: const TextStyle(color: AppTheme.textMuted),
              filled: true,
              fillColor: AppTheme.surfaceAlt,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _chip('الكل', null),
              ...Series.values.map((s) => _chip(seriesLabel(s), s)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${filtered.length} شخصية',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.compact ? 3 : 4,
              childAspectRatio: 0.72,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final c = filtered[i];
              return InkWell(
                onTap: () => widget.onSelect(c),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: StaticCharacterPainter(character: c),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, Series? value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: selected,
        selectedColor: AppTheme.primary,
        backgroundColor: AppTheme.surfaceAlt,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.textPrimary,
        ),
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }
}

// ===================================================================
// HOME SCREEN
// ===================================================================
class HomeScreen extends StatefulWidget {
  final Character initial;
  const HomeScreen({super.key, required this.initial});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _storageKey = 'char_toon_selected_v1';

  late Character _character;
  late BatteryService _battery;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _character = widget.initial;
    _battery = BatteryService();
  }

  @override
  void dispose() {
    _battery.dispose();
    super.dispose();
  }

  Future<void> _saveSelection(Character c) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_storageKey, c.id);
    } catch (_) {}
  }

  void _onPick(Character c) {
    setState(() => _character = c);
    _saveSelection(c);
    Navigator.of(context).pop();
  }

  void _openPicker() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('اختر شخصية')),
        body: CharacterPicker(onSelect: _onPick),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Character Toon'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: CharacterPicker(onSelect: _onPick, compact: true),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StatusBar(battery: _battery),
            Expanded(
              child: Center(
                child: CharacterAvatar(
                  character: _character,
                  battery: _battery,
                  size: 240,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    _character.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    seriesLabel(_character.series),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'اضغط الشخصية لتغيير الحركة',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.people_alt),
                  label: Text('تغيير الشخصية (${catalog.length})'),
                  onPressed: _openPicker,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final BatteryService battery;
  const _StatusBar({required this.battery});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: battery,
      builder: (ctx, _) {
        final lvl = battery.level;
        final thermal = battery.thermalState;
        final lvlColor = lvl > 60
            ? AppTheme.success
            : lvl > 20
                ? AppTheme.warning
                : AppTheme.danger;
        final tColor = switch (thermal) {
          ThermalState.critical => AppTheme.danger,
          ThermalState.hot => Colors.deepOrangeAccent,
          ThermalState.warm => AppTheme.warning,
          ThermalState.normal => AppTheme.success,
        };
        final tLabel = switch (thermal) {
          ThermalState.critical => 'حرج',
          ThermalState.hot => 'حار',
          ThermalState.warm => 'دافئ',
          ThermalState.normal => 'عادي',
        };
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _metric(Icons.battery_std, '$lvl%', lvlColor),
              _metric(Icons.thermostat, tLabel, tColor),
              _metric(
                battery.charging ? Icons.bolt : Icons.power_settings_new,
                battery.charging ? 'يشحن' : 'بطارية',
                battery.charging ? Colors.yellowAccent : Colors.blueGrey,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metric(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

// ===================================================================
// SPLASH + APP
// ===================================================================
class CharToonApp extends StatelessWidget {
  const CharToonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Character Toon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const _Splash(),
    );
  }
}

class _Splash extends StatefulWidget {
  const _Splash();

  @override
  State<_Splash> createState() => _SplashState();
}

class _SplashState extends State<_Splash> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    Character initial = catalog.first;
    try {
      final p = await SharedPreferences.getInstance();
      final id = p.getString('char_toon_selected_v1');
      if (id != null) {
        initial = catalog.firstWhere(
          (c) => c.id == id,
          orElse: () => catalog.first,
        );
      }
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(initial: initial)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppTheme.primaryLight),
      ),
    );
  }
}