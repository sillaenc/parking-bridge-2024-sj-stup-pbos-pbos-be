import 'dart:convert';
import 'dart:typed_data';
// import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart' as p;

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
  final ManageAddress manageAddress;
  SettingsParkingArea({required this.manageAddress});
  Router get router {
    final router = Router();

    String? url = manageAddress.displayDbAddr;
    var header = {'Content-Type': 'application/json'};
    router.get('/', (Request request) async {
      var body = {
        "transaction": [
          {"statement": "#S_TbParkingZone"}
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
      File file;
      String? extension;
      Uint8List? content;
      if (!request.isMultipart) {
        return Response.badRequest(body: 'bad request');
      }
      await for (final part in request.parts) {
        final headers = part.headers['content-disposition'] ?? '';
        if (headers.contains('name="filename"')) {
          fileName = await part.readString();
          fileName = p.basename(fileName);
        } else if (headers.contains('name="file"')) {
          content = await part.readBytes();
          extension = getExtensionFromContentDisposition(headers);
        }
      }
      filePath = '$fileDirectory/$fileName.$extension';
      file = File(filePath);
      await file.create();
      file.writeAsBytesSync(content!);

      // if (fileName != resultSet[fileName] && filePath != resultSet[filePath]) {
      if (1==1) {
        var body = {
          "transaction": [
            {
              "statement": "#I_TbPakringZone",
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
        var find ={
          "transaction": [
            {
              "statement": "#S_TbPakringZoneName",
              "values": {"parking_name": filename}
            },
          ]
        };
        var result = await http.post(
          Uri.parse(url!),
          headers: header,
          body: jsonEncode(find),
        );
        var resultSet = jsonDecode(utf8.decode(result.bodyBytes));
        var isfind = resultSet['results'][0]['resultSet'];
        print(isfind[0]);
        File file = File(isfind[0]['file_address']);
        if(await file.exists()){
          await file.delete();
          print("파일 삭제 성공!!");
        }else {print("파일이 존재하지 않습니다!");}
        var body = {
          "transaction": [
            {
              "statement": "#D_TbPakringZoneName",
              "values": {"parking_name": filename}
            },
          ]
        };
        await http.post(
          Uri.parse(url),
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
      String? beforePath;
      String? beforeName;
      File file;
      String? extension;
      Uint8List? content;
      var body = {
        "transaction": [
          {"statement": "#S_TbParkingZone"}
        ]
      };
      var response = await http.post(
        Uri.parse(url!),
        headers: header,
        body: jsonEncode(body),
      );
      var db = jsonDecode(utf8.decode(response.bodyBytes));
      var dbSet = db['results'][0]['resultSet'];
      // print(dbSet);
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
          content = await part.readBytes();
          extension = getExtensionFromContentDisposition(headers);
          print('1extension: $extension');

          // File file = await File('$fileDirectory/$fileName.$extension').create();
          // filePath = '$fileDirectory/$fileName.$extension';
          // file.writeAsBytesSync(content);
        }
        
      }
      print('2extension : $extension');
      filePath = '$fileDirectory/$fileName.$extension';
      beforePath= '$fileDirectory/$beforeName.$extension';
      print(beforePath);
      file = File(filePath);
      File beforefile = File(beforePath);
      await file.create();
      file.writeAsBytesSync(content!);
      if(await beforefile.exists()){
        await beforefile.delete();
        print("파일 삭제 성공!!");
      }else {print("파일이 이미 존재하지 않습니다!");}
      
      print('filePath : $filePath');
      print("fileName : $fileName");
      print('beforeName : $beforeName');
      print('dbSet : $dbSet');
      for(var item in dbSet){
        if(item['filename'] == fileName){
          return Response.ok('UpDate Complete');
        }
      }
      // if (fileName != null && filePath != null) {
      if (1==1) {
        var body = {
          "transaction": [
            {
              "statement": "#I_TbPakringZone",
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
              "statement": "#D_TbPakringZoneName",
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
