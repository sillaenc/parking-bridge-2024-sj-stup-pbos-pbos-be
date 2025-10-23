/// RTSP 관련 유틸리티 함수
///
/// RTSP 주소를 파일명으로 변환하고, FFmpeg를 실행하는 기능 제공

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';

import '../config/rtsp_config.dart';

/// RTSP 주소를 파일시스템 안전한 파일명으로 변환
///
/// IP, 도메인, DDNS 모두 지원
/// 예시:
/// - rtsp://192.168.1.100:554/stream1 → cam_192_168_1_100_554
/// - rtsp://pb0007.iptime.org:8554/cam1 → cam_pb0007_iptime_org_8554
/// - rtsp://abc.example.com:554/live → cam_abc_example_com_554
String rtspToFilename(String rtspAddress) {
  try {
    final uri = Uri.parse(rtspAddress);

    // 호스트 정제 (점과 하이픈을 언더스코어로 변환)
    String host =
        uri.host.replaceAll('.', '_').replaceAll('-', '_').toLowerCase();

    // 포트 (기본값 554)
    int port = uri.hasPort ? uri.port : 554;

    String filename = 'cam_${host}_${port}';

    // 파일명이 너무 길면 줄이기
    if (filename.length > RtspConfig.MAX_FILENAME_LENGTH) {
      final bytes = utf8.encode(rtspAddress);
      final hash =
          md5.convert(bytes).toString().substring(0, RtspConfig.HASH_LENGTH);
      final hint = host.substring(0, min(20, host.length));
      filename = 'cam_${hint}_${hash}';

      print('⚠️  긴 RTSP 주소 감지, 파일명 단축: $rtspAddress → $filename');
    }

    return filename;
  } catch (e) {
    // 파싱 실패 시 fallback (해시 사용)
    print('❌ RTSP 주소 파싱 실패: $rtspAddress, 에러: $e');
    final hash = rtspAddress.hashCode.abs().toString();
    return 'cam_fallback_${hash}';
  }
}

/// RTSP 주소에서 전체 파일 경로 생성 (확장자 포함)
String rtspToFullPath(String rtspAddress) {
  final filename = rtspToFilename(rtspAddress);
  return RtspConfig.getFullOutputPath(filename);
}

/// RTSP 주소에서 임시 파일 경로 생성
String rtspToTempPath(String rtspAddress) {
  final filename = rtspToFilename(rtspAddress);
  return RtspConfig.getTempFilePath(filename);
}

/// 파일명에서 RTSP 주소 힌트 복원 (디버깅용)
///
/// 정확한 RTSP 주소가 아닌 힌트만 반환
/// 예시: cam_192_168_1_100_554 → 192.168.1.100:554
String? filenameToRtspHint(String filename) {
  try {
    // .jpg 제거
    filename = filename.replaceAll('.jpg', '').replaceAll('.jpeg', '');

    // cam_ 접두사 제거
    if (filename.startsWith('cam_')) {
      filename = filename.substring(4);
    }

    // 포트 분리
    final parts = filename.split('_');
    if (parts.length < 2) return null;

    final portStr = parts.last;
    final hostParts = parts.sublist(0, parts.length - 1);

    // 호스트 복원 (언더스코어를 점으로)
    final host = hostParts.join('.').replaceAll('_', '.');

    return '$host:$portStr';
  } catch (e) {
    return null;
  }
}

/// RTSP 주소 유효성 검증
bool isValidRtspAddress(String rtspAddress) {
  try {
    final uri = Uri.parse(rtspAddress);

    // RTSP 스킴 확인
    if (uri.scheme != 'rtsp') return false;

    // 호스트 존재 확인
    if (uri.host.isEmpty) return false;

    return true;
  } catch (e) {
    return false;
  }
}

