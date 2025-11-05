## 파일별 route 구조와 기능

### 설명

#### main.dart
  - ('/getResource') : parking-data 정보를 client 요청 type으로 변환된 상태로 변환된 상태. 해당 route로 요청하면 Sort가 되어 있고 String type으로 response 한다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/getResource | GET | X | X | start,12,15,16,18,20,24,26,27,29,31,33,35,37,38,41,45,46,47,5,A1_1,A1_2,A1_3,A2_1,A2_2,A2_3,A3_1,A3_2,A3_3,A3_4,A4_2,A4_3,A4_4,A4_5,A4_6,A5_1,A5_2,A5_3,A5_4,A5_5,A5_6,A6_4,A7_1,A7_2,A7_3,A8_2,A8_3,A8_4,A8_5,A8_6,B1_1,B1_2,B1_3,B1_4,B2_1,B2_2,B2_3,B2_4,B2_5,B3_2,B3_4,B3_5,B3_6,B4_1,B4_2,B4_3,B4_4,B4_6,B5_1,B5_2,B5_3,B5_4,B6_1,B6_3,B7_1,B7_2,B7_3,B7_4,B8_1,B8_3,B8_4,B8_5,B9_1,B9_2,B9_3 |
  - parking-data를 String 형태로 만들어진 상태. 주차되어 있는 자리만 response 된다.

### base_information.dart(/base)
  - ('/') : 주차장에 대한 정보, name, address, latitude, longitude, manager, phone_number를 보낸다. 
  - ('/get') : db에 등록된 주차장 정보를 response한다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/base | POST | X | { "name" : "창업진흥원 주차장ㅋ","address" : "세종 집현중앙7로 16 창업진흥원", "latitude" : "36.4996", "longitude" : "127.3309", "manager" : "ㅁㄹ", "phonenumber" : "010-1234-5678"} | X |
| http://type-server-ip/base/get | GET | X | X | 하단 예시 |

<details>
<summary>접기/펼치기</summary>

```
{
    "all": 135,
    "use": 129,
    "db": {
        "uid": 1,
        "name": "창업진흥원 주차장ㅋ",
        "address": "세종 집현중앙7로 16 창업진흥원",
        "latitude": "36.4996",
        "longitude": "127.3309",
        "manager": "ㅁㄹ",
        "phone_number": "010-1234-5678"
    }
}
```
</details>

### billboard.dart(/billboard)(전광판)
  - ('/') : json으로 floor를 key로 해서 층을 post하면, 해당하는 층에 대해서 lot_type 별로 한자리 이상 빈 구역들을 모두 출력한다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/base | POST | X | { "floor" : "F1"} | [{"lot_type":1,"count":15},{"lot_type":4,"count":4}] |

### central.dart(/central)
  - ('/') : 실시간 층별로, 차종별로 group과 order을 만든다음, response한다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/statistics/central | GET | X | X | 하단에 예시가 있음 |

<details>
<summary>접기/펼치기</summary>

```
{"all":135,"use":112,"floors":["F1","F2"],"lots":[1,3,4],"parked":[{"lot_type":1,"floor":"F1","data":[{"count":52}]},{"lot_type":3,"floor":"F1","data":[{"count":4}]},{"lot_type":4,"floor":"F1","data":[{"count":2}]},{"lot_type":1,"floor":"F2","data":[{"count":54}]},{"lot_type":3,"floor":"F2","data":[{"count":0}]},{"lot_type":4,"floor":"F2","data":[{"count":0}]}]}
```
</details>

#### create_admin.dart (/create_admin)
  - 계정 생성 클래스
  - ('/') : Front에서 'account', 'passwd', 'admin' 의 key로 이루어진 json 형태로 값을 받은 후, 'tb_users' 테이블에 저장

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/create_admin | POST | String | { "account" : "testid", "passwd" : "1234", "username": "admin" } | 1 |
  - 1이 성공, 0은 실패. 0은 status에 error 원인이 같이 response 되기에 파악가능하다.

#### display.dart (/display)
  - display에 현재 주차 여부를 보내주는 api
  - ('/') : tb_lots 테이블에서 Floor가 사용자가 작성한 층에 대한 내용을 display 테이블에서 asset, point, tb_lots 테이블에서 isUsed를 보낸다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/display | POST | String | F1 OR F1,B2,B1 | 하단에 표시 |
- 설치 후 표시

#### confirm_account_list.dart (/confirm_account_list)
  - db에 클래스 있는지 확인하는 클래스
  - ('/') : 'tb_users' table의 rows가 1이라도 있는지를 확인해서 있으면 있으면 1, 없으면 0을 반환한다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/confirm_account_list | GET | X | X | 0 |

#### error.dart (/parking_wrong)
  - error에 차종이 들어 있는지 확인하는 클래스
  - ('/') : error가 없으면 문자열 0을 반환하고, 있으면 list화된 상태로 결과를 반환한다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/parking_wrong | GET | X | X | 0 |
| http://type-server-ip/parking_wrong | GET | X | X | [B07, C01, C02, C03, C04, C06, C08, E05, E06, G02, G04, G05, G06] |

#### firstSetting.dart (route 없음)
  - 서버 실행시 sqlite db 생성과 함께 1회 실행되는 클래스. tb_lots 세팅과 기타 세팅이 이루어진다.

### graphData.dart(/graphData)
  - ('/') : tb_lots table과 processed_db를 lot_type과 car_type으로 join하여 floor별로, lot_type별로 각각 count하여 response한다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/statistics/graphData | POST | X | { "day":"2024-11-26" } | 하단에 예시가 있음 |

<details>
<summary>접기/펼치기</summary>

```

[{"lot_type":1,"floor":"F1","data":[{"hour":"2024-11-26 00","count":5,"floor":"F1"},{"hour":"2024-11-26 01","count":4,"floor":"F1"},{"hour":"2024-11-26 02","count":4,"floor":"F1"},{"hour":"2024-11-26 03","count":4,"floor":"F1"},{"hour":"2024-11-26 04","count":4,"floor":"F1"},{"hour":"2024-11-26 05","count":6,"floor":"F1"},{"hour":"2024-11-26 06","count":9,"floor":"F1"},{"hour":"2024-11-26 07","count":19,"floor":"F1"},{"hour":"2024-11-26 08","count":57,"floor":"F1"},{"hour":"2024-11-26 09","count":57,"floor":"F1"},{"hour":"2024-11-26 10","count":57,"floor":"F1"},{"hour":"2024-11-26 11","count":57,"floor":"F1"},{"hour":"2024-11-26 12","count":58,"floor":"F1"},{"hour":"2024-11-26 13","count":59,"floor":"F1"},{"hour":"2024-11-26 14","count":57,"floor":"F1"}]},{"lot_type":3,"floor":"F1","data":[{"hour":"2024-11-26 08","count":1,"floor":"F1"},{"hour":"2024-11-26 09","count":1,"floor":"F1"},{"hour":"2024-11-26 10","count":1,"floor":"F1"},{"hour":"2024-11-26 11","count":1,"floor":"F1"},{"hour":"2024-11-26 12","count":1,"floor":"F1"},{"hour":"2024-11-26 13","count":1,"floor":"F1"},{"hour":"2024-11-26 14","count":1,"floor":"F1"}]},{"lot_type":4,"floor":"F1","data":[{"hour":"2024-11-26 00","count":2,"floor":"F1"},{"hour":"2024-11-26 01","count":2,"floor":"F1"},{"hour":"2024-11-26 02","count":2,"floor":"F1"},{"hour":"2024-11-26 03","count":2,"floor":"F1"},{"hour":"2024-11-26 04","count":2,"floor":"F1"},{"hour":"2024-11-26 05","count":2,"floor":"F1"},{"hour":"2024-11-26 06","count":2,"floor":"F1"},{"hour":"2024-11-26 07","count":2,"floor":"F1"},{"hour":"2024-11-26 08","count":2,"floor":"F1"},{"hour":"2024-11-26 09","count":2,"floor":"F1"},{"hour":"2024-11-26 10","count":2,"floor":"F1"},{"hour":"2024-11-26 11","count":2,"floor":"F1"},{"hour":"2024-11-26 12","count":2,"floor":"F1"},{"hour":"2024-11-26 13","count":2,"floor":"F1"},{"hour":"2024-11-26 14","count":2,"floor":"F1"}]},{"lot_type":1,"floor":"F2","data":[{"hour":"2024-11-26 00","count":1,"floor":"F2"},{"hour":"2024-11-26 01","count":1,"floor":"F2"},{"hour":"2024-11-26 02","count":1,"floor":"F2"},{"hour":"2024-11-26 03","count":1,"floor":"F2"},{"hour":"2024-11-26 04","count":1,"floor":"F2"},{"hour":"2024-11-26 05","count":1,"floor":"F2"},{"hour":"2024-11-26 06","count":1,"floor":"F2"},{"hour":"2024-11-26 07","count":3,"floor":"F2"},{"hour":"2024-11-26 08","count":60,"floor":"F2"},{"hour":"2024-11-26 09","count":61,"floor":"F2"},{"hour":"2024-11-26 10","count":61,"floor":"F2"},{"hour":"2024-11-26 11","count":61,"floor":"F2"},{"hour":"2024-11-26 12","count":61,"floor":"F2"},{"hour":"2024-11-26 13","count":61,"floor":"F2"},{"hour":"2024-11-26 14","count":61,"floor":"F2"}]},{"lot_type":3,"floor":"F2","data":[]},{"lot_type":4,"floor":"F2","data":[]}]
```
</details>

