import 'package:meta/meta.dart';

import 'collision_callbacks.dart';

enum BroadphaseType { sweep }

abstract class Broadphase<T extends Collidable<T>> {
  final List<T> items;
  Broadphase(this.items);

  Iterable<Potential<T>> query();
}

@immutable
class Potential<T> {
  final T a;
  final T b;

  const Potential(this.a, this.b);
}