/// RTSP 주소를 사용자 친화적 형태로 표시
String formatRtspAddress(String rtspAddress) {
  try {
    final uri = Uri.parse(rtspAddress);
    final host = uri.host;
    final port = uri.hasPort ? uri.port : 554;
    final path = uri.path;

    return '$host:$port$path';
  } catch (e) {
    return rtspAddress;
  }
}

/// FFmpeg가 시스템에 설치되어 있는지 확인
Future<bool> isFFmpegInstalled() async {
  try {
    final result = await Process.run(
      RtspConfig.FFMPEG_EXECUTABLE,
      ['-version'],
      runInShell: true,
    );
    return result.exitCode == 0;
  } catch (e) {
    return false;
  }
}

/// FFmpeg 버전 정보 조회
Future<String?> getFFmpegVersion() async {
  try {
    final result = await Process.run(
      RtspConfig.FFMPEG_EXECUTABLE,
      ['-version'],
      runInShell: true,
    );

    if (result.exitCode == 0) {
      final output = result.stdout.toString();
      // 첫 줄에서 버전 정보 추출
      final firstLine = output.split('\n').first;
      return firstLine;
    }
    return null;
  } catch (e) {
    return null;
  }
}

/// RTSP 스트림에서 단일 프레임 캡처 (FFmpeg 사용)
///
/// [rtspAddress]: RTSP 카메라 주소
/// [outputPath]: 출력 파일 경로
///
/// 반환값: 성공 여부
Future<bool> captureFrameFromRtsp(String rtspAddress, String outputPath) async {
  try {
    print('📸 캡처 시작: $rtspAddress → $outputPath');

    // FFmpeg 명령어 구성
    final args = [
      '-rtsp_transport', RtspConfig.RTSP_TRANSPORT, // TCP 전송
      '-i', rtspAddress, // 입력 RTSP 주소
      '-frames:v', '1', // 단일 프레임만 캡처
      '-q:v', RtspConfig.IMAGE_QUALITY.toString(), // 이미지 품질
      '-timeout', RtspConfig.ffmpegTimeoutMicroseconds.toString(), // 타임아웃
      '-loglevel', RtspConfig.FFMPEG_LOG_LEVEL, // 로그 레벨
      '-y', // 파일 덮어쓰기
      outputPath, // 출력 경로
    ];

    print('🎬 FFmpeg 실행: ${RtspConfig.FFMPEG_EXECUTABLE} ${args.join(" ")}');

    // FFmpeg 실행
    final result = await Process.run(
      RtspConfig.FFMPEG_EXECUTABLE,
      args,
      runInShell: true,
    );

    if (result.exitCode == 0) {
      // 파일 생성 확인
      final file = File(outputPath);
      if (await file.exists()) {
        final fileSize = await file.length();
        print('✅ 캡처 성공: ${outputPath} (${fileSize} bytes)');
        return true;
      } else {
        print('❌ 캡처 실패: 파일이 생성되지 않았습니다');
        return false;
      }
    } else {
      print('❌ FFmpeg 실행 실패 (exit code: ${result.exitCode})');
      print('   stderr: ${result.stderr}');
      return false;
    }
  } catch (e, stackTrace) {
    print('❌ 캡처 중 예외 발생: $e');
    print('   Stack trace: $stackTrace');
    return false;
  }
}

/// RTSP 스트림에서 프레임 캡처 (재시도 포함)
///
/// [rtspAddress]: RTSP 카메라 주소
/// [outputPath]: 출력 파일 경로
/// [retryCount]: 재시도 횟수 (기본값: 설정 파일 값)
///
/// 반환값: 성공 여부
Future<bool> captureFrameWithRetry(
  String rtspAddress,
  String outputPath, {
  int? retryCount,
}) async {
  final maxRetries = retryCount ?? RtspConfig.MAX_RETRY_COUNT;

  for (int attempt = 1; attempt <= maxRetries; attempt++) {
    print('🔄 캡처 시도 $attempt/$maxRetries: $rtspAddress');

    final success = await captureFrameFromRtsp(rtspAddress, outputPath);

    if (success) {
      return true;
    }

    // 마지막 시도가 아니면 대기 후 재시도
    if (attempt < maxRetries) {
      print('⏳ ${RtspConfig.RETRY_DELAY_SECONDS}초 후 재시도...');
      await Future.delayed(Duration(seconds: RtspConfig.RETRY_DELAY_SECONDS));
    }
  }

  print('❌ 최대 재시도 횟수 초과: $rtspAddress');
  return false;
}

