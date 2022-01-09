import 'dart:math';

import 'package:flame/collision_detection.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

class _HasCollidablesGame extends FlameGame with HasCollisionDetection {}

class _TestBlock extends PositionComponent with HasHitboxes {
  late final HitboxRectangle hitbox;

  _TestBlock(Vector2 position, Vector2 size, CollidableType type)
      : super(position: position, size: size) {
    collidableType = type;
    add(hitbox = HitboxRectangle());
  }

  bool collidedWithExactly(List<Collidable> collidables) {
    final otherCollidables = collidables.toSet()..remove(this);
    return activeCollisions.containsAll(otherCollidables) &&
        otherCollidables.containsAll(activeCollisions);
  }
}

void main() {
  final withCollidables = FlameTester(() => _HasCollidablesGame());

  group('Varying CollisionType', () {
    withCollidables.test('actives do collide', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.active,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollision(blockB), true);
      expect(blockB.activeCollision(blockA), true);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
    });

    withCollidables.test('sensors do not collide', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.passive,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.passive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.isEmpty, true);
      expect(blockB.activeCollisions.isEmpty, true);
    });

    withCollidables.test('inactives do not collide', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.inactive,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.inactive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.isEmpty, true);
      expect(blockB.activeCollisions.isEmpty, true);
    });

    withCollidables.test('active collides with static', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.passive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollision(blockB), true);
      expect(blockB.activeCollision(blockA), true);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
    });

    withCollidables.test('sensor collides with active', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.passive,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.active,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollision(blockB), true);
      expect(blockB.activeCollision(blockA), true);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
    });

    withCollidables.test('sensor does not collide with inactive', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.passive,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.inactive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
    });

    withCollidables.test('inactive does not collide with static', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.inactive,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.passive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
    });

    withCollidables.test('active does not collide with inactive', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.inactive,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
    });

    withCollidables.test('inactive does not collide with active', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.inactive,
      );
      final blockB = _TestBlock(
        Vector2.all(1),
        Vector2.all(10),
        CollidableType.active,
      );
      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
    });

    withCollidables.test(
      'correct collisions with many involved collidables',
      (game) async {
        final rng = Random(0);
        List<_TestBlock> generateBlocks(CollidableType type) {
          return List.generate(
            100,
            (_) => _TestBlock(
              Vector2.random(rng) - Vector2.random(rng),
              Vector2.all(10),
              type,
            ),
          );
        }

        final actives = generateBlocks(CollidableType.active);
        final passives = generateBlocks(CollidableType.passive);
        final inactives = generateBlocks(CollidableType.inactive);
        await game.ensureAddAll((actives + passives + inactives)..shuffle());
        game.update(0);
        expect(
          actives.every((c) => c.collidedWithExactly(actives + passives)),
          isTrue,
        );
        expect(passives.every((c) => c.collidedWithExactly(actives)), isTrue);
        expect(inactives.every((c) => c.activeCollisions.isEmpty), isTrue);
      },
    );

    withCollidables.test('detects collision after scale', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final blockB = _TestBlock(
        Vector2.all(11),
        Vector2.all(10),
        CollidableType.active,
      );
      expect(blockA.activeCollision(blockB), isFalse);
      await game.ensureAddAll([blockA, blockB]);
      expect(blockA.activeCollision(blockB), isFalse);
      game.update(0);
      print(blockA.intersections(blockB));
      print(game.collisionDetection.items);
      print(blockA.absoluteTopLeftPosition);
      print(blockB.absoluteTopLeftPosition);
      print(blockA.hitbox.absoluteTopLeftPosition);
      print(blockB.hitbox.absoluteTopLeftPosition);
      print(blockA.hitbox.size);
      print(blockB.hitbox.size);
      print(blockA.hitbox.vertices);
      expect(blockA.activeCollision(blockB), isFalse);
      expect(blockB.activeCollision(blockA), isFalse);
      expect(blockA.activeCollisions.length, 0);
      expect(blockB.activeCollisions.length, 0);
      blockA.scale = Vector2.all(2.0);
      game.update(0);
      expect(blockA.activeCollision(blockB), isTrue);
      expect(blockB.activeCollision(blockA), isTrue);
      expect(blockA.activeCollisions.length, 1);
      expect(blockB.activeCollisions.length, 1);
    });

    withCollidables.test('testPoint detects point after scale', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      await game.ensureAdd(blockA);
      game.update(0);
      expect(blockA.containsPoint(Vector2.all(11)), false);
      blockA.scale = Vector2.all(2.0);
      game.update(0);
      expect(blockA.containsPoint(Vector2.all(11)), true);
    });

    withCollidables.test('detects collision on child components', (game) async {
      final blockA = _TestBlock(
        Vector2.zero(),
        Vector2.all(10),
        CollidableType.active,
      );
      final innerBlockA = _TestBlock(
        blockA.size / 4,
        blockA.size / 2,
        CollidableType.active,
      );
      blockA.add(innerBlockA);

      final blockB = _TestBlock(
        Vector2.all(5),
        Vector2.all(10),
        CollidableType.active,
      );
      final innerBlockB = _TestBlock(
        blockA.size / 4,
        blockA.size / 2,
        CollidableType.active,
      );
      blockB.add(innerBlockB);

      await game.ensureAddAll([blockA, blockB]);
      game.update(0);
      expect(blockA.activeCollisions, {blockB, innerBlockB});
      expect(blockB.activeCollisions, {blockA, innerBlockA});
      expect(innerBlockA.activeCollisions, {blockB, innerBlockB});
      expect(innerBlockB.activeCollisions, {blockA, innerBlockA});
    });
  });
}