import 'dart:async';
import 'package:alantasdotdev/VerticalTabs.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final sink = StreamController<double>();
final pager = PageController();

void main() {
  runApp(
    MaterialApp(
      home: PageViewLab(),
    ),
  );
}

class PageViewLab extends StatefulWidget {
  @override
  _PageViewLabState createState() => _PageViewLabState();
}

class _PageViewLabState extends State<PageViewLab> {

  @override
  void initState() {
    super.initState();
    throttle(sink.stream).listen((offset) {
      pager.animateTo(
        offset,
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      );
    });
  }

  @override
  void dispose() {
    sink.close();
    pager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Listener(
          onPointerSignal: _handlePointerSignal,
          child: _IgnorePointerSignal(
            child: Home()),
        ),
      ),
    );
  }

  Stream<double> throttle(Stream<double> src) async* {
    double offset = pager.position.pixels;
    DateTime dt = DateTime.now();
    await for (var delta in src) {
      if (DateTime.now().difference(dt) > Duration(milliseconds: 200)) {
        offset = pager.position.pixels;
      }
      dt = DateTime.now();
      offset += delta;
      yield offset;
    }
  }

  void _handlePointerSignal(PointerSignalEvent e) {
    if (e is PointerScrollEvent && e.scrollDelta.dy != 0) {
      sink.add(e.scrollDelta.dy);
    }
  }
}

// workaround https://github.com/flutter/flutter/issues/35723
class _IgnorePointerSignal extends SingleChildRenderObjectWidget {
  _IgnorePointerSignal({Key key, Widget child}) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(_) => _IgnorePointerSignalRenderObject();
}

class _IgnorePointerSignalRenderObject extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {Offset position}) {
    final res = super.hitTest(result, position: position);
    result.path.forEach((item) {
      final target = item.target;
      if (target is RenderPointerListener) {
        target.onPointerSignal = null;
      }
    });
    return res;
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: VerticalTabs(pager: pager,
                    contentScrollAxis: Axis.vertical,
                    tabsWidth: 150,
                    tabs: <Tab>[
                      Tab(child: Text('Sobre'), icon: Icon(Icons.phone)),
                      Tab(child: Text('Experiencia')),
                      Tab(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 1),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.favorite),
                              SizedBox(width: 25),
                              Text('Projetos'),
                            ],
                          ),
                        ),
                      ),
                      Tab(child: Text('Habilidades')),
                      Tab(child: Text('Publicações')),
                      Tab(child: Text('Contato')),
                      Tab(child: Text('Currículo')),
                    ],
                    contents: <Widget>[
                      tabsContent('Flutter', 'Change page by scrolling content is disabled in settings. Changing contents pages is only available via tapping on tabs'),
                      tabsContent('Dart'),
                      tabsContent('Javascript'),
                      tabsContent('NodeJS'),
                      Container(
                          color: Colors.black12,
                          child: ListView.builder(
                              itemCount: 10,
                              itemExtent: 100,
                              itemBuilder: (context, index){
                                return Container(
                                  margin: EdgeInsets.all(10),
                                  color: Colors.white30,
                                );
                              })
                      ),
                      tabsContent('HTML 5'),
                      Container(
                          color: Colors.black12,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 10,
                              itemExtent: 100,
                              itemBuilder: (context, index){
                                return Container(
                                  margin: EdgeInsets.all(10),
                                  color: Colors.white30,
                                );
                              })
                      ),
                    ],
                  ),

                ),
              ),

            ],
          );
  }

  Widget tabsContent(String caption, [ String description = '' ] ) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      color: Colors.black12,
      child: Column(
        children: <Widget>[
          Text(
            caption,
            style: TextStyle(fontSize: 25),
          ),
          Divider(height: 20, color: Colors.black45,),
          Text(
            description,
            style: TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

