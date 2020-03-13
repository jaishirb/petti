import 'dart:convert';
import 'dart:io';

import 'package:Petti/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Card {
  final String id;
  final String name;
  final String location;
  final String distance;
  final String gravity;
  final String description;
  final String image;
  final String picture;

  const Card({this.id, this.name, this.location, this.distance, this.gravity,
    this.description, this.image, this.picture});
}

Future<List<Card>>getCards() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // var url = 'https://us-central1-petti-7933f.cloudfunctions.net/getFeed?uid=' + userId;
  var url = 'http://$DOMAIN/api/v1/mascotas/veterinarias';
  var httpClient = HttpClient();

  List<Card> cards;
  String result;
  try {
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    if (response.statusCode == HttpStatus.ok) {
      String json = await response.transform(utf8.decoder).join();
      print(jsonDecode(json));
      Map<String, dynamic> data = jsonDecode(json);
      cards = _generateCards(data['results']);
      result = "Success in http request for feed";
    } else {
      result =
      'Error getting a feed: Http status ${response.statusCode}';
    }
  } catch (exception) {
    result = 'Failed invoking the getFeed function. Exception: $exception';
  }
  print(result);
  return cards;
}


Card fromJson(Map data){
  return Card(
    id: data['id'].toString(),
    name: data['nombre'],
    location: data['servicio'],
    distance: data['direccion'],
    gravity: data['precio_read'] + ' cop',
    description: data['comentarios'],
    image: data['foto'],
    picture: data['background'],
  );
}
List<Card> _generateCards(List<dynamic> feedData) {
  List<Card> cards = [];

  for (var postData in feedData) {
    print(postData);
    cards.add(fromJson(postData));
  }

  return cards;
}


List<Card> cards = getCards() as List<Card>;