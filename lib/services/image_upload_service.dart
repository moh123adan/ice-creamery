import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageUploadService {
  final String _imgbbApiKey =
      '45a7b0069a5542187628a448ca0ea525'; // Your ImgBB API key

  Future<String?> uploadImageToImgBB(File imageFile) async {
    try {
      final uri = Uri.parse('https://api.imgbb.com/1/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['key'] = _imgbbApiKey
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonData = json.decode(responseString);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        final imageUrl = jsonData['data']['url'];
        print('Image uploaded successfully to ImgBB. URL: $imageUrl');
        return imageUrl;
      } else {
        print('Failed to upload image to ImgBB');
        return null;
      }
    } catch (e) {
      print('Error uploading image to ImgBB: $e');
      return null;
    }
  }
}
