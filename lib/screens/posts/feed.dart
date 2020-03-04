import 'package:Petti/screens/posts/upload_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'image_post.dart';
import 'dart:async';
import 'main.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Feed extends StatefulWidget {
  _Feed createState() => _Feed();
}

class _Feed extends State<Feed> with AutomaticKeepAliveClientMixin<Feed> {
  List<ImagePost> feedData;
  PageController pageController;
  int _page = 0;

  @override
  void initState() {
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
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // reloads state when opened again

    return Scaffold(
      appBar: AppBar(
        title: const Text('Petti posts',
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
    /**
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String json = prefs.getString("feed");
    if (json != null) {
      Map<String, dynamic> data = jsonDecode(json);
      List<ImagePost> listOfPosts = _generateFeed(data['results']);
      setState(() {
        feedData = listOfPosts;
      });
    } else {
      _getFeed();
    }
        **/
  }

  _getFeed() async {
    print("Staring getFeed");

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // var url = 'https://us-central1-petti-7933f.cloudfunctions.net/getFeed?uid=' + userId;
    var url = 'http://75.2.0.131/petti/api/v1/mascotas/publicaciones';
    var httpClient = HttpClient();

    List<ImagePost> listOfPosts;
    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String json = await response.transform(utf8.decoder).join();
        prefs.setString("feed", json);
        print(jsonDecode(json));
        Map<String, dynamic> data = jsonDecode(json);
        listOfPosts = _generateFeed(data['results']);
        result = "Success in http request for feed";
      } else {
        result =
            'Error getting a feed: Http status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'Failed invoking the getFeed function. Exception: $exception';
    }
    print(result);

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
