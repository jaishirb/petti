import 'package:Petti/screens/posts/upload_page.dart';
import 'package:Petti/services/feed.dart';
import 'package:Petti/shared/shared_preferences_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'image_post.dart';
import 'dart:async';

class Feed extends StatefulWidget {
  final String title;
  Feed({this.title});
  _Feed createState() => _Feed(title: title);
}

class _Feed extends State<Feed> with AutomaticKeepAliveClientMixin<Feed> {
  final String title;
  _Feed({this.title});
  List<ImagePost> feedData;
  PageController pageController;
  int _page = 0;

  @override
  void initState() {
    SharedPreferencesHelper.setSection(title);
    super.initState();
    pageController = PageController();
    this._loadFeed();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  buildFeed() {
    if (feedData != null) {
      return ListView(
        children: feedData,
      );
    } else {
      return Container(
          alignment: FractionalOffset.center,
          child: CircularProgressIndicator());
    }
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
    _refresh();
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // reloads state when opened again
    return Scaffold(
      appBar: AppBar(
        title: Text('$title',
            style: const TextStyle(
                fontFamily: "Billabong", color: Color.fromRGBO(28, 96, 97, 1.0), fontSize: 35.0)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: PageView(
        children: [
          Container(
            color: Colors.white,
            child:  RefreshIndicator(
              onRefresh: _refresh,
              child: buildFeed(),
            ),
          ),
          Container(
            color: Colors.white,
            child: Uploader(),
          ),
        ],
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home,
                  color: (_page == 0) ? Color.fromRGBO(28, 96, 97, 1.0) : Color.fromRGBO(89, 192, 154, 1.0)),
              title: Container(height: 0.0),
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle,
                  color: (_page == 1) ? Color.fromRGBO(28, 96, 97, 1.0) : Color.fromRGBO(89, 192, 154, 1.0)),
              title: Container(height: 0.0),
              backgroundColor: Colors.white),
        ],
        onTap: navigationTapped,
        currentIndex: _page,
      ),
    );
  }

  Future<Null> _refresh() async {
    await _getFeed();

    setState(() {});

    return;
  }

  _loadFeed() async {
    _getFeed();
  }

  _getFeed() async {
    List<ImagePost> listOfPosts;
    List<dynamic> data = await getDataFeedService(title);
    listOfPosts = _generateFeed(data);
    setState(() {
      feedData = listOfPosts;
    });
  }

  List<ImagePost> _generateFeed(List<dynamic> feedData) {
    List<ImagePost> listOfPosts = [];
    for (var postData in feedData) {
      print(postData);
      listOfPosts.add(ImagePost.fromJSON(postData));
    }

    return listOfPosts;
  }

  // ensures state is kept when switching pages
  @override
  bool get wantKeepAlive => true;
}
