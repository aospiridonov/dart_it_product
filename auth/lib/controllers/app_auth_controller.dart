import 'dart:io';

import 'package:auth/models/response_model.dart';
import 'package:auth/utils/app_const.dart';
import 'package:auth/utils/app_response.dart';
import 'package:auth/utils/app_utils.dart';
import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

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

    try {
      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.username).equalTo(user.username)
        ..returningProperties(
            (table) => [table.id, table.salt, table.hashPassword]);
      final findUser = await qFindUser.fetchOne();
      if (findUser == null) {
        throw QueryException.input('User is not found', []);
      }
      final requestHashPassword =
          generatePasswordHash(user.password ?? '', findUser.salt ?? '');
      if (requestHashPassword == findUser.hashPassword) {
        await _updateTokens(findUser.id ?? -1, managedContext);
        final newUser =
            await managedContext.fetchObjectWithID<User>(findUser.id);
        return AppResponse.ok(
          body: newUser?.backing.contents,
          message: 'Successful authorization',
        );
      } else {
        throw QueryException.input('Wrong password', []);
      }
    } catch (error) {
      return AppResponse.serverError(error, message: 'Authorization Error');
    }
  }

  @Operation.put()
  Future<Response> signUp(@Bind.body() User user) async {
    if (user.password == null || user.username == null || user.email == null) {
      return Response.badRequest(
          body: ResponseModel(
              message: 'Fields password, username and email are required'));
    }
    final salt = generateRandomSalt();
    final hashPassword = generatePasswordHash(user.password ?? "", salt);

    try {
      late final int id;
      await managedContext.transaction((transaction) async {
        final qCreateUser = Query<User>(transaction)
          ..values.username = user.username
          ..values.email = user.email
          ..values.salt = salt
          ..values.hashPassword = hashPassword;
        final createdUser = await qCreateUser.insert();
        id = createdUser.asMap()['id'];
        await _updateTokens(id, transaction);
      });
      final userData = await managedContext.fetchObjectWithID<User>(id);
      return AppResponse.ok(
        body: userData?.backing.contents,
        message: 'Successful registration',
      );
    } catch (error) {
      return AppResponse.serverError(error, message: 'Registration Error');
    }
  }

  @Operation.post('refresh')
  Future<Response> refreshToken(
      @Bind.path('refresh') String refreshToken) async {
    try {
      final id = AppUtils.getIdFromToken(refreshToken);
      final user = await managedContext.fetchObjectWithID<User>(id);
      if (user?.refreshToken != refreshToken) {
        return Response.unauthorized(
            body: ResponseModel(message: 'Token is not valid'));
      } else {
        await _updateTokens(id, managedContext);
        final user = await managedContext.fetchObjectWithID<User>(id);
        return AppResponse.ok(
          body: user?.backing.contents,
          message: 'Successful refresh of tokens',
        );
      }
    } catch (error) {
      return AppResponse.serverError(error, message: 'Error refresh token');
    }
  }

  Future<void> _updateTokens(int id, ManagedContext transaction) async {
    final Map<String, dynamic> tokens = _getTokens(id);
    final qUpdateTokens = Query<User>(transaction)
      ..where((user) => user.id).equalTo(id)
      ..values.accessToken = tokens['access']
      ..values.refreshToken = tokens['refresh'];
    await qUpdateTokens.updateOne();
  }

  Map<String, dynamic> _getTokens(int id) {
    final key = AppConst.secretKey;
    final accessClaimSet =
        JwtClaim(maxAge: Duration(hours: 1), otherClaims: {'id': id});
    final refreshClaimSet = JwtClaim(otherClaims: {'id': id});
    final tokens = <String, dynamic>{};
    tokens['access'] = issueJwtHS256(accessClaimSet, key);
    tokens['refresh'] = issueJwtHS256(refreshClaimSet, key);
    return tokens;
  }
}
