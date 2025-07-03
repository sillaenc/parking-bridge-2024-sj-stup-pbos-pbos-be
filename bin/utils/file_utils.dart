import 'dart:io';
import 'dart:typed_data';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/multipart.dart';
import 'package:path/path.dart' as p;
import '../models/parking_zone_models.dart';

/// 파일 확장자 추출 유틸리티
class FileExtensionExtractor {
  /// Content-Disposition 헤더에서 파일 확장자 추출
  static String getExtensionFromContentDisposition(String contentDisposition) {
    final regex = RegExp(r'filename="[^"]+\.(\w+)"');
    final match = regex.firstMatch(contentDisposition);
    if (match != null) {
      return match.group(1)!.toLowerCase();
    }
    return '';
  }

  /// 파일명에서 확장자 추출
  static String getExtensionFromFilename(String filename) {
    return p.extension(filename).replaceFirst('.', '').toLowerCase();
  }
}

/// Multipart 요청 파싱 유틸리티
class MultipartParser {
  /// 파일 업로드 요청 파싱
  static Future<FileUploadRequest?> parseFileUpload(Request request) async {
    if (!request.isMultipart) {
      return null;
    }

    String? fileName;
    String? extension;
    Uint8List? content;

    await for (final part in request.parts) {
      final headers = part.headers['content-disposition'] ?? '';

      if (headers.contains('name="filename"')) {
        fileName = await part.readString();
        fileName = p.basename(fileName);
      } else if (headers.contains('name="file"')) {
        content = await part.readBytes();
        extension =
            FileExtensionExtractor.getExtensionFromContentDisposition(headers);
      }
    }

    if (fileName != null && content != null && extension != null) {
      return FileUploadRequest(
        filename: fileName,
        content: content,
        extension: extension,
      );
    }

    return null;
  }

  /// 파일 업데이트 요청 파싱
  static Future<FileUpdateRequest?> parseFileUpdate(Request request) async {
    if (!request.isMultipart) {
      return null;
    }

    String? newFileName;
    String? oldFileName;
    String? extension;
    Uint8List? content;

    await for (final part in request.parts) {
      final headers = part.headers['content-disposition'] ?? '';

      if (headers.contains('name="filename"')) {
        newFileName = await part.readString();
        newFileName = p.basename(newFileName);
      } else if (headers.contains('name="beforeName"')) {
        oldFileName = await part.readString();
        oldFileName = p.basename(oldFileName);
      } else if (headers.contains('name="file"')) {
        content = await part.readBytes();
        extension =
            FileExtensionExtractor.getExtensionFromContentDisposition(headers);
      }
    }

    if (newFileName != null &&
        oldFileName != null &&
        content != null &&
        extension != null) {
      return FileUpdateRequest(
        newFilename: newFileName,
        oldFilename: oldFileName,
        content: content,
        extension: extension,
      );
    }

    return null;
  }
}

/// 파일 시스템 관리 유틸리티
class FileSystemManager {
  final String baseDirectory;

  FileSystemManager(
      {this.baseDirectory = ParkingZoneConstants.defaultFileDirectory});

  /// 파일 경로 생성
  String getFilePath(String filename, String extension) {
    return '$baseDirectory/$filename.$extension';
  }

  /// 파일 저장
  Future<FileInfo> saveFile(
      String filename, String extension, Uint8List content) async {
    final filePath = getFilePath(filename, extension);
    final file = File(filePath);

    // 디렉토리가 없으면 생성
    await file.parent.create(recursive: true);

    // 파일 저장
    await file.writeAsBytes(content);

    final stats = await file.stat();
    return FileInfo(
      filename: filename,
      fullPath: filePath,
      extension: extension,
      sizeBytes: stats.size,
      createdAt: stats.accessed,
      modifiedAt: stats.modified,
    );
  }

  /// 파일 삭제
  Future<bool> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
      return true;
    }
    return false;
  }

  /// 파일 존재 확인
  Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  /// 파일 정보 조회
  Future<FileInfo?> getFileInfo(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final stats = await file.stat();
      final filename = p.basenameWithoutExtension(filePath);
      final extension = p.extension(filePath).replaceFirst('.', '');

      return FileInfo(
        filename: filename,
        fullPath: filePath,
        extension: extension,
        sizeBytes: stats.size,
        createdAt: stats.accessed,
        modifiedAt: stats.modified,
      );
    }
    return null;
  }

  /// 파일 업데이트 (기존 파일 삭제 후 새 파일 저장)
  Future<FileInfo> updateFile(
    String oldFilePath,
    String newFilename,
    String extension,
    Uint8List content,
  ) async {
    // 기존 파일 삭제
    await deleteFile(oldFilePath);

    // 새 파일 저장
    return await saveFile(newFilename, extension, content);
  }

  /// 디렉토리 내 모든 파일 목록 조회
  Future<List<FileInfo>> listFiles() async {
    final directory = Directory(baseDirectory);
    if (!await directory.exists()) {
      return [];
    }

    final files = <FileInfo>[];
    await for (final entity in directory.list()) {
      if (entity is File) {
        final fileInfo = await getFileInfo(entity.path);
        if (fileInfo != null) {
          files.add(fileInfo);
        }
      }
    }

    return files;
  }
}

