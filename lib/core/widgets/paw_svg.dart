import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ── 공통 5개 path 데이터 (viewBox="0 0 384 352" 기준) ─────────────────
const String _palm =
    'M257.556763,210.399918 C263.100586,217.220169 270.532715,221.338120 276.582367,227.025818 '
    'C290.376801,239.994980 294.703888,257.017303 285.851044,273.562714 '
    'C279.918793,284.649780 265.411530,291.324341 253.133102,288.552948 '
    'C248.112823,287.419800 243.025421,286.311646 238.232162,284.496155 '
    'C223.955811,279.088959 210.097641,281.407074 196.282898,286.100494 '
    'C187.223251,289.178406 178.096664,291.433746 168.412323,289.481506 '
    'C145.834671,284.930115 135.278076,259.832184 147.860199,240.522430 '
    'C150.603256,236.312698 153.941559,232.679535 157.765198,229.379303 '
    'C168.148819,220.417068 177.411880,210.497467 183.650925,198.061615 '
    'C195.544174,174.355621 235.004532,171.284882 250.512375,198.494232 '
    'C252.737076,202.397598 255.060333,206.244812 257.556763,210.399918z';

const String _toe1 =
    'M235.106033,106.163368 C238.765503,100.259148 243.958206,96.625092 249.721710,93.919243 '
    'C258.437073,89.827568 269.014496,93.582375 274.819336,102.449860 '
    'C286.293274,119.977448 279.937988,153.856247 262.951660,166.083969 '
    'C247.052429,177.529160 231.463455,169.742279 226.896255,153.021454 '
    'C222.350693,136.379868 225.073273,120.749245 235.106033,106.163368z';

const String _toe2 =
    'M206.705719,116.450974 C211.744247,130.208542 213.125229,143.762558 207.152054,157.093399 '
    'C199.176514,174.893097 181.543732,177.345459 168.865906,162.388397 '
    'C159.912766,151.825653 156.190567,139.185364 156.391373,125.396500 '
    'C156.494080,118.343849 157.819122,111.661240 161.092865,105.213272 '
    'C165.061035,97.397568 170.983398,92.542503 179.589401,91.892914 '
    'C188.372665,91.229942 194.748093,96.273003 199.703766,102.867355 '
    'C202.672714,106.818054 205.212173,111.195839 206.705719,116.450974z';

const String _toe3 =
    'M119.764259,150.517731 C128.403458,145.737610 135.964020,148.408508 143.108673,153.021820 '
    'C156.353912,161.574295 165.282211,184.433853 161.616013,199.833344 '
    'C157.106064,218.776917 142.082977,224.324814 126.133751,212.992264 '
    'C120.504265,208.992279 116.739449,203.473206 113.940125,197.414124 '
    'C108.279533,185.161896 104.920021,172.642975 111.582863,159.498962 '
    'C113.455925,155.803909 115.894760,152.814163 119.764259,150.517731z';

const String _toe4 =
    'M271.660645,192.027023 C272.001251,174.289658 283.505615,157.618576 298.645599,152.451111 '
    'C309.784363,148.649292 320.576752,154.255020 324.566406,165.366882 '
    'C330.955719,183.162018 319.229889,211.827484 296.986115,217.720444 '
    'C285.062073,220.879456 273.209991,211.777069 271.813477,197.992462 '
    'C271.629395,196.175583 271.703918,194.332520 271.660645,192.027023z';

// ── Splash 발바닥 SVG ────────────────────────────────────────────────
// viewBox="90 75 260 240" — 레퍼런스 HTML과 동일
// rgba() → stop-color + stop-opacity 로 변환 (flutter_svg 호환)
const String kSplashPawSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="220" height="220" viewBox="90 75 260 240" fill="none">
  <defs>
    <radialGradient id="spConvex" cx="38%" cy="32%" r="58%" fx="35%" fy="28%" gradientUnits="objectBoundingBox">
      <stop offset="0%"   stop-color="#C4956A"/>
      <stop offset="30%"  stop-color="#8D6E63"/>
      <stop offset="65%"  stop-color="#5D3A2A"/>
      <stop offset="100%" stop-color="#2E1208"/>
    </radialGradient>
    <radialGradient id="spConvexToe" cx="40%" cy="30%" r="55%" fx="36%" fy="26%" gradientUnits="objectBoundingBox">
      <stop offset="0%"   stop-color="#D4A47A"/>
      <stop offset="28%"  stop-color="#A1887F"/>
      <stop offset="60%"  stop-color="#6D4C41"/>
      <stop offset="100%" stop-color="#3E1F10"/>
    </radialGradient>
    <radialGradient id="spRim" cx="50%" cy="50%" r="50%" gradientUnits="objectBoundingBox">
      <stop offset="70%"  stop-color="#000000" stop-opacity="0"/>
      <stop offset="100%" stop-color="#000000" stop-opacity="0.22"/>
    </radialGradient>
  </defs>

  <!-- ① 그림자 -->
  <g transform="translate(5,9)" opacity="0.32">
    <path fill="#1A0804" d="$_palm"/>
    <path fill="#1A0804" d="$_toe1"/>
    <path fill="#1A0804" d="$_toe2"/>
    <path fill="#1A0804" d="$_toe3"/>
    <path fill="#1A0804" d="$_toe4"/>
  </g>

  <!-- ② 베이스 radialGradient -->
  <path fill="url(#spConvex)"    d="$_palm"/>
  <path fill="url(#spConvexToe)" d="$_toe1"/>
  <path fill="url(#spConvexToe)" d="$_toe2"/>
  <path fill="url(#spConvexToe)" d="$_toe3"/>
  <path fill="url(#spConvexToe)" d="$_toe4"/>

  <!-- ③ 테두리 암부 -->
  <path fill="url(#spRim)" d="$_palm"/>
  <path fill="url(#spRim)" d="$_toe1"/>
  <path fill="url(#spRim)" d="$_toe2"/>
  <path fill="url(#spRim)" d="$_toe3"/>
  <path fill="url(#spRim)" d="$_toe4"/>

  <!-- ④ 하이라이트 -->
  <g transform="translate(-3,-4)" opacity="0.32">
    <path fill="white" d="$_palm"/>
    <path fill="white" d="$_toe1"/>
    <path fill="white" d="$_toe2"/>
    <path fill="white" d="$_toe3"/>
    <path fill="white" d="$_toe4"/>
  </g>
