import 'package:event_bus/event_bus.dart';
import 'package:hive/hive.dart';
import 'package:kiwi/kiwi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restio/restio.dart';
import 'package:restio_cache/restio_cache.dart';
import 'package:restler/blocs/settings/bloc.dart';
import 'package:restler/blocs/sse/bloc.dart';
import 'package:restler/blocs/websocket/bloc.dart';
import 'package:restler/constants.dart';
import 'package:restler/data/database.dart';
import 'package:restler/data/migrations/migration01.dart';
import 'package:restler/data/migrations/migration02.dart';
import 'package:restler/data/migrations/migration03.dart';
import 'package:restler/data/migrations/migration04.dart';
import 'package:restler/data/migrations/migration05.dart';
import 'package:restler/data/migrations/migration06.dart';
import 'package:restler/data/migrations/migration07.dart';
import 'package:restler/data/migrations/migration08.dart';
import 'package:restler/data/migrations/migration09.dart';
import 'package:restler/data/migrations/migration10.dart';
import 'package:restler/data/migrations/migration11.dart';
import 'package:restler/data/migrations/migration12.dart';
import 'package:restler/data/migrations/migration13.dart';
import 'package:restler/data/providers/call_provider.dart';
import 'package:restler/data/providers/certificate_provider.dart';
import 'package:restler/data/providers/cookie_provider.dart';
import 'package:restler/data/providers/dns_provider.dart';
import 'package:restler/data/providers/environment_provider.dart';
import 'package:restler/data/providers/folder_provider.dart';
import 'package:restler/data/providers/history_provider.dart';
import 'package:restler/data/providers/proxy_provider.dart';
import 'package:restler/data/providers/request_provider.dart';
import 'package:restler/data/providers/response_provider.dart';
import 'package:restler/data/providers/tab_provider.dart';
import 'package:restler/data/providers/variable_provider.dart';
import 'package:restler/data/providers/workspace_provider.dart';
import 'package:restler/data/repositories/certificate_repository.dart';
import 'package:restler/data/repositories/collection_repository.dart';
import 'package:restler/data/repositories/cookie_repository.dart';
import 'package:restler/data/repositories/dns_repository.dart';
import 'package:restler/data/repositories/environment_repository.dart';
import 'package:restler/data/repositories/history_repository.dart';
import 'package:restler/data/repositories/proxy_repository.dart';
import 'package:restler/data/repositories/request_repository.dart';
import 'package:restler/data/repositories/response_repository.dart';
import 'package:restler/data/repositories/tab_repository.dart';
import 'package:restler/data/repositories/variable_repository.dart';
import 'package:restler/data/repositories/workspace_repository.dart';
import 'package:restler/data/storage.dart';
import 'package:restler/messager.dart';
import 'package:restler/services/variable_loader.dart';
import 'package:restler/settings.dart';
import 'package:sqflite/sqflite.dart';

final kiwi = KiwiContainer();

Future<void> initInject() async {
  // Database.
  final database = await _initDatabase();
  final storage = Storage(database);
  kiwi.registerInstance(storage);
  // Box.
  final box = await _initHive();
  kiwi.registerInstance(box);
  // Settings.
  final settings = Settings(box);
  kiwi.registerInstance(settings);
  // Cache.
  final cacheDir = await getTemporaryDirectory();
  print('Cache directory at $cacheDir');
  final cacheStore = await LruCacheStore.local(
    cacheDir.path,
    maxSize: settings.cacheMaxSize * 1024 * 1024,
  );
  kiwi.registerInstance(cacheDir, name: 'cache');
  kiwi.registerInstance<CacheStore>(cacheStore);
  kiwi.registerInstance(Cache(store: cacheStore));
  // Providers.
  kiwi.registerSingleton((i) => CallProvider(i()));
  kiwi.registerSingleton((i) => FolderProvider(i()));
  kiwi.registerSingleton((i) => TabProvider(i()));
  kiwi.registerSingleton((i) => ResponseProvider(i()));
  kiwi.registerSingleton((i) => RequestProvider(i()));
  kiwi.registerSingleton((i) => HistoryProvider(i()));
  kiwi.registerSingleton((i) => CookieProvider(i()));
  kiwi.registerSingleton((i) => CertificateProvider(i()));
  kiwi.registerSingleton((i) => ProxyProvider(i()));
  kiwi.registerSingleton((i) => DnsProvider(i()));
  kiwi.registerSingleton((i) => WorkspaceProvider(i()));
  kiwi.registerSingleton((i) => EnvironmentProvider(i()));
  kiwi.registerSingleton((i) => VariableProvider(i()));
  // Repositories.
  kiwi.registerSingleton((i) => TabRepository(i(), i()));
  kiwi.registerSingleton((i) => RequestRepository(i()));
  kiwi.registerSingleton((i) => ResponseRepository(i()));
  kiwi.registerSingleton((i) => CookieRepository(i()));
  kiwi.registerSingleton((i) => HistoryRepository(i(), i(), i()));
  kiwi.registerSingleton((i) => CollectionRepository(i(), i(), i()));
  kiwi.registerSingleton((i) => CertificateRepository(i()));
  kiwi.registerSingleton((i) => ProxyRepository(i()));
  kiwi.registerSingleton((i) => DnsRepository(i()));
  kiwi.registerSingleton((i) => WorkspaceRepository(i()));
  kiwi.registerSingleton((i) => EnvironmentRepository(i(), i()));
  kiwi.registerSingleton((i) => VariableRepository(i()));
  // Others.
  kiwi.registerInstance(EventBus());
  kiwi.registerSingleton((i) => Messager(i()));
  kiwi.registerSingleton((i) => VariableLoader(i(), i(), i()));
  kiwi.registerInstance(ConnectionPool());
  // Blocs.
  kiwi.registerSingleton((i) => SettingsBloc(i()));
  kiwi.registerSingleton((i) => WebSocketBloc());
  kiwi.registerSingleton((i) => SseBloc());
}

Future<Database> _initDatabase() async {
  final database = await openDatabaseWithMigration(
    name: databaseName,
    version: databaseVersion,
    migrations: [
      const ZeroToOneMigration(),
      const OneToTwoMigration(),
      const TwoToThreeMigration(),
      const ThreeToFourMigration(),
      const FourToFiveMigration(),
      const FiveToSixMigration(),
      const SixToSevenMigration(),
      const SevenToEightMigration(),
      const EightToNineMigration(),
      const NineToTenMigration(),
      const TenToElevenMigration(),
      const ElevenToTwelveMigration(),
      const TwelveToThirteenMigration(),
    ],
  );

  return database;
}

Future<Box> _initHive() async {
  final path = await getApplicationDocumentsDirectory();
  Hive.init(path.path);
  return Hive.openBox('app');
}
