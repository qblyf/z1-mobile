import 'package:mocktail/mocktail.dart';
import 'package:z1_mobile/core/services/token_service.dart';
import 'package:z1_mobile/features/auth/data/datasources/auth_remote_datasource.dart';

/// AuthRemoteDataSource 的 Mock
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

/// TokenService 的 Mock
class MockTokenService extends Mock implements TokenService {}