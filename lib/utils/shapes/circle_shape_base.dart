import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/drawing_point.dart';
import 'base_shape_generator.dart';

abstract class CircleShapeBase extends ShapeGenerator {
  /// サブクラスで実装する半径の計算方法
  /// [center] 円の中心座標
  /// [start] ドラッグ開始座標
  /// [end] ドラッグ終了座標
  /// 戻り値: 円の半径（ピクセル単位）
  ///
  /// このメソッドをオーバーライドして、円の大きさを決定する計算ロジックを実装します。
  /// 例：縦横の長い方を直径とする、対角線の長さを直径とする、など
  double calculateRadius(Offset center, Offset start, Offset end);

  @override
  List<DrawingPoint?> generateShape({
    required Offset start,
    required Offset end,
    required Paint paint,
    required Size canvasSize,
    required bool isFilled,
  }) {
    final points = <DrawingPoint?>[];
    getWidth(start, end);
    getHeight(start, end);

    // ドラッグの開始点と終了点の中間点を円の中心とする
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    // サブクラスで定義された方法で半径を計算
    final radius = calculateRadius(center, start, end);

    _drawCircle(points, center, radius, paint, canvasSize, isFilled);

    return points;
  }

  /// 円を描画する内部メソッド
  /// [points] 描画するピクセル座標を格納するリスト
  /// [center] 円の中心座標
  /// [radius] 円の半径
  /// [paint] 描画に使用するペイント設定
  /// [canvasSize] キャンバスのサイズ
  /// [isFilled] 塗りつぶすかどうか
  ///
  /// アルゴリズムの概要：
  /// 1. 描画範囲を計算（キャンバスの境界でクリップ）
  /// 2. 範囲内の各ピクセルに対して：
  ///    - 中心からの距離を計算
  ///    - 距離を半径で正規化（1.0が円周上）
  ///    - 条件に応じてピクセルを描画
  void _drawCircle(
    List<DrawingPoint?> points,
    Offset center,
    double radius,
    Paint paint,
    Size canvasSize,
    bool isFilled,
  ) {
    // 描画範囲の計算
    // キャンバスの境界でクリッピング
    final boundLeft = math.max(0, (center.dx - radius).floor());
    final boundRight = math.min(
      canvasSize.width.floor() - 1,
      (center.dx + radius).floor(),
    );
    final boundTop = math.max(0, (center.dy - radius).floor());
    final boundBottom = math.min(
      canvasSize.height.floor() - 1,
      (center.dy + radius).floor(),
    );

    // 描画範囲内の各ピクセルを走査
    for (int x = boundLeft; x <= boundRight; x++) {
      for (int y = boundTop; y <= boundBottom; y++) {
        // 中心からの相対距離をピクセル単位で計算
        final dx = x - center.dx;
        final dy = y - center.dy;

        // ピタゴラスの定理で距離を計算し、半径で正規化
        // 結果が1.0のとき円周上、<1.0のとき円の内側、>1.0のとき円の外側
        final distance = math.sqrt(dx * dx + dy * dy) / radius;

        if (isFilled) {
          // 塗りつぶしモード：円の内側のピクセルを全て描画
          if (distance <= 1.0) {
            addPoint(points, x.toDouble(), y.toDouble(), paint, canvasSize);
          }
        } else {
          // 輪郭モード：円周付近のピクセルのみを描画
          // カスタマイズポイント1：閾値の調整
          // - 現在の値0.1を変更することで線の太さを調整可能
          // - 値を小さくすると線が細く、大きくすると太くなる
          // カスタマイズポイント2：アンチエイリアス
          // - 複数の閾値を使用し、距離に応じて透明度を変える
          // - 例：distance=1.0±0.1で不透明度100%、1.0±0.2で50%など
          if ((distance - 1.0).abs() <= 0.1) {
            addPoint(points, x.toDouble(), y.toDouble(), paint, canvasSize);
          }
        }
      }
    }
  }
}
