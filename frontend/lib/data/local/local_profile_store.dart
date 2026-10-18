import 'package:uuid/uuid.dart';

import 'app_database.dart';

/// Creates the one local guest profile or returns the profile already saved.
///
/// Repositories will use its stable ID to scope every task and history query.
final class LocalProfileStore {
  LocalProfileStore(this._database, {Uuid? uuid}) : _uuid = uuid ?? Uuid();

  static const guestProfileType = 'GUEST';

  final AppDatabase _database;
  final Uuid _uuid;

  Future<ProfileRecord> getOrCreateGuestProfile() {
    return _database.transaction(() async {
      final existing =
          await (_database.select(_database.localProfiles)
                ..where(
                  (profile) => profile.profileType.equals(guestProfileType),
                )
                ..limit(1))
              .getSingleOrNull();
      if (existing != null) return existing;

      final now = DateTime.now().toUtc();
      final profileId = _uuid.v4();
      await _database
          .into(_database.localProfiles)
          .insert(
            LocalProfilesCompanion.insert(
              id: profileId,
              createdAtUtc: now,
              updatedAtUtc: now,
            ),
          );

      return (_database.select(
        _database.localProfiles,
      )..where((profile) => profile.id.equals(profileId))).getSingle();
    });
  }
}