### led_cal.dart(/led_cal)
  - ('/') : 주차장의 주차상황에 관한걸 카메라 기준으로 camera, color로 response한다. color는 주차자리가 1자리라도 남았으면 green으로 response하며, 1자리도 남지 않을 경우는 red로 response한다

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/led_cal | GET | X | X | {"camera":"A01","color":"green"},{"camera":"A02","color":"green"},{"camera":"A03","color":"green"},{"camera":"A04","color":"green"},{"camera":"A05","color":"green"},{"camera":"A06","color":"red"},{"camera":"A07","color":"green"},{"camera":"A08","color":"green"},{"camera":"A09","color":"red"},{"camera":"A10","color":"red"},{"camera":"A11","color":"green"},{"camera":"A12","color":"green"},{"camera":"A13","color":"green"},{"camera":"B01","color":"green"},{"camera":"B02","color":"green"},{"camera":"B03","color":"green"},{"camera":"B04","color":"green"},{"camera":"C01","color":"green"},{"camera":"C02","color":"green"},{"camera":"C03","color":"green"} |

### isalive.dart(/isalive)(수정 필요)
  - ('/') : 주차장의 주차상황에 관한걸 카메라 기준으로 camera, color로 response한다. color는 주차자리가 1자리라도 남았으면 green으로 response하며, 1자리도 남지 않을 경우는 red로 response한다

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/get | GET | X | X |  |
| http://type-server-ip/ | POST | X | X |  |

#### login_main.dart (/parking_status)
  - 메인 화면 실시간 전달 정보
  - ('/') :  'tb_lots'에서 uid, tag, lot_type, isUsed을 select 해서 Response해서 return한다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/parking_status| GET | X | X | 하단에 기재 |
- example output
```
[{"uid":1,"tag":"45","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":2,"tag":"46","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":3,"tag":"47","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":4,"tag":"44","lot_type":4,"isUsed":0,"asset":"N_horizontal_disable.png"},{"uid":5,"tag":"43","lot_type":4,"isUsed":0,"asset":"N_horizontal_disable.png"},{"uid":6,"tag":"42","lot_type":4,"isUsed":0,"asset":"N_horizontal_disable.png"},{"uid":7,"tag":"27","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":8,"tag":"28","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":9,"tag":"29","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":10,"tag":"30","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":11,"tag":"31","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":12,"tag":"32","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":13,"tag":"33","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":14,"tag":"34","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":15,"tag":"35","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":16,"tag":"36","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":17,"tag":"37","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":18,"tag":"41","lot_type":3,"isUsed":1,"asset":"L_horizontal_disable.png"},{"uid":19,"tag":"40","lot_type":3,"isUsed":0,"asset":"L_horizontal_disable.png"},{"uid":20,"tag":"16","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":21,"tag":"17","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":22,"tag":"18","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":23,"tag":"19","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":24,"tag":"20","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":25,"tag":"21","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":26,"tag":"22","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":27,"tag":"23","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":28,"tag":"24","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":29,"tag":"25","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":30,"tag":"26","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":31,"tag":"39","lot_type":3,"isUsed":0,"asset":"L_horizontal_disable.png"},{"uid":32,"tag":"38","lot_type":3,"isUsed":1,"asset":"L_horizontal_disable.png"},{"uid":33,"tag":"1","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":34,"tag":"2","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":35,"tag":"3","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":36,"tag":"4","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":37,"tag":"5","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":38,"tag":"6","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":39,"tag":"7","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":40,"tag":"8","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":41,"tag":"9","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":42,"tag":"10","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":43,"tag":"11","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":44,"tag":"12","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":45,"tag":"13","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":46,"tag":"14","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":47,"tag":"15","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":48,"tag":"A8_6","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":49,"tag":"A8_5","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":50,"tag":"A8_4","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":51,"tag":"A8_3","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":52,"tag":"A7_3","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":53,"tag":"A7_2","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":54,"tag":"A7_1","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":55,"tag":"A1_3","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":56,"tag":"A1_2","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":57,"tag":"A1_1","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":58,"tag":"A2_3","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":59,"tag":"A2_2","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":60,"tag":"A2_1","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":61,"tag":"A3_4","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":62,"tag":"A3_3","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":63,"tag":"A3_2","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":64,"tag":"A4_5","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":65,"tag":"A4_6","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":66,"tag":"A4_4","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":67,"tag":"A4_3","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":68,"tag":"A4_2","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":69,"tag":"A6_1","lot_type":4,"isUsed":1,"asset":"L_horizontal_disable.png"},{"uid":70,"tag":"A4_1","lot_type":4,"isUsed":0,"asset":"L_horizontal_disable.png"},{"uid":71,"tag":"A8_1","lot_type":4,"isUsed":0,"asset":"L_vertical_disable.png"},{"uid":72,"tag":"A8_2","lot_type":4,"isUsed":1,"asset":"L_vertical_disable.png"},{"uid":73,"tag":"A3_1","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":74,"tag":"A5_6","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":75,"tag":"A6_2","lot_type":4,"isUsed":0,"asset":"L_horizontal_disable.png"},{"uid":76,"tag":"A5_1","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":77,"tag":"A5_5","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":78,"tag":"A6_3","lot_type":4,"isUsed":0,"asset":"L_horizontal_disable.png"},{"uid":79,"tag":"A5_2","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":80,"tag":"A5_4","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":81,"tag":"A6_4","lot_type":4,"isUsed":1,"asset":"L_horizontal_disable.png"},{"uid":82,"tag":"A5_3","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":83,"tag":"B8_5","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":84,"tag":"B8_1","lot_type":4,"isUsed":1,"asset":"L_horizontal_disable.png"},{"uid":85,"tag":"B8_4","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":86,"tag":"B7_4","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":87,"tag":"B1_1","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":88,"tag":"B8_3","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":89,"tag":"B1_2","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":90,"tag":"B8_2","lot_type":4,"isUsed":0,"asset":"L_horizontal_disable.png"},{"uid":91,"tag":"B9_3","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":92,"tag":"B1_3","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":93,"tag":"B6_1","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":94,"tag":"B6_2","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":95,"tag":"B6_3","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":96,"tag":"B7_1","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":97,"tag":"B7_2","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":98,"tag":"B7_3","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":99,"tag":"B9_2","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":100,"tag":"B1_4","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":101,"tag":"B9_1","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":102,"tag":"B3_3","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":103,"tag":"B3_2","lot_type":1,"isUsed":0,"asset":"N_vertical_disable.png"},{"uid":104,"tag":"B3_1","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":105,"tag":"B4_3","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":106,"tag":"B4_2","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":107,"tag":"B4_1","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":108,"tag":"B2_4","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":109,"tag":"B5_3","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":110,"tag":"B2_5","lot_type":4,"isUsed":0,"asset":"L_horizontal_disable.png"},{"uid":111,"tag":"B5_2","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":112,"tag":"B5_1","lot_type":1,"isUsed":1,"asset":"N_horizontal_disable.png"},{"uid":113,"tag":"B2_1","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":114,"tag":"B2_2","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":115,"tag":"B2_3","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":116,"tag":"B3_4","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":117,"tag":"B3_5","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":118,"tag":"B3_6","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":119,"tag":"B4_4","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":120,"tag":"B4_5","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":121,"tag":"B4_6","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"},{"uid":122,"tag":"B5_4","lot_type":1,"isUsed":1,"asset":"N_vertical_disable.png"}]
```

  - uid : 주차장 순번.
  - tag : 해당 주차칸에 부여된 인식 코드
  - isUsed : 주차중 유무를 나타냄.
  - asset : 해당 주차칸의 방향 및 차종을 나타냄

