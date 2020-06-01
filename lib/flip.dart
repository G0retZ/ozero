import 'dart:math';

import 'package:flutter/widgets.dart';

class FlipTransition extends AnimatedWidget {
  /// Creates a flip transition.
  ///
  /// The [turns] argument must not be null.
  const FlipTransition({
    Key key,
    @required Animation<double> turns,
    this.alignment = Alignment.center,
    this.child,
  })  : assert(turns != null),
        super(key: key, listenable: turns);

  /// The animation that controls the rotation of the child.
  ///
  /// If the current value of the turns animation is v, the child will be
  /// rotated v * 2 * pi radians before being painted.
  Animation<double> get turns => listenable as Animation<double>;

  /// The alignment of the origin of the coordinate system around which the
  /// rotation occurs, relative to the size of the box.
  ///
  /// For example, to set the origin of the rotation to top right corner, use
  /// an alignment of (1.0, -1.0) or use [Alignment.topRight]
  final Alignment alignment;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double turnsValue = turns.value;
    final Matrix4 transform = Matrix4.identity();
    transform.setEntry(3, 2, 0.001);
    transform.rotateY(((turnsValue <= 0.5 ? 0.5 : turnsValue) - 1) * pi);
    return Transform(
      transform: transform,
      alignment: alignment,
      child: child,
    );
  }
}
