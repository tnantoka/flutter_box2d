import 'dart:math';
import 'package:flutter/material.dart';
import 'package:box2d_flame/box2d.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:flutter_shapes/flutter_shapes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Scene scene;

  @override
  void initState() {
    super.initState();

    scene = Scene(const Size(1024.0, 1024.0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SpriteWidget(scene),
    );
  }
}

class Scene extends NodeWithSize {
  Scene(Size size) : super(size) {
    userInteractionEnabled = true;
    world = World.withGravity(Vector2(0.0, 9.8));
    rand = Random();
    _addFloor();
  }

  World world;
  Random rand;

  @override
  void update(double dt) {
    super.update(dt);
    world.stepDt(dt, 10, 10);
  }

  @override
  bool handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerDownEvent) {
      final Offset localPosition =
          convertPointToNodeSpace(event.boxPosition).translate(0, 50);
      _addShape(localPosition);
    }
    return true;
  }

  void _addShape(Offset position) {
    final PhysicsNode node = PhysicsNode()
      ..type = Shapes.types[rand.nextInt(Shapes.types.length - 1)]
      ..radius = 30
      ..position = position;
    addChild(node);

    final CircleShape shape = CircleShape();
    shape.radius = node.radius * 0.95;

    final FixtureDef fixtureDef = FixtureDef();
    fixtureDef.friction = 0.5;
    fixtureDef.restitution = 0.1;
    fixtureDef.density = 10;
    fixtureDef.shape = shape;

    final BodyDef bodyDef = BodyDef();
    bodyDef.linearVelocity = Vector2(0.0, 200.0);
    bodyDef.position = Vector2(node.position.dx, node.position.dy);
    bodyDef.type = BodyType.DYNAMIC;
    bodyDef.bullet = true;

    final Body body = world.createBody(bodyDef);
    body.createFixtureFromFixtureDef(fixtureDef);

    node.body = body;
  }

  void _addFloor() {
    final PhysicsNode node = PhysicsNode()
      ..type = 'Rect'
      ..radius = 1024
      ..position = const Offset(512, 2000);
    addChild(node);

    final PolygonShape shape = PolygonShape();
    shape.setAsBoxXY(1024, 1024);

    final FixtureDef fixtureDef = FixtureDef();
    fixtureDef.friction = 0.5;
    fixtureDef.restitution = 0.2;
    fixtureDef.density = 10;
    fixtureDef.shape = shape;

    final BodyDef bodyDef = BodyDef();
    bodyDef.position = Vector2(node.position.dx, node.position.dy);
    bodyDef.type = BodyType.STATIC;
    bodyDef.bullet = true;

    final Body body = world.createBody(bodyDef);
    body.createFixtureFromFixtureDef(fixtureDef);

    node.body = body;
  }
}

class PhysicsNode extends Node {
  Body body;
  String type;
  double radius;
  double angle = 0;

  @override
  void update(double dt) {
    super.update(dt);
    position = Offset(body.position.x, body.position.y);
    angle = body.getAngle();
  }

  @override
  void paint(Canvas canvas) {
    final Paint fill = Paint()
      ..color = Colors.grey[300].withOpacity(0.7)
      ..style = PaintingStyle.fill;
    final Paint stroke = Paint()
      ..color = Colors.grey[700]
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    const Offset center = Offset.zero;
    final Shapes shapes =
        Shapes(canvas: canvas, radius: radius, center: center, angle: angle);
    for (Paint paint in <Paint>[fill, stroke]) {
      shapes
        ..paint = paint
        ..draw(type);
    }
  }
}
