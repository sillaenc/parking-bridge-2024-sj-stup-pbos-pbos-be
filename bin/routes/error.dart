/// Parking Area Vehicle Information.dart
/// 
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../data/manage_address.dart';
import 'package:http/http.dart' as http;
import '../data/global.dart';

class Error {
  final ManageAddress manageAddress;
  Error({required this.manageAddress});
  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
    try {
      if (error.isEmpty) {
        return Response.ok(
          '0',
          headers: {'content-type': 'text/plain; charset=utf-8'},
        );
      } else {
        final jsonBody = jsonEncode(error);
        return Response.ok(
          jsonBody,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }
    } catch (e, stackTrace) {
      print('Error: $e');
      print('StackTrace: $stackTrace');
      return Response.badRequest(body: 'Error: $e');
    }
  });

    return router;
  }
}
