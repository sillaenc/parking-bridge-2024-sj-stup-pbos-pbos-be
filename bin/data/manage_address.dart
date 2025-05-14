// /bin/data/manage_address.dart


class ManageAddress {
  
  String? engineDbAddr;
  String? displayDbAddr;
  String? displayDbLPR;
  //displayDbAddr을 제대로 입력해야 404에러가 안뜨고, 추후 작업이 이루어질 수 있다. 해당 내용은 프론트에서 response로 참고할 것.
  //engineDbAddr은 실제로 실행되고 있는 엔진을 입력해야 정보가 displayAddr로 insert가 된다.
  ManageAddress({this.engineDbAddr, this.displayDbAddr, this.displayDbLPR});

  factory ManageAddress.fromJson(Map<String, dynamic> json) {
    return ManageAddress(
      engineDbAddr: json['engine_db_addr'],
      displayDbAddr: json['display_db_addr'],
      displayDbLPR:json['display_db_lpr']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['engine_db_addr'] = engineDbAddr;
    data['display_db_addr'] = displayDbAddr;
    data['display_db_lpr'] = displayDbLPR;
    return data;
  }
}
