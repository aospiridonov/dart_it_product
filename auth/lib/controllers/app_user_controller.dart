import 'dart:io';

import 'package:auth/utils/app_response.dart';
import 'package:auth/utils/app_utils.dart';
import 'package:conduit/conduit.dart';

import '../models/user.dart';
import '../utils/app_const.dart';

class AppUserController extends ResourceController {
  final ManagedContext managedContext;

  AppUserController(this.managedContext);

  @Operation.get()
  Future<Response> getProfile(
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(id)
        ?..removePropertiesFromBackingMap(
            [AppConst.accessToken, AppConst.refreshToken]);
      return AppResponse.ok(
          message: 'Successful profile acquisition',
          body: user?.backing.contents);
    } catch (error) {
      return AppResponse.serverError(error,
          message: "Error profile acquisition");
    }
  }

  @Operation.post()
  Future<Response> updateProfile(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() User user,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final fetchedUser = await managedContext.fetchObjectWithID<User>(id);
      final qUpdateUser = Query<User>(managedContext)
        ..where((user) => user.id).equalTo(id)
        ..values.username = user.username ?? fetchedUser?.username
        ..values.email = user.email ?? fetchedUser?.email;
      await qUpdateUser.updateOne();
      final updatedUser = await managedContext.fetchObjectWithID<User>(id)
        ?..removePropertiesFromBackingMap(
            [AppConst.accessToken, AppConst.refreshToken]);

      return AppResponse.ok(
          message: 'Successful update profile data',
          body: updatedUser?.backing.contents);
    } catch (error) {
      return AppResponse.serverError(error, message: "Error update profile");
    }
  }

  @Operation.put()
  Future<Response> updatePassword(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.query('oldPassword') String oldPassword,
    @Bind.query('newPassword') String newPassword,
  ) async {
    try {
      final id = AppUtils.getIdFromHeader(header);
      final qFindUser = Query<User>(managedContext)
        ..where((table) => table.id).equalTo(id)
        ..returningProperties((table) => [table.salt, table.hashPassword]);
      final findUser = await qFindUser.fetchOne();
      final salt = findUser?.salt ?? '';
      final oldPasswordHash = generatePasswordHash(oldPassword, salt);
      if (oldPasswordHash != findUser?.hashPassword) {
        return AppResponse.badRequest(message: 'Password is not valid');
      }
      final newPasswordHash = generatePasswordHash(newPassword, salt);
      final qUpdateUser = Query<User>(managedContext)
        ..where((user) => user.id).equalTo(id)
        ..values.hashPassword = newPasswordHash;
      await qUpdateUser.updateOne();
      return AppResponse.ok(message: 'Successful update password');
    } catch (error) {
      return AppResponse.serverError(error, message: 'Error update password');
    }
  }
}