#### login_setting.dart (/login_setting) 
  - 로그인 관련 클래스 
  - ('/') :  Front에서 'account', 'passwd'의 key로 이루어진 json 형태로 값을 받은 후, 'tb_users' 테이블에서 select 하는 방식으로 return 받아 유무를 확인.
  - ('/base') : 'tb_lot_type' , 'tb_users', tb_lots_image' table + 'tb_lots' length return 

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/login_setting | POST | String | { "account" : "testid", "passwd" : "1234" } | { "uid": 1, "account": "testid", "username": "admin", "userlevel": 0, "isActivated": 1 },<br> { "token": eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY2NvdW50IjoidGVzdGlkIiwiaWF0IjoxNzI0MTk5MDgxLCJleHAiOjE3MjQyMDI2ODF9.1hwPfyzFHXmkehDpsx7JAzWmEjtxDrmMES0HVfRdo6Q" } |
| http://type-server-ip/login_setting/base | GET | x | x | 하단 기재 |
- example output
<details>
<summary>접기/펼치기</summary>

```
[
    342,
    17,
    2,
    3,
    13,
    1,
    14,
    12,
    4,
    {
        "xbottomright": 1920,
        "ybottomright": 1080
    },
    {
        "uid": 1,
        "lot_type": "N",
        "tag": "일반",
        "code_format": "N000",
        "isUsed": 1
    },
    {
        "uid": 2,
        "lot_type": "D",
        "tag": "장애인",
        "code_format": "D000",
        "isUsed": 1
    },
    {
        "uid": 3,
        "lot_type": "M",
        "tag": "전기",
        "code_format": "E000",
        "isUsed": 1
    },
    {
        "uid": 4,
        "lot_type": "P",
        "tag": "친환경",
        "code_format": "F000",
        "isUsed": 1
    },
    {
        "uid": 5,
        "lot_type": "O",
        "tag": "경차",
        "code_format": "L000",
        "isUsed": 1
    },
    {
        "uid": 6,
        "lot_type": "G",
        "tag": "임산부",
        "code_format": "P000",
        "isUsed": 1
    },
    {
        "uid": 7,
        "lot_type": "E",
        "tag": "공용차",
        "code_format": "O000",
        "isUsed": 1
    },
    {
        "uid": 8,
        "lot_type": "F",
        "tag": "관용차",
        "code_format": "G000",
        "isUsed": 1
    },
    {
        "uid": 9,
        "lot_type": "L",
        "tag": "유공자",
        "code_format": "M000",
        "isUsed": 1
    },
    {
        "uid": 1,
        "point": "445, 520",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "70로9136",
        "startTime": "2025-03-18 18:08:56"
    },
    {
        "uid": 2,
        "point": "421, 510",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "12어3836",
        "startTime": "2025-03-19 08:00:49"
    },
    {
        "uid": 3,
        "point": "397, 499",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "75가9789",
        "startTime": "2025-03-19 09:52:38"
    },
    {
        "uid": 4,
        "point": "367, 487",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "18보1629",
        "startTime": "2025-03-19 08:02:48"
    },
    {
        "uid": 5,
        "point": "343, 476",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "370무8618",
        "startTime": "2025-03-19 07:51:19"
    },
    {
        "uid": 6,
        "point": "319, 466",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "178로1976",
        "startTime": "2025-03-19 08:02:09"
    },
    {
        "uid": 7,
        "point": "289, 453",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "03주4057",
        "startTime": "2025-03-19 08:10:25"
    },
    {
        "uid": 8,
        "point": "265, 443",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "263보2750",
        "startTime": "2025-03-19 05:54:36"
    },
    {
        "uid": 9,
        "point": "241, 433",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "27누7074",
        "startTime": "2025-03-19 08:05:20"
    },
    {
        "uid": 10,
        "point": "210, 420",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "47다9238",
        "startTime": "2025-03-19 08:04:17"
    },
    {
        "uid": 11,
        "point": "187, 410",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "14마8599",
        "startTime": "2025-03-19 08:12:35"
    },
    {
        "uid": 12,
        "point": "100, 401",
        "lot_type": 1,
        "asset": "nHorizontal23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "07오2988",
        "startTime": "2025-03-19 11:06:37"
    },
    {
        "uid": 13,
        "point": "110, 377",
        "lot_type": 1,
        "asset": "nHorizontal23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "169나7015",
        "startTime": "2025-03-19 07:56:25"
    },
    {
        "uid": 14,
        "point": "67, 479",
        "lot_type": 1,
        "asset": "nHorizontal23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "19오1993",
        "startTime": "2025-03-19 10:07:33"
    },
    {
        "uid": 15,
        "point": "77, 455",
        "lot_type": 1,
        "asset": "nHorizontal23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 16,
        "point": "87, 431",
        "lot_type": 1,
        "asset": "nHorizontal23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "33도0355",
        "startTime": "2025-03-19 10:24:53"
    },
    {
        "uid": 17,
        "point": "166, 458",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "07오0867",
        "startTime": "2025-03-19 09:05:19"
    },
    {
        "uid": 18,
        "point": "190, 468",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "106머8929",
        "startTime": "2025-03-19 07:48:22"
    },
    {
        "uid": 19,
        "point": "220, 481",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "50너1347",
        "startTime": "2025-03-19 11:01:29"
    },
    {
        "uid": 20,
        "point": "244, 491",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "59더3252",
        "startTime": "2025-03-19 08:06:38"
    },
    {
        "uid": 21,
        "point": "268, 501",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "02너6994",
        "startTime": "2025-03-19 10:17:12"
    },
    {
        "uid": 22,
        "point": "299, 514",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "77러5781",
        "startTime": "2025-03-19 10:01:50"
    },
    {
        "uid": 23,
        "point": "323, 524",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "67우1941",
        "startTime": "2025-03-19 01:31:26"
    },
    {
        "uid": 24,
        "point": "347, 534",
        "lot_type": 1,
        "asset": "nVertical23.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "013구3154",
        "startTime": "2025-03-19 10:56:23"
    },
    {
        "uid": 25,
        "point": "668, 428",
        "lot_type": 2,
        "asset": "dVertical12.png",
        "isUsed": 0,
        "floor": "B1",
        "plate": "363오7892",
        "startTime": "2025-03-18 17:20:25"
    },
    {
        "uid": 26,
        "point": "744, 412",
        "lot_type": 2,
        "asset": "dVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "05마7415",
        "startTime": "2025-03-19 07:38:00"
    },
    {
        "uid": 27,
        "point": "718, 417",
        "lot_type": 2,
        "asset": "dVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "145버4820",
        "startTime": "2025-03-19 10:52:33"
    },
    {
        "uid": 28,
        "point": "723, 316",
        "lot_type": 2,
        "asset": "dVertical12.png",
        "isUsed": 0,
        "floor": "B1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 29,
        "point": "827, 394",
        "lot_type": 3,
        "asset": "mVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "27서6697",
        "startTime": "2025-03-19 08:25:26"
    },
    {
        "uid": 30,
        "point": "802, 399",
        "lot_type": 3,
        "asset": "mVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "41우3150",
        "startTime": "2025-03-18 20:16:39"
    },
    {
        "uid": 31,
        "point": "756, 309",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "03너9011",
        "startTime": "2025-03-19 10:57:54"
    },
    {
        "uid": 32,
        "point": "781, 303",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "40버1837",
        "startTime": "2025-03-19 07:06:57"
    },
    {
        "uid": 33,
        "point": "807, 298",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "59루1491",
        "startTime": "2025-03-19 09:36:15"
    },
    {
        "uid": 34,
        "point": "839, 291",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "41러9724",
        "startTime": "2025-03-19 10:40:24"
    },
    {
        "uid": 35,
        "point": "864, 286",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "54소1489",
        "startTime": "2025-03-19 01:37:11"
    },
    {
        "uid": 36,
        "point": "890, 280",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "54소1096",
        "startTime": "2025-03-19 06:23:24"
    },
    {
        "uid": 37,
        "point": "910, 376",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "320누9063",
        "startTime": "2025-03-19 11:05:39"
    },
    {
        "uid": 38,
        "point": "885, 382",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "07가3960",
        "startTime": "2025-03-19 07:19:05"
    },
    {
        "uid": 39,
        "point": "859, 387",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "279호7645",
        "startTime": "2025-03-19 11:09:29"
    },
    {
        "uid": 40,
        "point": "922, 274",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "54소1135",
        "startTime": "2025-03-19 07:32:17"
    },
    {
        "uid": 41,
        "point": "947, 268",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "135고1652",
        "startTime": "2025-03-19 07:38:41"
    },
    {
        "uid": 42,
        "point": "973, 263",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "101수8147",
        "startTime": "2025-03-19 07:34:51"
    },
    {
        "uid": 43,
        "point": "993, 359",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "36주1982",
        "startTime": "2025-03-19 07:16:32"
    },
    {
        "uid": 44,
        "point": "968, 364",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "19두0509",
        "startTime": "2025-03-19 09:04:44"
    },
    {
        "uid": 45,
        "point": "942, 369",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "60마2891",
        "startTime": "2025-03-19 11:11:25"
    },
    {
        "uid": 46,
        "point": "1026, 352",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "104너8586",
        "startTime": "2025-03-19 11:05:25"
    },
    {
        "uid": 47,
        "point": "1051, 346",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "228나3683",
        "startTime": "2025-03-19 07:46:55"
    },
    {
        "uid": 48,
        "point": "1076, 341",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "39오0355",
        "startTime": "2025-03-19 11:04:08"
    },
    {
        "uid": 49,
        "point": "1160, 323",
        "lot_type": 4,
        "asset": "pVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "23오7895",
        "startTime": "2025-03-19 11:02:53"
    },
    {
        "uid": 50,
        "point": "1134, 329",
        "lot_type": 4,
        "asset": "pVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "50너3021",
        "startTime": "2025-03-19 09:09:44"
    },
    {
        "uid": 51,
        "point": "1109, 334",
        "lot_type": 4,
        "asset": "pVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "160호5951",
        "startTime": "2025-03-19 10:57:45"
    },
    {
        "uid": 52,
        "point": "1130, 218",
        "lot_type": 2,
        "asset": "dVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "48가8098",
        "startTime": "2025-03-19 08:51:07"
    },
    {
        "uid": 53,
        "point": "559, 629",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "34주8584",
        "startTime": "2025-03-19 07:39:56"
    },
    {
        "uid": 54,
        "point": "610, 601",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "37부8859",
        "startTime": "2025-03-19 07:09:19"
    },
    {
        "uid": 55,
        "point": "693, 583",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "57보7267",
        "startTime": "2025-03-19 07:54:40"
    },
    {
        "uid": 56,
        "point": "668, 588",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "39모2605",
        "startTime": "2025-03-19 07:53:24"
    },
    {
        "uid": 57,
        "point": "642, 594",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "235서5501",
        "startTime": "2025-03-19 10:59:03"
    },
    {
        "uid": 58,
        "point": "629, 496",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "30루9136",
        "startTime": "2025-03-19 07:01:17"
    },
    {
        "uid": 59,
        "point": "654, 491",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "58누0730",
        "startTime": "2025-03-19 07:17:14"
    },
    {
        "uid": 60,
        "point": "680, 485",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "39오2050",
        "startTime": "2025-03-19 07:15:58"
    },
    {
        "uid": 61,
        "point": "776, 565",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "38루9255",
        "startTime": "2025-03-19 11:12:46"
    },
    {
        "uid": 62,
        "point": "751, 571",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "34버1218",
        "startTime": "2025-03-19 07:52:58"
    },
    {
        "uid": 63,
        "point": "726, 576",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "41보0851",
        "startTime": "2025-03-19 08:52:26"
    },
    {
        "uid": 64,
        "point": "705, 480",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "22로1452",
        "startTime": "2025-03-19 08:11:16"
    },
    {
        "uid": 65,
        "point": "731, 475",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "30나7319",
        "startTime": "2025-03-19 10:52:01"
    },
    {
        "uid": 66,
        "point": "756, 469",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "09어7801",
        "startTime": "2025-03-19 10:53:58"
    },
    {
        "uid": 67,
        "point": "788, 462",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "149라7083",
        "startTime": "2025-03-19 09:45:59"
    },
    {
        "uid": 68,
        "point": "814, 457",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "289버7781",
        "startTime": "2025-03-19 07:31:18"
    },
    {
        "uid": 69,
        "point": "839, 452",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "278거9734",
        "startTime": "2025-03-19 11:12:09"
    },
    {
        "uid": 70,
        "point": "860, 547",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "288저6047",
        "startTime": "2025-03-19 10:04:43"
    },
    {
        "uid": 71,
        "point": "834, 553",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "10서9264",
        "startTime": "2025-03-19 10:58:39"
    },
    {
        "uid": 72,
        "point": "809, 558",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "160호9915",
        "startTime": "2025-03-19 10:58:01"
    },
    {
        "uid": 73,
        "point": "871, 445",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "12러1000",
        "startTime": "2025-03-19 11:08:19"
    },
    {
        "uid": 74,
        "point": "897, 439",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "28버2940",
        "startTime": "2025-03-19 07:28:45"
    },
    {
        "uid": 75,
        "point": "922, 434",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "161더3246",
        "startTime": "2025-03-19 11:01:51"
    },
    {
        "uid": 76,
        "point": "1026, 512",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "38어2056",
        "startTime": "2025-03-19 07:44:03"
    },
    {
        "uid": 77,
        "point": "1001, 518",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "63저0916",
        "startTime": "2025-03-19 10:37:27"
    },
    {
        "uid": 78,
        "point": "975, 523",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "28너5479",
        "startTime": "2025-03-19 08:13:25"
    },
    {
        "uid": 79,
        "point": "955, 427",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "32주5685",
        "startTime": "2025-03-19 10:09:53"
    },
    {
        "uid": 80,
        "point": "980, 422",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "381가8864",
        "startTime": "2025-03-19 03:16:34"
    },
    {
        "uid": 81,
        "point": "1006, 416",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "61라7714",
        "startTime": "2025-03-19 10:19:31"
    },
    {
        "uid": 82,
        "point": "1038, 409",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "43저2439",
        "startTime": "2025-03-19 11:12:49"
    },
    {
        "uid": 83,
        "point": "1063, 404",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "26다5163",
        "startTime": "2025-03-18 17:20:45"
    },
    {
        "uid": 84,
        "point": "1089, 399",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "44하9174",
        "startTime": "2025-03-19 10:07:58"
    },
    {
        "uid": 85,
        "point": "1109, 494",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "22나9350",
        "startTime": "2025-03-19 07:14:45"
    },
    {
        "uid": 86,
        "point": "1084, 500",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "26다5767",
        "startTime": "2025-03-19 07:22:25"
    },
    {
        "uid": 87,
        "point": "1058, 505",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "175두3873",
        "startTime": "2025-03-19 06:00:47"
    },
    {
        "uid": 88,
        "point": "1192, 477",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "124주2750",
        "startTime": "2025-03-19 05:47:10"
    },
    {
        "uid": 89,
        "point": "1167, 482",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "353머3922",
        "startTime": "2025-03-19 07:31:47"
    },
    {
        "uid": 90,
        "point": "1141, 488",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "04무5896",
        "startTime": "2025-03-19 10:22:33"
    },
    {
        "uid": 91,
        "point": "1121, 392",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "33주5039",
        "startTime": "2025-03-19 10:52:05"
    },
    {
        "uid": 92,
        "point": "1146, 386",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "50나0576",
        "startTime": "2025-03-19 06:49:42"
    },
    {
        "uid": 93,
        "point": "1172, 381",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "70어6735",
        "startTime": "2025-03-19 10:39:53"
    },
    {
        "uid": 94,
        "point": "1292, 315",
        "lot_type": 5,
        "asset": "oVertical12.png",
        "isUsed": 0,
        "floor": "B1",
        "plate": "51오7526",
        "startTime": "2025-03-18 18:14:53"
    },
    {
        "uid": 95,
        "point": "1318, 310",
        "lot_type": 5,
        "asset": "oVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "175조8757",
        "startTime": "2025-03-19 01:46:13"
    },
    {
        "uid": 96,
        "point": "1343, 304",
        "lot_type": 5,
        "asset": "oVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "194호8697",
        "startTime": "2025-03-19 09:02:42"
    },
    {
        "uid": 97,
        "point": "1367, 183",
        "lot_type": 2,
        "asset": "dVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "68다3374",
        "startTime": "2025-03-19 10:04:50"
    },
    {
        "uid": 98,
        "point": "1393, 183",
        "lot_type": 2,
        "asset": "dVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "360거5209",
        "startTime": "2025-03-19 10:55:32"
    },
    {
        "uid": 99,
        "point": "1376, 297",
        "lot_type": 5,
        "asset": "oVertical12.png",
        "isUsed": 0,
        "floor": "B1",
        "plate": "36누1804",
        "startTime": "2025-03-19 05:58:08"
    },
    {
        "uid": 100,
        "point": "1401, 292",
        "lot_type": 5,
        "asset": "oVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "998두6210",
        "startTime": "2025-03-18 17:20:42"
    },
    {
        "uid": 101,
        "point": "1426, 287",
        "lot_type": 5,
        "asset": "oVertical12.png",
        "isUsed": 0,
        "floor": "B1",
        "plate": "121러8583",
        "startTime": "2025-03-19 05:52:22"
    },
    {
        "uid": 102,
        "point": "1459, 280",
        "lot_type": 5,
        "asset": "oVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "50나0593",
        "startTime": "2025-03-19 11:09:41"
    },
    {
        "uid": 103,
        "point": "1484, 274",
        "lot_type": 5,
        "asset": "oVertical12.png",
        "isUsed": 0,
        "floor": "B1",
        "plate": "50나0593",
        "startTime": "2025-03-18 17:20:55"
    },
    {
        "uid": 104,
        "point": "1220, 581",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "04무5027",
        "startTime": "2025-03-19 10:18:47"
    },
    {
        "uid": 105,
        "point": "1215, 556",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "57머1385",
        "startTime": "2025-03-19 06:36:23"
    },
    {
        "uid": 106,
        "point": "1209, 530",
        "lot_type": 6,
        "asset": "gHorizontal.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "54소1416",
        "startTime": "2025-03-19 10:36:45"
    },
    {
        "uid": 107,
        "point": "1238, 664",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "53너9986",
        "startTime": "2025-03-19 10:51:44"
    },
    {
        "uid": 108,
        "point": "1232, 639",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "717다6585",
        "startTime": "2025-03-19 07:44:50"
    },
    {
        "uid": 109,
        "point": "1227, 613",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "66주2883",
        "startTime": "2025-03-19 07:46:06"
    },
    {
        "uid": 110,
        "point": "1255, 747",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "04도3396",
        "startTime": "2025-03-19 07:58:53"
    },
    {
        "uid": 111,
        "point": "1250, 722",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "221거9831",
        "startTime": "2025-03-19 08:00:10"
    },
    {
        "uid": 112,
        "point": "1245, 697",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "286러1957",
        "startTime": "2025-03-19 07:55:03"
    },
    {
        "uid": 113,
        "point": "1268, 805",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "201더6509",
        "startTime": "2025-03-19 10:07:28"
    },
    {
        "uid": 114,
        "point": "1262, 780",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "17소2473",
        "startTime": "2025-03-19 11:05:16"
    },
    {
        "uid": 115,
        "point": "1345, 847",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "85보6202",
        "startTime": "2025-03-19 05:35:07"
    },
    {
        "uid": 116,
        "point": "1319, 847",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "54오2155",
        "startTime": "2025-03-19 08:08:13"
    },
    {
        "uid": 117,
        "point": "1409, 847",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "226어5501",
        "startTime": "2025-03-19 11:09:07"
    },
    {
        "uid": 118,
        "point": "1383, 847",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "209머2456",
        "startTime": "2025-03-19 11:09:07"
    },
    {
        "uid": 119,
        "point": "1356, 749",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "150소8001",
        "startTime": "2025-03-19 08:06:35"
    },
    {
        "uid": 120,
        "point": "1382, 749",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "209소4145",
        "startTime": "2025-03-19 08:09:08"
    },
    {
        "uid": 121,
        "point": "1494, 847",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "48수4115",
        "startTime": "2025-03-19 08:07:08"
    },
    {
        "uid": 122,
        "point": "1468, 847",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "170러6185",
        "startTime": "2025-03-19 08:02:41"
    },
    {
        "uid": 123,
        "point": "1442, 847",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "62다2652",
        "startTime": "2025-03-19 09:37:08"
    },
    {
        "uid": 124,
        "point": "1415, 749",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "64오4636",
        "startTime": "2025-03-19 11:04:01"
    },
    {
        "uid": 125,
        "point": "1441, 749",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "50부8642",
        "startTime": "2025-03-19 08:12:58"
    },
    {
        "uid": 126,
        "point": "1467, 749",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "09보7895",
        "startTime": "2025-03-19 11:09:47"
    },
    {
        "uid": 127,
        "point": "1579, 847",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "103우8571",
        "startTime": "2025-03-19 08:24:29"
    },
    {
        "uid": 128,
        "point": "1553, 847",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "998두6220",
        "startTime": "2025-03-18 17:21:00"
    },
    {
        "uid": 129,
        "point": "1527, 847",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 0,
        "floor": "B1",
        "plate": "101버7339",
        "startTime": "2025-03-19 10:40:15"
    },
    {
        "uid": 130,
        "point": "1500, 749",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "199하4606",
        "startTime": "2025-03-19 10:13:45"
    },
    {
        "uid": 131,
        "point": "1526, 749",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "129누3422",
        "startTime": "2025-03-19 08:28:45"
    },
    {
        "uid": 132,
        "point": "1552, 749",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "24노8827",
        "startTime": "2025-03-19 09:59:39"
    },
    {
        "uid": 133,
        "point": "1638, 847",
        "lot_type": 5,
        "asset": "oVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "179호5235",
        "startTime": "2025-03-18 17:21:01"
    },
    {
        "uid": 134,
        "point": "1612, 847",
        "lot_type": 5,
        "asset": "oVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 135,
        "point": "1585, 749",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "74오2907",
        "startTime": "2025-03-19 09:48:37"
    },
    {
        "uid": 136,
        "point": "1611, 749",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "265어9535",
        "startTime": "2025-03-19 08:12:11"
    },
    {
        "uid": 137,
        "point": "1637, 749",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 138,
        "point": "1670, 749",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "13보2812",
        "startTime": "2025-03-19 07:59:00"
    },
    {
        "uid": 139,
        "point": "1696, 749",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "815머3070",
        "startTime": "2025-03-19 08:31:34"
    },
    {
        "uid": 140,
        "point": "1722, 749",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "54구2659",
        "startTime": "2025-03-18 17:21:02"
    },
    {
        "uid": 141,
        "point": "1810, 847",
        "lot_type": 2,
        "asset": "dVertical.png",
        "isUsed": 0,
        "floor": "B1",
        "plate": "80다3352",
        "startTime": "2025-03-19 10:18:29"
    },
    {
        "uid": 142,
        "point": "1845, 797",
        "lot_type": 2,
        "asset": "dHorizontal12.png",
        "isUsed": 0,
        "floor": "B1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 143,
        "point": "1827, 714",
        "lot_type": 5,
        "asset": "oHorizontal.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "07가2400",
        "startTime": "2025-03-19 10:53:41"
    },
    {
        "uid": 144,
        "point": "1833, 739",
        "lot_type": 5,
        "asset": "oHorizontal.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "289너7635",
        "startTime": "2025-03-19 09:00:25"
    },
    {
        "uid": 145,
        "point": "1838, 764",
        "lot_type": 5,
        "asset": "oHorizontal.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 146,
        "point": "1705, 686",
        "lot_type": 1,
        "asset": "nHorizontal10.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "109머8024",
        "startTime": "2025-03-19 08:26:56"
    },
    {
        "uid": 147,
        "point": "1700, 661",
        "lot_type": 1,
        "asset": "nHorizontal10.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "151너7877",
        "startTime": "2025-03-19 08:19:54"
    },
    {
        "uid": 148,
        "point": "1809, 629",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "612보0397",
        "startTime": "2025-03-19 10:53:00"
    },
    {
        "uid": 149,
        "point": "1815, 655",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "05우7660",
        "startTime": "2025-03-19 08:19:16"
    },
    {
        "uid": 150,
        "point": "1820, 680",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "35수6882",
        "startTime": "2025-03-19 08:16:43"
    },
    {
        "uid": 151,
        "point": "1799, 579",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "21무5990",
        "startTime": "2025-03-19 08:02:51"
    },
    {
        "uid": 152,
        "point": "1804, 604",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "288소8151",
        "startTime": "2025-03-19 10:41:38"
    },
    {
        "uid": 153,
        "point": "1782, 502",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 154,
        "point": "1788, 528",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "356누8282",
        "startTime": "2025-03-19 07:32:39"
    },
    {
        "uid": 155,
        "point": "1793, 553",
        "lot_type": 1,
        "asset": "nHorizontal12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "334고4087",
        "startTime": "2025-03-19 11:12:52"
    },
    {
        "uid": 156,
        "point": "1703, 599",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "142로6076",
        "startTime": "2025-03-19 08:15:01"
    },
    {
        "uid": 157,
        "point": "1677, 599",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "39도0789",
        "startTime": "2025-03-19 08:06:43"
    },
    {
        "uid": 158,
        "point": "1645, 601",
        "lot_type": 1,
        "asset": "nVertical7.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "548무9490",
        "startTime": "2025-03-19 11:06:43"
    },
    {
        "uid": 159,
        "point": "1620, 604",
        "lot_type": 1,
        "asset": "nVertical7.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "31노5377",
        "startTime": "2025-03-18 17:55:49"
    },
    {
        "uid": 160,
        "point": "1594, 607",
        "lot_type": 1,
        "asset": "nVertical7.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "12더0956",
        "startTime": "2025-03-19 08:32:55"
    },
    {
        "uid": 161,
        "point": "1509, 617",
        "lot_type": 1,
        "asset": "nVertical7.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "142거9750",
        "startTime": "2025-03-19 08:17:36"
    },
    {
        "uid": 162,
        "point": "1535, 614",
        "lot_type": 1,
        "asset": "nVertical7.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "398우2887",
        "startTime": "2025-03-19 08:20:09"
    },
    {
        "uid": 163,
        "point": "1561, 611",
        "lot_type": 1,
        "asset": "nVertical7.png",
        "isUsed": 0,
        "floor": "B1",
        "plate": "41라9787",
        "startTime": "2025-03-19 08:14:24"
    },
    {
        "uid": 164,
        "point": "1542, 508",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "11무1787",
        "startTime": "2025-03-19 11:07:24"
    },
    {
        "uid": 165,
        "point": "1516, 514",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "167다3457",
        "startTime": "2025-03-19 08:30:23"
    },
    {
        "uid": 166,
        "point": "1491, 519",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 0,
        "floor": "B1",
        "plate": "306고3034",
        "startTime": "2025-03-19 08:13:08"
    },
    {
        "uid": 167,
        "point": "1479, 622",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "59구0671",
        "startTime": "2025-03-19 07:58:28"
    },
    {
        "uid": 168,
        "point": "1453, 627",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "65모6225",
        "startTime": "2025-03-19 02:28:39"
    },
    {
        "uid": 169,
        "point": "1428, 633",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "137나7935",
        "startTime": "2025-03-19 11:07:24"
    },
    {
        "uid": 170,
        "point": "1407, 537",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "65모4611",
        "startTime": "2025-03-19 10:22:27"
    },
    {
        "uid": 171,
        "point": "1433, 531",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "24조1547",
        "startTime": "2025-03-19 08:06:08"
    },
    {
        "uid": 172,
        "point": "1458, 526",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "107마7227",
        "startTime": "2025-03-19 08:08:43"
    },
    {
        "uid": 173,
        "point": "1396, 640",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "381고3725",
        "startTime": "2025-03-19 10:53:43"
    },
    {
        "uid": 174,
        "point": "1370, 645",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "256주3279",
        "startTime": "2025-03-19 07:58:17"
    },
    {
        "uid": 175,
        "point": "1345, 650",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "201거1743",
        "startTime": "2025-03-19 10:41:32"
    },
    {
        "uid": 176,
        "point": "1324, 554",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "40무0537",
        "startTime": "2025-03-19 09:26:18"
    },
    {
        "uid": 177,
        "point": "1350, 549",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "771어3085",
        "startTime": "2025-03-19 11:10:25"
    },
    {
        "uid": 178,
        "point": "1375, 544",
        "lot_type": 1,
        "asset": "nVertical12.png",
        "isUsed": 1,
        "floor": "B1",
        "plate": "22너6574",
        "startTime": "2025-03-19 11:11:04"
    },
    {
        "uid": 179,
        "point": "643,170",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 180,
        "point": "643,196",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 181,
        "point": "643,222",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 182,
        "point": "643,248",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 183,
        "point": "643,274",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 184,
        "point": "643,300",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 185,
        "point": "643,326",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 186,
        "point": "643,352",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 187,
        "point": "643,378",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 188,
        "point": "643,404",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 189,
        "point": "643,430",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 190,
        "point": "643,456",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 191,
        "point": "643,482",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 192,
        "point": "643,508",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 193,
        "point": "643,534",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 194,
        "point": "643,560",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 195,
        "point": "643,586",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 196,
        "point": "643,612",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 197,
        "point": "643,638",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 198,
        "point": "643,664",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 199,
        "point": "643,690",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 200,
        "point": "643,716",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 201,
        "point": "643,742",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 202,
        "point": "643,768",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 203,
        "point": "643,794",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 204,
        "point": "643,820",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 205,
        "point": "643,846",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 206,
        "point": "643,872",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 207,
        "point": "643,898",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 208,
        "point": "643,924",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 209,
        "point": "643,950",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 210,
        "point": "879,196",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 211,
        "point": "879,222",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 212,
        "point": "879,248",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 213,
        "point": "879,274",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 214,
        "point": "879,300",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 215,
        "point": "879,326",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 216,
        "point": "879,352",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 217,
        "point": "879,378",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 218,
        "point": "879,404",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 219,
        "point": "879,430",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 220,
        "point": "879,456",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 221,
        "point": "879,482",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 222,
        "point": "879,508",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 223,
        "point": "879,534",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 224,
        "point": "879,560",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 225,
        "point": "879,586",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 226,
        "point": "879,612",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 227,
        "point": "879,638",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 228,
        "point": "879,664",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 229,
        "point": "879,690",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 230,
        "point": "879,716",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 231,
        "point": "879,742",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 232,
        "point": "879,768",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 233,
        "point": "879,794",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 234,
        "point": "879,820",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 235,
        "point": "879,846",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 236,
        "point": "879,872",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 237,
        "point": "879,898",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 238,
        "point": "934,196",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 239,
        "point": "934,222",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 240,
        "point": "934,248",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 241,
        "point": "934,274",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 242,
        "point": "934,300",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 243,
        "point": "934,326",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 244,
        "point": "934,352",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 245,
        "point": "934,378",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 246,
        "point": "934,404",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 247,
        "point": "934,430",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 248,
        "point": "934,456",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 249,
        "point": "934,482",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 250,
        "point": "934,508",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 251,
        "point": "934,534",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 252,
        "point": "934,560",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 253,
        "point": "934,586",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 254,
        "point": "934,612",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 255,
        "point": "934,638",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 256,
        "point": "934,664",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 257,
        "point": "934,690",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 258,
        "point": "934,716",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 259,
        "point": "934,742",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 260,
        "point": "934,768",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 261,
        "point": "934,794",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 262,
        "point": "934,820",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 263,
        "point": "934,846",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 264,
        "point": "934,872",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 265,
        "point": "934,898",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 266,
        "point": "678,999",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 267,
        "point": "704,999",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 268,
        "point": "730,999",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 269,
        "point": "756,999",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 270,
        "point": "782,999",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 271,
        "point": "808,999",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 272,
        "point": "834,999",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 273,
        "point": "860,999",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 274,
        "point": "886,999",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 275,
        "point": "912,999",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 276,
        "point": "938,999",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 277,
        "point": "989,196",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 278,
        "point": "989,222",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 279,
        "point": "989,248",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 280,
        "point": "989,274",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 281,
        "point": "989,300",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 282,
        "point": "989,326",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 283,
        "point": "989,352",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 284,
        "point": "989,378",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 285,
        "point": "989,404",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 286,
        "point": "989,430",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 287,
        "point": "989,456",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 288,
        "point": "989,482",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 289,
        "point": "989,508",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 290,
        "point": "989,534",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 291,
        "point": "989,560",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 292,
        "point": "989,586",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 293,
        "point": "989,612",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 294,
        "point": "989,638",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 295,
        "point": "989,664",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 296,
        "point": "989,690",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 297,
        "point": "989,716",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 298,
        "point": "989,742",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 299,
        "point": "989,768",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 300,
        "point": "1044,196",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 301,
        "point": "1044,222",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 302,
        "point": "1044,248",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 303,
        "point": "1044,274",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 304,
        "point": "1044,300",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 305,
        "point": "1044,326",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 306,
        "point": "1044,352",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 307,
        "point": "1044,378",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 308,
        "point": "1044,404",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 309,
        "point": "1044,430",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 310,
        "point": "1044,456",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 311,
        "point": "1044,482",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 312,
        "point": "1044,508",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 313,
        "point": "1044,534",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 314,
        "point": "1044,560",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 315,
        "point": "1044,586",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 316,
        "point": "1044,612",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 317,
        "point": "1044,638",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 318,
        "point": "1044,664",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 319,
        "point": "1044,690",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 320,
        "point": "1044,716",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 321,
        "point": "1044,742",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 322,
        "point": "1044,768",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 323,
        "point": "1199,196",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 324,
        "point": "1199,222",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 325,
        "point": "1199,248",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 326,
        "point": "1199,274",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 327,
        "point": "1199,300",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 328,
        "point": "1199,326",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 329,
        "point": "1199,352",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 330,
        "point": "1199,378",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 331,
        "point": "1199,404",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 332,
        "point": "1199,430",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 333,
        "point": "1199,456",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 334,
        "point": "1199,482",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 335,
        "point": "1199,508",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 336,
        "point": "1199,534",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 337,
        "point": "1199,560",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 338,
        "point": "1199,586",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 339,
        "point": "1199,612",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 340,
        "point": "1199,638",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 341,
        "point": "1199,664",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 342,
        "point": "1254,196",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 343,
        "point": "1254,222",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 344,
        "point": "1254,248",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 345,
        "point": "1254,274",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 346,
        "point": "1254,300",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 347,
        "point": "1254,326",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 348,
        "point": "1254,352",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 349,
        "point": "1254,378",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 350,
        "point": "1254,404",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 351,
        "point": "1254,430",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 352,
        "point": "1254,456",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 353,
        "point": "1254,482",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 354,
        "point": "1254,508",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 355,
        "point": "1254,534",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 356,
        "point": "1254,560",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 357,
        "point": "1254,586",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 358,
        "point": "1254,612",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 359,
        "point": "1254,638",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 360,
        "point": "1254,664",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 361,
        "point": "964,947",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 362,
        "point": "990,947",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 363,
        "point": "1016,947",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 364,
        "point": "1042,947",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 365,
        "point": "1068,947",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 366,
        "point": "1094,947",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 367,
        "point": "1120,947",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 368,
        "point": "1146,947",
        "lot_type": 1,
        "asset": "nVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 369,
        "point": "1185,882",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 370,
        "point": "1185,908",
        "lot_type": 1,
        "asset": "nHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 371,
        "point": "1303,136",
        "lot_type": 2,
        "asset": "dHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 372,
        "point": "1303,162",
        "lot_type": 2,
        "asset": "dHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 373,
        "point": "1303,188",
        "lot_type": 2,
        "asset": "dHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 374,
        "point": "1303,352",
        "lot_type": 2,
        "asset": "dHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 375,
        "point": "1303,378",
        "lot_type": 2,
        "asset": "dHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 376,
        "point": "1303,404",
        "lot_type": 2,
        "asset": "dHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 377,
        "point": "1303,664",
        "lot_type": 2,
        "asset": "dHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 378,
        "point": "1303,690",
        "lot_type": 2,
        "asset": "dHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 379,
        "point": "926,75",
        "lot_type": 7,
        "asset": "eVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 380,
        "point": "952,97",
        "lot_type": 7,
        "asset": "eVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 381,
        "point": "978,97",
        "lot_type": 7,
        "asset": "eVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 382,
        "point": "1004,97",
        "lot_type": 7,
        "asset": "eVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 383,
        "point": "1030,97",
        "lot_type": 7,
        "asset": "eVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 384,
        "point": "1056,97",
        "lot_type": 7,
        "asset": "eVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 385,
        "point": "1082,97",
        "lot_type": 7,
        "asset": "eVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 386,
        "point": "1108,97",
        "lot_type": 7,
        "asset": "eVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 387,
        "point": "1108,97",
        "lot_type": 7,
        "asset": "eVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 388,
        "point": "1134,97",
        "lot_type": 7,
        "asset": "eVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 389,
        "point": "1160,97",
        "lot_type": 7,
        "asset": "eVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 390,
        "point": "1186,97",
        "lot_type": 7,
        "asset": "eVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 391,
        "point": "1212,97",
        "lot_type": 7,
        "asset": "eVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 392,
        "point": "1238,97",
        "lot_type": 7,
        "asset": "eVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 393,
        "point": "714,75",
        "lot_type": 8,
        "asset": "fVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 394,
        "point": "740,75",
        "lot_type": 8,
        "asset": "fVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 395,
        "point": "766,75",
        "lot_type": 8,
        "asset": "fVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 396,
        "point": "792,75",
        "lot_type": 8,
        "asset": "fVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 397,
        "point": "818,75",
        "lot_type": 8,
        "asset": "fVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 398,
        "point": "844,75",
        "lot_type": 8,
        "asset": "fVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 399,
        "point": "870,75",
        "lot_type": 8,
        "asset": "fVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 400,
        "point": "896,75",
        "lot_type": 8,
        "asset": "fVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 401,
        "point": "922,75",
        "lot_type": 8,
        "asset": "fVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 402,
        "point": "848,75",
        "lot_type": 8,
        "asset": "fVertical.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 403,
        "point": "874,75",
        "lot_type": 8,
        "asset": "fVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 404,
        "point": "900,75",
        "lot_type": 8,
        "asset": "fVertical.png",
        "isUsed": 1,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 405,
        "point": "643,118",
        "lot_type": 9,
        "asset": "lHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 406,
        "point": "643,144",
        "lot_type": 9,
        "asset": "lHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 407,
        "point": "989,170",
        "lot_type": 9,
        "asset": "lHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    },
    {
        "uid": 408,
        "point": "989,794",
        "lot_type": 9,
        "asset": "lHorizontal.png",
        "isUsed": 0,
        "floor": "F1",
        "plate": null,
        "startTime": null
    }
]
```
</details>

  -  앞 8개 int 값 : lot_type 순서대로 주차현황을 return
  - xbottomright : 지정된 주차장의 x 길이
  - ybottomright : 지정된 주차장의 y 길이
  - uid : 주차장 순번.
  - lot_type: 차종 관련 정보
  - tag : 해당 주차칸에 부여된 인식 코드
  - code_format : 표시 형식을 나타냄. ex) lot_type이 N일시 Nxxx 형태로 나타냄
  - isUsed : 주차중 유무를 나타냄.
  - point : 해당 주차칸에 부여된 위치 좌표
  - asset : 해당 주차칸의 방향 및 차종을 나타냄
  - plate : 차번호
  - startTime : 해당 차가 주차가 시작된 시각

