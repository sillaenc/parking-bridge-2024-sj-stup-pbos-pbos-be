// HTTP 요청 했을 때, JSON 데이터 파싱하는 부분
// {
//     "xbottomright": 1920,
//     "ybottomright": 1080
// },
// {
//     "uid": 1,
//     "lot_type": "NomalCar",
//     "isUsed": null
// },
// {
//     "uid": 2,
//     "lot_type": "ElectricCar",
//     "isUsed": null
// },
// {
//     "uid": 3,
//     "lot_type": "DisabledPeople",
//     "isUsed": null
// },
// {
//     "uid": 4,
//     "lot_type": "LightCar",
//     "isUsed": null
// },
// {
//     "uid": 5,
//     "lot_type": "Senior",
//     "isUsed": null
// },
// {
//     "uid": 6,
//     "lot_type": "PregnantWoman",
//     "isUsed": null
// },
// {
//     "uid": 7,
//     "lot_type": "WomanOnly",
//     "isUsed": null
// },
// {
//     "uid": 1,
//     "tag": "N034",
//     "lot_type": 1,
//     "point_x": 1620,
//     "point_y": 50,
//     "isUsed": 0
// },
// {
//     "uid": 2,
//     "tag": "N035",
//     "lot_type": 1,
//     "point_x": 1530,
//     "point_y": 50,
//     "isUsed": 0
// },
// {
//     "uid": 3,
//     "tag": "N036",
//     "lot_type": 1,
//     "point_x": 1480,
//     "point_y": 50,
//     "isUsed": 0
// },
// {
//     "uid": 4,
//     "tag": "N037",
//     "lot_type": 1,
//     "point_x": 1430,
//     "point_y": 50,
//     "isUsed": 0
// },
// {
//     "uid": 5,
//     "tag": "N038",
//     "lot_type": 1,
//     "point_x": 1340,
//     "point_y": 50,
//     "isUsed": 0
// },
// {
//     "uid": 6,
//     "tag": "N039",
//     "lot_type": 1,
//     "point_x": 1290,
//     "point_y": 50,
//     "isUsed": 0
// },
// {
//     "uid": 7,
//     "tag": "N040",
//     "lot_type": 1,
//     "point_x": 1240,
//     "point_y": 50,
//     "isUsed": 0
// },
// {
//     "uid": 8,
//     "tag": "N041",
//     "lot_type": 1,
//     "point_x": 1150,
//     "point_y": 50,
//     "isUsed": 0
// },
// {
//     "uid": 9,
//     "tag": "N042",
//     "lot_type": 1,
//     "point_x": 1100,
//     "point_y": 50,
//     "isUsed": 0
// },
// {
//     "uid": 10,
//     "tag": "N043",
//     "lot_type": 1,
//     "point_x": 1050,
//     "point_y": 50,
//     "isUsed": 0
// }

import 'dart:convert';

void main() {
  // 이 부분은 실제로 HTTP 요청을 보내고 응답을 받는 부분입니다.
  // 여기서는 단순히 JSON 데이터를 문자열로 표현하여 사용합니다.
  String jsonResponse = '''
  [
    {
        "xbottomright": 1920,
        "ybottomright": 1080
    },
    {
        "uid": 1,
        "lot_type": "NomalCar",
        "isUsed": null
    },
    {
        "uid": 2,
        "lot_type": "ElectricCar",
        "isUsed": null
    },
    {
        "uid": 3,
        "lot_type": "DisabledPeople",
        "isUsed": null
    },
    // 이하 생략
  ]
  ''';

  List<dynamic> jsonList = json.decode(jsonResponse);

  // 첫 번째 데이터를 ParkingSpace 객체로 변환
  ParkingSpace parkingSpace = ParkingSpace.fromJson(jsonList[0]);
  print('Parking Space:');
  print('X Bottom Right: ${parkingSpace.xBottomRight}');
  print('Y Bottom Right: ${parkingSpace.yBottomRight}');
  print('');

  // 두 번째 데이터부터는 ParkingType 또는 ParkingZone 객체로 변환
  for (int i = 1; i < jsonList.length; i++) {
    var jsonData = jsonList[i];
    if (jsonData.containsKey('tag')) {
      // ParkingZone 객체로 변환
      ParkingZone parkingZone = ParkingZone.fromJson(jsonData);
      print('Parking Zone ${parkingZone.uid}:');
      print('Tag: ${parkingZone.tag}');
      print('Lot Type: ${parkingZone.lotType}');
      print('Point X: ${parkingZone.pointX}');
      print('Point Y: ${parkingZone.pointY}');
      print('Is Used: ${parkingZone.isUsed}');
      print('');
    } else {
      // ParkingType 객체로 변환
      ParkingType parkingType = ParkingType.fromJson(jsonData);
      print('Parking Type ${parkingType.uid}:');
      print('Lot Type: ${parkingType.lotType}');
      print('Is Used: ${parkingType.isUsed}');
      print('');
    }
  }
}

class ParkingSpace {
  final int xBottomRight;
  final int yBottomRight;

  ParkingSpace({required this.xBottomRight, required this.yBottomRight});

  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      xBottomRight: json['xbottomright'],
      yBottomRight: json['ybottomright'],
    );
  }
}

class ParkingType {
  final int uid;
  final String lotType;
  final bool? isUsed;

  ParkingType({required this.uid, required this.lotType, this.isUsed});

  factory ParkingType.fromJson(Map<String, dynamic> json) {
    return ParkingType(
      uid: json['uid'],
      lotType: json['lot_type'],
      isUsed: json['isUsed'],
    );
  }
}

class ParkingZone {
  final int uid;
  final String tag;
  final int lotType;
  final int pointX;
  final int pointY;
  final int isUsed;

  ParkingZone({
    required this.uid,
    required this.tag,
    required this.lotType,
    required this.pointX,
    required this.pointY,
    required this.isUsed,
  });

  factory ParkingZone.fromJson(Map<String, dynamic> json) {
    return ParkingZone(
      uid: json['uid'],
      tag: json['tag'],
      lotType: json['lot_type'],
      pointX: json['point_x'],
      pointY: json['point_y'],
      isUsed: json['isUsed'],
    );
  }
}
