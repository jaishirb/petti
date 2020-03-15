import 'package:Petti/utils/utils.dart';
import 'package:dio/dio.dart';


Future<int> uploadImageService(var imageFile) async {
  var dio = Dio();
  String fileName = imageFile.path.split('/').last;
  FormData formData = FormData.fromMap({
    "photo": await MultipartFile.fromFile(imageFile.path, filename:fileName),
    "title": "test"
  });
  final response = await dio.post('http://$DOMAIN/api/v1/mascotas/imagenes/', data: formData);
  final id = response.data['id'];
  return id;
}

Future<int> postToFireStoreService({int mediaUrl, String location, String description,
  String section}) async {
  var dio = Dio();
  String _action;
  switch(section){
    case 'Adopción':
      _action = 'adopcion';
      break;
    case 'Compra/venta':
      _action = 'compraventa';
      break;
    case 'Parejas':
      _action = 'parejas';
      break;
  }
  FormData formData = FormData.fromMap({
    "location": location,
    "media_url": mediaUrl,
    "description": description,
    "tag": _action,
  });
  final response = await dio.post('http://$DOMAIN/api/v1/mascotas/publicaciones/', data: formData);
 return response.statusCode;
}