#### multiple_electric_signs.dart(/multiple_electric_signs)
  - ('/') : multiple_signs table의 모든 column을 select해서 response한다.
  - ('/insert') : multiple_signs table에 uid, parking_lot을 insert한다. uid가 이미 table에 있으면 409를 return한다.
  - ('/update') : multiple_signs table uid가 같은 row의 parking_lot을 update한다.
  - ('/delete') : multiple_signs table uid가 같은 row를 삭제한다.

#### pabi.dart(/pabi)(Parking Area Vehicle Information.dart)
  - ('/tag') : tb_lots table에서 tag를 조건으로 tag, plate, startTime을 SELECT한다.
  - ('/car') : tb_lots table에서 plate가 뒷부분이 동일한 차번호의 tag, plate, startTime을 전부 SELECT한다.

| /route 사용 예 | Method | Type and Value | Example input | Example output |
|---------------|--------|---------------|---------------|---------------|
| `http://type-server-ip/pabi/tag` | POST | STRING | `{"tag":"B1_E06_1_N102"}` | ```json {"tag": "B1_E06_1_N102", "plate": "62다2652", "startTime": "2025-03-19 09:37:08"} ``` |
| `http://type-server-ip/pabi/car` | POST | STRING | `{"plate" : "3836"}` | ```json [ {"tag": "B1_A01_1_N002", "plate": "12어3836", "startTime": "2025-03-19 08:00:49"} ] ``` |

