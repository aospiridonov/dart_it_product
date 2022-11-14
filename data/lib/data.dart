import 'package:data/utils/app_env.dart';
import 'package:conduit/conduit.dart';

import 'controllers/app_token_controller.dart';
import 'controllers/app_post_controller.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  @override
  Future prepare() {
    final persistentStore = _initDataBase();
    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);
    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route('posts/[:id]')
        .link(() => AppTokenController())!
        .link(() => AppPostController(managedContext));

  PostgreSQLPersistentStore _initDataBase() {
    return PostgreSQLPersistentStore(
      AppEnv.dbUsername,
      AppEnv.dbPassword,
      AppEnv.dbHost,
      int.tryParse(AppEnv.dbPort),
      AppEnv.dbDatabaseName,
    );
  }
}
