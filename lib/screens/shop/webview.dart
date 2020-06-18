import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';


class WebViewContainer extends StatefulWidget {
  final url;

  WebViewContainer(this.url);

  @override
  createState() => _WebViewContainerState(this.url);
}

class _WebViewContainerState extends State<WebViewContainer> {
  var _url;
  final _key = UniqueKey();
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  _WebViewContainerState(this._url);


  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
        url: _url,
        mediaPlaybackRequiresUserGesture: false,
        appBar: AppBar(
          title: Text('Pagos',
              style: const TextStyle(
                  fontFamily: "Billabong",
                  color: Color.fromRGBO(28, 96, 97, 1.0),
                  fontSize: 35.0)),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        withZoom: true,
        withLocalStorage: true,
        hidden: true,
        initialChild: Container(
          color: Colors.white,
          child: const Center(
            child: Text('Cargando...'),
          ),
        ),
    );
  }
}