#### receive_enginedata_send_to_dartserver.dart (route not exist)
  - n초마다(현재 설정으로는 2초) engine에서 json을 받아, 'tb_lots' Update, 'tb_lot_status' Insert 진행. 1시간, 1일, 1달, 1년 정각마다 'processed_db', 'perday', 'permonth', 'peryear' table에 통계를 내서 저장한다.

#### settings.dart(/settings)
  - 설정 관련 클래스
  - ('/') : settings table에 key , value column에 각각 key value 형식으로 정보를 upsert 하는 방식
  - ('/get') : settings table에 key를 입력해서 해당하는걸 찾아서 response한다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/settings | POST | STRING,JSON | {"key":"test","value":json타입의 무언가} | 200 |
| http://type-server-ip/settings/get | POST | String | {"key" : "test"} | {"uid":1, "key":"test", "value": EncodeJson 형식} |

#### setting_account.dart (/settings/account)
  - 사용자 관리 클래스
  - ('/') : 'tb_users' 에서 account, username. userlevel를 select해서 response
  - ('/updateUser') : account를 Where로 한 'tb_users' table의 passwd, username, userlevel, isActivated column을 update한다.
  - ('/changePassword') : account, passwd, passCheck, newpasswd를 입력받아, passwd, passCheck, newpasswd 각각의 합치여부를 확인 후, 'tb_users' table의 passwd를 비교하고, update 후 reaponse한다. 
  - ('/insertUser') : 'tb_users' table에  account, passwd, username, userlevel, isActivated column을 insert한다.
  - ('/deleteUser') : 'tb_users' table에 account를 where로 한 rows를 삭제한다.
  - ('/resetPassword') : account를 입력받아, 'tb_users'에서 account를 where로 비교후, 해당 account가 일치한 column의 passwd를 '미리 지정한 비밀번호'로 초기화한다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/settings/account | GET | X | X | [{"account":"testid","username":null,"userlevel":0,"isActivated":1}] |
