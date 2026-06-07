import 'package:mocktail/mocktail.dart';
import 'package:z1_mobile/core/services/token_service.dart';
import 'package:z1_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:z1_mobile/features/auth/data/datasources/session_remote_datasource.dart';

/// AuthRemoteDataSource 的 Mock
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

/// SessionRemoteDataSource 的 Mock
class MockSessionRemoteDataSource extends Mock
    implements SessionRemoteDataSource {}

/// TokenService 的 Mock
class MockTokenService extends Mock implements TokenService {}