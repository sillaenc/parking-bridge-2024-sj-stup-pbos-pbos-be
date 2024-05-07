import 'dart:convert';
// import 'package:drift/drift.dart';
import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf_io.dart' as io;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import '../data/manage_address.dart'; // json 처리

String fileDirectory = 'file';

String getExtensionFromContentDisposition(String contentDisposition) {
  final regex = RegExp(r'filename="[^"]+\.(\w+)"');
  final match = regex.firstMatch(contentDisposition);
  if (match != null) {
    return match.group(1)!;
  } else {
    return '';
  }
}

class SettingsParkingArea {
  ManageAddress manageAddress = ManageAddress();
  SettingsParkingArea(this.manageAddress);
  Router get router {
    final router = Router();

    String? url = manageAddress.displayDbAddr;
    var header = {'Content-Type': 'application/json'};
    var headers = {'Content-Type': 'multipart/form-data'};
    router.get('/', (Request request) async {
      var body = {
        "transaction": [
          {"query": "SELECT * FROM tb_parking_zone"}
        ]
      };
      var response = await http.post(
        Uri.parse(url!),
        headers: header,
        body: jsonEncode(body),
      );
      var db = jsonDecode(utf8.decode(response.bodyBytes));
      var dbSet = db['results'][0]['resultSet'];
      var info = jsonEncode(dbSet);
      print(info);
      return Response.ok(info);
    });

    router.post('/insertFile', (Request request) async {
      String? fileName;
      String? filePath;
      if (!request.isMultipart) {
        return Response.badRequest(body: 'bad request');
      }
      await for (final part in request.parts) {
        final headers = part.headers['content-disposition'] ?? '';
        if (headers.contains('name="filename"')) {
          fileName = await part.readString();
          fileName = p.basename(fileName);
        } else if (headers.contains('name="file"')) {
          final content = await part.readBytes();
          final extension = getExtensionFromContentDisposition(headers);
          print('extension: $extension');
          File file = await File('$fileDirectory/$fileName.$extension').create();
          filePath = '$fileDirectory/$fileName.$extension';
          file.writeAsBytesSync(content);
        }
      }
      print(filePath);
      print(fileName);
      if (fileName != null && filePath != null) {
        var body = {
          "transaction": [
            {
              "query": "INSERT INTO tb_parking_zone (parking_name, file_address) VALUES (:parking_name, :file_address)",
              "values": {"parking_name": fileName, "file_address": filePath}
            },
          ]
        };
        await http.post(
          Uri.parse(url!),
          headers: header,
          body: jsonEncode(body),
        );
        return Response.ok('File uploaded and saved to database');
      } else {
        return Response.internalServerError(body: 'File upload failed');
      }
    });

    router.post('/deleteFile', (Request request) async {
      var requestBody = await request.readAsString();
      var requestData = jsonDecode(requestBody);

      var filename = requestData['filename'];
      try {
        var body = {
          "transaction": [
            {
              "query": "DELETE FROM tb_parking_zone WHERE parking_name = :parking_name",
              "values": {"parking_name": filename}
            },
          ]
        };
        await http.post(
          Uri.parse(url!),
          headers: header,
          body: jsonEncode(body),
        );
        return Response.ok("delete success");
      } catch (e, stackTrace) {
        print('Error: $e');
        print('StackTrace: $stackTrace');
        return Response.internalServerError(body: 'Error: $e');
      }
    });

    router.post('/UpdateFile', (Request request) async {
      String? fileName;
      String? filePath;
      String? beforeName;
      var body = {
        "transaction": [
          {"query": "SELECT * FROM tb_parking_zone"}
        ]
      };
      var response = await http.post(
        Uri.parse(url!),
        headers: header,
        body: jsonEncode(body),
      );
      var db = jsonDecode(utf8.decode(response.bodyBytes));
      var dbSet = db['results'][0]['resultSet'];
      print(dbSet);
      if (!request.isMultipart) {
        return Response.badRequest(body: 'bad request');
      }
      await for (final part in request.parts) {
        final headers = part.headers['content-disposition'] ?? '';
        if (headers.contains('name="filename"')) {
          fileName = await part.readString();
          fileName = p.basename(fileName);
        }else if(headers.contains('name="beforeName"')){
          beforeName = await part.readString();
          beforeName = p.basename(beforeName);
        } else if (headers.contains('name="file"')) {
          final content = await part.readBytes();
          final extension = getExtensionFromContentDisposition(headers);
          print('extension: $extension');

          File file = await File('$fileDirectory/$fileName.$extension').create();
          filePath = '$fileDirectory/$fileName.$extension';
          file.writeAsBytesSync(content);
        }
      }
      print(filePath);
      print(fileName);
      print(beforeName);
      print(dbSet);
      for(var item in dbSet){
        if(item['filename'] == fileName){
          return Response.ok('UpDate Complete');
        }
      }
      if (fileName != null && filePath != null) {
        var body = {
          "transaction": [
            {
              "query": "INSERT INTO tb_parking_zone (parking_name, file_address) VALUES (:parking_name, :file_address)",
              "values": {"parking_name": fileName, "file_address": filePath}
            },
          ]
        };
        await http.post(
          Uri.parse(url),
          headers: header,
          body: jsonEncode(body),
        );
        var body2 = {
          "transaction": [
            {
              "query": "DELETE FROM tb_parking_zone WHERE parking_name = :parking_name",
              "values": {"parking_name": beforeName}
            },
          ]
        };
        await http.post(
          Uri.parse(url),
          headers: header,
          body: jsonEncode(body2),
        );
        return Response.ok('File uploaded and saved to database');
      } else {
        return Response.internalServerError(body: 'File upload failed');
      }
    });

    return router;
  }
}