| http://type-server-ip/settings/account/updateUser | POST | String,INT | {"account" : "testid", "username" : "updatecheck","userlevel" : 2,"isActivated" : 1 } | update success |
| http://type-server-ip/settings/account/changePassword | POST | String | { "account": "testid", "passwd" : "1234", "passwdCheck":"1234", "newpasswd": "12345" } | update success |
| http://type-server-ip/settings/account/insertUser | POST | String,INT | {"account" : "testid2","passwd" : "1234","passwdCheck" : "1235","username" : "updatecheck","userlevel" : 1,"isActivated" : 1 } | 비밀번호 확인 요망 |
| http://type-server-ip/settings/account/deleteUser | POST | String | {"account" : "testid2", "passwd" : "1234"} | delete success |
| http://type-server-ip/settings/account/resetPassword | POST | String | {"account" : "testid2"} | reset success |

#### settings_cam_parking_area.dart (/settings/cam_parking_area)
  - 주차구역 관련 라우트 클래스
  - ('/') : 'tb_parking_surface' 에서 tag, engine_code. uri를 select해서 response
  - ('/updateZone') : tag를 Where로 한 'tb_parking_surface' table을 select 하고, uid를 Where로 하는 'tb_parking_surface'의 tag, engine_code, uri를 update한다.
  - 카메라, 주차면 관련 정보 설정 창 관련 클래스
  - ('/insertZone') : 'tb_parking_surface' table에 tag, engine_code, uri column을 insert한다.
  - ('/deleteZone') : 'tb_parking_surface' table에 tag를 Where로 한 rows를 삭제한다.

