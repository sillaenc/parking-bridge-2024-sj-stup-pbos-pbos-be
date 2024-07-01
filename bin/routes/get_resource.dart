import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:http/http.dart' as http;
import '../data/manage_address.dart';

class GetResource {
  final ManageAddress manageAddress;
  GetResource({required this.manageAddress});
  
  Router get router {
    final router = Router();
    String? url = manageAddress.displayDbAddr;
    var headers = {'Content-Type': 'application/json'};
    //base_return router
    router.get('/', (Request request) async {
      var body = {
        "transaction": [
          {"query": "SELECT * FROM multiple_signs"}
        ]
      };
      var response = await http.post(
        Uri.parse(url!),
        headers: headers,
        body: jsonEncode(body),
      );
      //var db = jsonDecode(utf8.decode(response.bodyBytes));
      var db = jsonDecode(response.body);
      var dbSet = db['results'][0]['resultSet'];
      var info = jsonEncode(dbSet);
      print(info);
      return Response.ok(info);
    });
    
    return router;
  }
}