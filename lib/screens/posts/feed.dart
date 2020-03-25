import 'package:Petti/screens/posts/upload_page.dart';
import 'package:Petti/services/feed.dart';
import 'package:Petti/shared/shared_preferences_helper.dart';
import 'package:Petti/utils/utils.dart';
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
  String next;
  bool first = true;
  ScrollController _scrollController = new ScrollController();
  PageView pageView;

  @override
  void initState() {
    SharedPreferencesHelper.setSection(title);
    super.initState();
    pageController = PageController();
    feedData = null;
    this._loadFeed(false);
    _scrollController.addListener((){
      if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent/2){
        this._loadFeed(true);
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  buildFeed() {

    if (feedData != null) {
      return ListView.builder(
        itemBuilder: (c, i) => feedData[i],
        controller: _scrollController,
        itemCount: feedData.length,
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
    //_refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // reloads state when opened again
    this.pageView = PageView(
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
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('$title',
            style: const TextStyle(
                fontFamily: "Billabong", color: Color.fromRGBO(28, 96, 97, 1.0), fontSize: 35.0)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: this.pageView,
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
    //feedData = new List<ImagePost>();
    feedData = null;
    await _getFeed(false);
    setState(() {});
    return;
  }

  _loadFeed(bool flag) async {
    _getFeed(flag);
  }

  _getFeed(bool flag) async {
    List<ImagePost> listOfPosts;
    String _action;
    switch(title){
      case 'Adopción':
        _action = 'adopcion';
        break;
      case 'Compra/venta/pérdida':
        _action = 'compraventa';
        break;
      case 'Coupet':
        _action = 'parejas';
        break;
    }
    String url;
    if(!flag){
      url = 'http://$DOMAIN/api/v1/mascotas/publicaciones/?action=$_action';
    }else{
      //print('loading next');
      url = next;
    }
    if(url != null){
      print(url);
      Map<String, dynamic> data = await getDataFeedService(title, url);
      List<dynamic> results = data['results'];
      listOfPosts = _generateFeed(results);
      if(!flag){
        feedData = new List<ImagePost>();
      }
      setState(() {
        feedData.addAll(listOfPosts);
      });
      next = data['next'];
    }
  }

  List<ImagePost> _generateFeed(List<dynamic> feedData) {
    List<ImagePost> listOfPosts = [];
    for (var postData in feedData) {
      listOfPosts.add(ImagePost.fromJSON(postData));
    }
    return listOfPosts;
  }

  // ensures state is kept when switching pages
  @override
  bool get wantKeepAlive => true;
}
