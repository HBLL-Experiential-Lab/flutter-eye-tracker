import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unity_eye_tracker/backend/tcp_server.dart';
import 'package:unity_eye_tracker/model/session.dart';
import 'package:unity_eye_tracker/ui/dashboard/live/live_gaze_data.dart';
import 'package:unity_eye_tracker/ui/theme.dart';
import 'package:tinycolor/tinycolor.dart';

class Dashboard extends StatefulWidget {
  final Session session;

  const Dashboard({Key key, this.session}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _pageIndex = 0;
  PageController _controller;

  final _pageDuration = Duration(milliseconds: 300);
  final _pageCurve = Curves.easeInOut;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _controller.addListener(() {
      setState(() {
        _pageIndex = _controller.page.round();
      });
    });
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

    var _pages = [
      DashboardPage(title: "Live", icon: Icons.visibility, rows: [
        DashboardRow(entries: [
          DashboardEntry(title: "Controls", child: Text("another"), flex: 1)
        ]),
        DashboardRow(size: DashboardSize.Large, entries: [
          DashboardEntry(
              title: "Live Gaze Data",
              flex: 2,
              child: LiveGazeData(
                session: widget.session,
              )),
        ])
      ]),
      DashboardPage(title: "Runs", icon: Icons.dns),
      DashboardPage(title: "Calibrate", icon: Icons.calculate),
    ];

    return Scaffold(
      body: Container(
        color: Theming.background_blue_grey,
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Row(
              children: [
                DashboardNavigator(
                  pages: _pages,
                  currentIndex: _pageIndex,
                  key: UniqueKey(),
                  onPageTapped: (i) => _controller.animateToPage(i,
                      duration: _pageDuration, curve: _pageCurve),
                ),
                Expanded(
                    child: Column(
                  children: [
                    _topBar,
                    Expanded(
                        child: PageView(
                      controller: _controller,
                      scrollDirection: Axis.vertical,
                      children: _pages
                          .map((page) => DashboardPageViewer(page: page))
                          .toList(),
                    ))
                  ],
                ))
              ],
            )),
      ),
    );
  }
}

class DashboardPageViewer extends StatelessWidget {
  final DashboardPage page;

  const DashboardPageViewer({Key key, this.page}) : super(key: key);

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
    return page.rows != null && page.rows.isNotEmpty
        ? ListView(
            children: page.rows.map((e) => _row(e)).toList(),
          )
        : Center(
            child: Text("Nothing is here :("),
          );
  }
}

class DashboardNavigator extends StatelessWidget {
  final List<DashboardPage> pages;
  final int currentIndex;
  final ValueChanged<int> onPageTapped;

  const DashboardNavigator(
      {Key key, this.pages, this.currentIndex, this.onPageTapped})
      : super(key: key);

  Widget _pages(List<Widget> children) {
    return Expanded(
      child: ListView(
        children: [...children],
      ),
    );
  }

  Widget _page(BuildContext context, DashboardPage page, int index) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Material(
        elevation: currentIndex == index ? 2.0 : 0,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: Theming.royal,
          onTap: () {
            onPageTapped(index);
          },
          child: Container(
            color: currentIndex == index
                ? TinyColor(Theming.background_blue_grey).darken(10).color
                : Colors.transparent,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    page.icon,
                    size: 18,
                    color: currentIndex == index ? Theming.royal : Theming.navy,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      page.title,
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                          color: currentIndex == index
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
          _pages(pages
              .map((page) => _page(context, page, pages.indexOf(page)))
              .toList())
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