#### settings_db_management.dart (/settings/db_management)
  - db 세팅 관련 정보 설정 창 관련 클래스
  - ('/engine') : tb_db_setting에 저장된 engine_db_addr column을 입력값으로 Update한다.
  - ('/display') : tb_db_setting에 저장된 display_db_addr column을 입력값으로 Update한다.

#### settings_parking_area.dart (/settings/parking_area)
  - 주차장 상세 정보 설정 창 관련 클래스.
  - ('/') : 'tb_parking_zone'을 select해서 response
  - ('/updateFile') : 'tb_parking_zone' table에 parking_name, file_address를 insert하고, pakring_name을 where로 하는 rows를 삭제한다.
  - ('/insertFile') : 'tb_parking_zone' table에 parking_name, file_address를 insert한다.
  - ('/deleteFile') : 'tb_parking_zone' table에 pakring_name을 where로 하는 rows를 삭제한다.
  - ('/ChangeLotType') : 'tb_lots' table에 tag를 찾고, tag를 changed_tag로 수정하고, 동일 행의 lot_type을 update한다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/settings/parking_area | GET | X | X | [[{"uid":1,"parking_name":"지상1층.json","file_address":"bin/data/json_folder/지상1층.json"},{"uid":2,"parking_name":"지하1층.json","file_address":"bin/data/json_folder/지하1층.json"}] |
| http://type-server-ip/settings/parking_area/updateFile | POST | String, File | {"account" : "testid2","passwd" : "1234","passwdCheck" : "1235","username" : "updatecheck","userlevel" : 1,"isActivated" : 1 } | 비밀번호 확인 요망 |
| http://type-server-ip/settings/parking_area/deleteFile | POST | String | {"account" : "testid2","passwd" : "1234" } | delete success |
| http://type-server-ip/settings/parking_area/ChangeLotType | POST | String | { "changed_tag":"F1_A08_3_L099", "lot_type":3, "tag":"F1_A08_3_N024"} | 차종 변경완료 |

#### statistics_cam_parking_area.dart (/statistics/cam_parking_area)
  - 통계를 select하는 라우트가 모인 클래스이다.
  - ('/oneDay') : processed_db table에서 car_type, hour_parking, recorded_hour column을 전일 0시부터 현재 시각까지 select 한다.
  - ('/oneWeek') : processed_db table에서 car_type, day_parking, recorded_day column을 저번주 시작일인 일요일 부터 당일까지 select 한다. ex) 20240820에 router 요청 시, 20240811부터 select
  - ('/oneMonth') : processed_db table에서 car_type, day_parking, recorded_day column을 저번달과 이번달을 select 한다.
  - ('/oneYear') : processed_db table에서 car_type, month_parking, recorded_month column을 select 한다.
  - ('/sevealYears') : processed_db table에서 car_type, year_parking, recorded_year column을 select 한다.
  - ('/searchDay') : startDay, endDay를 입력받아, startDay부터 endDay 사이의 일간 데이터를 select한다.
  - ('/searchgraph') :startDay, endDay를 입력받아, startDay부터 endDay 까지 일간 데이터를 select한다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/statistics/cam_parking_area/oneDay | GET | X | X | [ [ {"car_type":1,"hour_parking":1,"recorded_hour":"2024-7-3 15"},....] |
| http://type-server-ip/statistics/cam_parking_area/oneWeek | GET | X | X | [ {"car_type":1,"hour_parking":1,"recorded_hour":"2024-7-3 15"},....] |
| http://type-server-ip/statistics/cam_parking_area/oneMonth | GET | X | X | {"car_type":1,"hour_parking":1,"recorded_hour":"2024-7-3"},....] |
| http://type-server-ip/statistics/cam_parking_area/oneYear | GET | X | X | [ {"car_type":1,"hour_parking":1,"recorded_hour":"2024-7"},....] |
| http://type-server-ip/statistics/cam_parking_area/severalYeears | GET | X | X | [ {"car_type":1,"hour_parking":1,"recorded_hour":"2024"},....] |
| http://type-server-ip/statistics/cam_parking_area/searchDay| POST| X | {"startDay":"2024-11-19", "endDay":"2024-11-20"} | [ {"car_type":1,"hour_parking":1,"recorded_hour":"2024"},....] |
| http://type-server-ip/statistics/cam_parking_area/searchgraph| POST| X | {"startDay":"2024-11-19", "endDay":"2024-11-20"} | [ {"car_type":1,"hour_parking":1,"recorded_hour":"2024"},....] |

#### manage_address.dart (route 없음)
  - 서버 내에서 front DB와 engine DB의 주소를 담아두는 클래스.

#### ping.dart (/ping)
  - ping을 날려서 확인해야할 목록들이 전부 연결중인지 연결중인지에 대한 결과를 가져온다.
  - ('/') : ping table에서 name, isalive column을 가져온다.

| /route 사용 예 | POST,GET | Type and Value | Example input | Example output|
| ------ | ------ | ------ | ------ | ------ |
| http://type-server-ip/ping | GET | X | X | [ [ {name: S06, isalright: 1}, {name: C08, isalright: 1}, {name: S05, isalright: 1}, {name: S01, isalright: 1}, {name: S07, isalright: 1}, {name: S04, isalright: 1}, {name: S02, isalright: 1}, {name: S03, isalright: 1}, {name: A02, isalright: 1}, {name: S17, isalright: 1}, {name: S10, isalright: 1}, {name: A01, isalright: 1}, {name: S14, isalright: 1}, {name: A03, isalright: 1}, {name: A07, isalright: 1}, {name: S16, isalright: 1}, {name: S12, isalright: 1}, {name: S13, isalright: 1}, {name: A04, isalright: 1}, {name: S11, isalright: 1}, {name: S09, isalright: 1}, {name: A08, isalright: 1}, {name: C01, isalright: 1}, {name: C05, isalright: 1}, {name: B05, isalright: 1}, {name: S08, isalright: 1}, {name: A06, isalright: 1}, {name: C03, isalright: 1}, {name: A05, isalright: 1}, {name: B04, isalright: 1}, {name: B08, isalright: 1}, {name: C02, isalright: 1}, {name: B01, isalright: 1}, {name: C04, isalright: 1}, {name: D02, isalright: 1}, {name: E05, isalright: 1}, {name: F03, isalright: 1}, {name: C06, isalright: 1}, {name: E02, isalright: 1}, {name: B03, isalright: 1}, {name: E06, isalright: 1}, {name: D03, isalright: 1}, {name: B07, isalright: 1}, {name: S15, isalright: 1}, {name: A09, isalright: 1}, {name: C07, isalright: 1}, {name: B02, isalright: 1}, {name: B06, isalright: 1}, {name: F05, isalright: 1}, {name: G01, isalright: 1}, {name: E01, isalright: 1}, {name: F07, isalright: 1}, {name: G04, isalright: 1}, {name: F02, isalright: 1}, {name: E03, isalright: 1}, {name: H03, isalright: 1}, {name: E04, isalright: 1}, {name: F01, isalright: 1}, {name: G02, isalright: 1}, {name: G05, isalright: 1}, {name: H02, isalright: 1}, {name: D01, isalright: 1}, {name: G03, isalright: 1}, {name: F04, isalright: 1}, {name: G06, isalright: 1}, {name: F06, isalright: 1}, {name: H01, isalright: 1}, {name: billboard2, isalright: 1}, {name: billboard1, isalright: 1}, {name: display, isalright: 0}, {name: controlroom, isalright: 0}, {name: serveserver, isalright: 0}]} |