</svg>
''';

// ── 홈 네비 발바닥 SVG ────────────────────────────────────────────────
// viewBox="0 0 384 352" — 레퍼런스 HTML과 동일, fill=#8D6E63(var(--brown))
String kNavPawSvg({String color = '#8D6E63', double opacity = 1.0}) => '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 352" fill="none">
  <path fill="$color" opacity="$opacity" d="$_palm"/>
  <path fill="$color" opacity="$opacity" d="$_toe1"/>
  <path fill="$color" opacity="$opacity" d="$_toe2"/>
  <path fill="$color" opacity="$opacity" d="$_toe3"/>
  <path fill="$color" opacity="$opacity" d="$_toe4"/>
</svg>
''';

// ── FAB 내부 발바닥 SVG ───────────────────────────────────────────────
// 레퍼런스 HTML fab-inner SVG 그대로:
// palm → fabPad(밝은 베이지), toes → fabGrad(어두운 브라운), + 그림자 + 하이라이트
const String kFabPawSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="34" height="34" viewBox="0 0 384 352" fill="none">
  <defs>
    <linearGradient id="fabGrad" x1="25%" y1="15%" x2="70%" y2="100%">
      <stop offset="0%"   stop-color="#D7CCC8"/>
      <stop offset="50%"  stop-color="#A1887F"/>
      <stop offset="100%" stop-color="#6D4C41"/>
    </linearGradient>
    <linearGradient id="fabPad" x1="25%" y1="15%" x2="70%" y2="100%">
      <stop offset="0%"   stop-color="#EFEBE9"/>
      <stop offset="45%"  stop-color="#BCAAA4"/>
      <stop offset="100%" stop-color="#8D6E63"/>
    </linearGradient>
  </defs>
  <g transform="translate(4,6)" opacity="0.3">
    <path fill="#3E1F10" d="$_palm"/>
    <path fill="#3E1F10" d="$_toe1"/>
    <path fill="#3E1F10" d="$_toe2"/>
    <path fill="#3E1F10" d="$_toe3"/>
    <path fill="#3E1F10" d="$_toe4"/>
  </g>
  <path fill="url(#fabPad)" d="$_palm"/>
  <path fill="url(#fabGrad)" d="$_toe1"/>
  <path fill="url(#fabGrad)" d="$_toe2"/>
  <path fill="url(#fabGrad)" d="$_toe3"/>
  <path fill="url(#fabGrad)" d="$_toe4"/>
  <g transform="translate(-2,-3)" opacity="0.22">
    <path fill="white" d="$_palm"/>
    <path fill="white" d="$_toe1"/>
    <path fill="white" d="$_toe2"/>
    <path fill="white" d="$_toe3"/>
    <path fill="white" d="$_toe4"/>
  </g>
</svg>
''';

// ── 위젯 ────────────────────────────────────────────────────────────

/// 스플래시 전용 발바닥 (220×220, 입체 그라디언트)
class SplashPawSvg extends StatelessWidget {
  const SplashPawSvg({super.key, this.size = 220});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      kSplashPawSvg,
      width: size,
      height: size,
    );
  }
}

/// 홈 타이틀 옆 소형 발바닥 (브라운, 단색)
class NavPawSvg extends StatelessWidget {
  const NavPawSvg({
    super.key,
    this.width = 22,
    this.height = 20,
    this.color = '#8D6E63',
    this.opacity = 1.0,
  });

  final double width;
  final double height;
  final String color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      kNavPawSvg(color: color, opacity: opacity),
      width: width,
      height: height,
    );
  }
}
