import 'package:Petti/services/cards.dart';

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
  List<Card> cards;
  List<dynamic> data = await getDataCardsService();
  cards = _generateCards(data);
  return cards;
}


Card fromJson(Map data){
  return Card(
    id: data['id'].toString(),
    name: data['nombre_empresa'],
    location: data['nombre'],
    distance: data['direccion_empresa'],
    gravity: data['precio_read'] + ' cop',
    description: data['descripcion'],
    image: data['foto_empresa'],
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