/// 원자적 파일 쓰기 (임시 파일 → 실제 파일)
///
/// 파일 쓰기 중에 읽기 요청이 와도 안전하도록 처리
///
/// [rtspAddress]: RTSP 주소
/// [finalPath]: 최종 파일 경로
///
/// 반환값: 성공 여부
Future<bool> atomicCapture(String rtspAddress, String finalPath) async {
  try {
    // 1. 임시 파일로 캡처
    final tempPath = rtspToTempPath(rtspAddress);

    final success = await captureFrameWithRetry(rtspAddress, tempPath);

    if (!success) {
      return false;
    }

    // 2. 임시 파일을 최종 경로로 이동 (원자적 연산)
    final tempFile = File(tempPath);
    if (await tempFile.exists()) {
      await tempFile.rename(finalPath);
      print('✅ 원자적 파일 쓰기 완료: $finalPath');
      return true;
    } else {
      print('❌ 임시 파일이 존재하지 않습니다: $tempPath');
      return false;
    }
  } catch (e) {
    print('❌ 원자적 캡처 실패: $e');
    return false;
  }
}

/// 디렉토리 존재 확인 및 생성
Future<void> ensureDirectoryExists(String dirPath) async {
  final directory = Directory(dirPath);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
    print('📁 디렉토리 생성: $dirPath');
  }
}

/// 파일 존재 여부 확인
Future<bool> fileExists(String filePath) async {
  final file = File(filePath);
  return await file.exists();
}

/// 파일 크기 조회 (바이트)
Future<int?> getFileSize(String filePath) async {
  try {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return null;
  } catch (e) {
    return null;
  }
}

/// 파일 크기를 사람이 읽기 쉬운 형태로 변환
String formatFileSize(int bytes) {
  if (bytes < 1024) return '${bytes}B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
}

/// 파일 마지막 수정 시간 조회
Future<DateTime?> getFileModifiedTime(String filePath) async {
  try {
    final file = File(filePath);
    if (await file.exists()) {
      final stat = await file.stat();
      return stat.modified;
    }
    return null;
  } catch (e) {
    return null;
  }
}

/// RTSP 주소 목록에서 고유 주소만 추출
List<String> getUniqueRtspAddresses(List<String> addresses) {
  return addresses.toSet().toList();
}

/// 캡처 디렉토리의 모든 이미지 파일 목록 조회
Future<List<File>> listCapturedImages() async {
  try {
    final directory = Directory(RtspConfig.CAPTURE_OUTPUT_DIR);
    if (!await directory.exists()) {
      return [];
    }

    final files = await directory
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .where((file) => file.path.endsWith('.${RtspConfig.IMAGE_FORMAT}'))
        .toList();

    return files;
  } catch (e) {
    print('❌ 이미지 목록 조회 실패: $e');
    return [];
  }
}

/// 캡처 디렉토리 통계 정보
Future<Map<String, dynamic>> getCaptureDirectoryStats() async {
  try {
    final files = await listCapturedImages();
    int totalSize = 0;

    for (final file in files) {
      final size = await getFileSize(file.path);
      if (size != null) totalSize += size;
    }

    return {
      'total_files': files.length,
      'total_size_bytes': totalSize,
      'total_size_formatted': formatFileSize(totalSize),
      'directory': RtspConfig.CAPTURE_OUTPUT_DIR,
    };
  } catch (e) {
    return {
      'error': e.toString(),
    };
  }
}