/// 파일 및 주차 구역 유효성 검사 유틸리티
class ParkingZoneValidator {
  /// 파일명 유효성 검사
  static bool isValidFilename(String filename) {
    if (filename.isEmpty) return false;
    if (filename.length > ParkingZoneConstants.maxFilenameLength) return false;

    // 파일명에 특수 문자가 포함되어 있는지 확인
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if (invalidChars.hasMatch(filename)) return false;

    return filename.trim().isNotEmpty;
  }

  /// 파일 확장자 유효성 검사
  static bool isValidFileExtension(String extension) {
    if (extension.isEmpty) return false;
    return ParkingZoneConstants.supportedExtensions
        .contains(extension.toLowerCase());
  }

  /// 파일 크기 유효성 검사
  static bool isValidFileSize(int sizeBytes) {
    return sizeBytes <= ParkingZoneConstants.maxFileSizeBytes;
  }

  /// 주차 공간 유형 유효성 검사
  static bool isValidLotType(int lotType) {
    return lotType >= ParkingZoneConstants.lotTypeNormal &&
        lotType <= ParkingZoneConstants.lotTypeCompact;
  }

  /// 태그 유효성 검사
  static bool isValidTag(String tag) {
    if (tag.isEmpty) return false;
    if (tag.length > 50) return false;
    return tag.trim().isNotEmpty;
  }

  /// 파일 업로드 요청 종합 유효성 검사
  static ValidationResult validateFileUpload(FileUploadRequest request) {
    final errors = <String>[];

    if (!isValidFilename(request.filename)) {
      errors.add('Invalid filename format');
    }

    if (!isValidFileExtension(request.extension)) {
      errors.add('Unsupported file extension: ${request.extension}');
    }

    if (!isValidFileSize(request.content.length)) {
      errors.add(
          'File size exceeds maximum limit of ${ParkingZoneConstants.maxFileSizeBytes / (1024 * 1024)}MB');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 파일 업데이트 요청 종합 유효성 검사
  static ValidationResult validateFileUpdate(FileUpdateRequest request) {
    final errors = <String>[];

    if (!isValidFilename(request.newFilename)) {
      errors.add('Invalid new filename format');
    }

    if (!isValidFilename(request.oldFilename)) {
      errors.add('Invalid old filename format');
    }

    if (!isValidFileExtension(request.extension)) {
      errors.add('Unsupported file extension: ${request.extension}');
    }

    if (!isValidFileSize(request.content.length)) {
      errors.add(
          'File size exceeds maximum limit of ${ParkingZoneConstants.maxFileSizeBytes / (1024 * 1024)}MB');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 주차 공간 유형 변경 요청 유효성 검사
  static ValidationResult validateLotTypeChange(LotTypeChangeRequest request) {
    final errors = <String>[];

    if (!isValidLotType(request.lotType)) {
      errors.add('Invalid lot type: ${request.lotType}');
    }

    if (!isValidTag(request.tag)) {
      errors.add('Invalid tag format');
    }

    if (!isValidTag(request.changedTag)) {
      errors.add('Invalid changed tag format');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 주차 상태 변경 요청 유효성 검사
  static ValidationResult validateParkingStatusChange(
      ParkingStatusChangeRequest request) {
    final errors = <String>[];

    if (!isValidTag(request.tag)) {
      errors.add('Invalid tag format');
    }

    // parked는 bool이므로 추가 검증 불필요

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// 파일 삭제 요청 유효성 검사
  static ValidationResult validateFileDelete(FileDeleteRequest request) {
    final errors = <String>[];

    if (!isValidFilename(request.filename)) {
      errors.add('Invalid filename format');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// 유효성 검사 결과를 담는 클래스 (user_models에서 이미 정의되어 있지만 중복 정의)
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  /// 첫 번째 에러 메시지를 반환합니다
  String get firstError => errors.isNotEmpty ? errors.first : '';

  /// 모든 에러 메시지를 하나의 문자열로 합칩니다
  String get allErrors => errors.join(', ');
}
