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
    _addCircle(Offset(512, 512));
    _addFloor();
  }

  World world;

  @override
  void update(double dt) {
    super.update(dt);
    world.stepDt(dt, 10, 10);
  }

  @override
  handleEvent(SpriteBoxEvent event) {
    if (event.type == PointerDownEvent) {
      Offset localPosition = convertPointToNodeSpace(event.boxPosition);
      _addCircle(localPosition);
    }
    return true;
  }

  void _addCircle(Offset position) {
    final PhysicsNode node = PhysicsNode()
      ..type = ShapeTypes.Circle
      ..radius = 30
      ..position = position;
    addChild(node);

    final CircleShape shape = CircleShape();
    shape.radius = 30;

    final FixtureDef fixtureDef = FixtureDef();
    fixtureDef.friction = 0.5;
    fixtureDef.restitution = 0.4;
    fixtureDef.density = 1;
    fixtureDef.shape = shape;

    final BodyDef bodyDef = BodyDef();
    bodyDef.linearVelocity = Vector2(0.0, 50.0);
    bodyDef.position = Vector2(node.position.dx, node.position.dy);
    bodyDef.type = BodyType.DYNAMIC;
    bodyDef.bullet = true;

    final Body body = world.createBody(bodyDef);
    body.createFixtureFromFixtureDef(fixtureDef);

    node.body = body;
  }

  void _addFloor() {
    final PhysicsNode node = PhysicsNode()
      ..type = ShapeTypes.Rect
      ..radius = 1024
      ..position = const Offset(512, 2000);
    addChild(node);

    final PolygonShape shape = PolygonShape();
    shape.setAsBoxXY(1024, 1024);

    final FixtureDef fixtureDef = FixtureDef();
    fixtureDef.friction = 0.5;
    fixtureDef.restitution = 0.4;
    fixtureDef.density = 1;
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
  ShapeTypes type;
  double radius;

  @override
  void update(double dt) {
    super.update(dt);
    position = Offset(body.position.x, body.position.y);
  }

  @override
  void paint(Canvas canvas) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;
    const Offset center = Offset.zero;
    Shapes(canvas: canvas, paint: paint, radius: radius, center: center)
        .drawType(type);
  }
}
