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
  Future<Response> updateProfile() async {
    try {
      return AppResponse.ok(message: 'updateProfile');
    } catch (error) {
      return AppResponse.serverError(error);
    }
  }

  @Operation.put()
  Future<Response> updatePassword() async {
    try {
      return AppResponse.ok(message: 'updatePassword');
    } catch (error) {
      return AppResponse.serverError(error);
    }
  }
}
