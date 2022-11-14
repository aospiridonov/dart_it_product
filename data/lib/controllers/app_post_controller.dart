import 'package:data/utils/app_response.dart';
import 'package:conduit/conduit.dart';

class AppPostController extends ResourceController {
  final ManagedContext managedContext;

  AppPostController(this.managedContext);

  @Operation.get()
  Future<Response> getPosts() async {
    try {
      /*
      final id = AppUtils.getIdFromHeader(header);
      final user = await managedContext.fetchObjectWithID<User>(id)
        ?..removePropertiesFromBackingMap(
            [AppConst.accessToken, AppConst.refreshToken]);
            
      return AppResponse.ok(
          message: 'Successful profile acquisition',
          body: user?.backing.contents);
          */
      return AppResponse.ok(message: 'Successful receipt of posts');
    } catch (error) {
      return AppResponse.serverError(error, message: "Error receipt of posts");
    }
  }
}
