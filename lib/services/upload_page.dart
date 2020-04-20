import 'package:Petti/utils/utils.dart';
import 'package:dio/dio.dart';


Future<int> uploadImageService(var imageFile) async {
  var dio = Dio();
  String fileName = imageFile.path.split('/').last;
  FormData formData = FormData.fromMap({
    "photo": await MultipartFile.fromFile(imageFile.path, filename:fileName),
    "title": "test"
  });
  final headers = await getHeaders();
  final response = await dio.post(
      'http://$DOMAIN/api/v1/mascotas/imagenes/',
      data: formData,
      options: Options(
          headers: headers
      )
  );
  final id = response.data['id'];
  return id;
}

Future<int> postToFireStoreService({int mediaUrl, String location, String description,
  String section}) async {
  var dio = Dio();
  String _action;
  switch(section){
    case 'Adopción y perdidos':
      _action = 'adopcion';
      break;
    case 'Compra y venta':
      _action = 'compraventa';
      break;
    case 'Coupet':
      _action = 'parejas';
      break;
  }
  Map t = {
    "location": location,
    "media_url": mediaUrl,
    "description": description,
    "tag": _action,
  };
  print(t);
  FormData formData = FormData.fromMap({
    "location": location,
    "media_url": mediaUrl,
    "description": description,
    "tag": _action,
  });
  final headers = await getHeaders();
  final response = await dio.post(
      'http://$DOMAIN/api/v1/mascotas/publicaciones/',
      data: formData,
      options: Options(
        headers: headers
      )
  );
 return response.statusCode;
}