import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

part 'converter.dart';
part 'generated/database.g.dart';
part 'groups.dart';
part 'icons.dart';
part 'links.dart';
part 'profiles.dart';
part 'rules.dart';
part 'scripts.dart';

@DriftDatabase(
  tables: [
    Profiles,
    Scripts,
    Rules,
    ProfileRuleLinks,
    ProxyGroups,
    IconRecords,
  ],
  daos: [ProfilesDao, ScriptsDao, RulesDao, ProxyGroupsDao, IconRecordsDao],
)
class Database extends _$Database {
  Database([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final databaseFile = File(await appPath.databasePath);
      return NativeDatabase.createInBackground(databaseFile);
    });
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(proxyGroups);
          await m.createTable(iconRecords);
          await _resetOrders();
        }
      },
    );
  }

  Future<void> _resetOrders() async {
    await rulesDao.resetOrders();
  }

  Future<void> restore(
    List<Profile> profiles,
    List<Script> scripts,
    List<Rule> rules,
    List<ProfileRuleLink> links, {
    bool isOverride = false,
  }) async {
    if (profiles.isNotEmpty ||
        scripts.isNotEmpty ||
        rules.isNotEmpty ||
        links.isNotEmpty) {
      await batch((b) {
        isOverride
            ? profilesDao.setAllWithBatch(b, profiles)
            : profilesDao.putAllWithBatch(
                b,
                profiles.map((item) => item.toCompanion()),
              );
        scriptsDao.setAllWithBatch(b, scripts);
        rulesDao.restoreWithBatch(b, rules, links);
      });
    }
  }

  Future<void> setProfileCustomData(
    int profileId,
    List<ProxyGroup> groups,
    List<Rule> rules,
  ) async {
    await batch((b) {
      proxyGroupsDao.setAllWithBatch(profileId, b, groups);
      rulesDao.setCustomRulesWithBatch(profileId, b, rules);
    });
  }
}

extension TableInfoExt<Tbl extends Table, Row> on TableInfo<Tbl, Row> {
  void setAll(
    Batch batch,
    Iterable<Insertable<Row>> items, {
    required Expression<bool> Function(Tbl tbl) deleteFilter,
    bool preDelete = false,
  }) async {
    if (preDelete) {
      batch.deleteWhere(this, deleteFilter);
    }
    batch.insertAllOnConflictUpdate(this, items);
    if (!preDelete) {
      batch.deleteWhere(this, deleteFilter);
    }
  }

  Selectable<int?> get count {
    final countExp = countAll();
    final query = select().addColumns([countExp]);
    return query.map((row) => row.read(countExp));
  }

  Future<int> remove(Expression<bool> Function(Tbl tbl) filter) async {
    return await (delete()..where(filter)).go();
  }

  Future<int> put(Insertable<Row> item) async {
    return await insertOnConflictUpdate(item);
  }
}

extension SimpleSelectStatementExt<T extends HasResultSet, D>
    on SimpleSelectStatement<T, D> {
  Selectable<int> get count {
    final countExp = countAll();
    final query = addColumns([countExp]);
    return query.map((row) => row.read(countExp)!);
  }
}

extension JoinedSelectStatementExt<T extends HasResultSet, D>
    on JoinedSelectStatement<T, D> {
  Selectable<int> get count {
    final countExp = countAll();
    addColumns([countExp]);
    return map((row) => row.read(countExp)!);
  }
}

// extension _AsyncMapPerSubscription<S> on Stream<S> {
//   Stream<T> asyncMapPerSubscription<T>(FutureOr<T> Function(S) mapper) {
//     return Stream.multi((listener) {
//       late StreamSubscription<S> subscription;
//
//       void onData(S original) {
//         subscription.pause();
//         Future.sync(() => mapper(original))
//             .then(listener.addSync, onError: listener.addErrorSync)
//             .whenComplete(subscription.resume);
//       }
//
//       subscription = listen(
//         onData,
//         onError: listener.addErrorSync,
//         onDone: listener.closeSync,
//         cancelOnError: false, // Determined by downstream subscription
//       );
//
//       listener
//         ..onPause = subscription.pause
//         ..onResume = subscription.resume
//         ..onCancel = subscription.cancel;
//     }, isBroadcast: isBroadcast);
//   }
// }

// extension SelectableExt<T> on Selectable<T> {
//   Selectable<N> isolateMap<N>(N Function(T) mapper) {
//     return _IsolateMappedSelectable<T, N>(this, mapper);
//   }
// }
//
// class _IsolateMappedSelectable<S, T> extends Selectable<T> {
//   final Selectable<S> _source;
//   final T Function(S) _mapper;
//
//   _IsolateMappedSelectable(this._source, this._mapper);
//
//   @override
//   Future<List<T>> get() {
//     return _source.get().then(_mapResults);
//   }
//
//   @override
//   Stream<List<T>> watch() {
//     return _AsyncMapPerSubscription(
//       _source.watch(),
//     ).asyncMapPerSubscription(_mapResults);
//   }
//
//   Future<List<T>> _mapResults(List<S> results) async {
//     return mapListTask(results, _mapper);
//   }
// }

final database = Database();
