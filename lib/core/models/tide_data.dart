/// Jeden bod predikovanej krivky prílivu/odlivu.
class TidePoint {
  final DateTime time;
  final double heightM;
  /// 'high' / 'low' pri extrémoch, inak null.
  final String? extremeType;

  const TidePoint({required this.time, required this.heightM, this.extremeType});

  bool get isHigh => extremeType == 'high';
  bool get isLow => extremeType == 'low';
}
