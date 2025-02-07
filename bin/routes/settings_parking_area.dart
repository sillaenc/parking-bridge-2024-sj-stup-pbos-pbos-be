import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:path/path.dart' as p;
import '../data/db.dart';
import '../data/manage_address.dart';

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
    
    // GET: 주차 구역 조회 (쿼리 "S_TbParkingZone")
    router.get('/', (Request request) async {
      try {
        final db = await Database.getInstance();
        List<Map<String, dynamic>> resultSet = await db.query("S_TbParkingZone");
        String info = jsonEncode(resultSet);
        return Response.ok(info, headers: {'Content-Type': 'application/json'});
      } catch (e, st) {
        print('Error in SettingsParkingArea GET: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /insertFile: 파일 업로드 후 DB 기록 (쿼리 "I_TbPakringZone")
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
        final disposition = part.headers['content-disposition'] ?? '';
        if (disposition.contains('name="filename"')) {
          fileName = await part.readString();
          fileName = p.basename(fileName);
        } else if (disposition.contains('name="file"')) {
          content = await part.readBytes();
          extension = getExtensionFromContentDisposition(disposition);
        }
      }
      filePath = '$fileDirectory/$fileName.$extension';
      file = File(filePath);
      await file.create(recursive: true);
      file.writeAsBytesSync(content!);
      
      final db = await Database.getInstance();
      await db.query("I_TbPakringZone", {"parking_name": fileName, "file_address": filePath});
      return Response.ok('File uploaded and saved to database');
    });
    
    // POST /deleteFile: 파일 삭제 및 DB 기록 삭제 (쿼리 "S_TbPakringZoneName" & "D_TbPakringZoneName")
    router.post('/deleteFile', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        var filename = requestData['filename'];
        
        final db = await Database.getInstance();
        List<Map<String, dynamic>> findResult = await db.query("S_TbPakringZoneName", {"parking_name": filename});
        if (findResult.isEmpty) {
          return Response.internalServerError(body: 'File not found in DB');
        }
        String fileAddress = findResult.first['file_address'];
        File file = File(fileAddress);
        if (await file.exists()) {
          await file.delete();
          print("파일 삭제 성공!!");
        } else {
          print("파일이 존재하지 않습니다!");
        }
        await db.query("D_TbPakringZoneName", {"parking_name": filename});
        return Response.ok("delete success");
      } catch (e, st) {
        print('Error in SettingsParkingArea deleteFile: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /UpdateFile: 파일 업데이트 (쿼리 "I_TbPakringZone" 삽입 & "D_TbPakringZoneName" 삭제)
    router.post('/UpdateFile', (Request request) async {
      String? fileName;
      String? filePath;
      String? beforeName;
      String? beforePath;
      File file;
      String? extension;
      Uint8List? content;
      
      final db = await Database.getInstance();
      List<Map<String, dynamic>> dbSet = await db.query("S_TbParkingZone");
      
      if (!request.isMultipart) {
        return Response.badRequest(body: 'bad request');
      }
      await for (final part in request.parts) {
        final disposition = part.headers['content-disposition'] ?? '';
        if (disposition.contains('name="filename"')) {
          fileName = await part.readString();
          fileName = p.basename(fileName);
        } else if (disposition.contains('name="beforeName"')) {
          beforeName = await part.readString();
          beforeName = p.basename(beforeName);
        } else if (disposition.contains('name="file"')) {
          content = await part.readBytes();
          extension = getExtensionFromContentDisposition(disposition);
          print('extension: $extension');
        }
      }
      print('extension: $extension');
      filePath = '$fileDirectory/$fileName.$extension';
      beforePath = '$fileDirectory/$beforeName.$extension';
      print('beforePath: $beforePath');
      file = File(filePath);
      File beforefile = File(beforePath);
      await file.create(recursive: true);
      file.writeAsBytesSync(content!);
      if (await beforefile.exists()) {
        await beforefile.delete();
        print("파일 삭제 성공!!");
      } else {
        print("파일이 이미 존재하지 않습니다!");
      }
      print('filePath: $filePath');
      print("fileName: $fileName");
      print('beforeName: $beforeName');
      print('dbSet: $dbSet');
      bool found = false;
      for (var item in dbSet) {
        if (item['filename'] == fileName) {
          found = true;
          break;
        }
      }
      if (found) {
        return Response.ok('UpDate Complete');
      } else {
        await db.query("I_TbPakringZone", {"parking_name": fileName, "file_address": filePath});
        await db.query("D_TbPakringZoneName", {"parking_name": beforeName});
        return Response.ok('File uploaded and saved to database');
      }
    });
    
    // POST /ChangeLotType: 차종 변경 (쿼리 "U_LotType")
    router.post('/ChangeLotType', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        int lotType = requestData['lot_type'];
        String changedTag = requestData['changed_tag'];
        String tag = requestData['tag'];
        final db = await Database.getInstance();
        await db.query("U_LotType", {"changed_tag": changedTag, "tag": tag, "lot_type": lotType});
        return Response.ok("차종 변경완료");
      } catch (e, st) {
        print('Error in SettingsParkingArea ChangeLotType: $e');
        return Response.internalServerError(body: 'Error: $e');
      }
    });
    
    // POST /ChangeParked: 사용여부 변경 (쿼리 "U_Parked")
    router.post('/ChangeParked', (Request request) async {
      try {
        final requestBody = await request.readAsString();
        final requestData = jsonDecode(requestBody);
        bool parked = requestData['parked'];
        String tag = requestData['tag'];
        final db = await Database.getInstance();
        await db.query("U_Parked", {"parked": parked, "tag": tag});
        return Response.ok("사용여부 변경완료");
      } catch (e) {
        print('Error in SettingsParkingArea ChangeParked: $e');
        return Response.internalServerError(body: '/ChangeParked 서버 오류로 실패');
      } finally {
        print('/ChangeParked 요청 처리 완료');
      }
    });
    
    return router;
  }
}
