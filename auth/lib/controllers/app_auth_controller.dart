import 'package:auth/models/response_model.dart';
import 'package:conduit/conduit.dart';

import '../models/user.dart';

class AppAuthController extends ResourceController {
  final ManagedContext managedContext;

  AppAuthController(this.managedContext);

  @Operation.post()
  Future<Response> signIn(@Bind.body() User user) async {
    if (user.password == null || user.username == null) {
      return Response.badRequest(
          body: ResponseModel(
              message: 'Fields password and username are required'));
    }

    final User fetchedUser = User();

    // connect to DB
    // find user
    // check password
    // fetch user

    return Response.ok(ResponseModel(data: {
      'id': fetchedUser.id,
      'refreshToken': fetchedUser.refreshToken,
      'accessToken': fetchedUser.accessToken,
    }, message: 'Successful authorization')
        .toJson());
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password == null || user.username == null || user.email == null) {
      return Response.badRequest(
          body: ResponseModel(
              message: 'Fields password, username and email are required'));
    }

    final User fetchedUser = User();

    // connect to DB
    // create user
    // fetch user

    return Response.ok(ResponseModel(data: {
      'id': fetchedUser.id,
      'refreshToken': fetchedUser.refreshToken,
      'accessToken': fetchedUser.accessToken,
    }, message: 'Successful registration')
        .toJson());
  }

  @Operation.post('refresh')
  Future<Response> refreshToken(
      @Bind.path('refresh') String refreshToken) async {
    final User fetchedUser = User();

    // connect to DB
    // find user
    // check token
    // fetch user

    return Response.ok(ResponseModel(data: {
      'id': fetchedUser.id,
      'refreshToken': fetchedUser.refreshToken,
      'accessToken': fetchedUser.accessToken,
    }, message: 'Successful refresh tokens')
        .toJson());
  }
}
