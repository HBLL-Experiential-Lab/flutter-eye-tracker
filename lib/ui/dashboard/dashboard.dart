import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_eye_tracker/ui/routers/dashboard_router.gr.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_eye_tracker/backend/session/session_bloc.dart';
import 'package:flutter_eye_tracker/backend/tcp_server.dart';
import 'package:flutter_eye_tracker/model/session.dart';
import 'package:flutter_eye_tracker/ui/theme.dart';
import 'package:tinycolor/tinycolor.dart';

class Dashboard extends StatefulWidget {
  final Session session;

  const Dashboard({Key key, this.session}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  GlobalKey _navKey = GlobalKey();
  ChangeRouteObserver routeObserver;
  DashboardController _controller;

  @override
  void initState() {
    super.initState();
    context.read<SessionBloc>().add(SessionEventLoad(widget.session));
    routeObserver = ChangeRouteObserver(onPathChanged: (val) {
      if (_controller != null) {
        _controller.updatePath(val);
      }
    });
  }

  Widget _loading() {
    return Center(
      child: SpinKitDoubleBounce(
        color: Theming.navy,
        size: 50.0,
      ),
    );
  }

  Widget _failed() {
    return Center(
      child: Icon(Icons.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _topBar = SizedBox(
      width: double.infinity,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FlatButton(
              onPressed: () {
                TCPServer.stop();
                Navigator.pop(context);
              },
              child: Text("Close"))
        ],
      ),
    );
    return Scaffold(body: BlocBuilder<SessionBloc, SessionState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case SessionStateFailed:
            return _failed();
          case SessionStateDone:
            var _routes = [
              DashboardRoute(title: "Live", icon: Icons.visibility, path: "/"),
              DashboardRoute(title: "Runs", icon: Icons.dns, path: "/runs"),
              DashboardRoute(
                  title: "Calibrate",
                  icon: Icons.calculate,
                  path: "/calibration"),
            ];
            return Container(
              color: Theming.background_blue_grey,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Row(
                    children: [
                      DashboardNavigator(
                        pages: _routes,
                        onCreate: (val) => {_controller = val},
                        key: UniqueKey(),
                        onPageTapped: (path) =>
                            (_navKey.currentState as ExtendedNavigatorState)
                                .popAndPush(path),
                      ),
                      Expanded(
                          child: Column(
                        children: [
                          _topBar,
                          Expanded(
                            child: ExtendedNavigator(
                              key: _navKey,
                              observers: [routeObserver],
                              router: DashboardRouter(),
                            ),
                          )
                        ],
                      ))
                    ],
                  )),
            );
          default:
            return _loading();
        }
      },
    ));
  }
}

class DashboardController {
  final ValueChanged<String> updatePath;

  DashboardController(this.updatePath);
}

class DashboardPageViewer extends StatefulWidget {
  final DashboardPage page;

  const DashboardPageViewer({Key key, this.page}) : super(key: key);

  @override
  _DashboardPageViewerState createState() => _DashboardPageViewerState();
}

class _DashboardPageViewerState extends State<DashboardPageViewer> {
  double _getHeight(DashboardSize size) {
    switch (size) {
      case DashboardSize.Small:
        return 200.0;
      case DashboardSize.Medium:
        return 350.0;
      case DashboardSize.Large:
        return 500.0;
    }
  }

  Widget _entry(DashboardEntry entry) {
    return Expanded(
      child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {},
            child: Column(
              children: [
                if (entry.title != null)
                  ListTile(
                    title: Text(entry.title),
                    subtitle:
                        entry.subtitle != null ? Text(entry.subtitle) : null,
                  ),
                Expanded(child: entry.child)
              ],
            ),
          )),
      flex: entry.flex,
    );
  }

  Widget _row(DashboardRow row) {
    return Center(
      child: SizedBox(
        height: _getHeight(row.size),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: row.entries.map((e) => _entry(e)).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();
    return widget.page.rows != null && widget.page.rows.isNotEmpty
        ? Scrollbar(
            isAlwaysShown: true,
            controller: _scrollController,
            child: ListView(
              controller: _scrollController,
              children: widget.page.rows.map((e) => _row(e)).toList(),
            ),
          )
        : Center(
            child: Text("Nothing is here :("),
          );
  }
}

class DashboardNavigator extends StatefulWidget {
  final List<DashboardRoute> pages;
  final ValueChanged<String> onPageTapped;
  final ValueChanged<DashboardController> onCreate;

  const DashboardNavigator(
      {Key key, this.pages, this.onPageTapped, this.onCreate})
      : super(key: key);

  @override
  _DashboardNavigatorState createState() => _DashboardNavigatorState();
}

class _DashboardNavigatorState extends State<DashboardNavigator> {
  String route = "/";
  Widget _pages(List<Widget> children) {
    return Expanded(
      child: ListView(
        children: [...children],
      ),
    );
  }

  bool _same(String route, String path) {
    if (path.length < route.length) {
      String sub = route.substring(0, path.length);
      return sub == route;
    } else {
      String sub = path.substring(0, route.length);
      return sub == path;
    }
  }

  Widget _page(BuildContext context, DashboardRoute page) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 2.0, bottom: 2.0, left: 6.0, right: 2),
      child: Material(
        elevation: _same(route, page.path) ? 2.0 : 0,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: Theming.royal,
          onTap: () {
            widget.onPageTapped(page.path);
          },
          child: Container(
            color: _same(route, page.path)
                ? TinyColor(Theming.background_blue_grey).darken(10).color
                : Colors.transparent,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
              child: Row(
                children: [
                  Icon(
                    page.icon,
                    size: 18,
                    color:
                        _same(route, page.path) ? Theming.royal : Theming.navy,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      page.title,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: _same(route, page.path)
                              ? Theming.royal
                              : Theming.navy),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    widget.onCreate(DashboardController((value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          route = value;
        });
      });
    }));
    var _heading = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.asset(
                    "assets/icon_24_24.png",
                    width: 15,
                    height: 15,
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("Eye Tracker",
                  style: Theme.of(context).textTheme.headline6),
            ),
          ],
        ));

    return SizedBox(
      width: 250,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading,
          _pages(widget.pages.map((page) => _page(context, page)).toList())
        ],
      ),
    );
  }
}

class DashboardPage {
  @required
  final String title;
  final IconData icon;
  final List<DashboardRow> rows;

  DashboardPage({this.title, this.icon, this.rows});
}

class DashboardRow {
  final List<DashboardEntry> entries;
  final DashboardSize size;

  DashboardRow({this.entries, this.size = DashboardSize.Small});
}

class DashboardEntry {
  final Widget child;
  final int flex;
  final String title;
  final String subtitle;

  DashboardEntry(
      {@required this.child, this.title, this.subtitle, this.flex = 1});
}

enum DashboardSize { Small, Medium, Large }

class DashboardRoute {
  final String title;
  final IconData icon;
  final String path;

  DashboardRoute({this.title, this.icon, this.path});
}

class ChangeRouteObserver extends NavigatorObserver {
  final ValueChanged<String> onPathChanged;

  ChangeRouteObserver({this.onPathChanged});

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    if (onPathChanged != null) onPathChanged(route.settings.name);
  }
}
