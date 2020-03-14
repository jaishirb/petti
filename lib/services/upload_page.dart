import 'package:Petti/utils/utils.dart';
import 'package:dio/dio.dart';


Future<int> uploadImage(var imageFile) async {
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

Future<int> postToFireStore({int mediaUrl, String location, String description}) async {
  var dio = Dio();
  FormData formData = FormData.fromMap({
    "location": location,
    "media_url": mediaUrl,
    "description": description,
  });
  final response = await dio.post('http://$DOMAIN/api/v1/mascotas/publicaciones/', data: formData);
 return response.statusCode;
}