/// 디스플레이 관련 데이터 모델
///
/// 디스플레이 정보 조회 및 대량 업데이트를 위한 데이터 구조들을 정의

/// 층별 디스플레이 정보 요청
class DisplayInfoRequest {
  final String floors; // 쉼표로 구분된 층 정보

  DisplayInfoRequest({required this.floors});

  factory DisplayInfoRequest.fromJson(Map<String, dynamic> json) =>
      DisplayInfoRequest(
        floors: json['floor']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'floor': floors,
      };
}

/// 대량 디스플레이 업데이트 요청
class BulkDisplayUpdateRequest {
  final Map<String, dynamic> tbLots;

  BulkDisplayUpdateRequest({required this.tbLots});

  factory BulkDisplayUpdateRequest.fromJson(Map<String, dynamic> json) =>
      BulkDisplayUpdateRequest(
        tbLots: json['tb_lots'] ?? {},
      );

  Map<String, dynamic> toJson() => {
        'tb_lots': tbLots,
      };
}

/// 디스플레이 정보
class DisplayInfo {
  final String point;
  final String asset;

  DisplayInfo({
    required this.point,
    required this.asset,
  });

  factory DisplayInfo.fromJson(Map<String, dynamic> json) => DisplayInfo(
        point: json['point']?.toString() ?? '',
        asset: json['asset']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'point': point,
        'asset': asset,
      };
}

/// 디스플레이 응답 데이터
class DisplayResponseData {
  final List<String> floors;
  final List<DisplayInfo> displayInfoList;
  final int totalCount;

  DisplayResponseData({
    required this.floors,
    required this.displayInfoList,
    required this.totalCount,
  });

  Map<String, dynamic> toJson() => {
        'floors': floors,
        'display_info': displayInfoList.map((e) => e.toJson()).toList(),
        'total_count': totalCount,
        'timestamp': DateTime.now().toIso8601String(),
      };
}

/// 대량 업데이트 결과
class BulkUpdateResult {
  final int totalItems;
  final int successCount;
  final List<String> errors;

  BulkUpdateResult({
    required this.totalItems,
    required this.successCount,
    required this.errors,
  });

  Map<String, dynamic> toJson() => {
        'total_items': totalItems,
        'success_count': successCount,
        'error_count': errors.length,
        'errors': errors,
        'success_rate': totalItems > 0
            ? (successCount / totalItems * 100).toStringAsFixed(1)
            : '0.0',
        'timestamp': DateTime.now().toIso8601String(),
      };
}

/// 디스플레이 서비스 응답
class DisplayServiceResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;

  DisplayServiceResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      'success': success,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (data != null) {
      if (data is DisplayResponseData) {
        result['data'] = (data as DisplayResponseData).toJson();
      } else if (data is BulkUpdateResult) {
        result['data'] = (data as BulkUpdateResult).toJson();
      } else {
        result['data'] = data;
      }
    }

    if (error != null) {
      result['error'] = error;
    }

    return result;
  }
}
