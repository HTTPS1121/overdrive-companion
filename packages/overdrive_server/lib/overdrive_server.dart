library overdrive_server;

export 'src/api/overdrive_api_client.dart';
export 'src/auth/connection_errors.dart';
export 'src/auth/tunnel_credentials.dart';
export 'src/config/app_settings.dart';
export 'src/repositories/overdrive_endpoints.dart';

/// Active data implementation for the companion UI lives in the app layer.
/// Set [kCompanionUsesDemoRepository] in the app when wiring a real backend.
const bool kOverdriveServerPackageIsolated = true;
