// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../database.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profilesStream)
const profilesStreamProvider = ProfilesStreamProvider._();

final class ProfilesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Profile>>,
          List<Profile>,
          Stream<List<Profile>>
        >
    with $FutureModifier<List<Profile>>, $StreamProvider<List<Profile>> {
  const ProfilesStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilesStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilesStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Profile>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Profile>> create(Ref ref) {
    return profilesStream(ref);
  }
}

String _$profilesStreamHash() => r'483907aa6c324209b5202369300a4a53230f83db';

@ProviderFor(addedRulesStream)
const addedRulesStreamProvider = AddedRulesStreamFamily._();

final class AddedRulesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Rule>>,
          List<Rule>,
          Stream<List<Rule>>
        >
    with $FutureModifier<List<Rule>>, $StreamProvider<List<Rule>> {
  const AddedRulesStreamProvider._({
    required AddedRulesStreamFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'addedRulesStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addedRulesStreamHash();

  @override
  String toString() {
    return r'addedRulesStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Rule>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Rule>> create(Ref ref) {
    final argument = this.argument as int;
    return addedRulesStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AddedRulesStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addedRulesStreamHash() => r'3147271d6149b9c3861e99671fe7ac1f8a8fa23b';

final class AddedRulesStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Rule>>, int> {
  const AddedRulesStreamFamily._()
    : super(
        retry: null,
        name: r'addedRulesStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddedRulesStreamProvider call(int profileId) =>
      AddedRulesStreamProvider._(argument: profileId, from: this);

  @override
  String toString() => r'addedRulesStreamProvider';
}

@ProviderFor(addedRules)
const addedRulesProvider = AddedRulesFamily._();

final class AddedRulesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Rule>>,
          List<Rule>,
          FutureOr<List<Rule>>
        >
    with $FutureModifier<List<Rule>>, $FutureProvider<List<Rule>> {
  const AddedRulesProvider._({
    required AddedRulesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'addedRulesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addedRulesHash();

  @override
  String toString() {
    return r'addedRulesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Rule>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Rule>> create(Ref ref) {
    final argument = this.argument as int;
    return addedRules(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AddedRulesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addedRulesHash() => r'fa2569f7781c93e00bd2017c956ff377e436667a';

final class AddedRulesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Rule>>, int> {
  const AddedRulesFamily._()
    : super(
        retry: null,
        name: r'addedRulesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddedRulesProvider call(int profileId) =>
      AddedRulesProvider._(argument: profileId, from: this);

  @override
  String toString() => r'addedRulesProvider';
}

@ProviderFor(customRulesCount)
const customRulesCountProvider = CustomRulesCountFamily._();

final class CustomRulesCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  const CustomRulesCountProvider._({
    required CustomRulesCountFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'customRulesCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customRulesCountHash();

  @override
  String toString() {
    return r'customRulesCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as int;
    return customRulesCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomRulesCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customRulesCountHash() => r'a3ff7941bcbb2696ba48c82b9310d81d7238536f';

final class CustomRulesCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, int> {
  const CustomRulesCountFamily._()
    : super(
        retry: null,
        name: r'customRulesCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CustomRulesCountProvider call(int profileId) =>
      CustomRulesCountProvider._(argument: profileId, from: this);

  @override
  String toString() => r'customRulesCountProvider';
}

@ProviderFor(proxyGroupsCount)
const proxyGroupsCountProvider = ProxyGroupsCountFamily._();

final class ProxyGroupsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  const ProxyGroupsCountProvider._({
    required ProxyGroupsCountFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'proxyGroupsCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$proxyGroupsCountHash();

  @override
  String toString() {
    return r'proxyGroupsCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as int;
    return proxyGroupsCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProxyGroupsCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$proxyGroupsCountHash() => r'9bf90fc25a9ae3b9ab7aa0784d4e47786f4c4d52';

final class ProxyGroupsCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, int> {
  const ProxyGroupsCountFamily._()
    : super(
        retry: null,
        name: r'proxyGroupsCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProxyGroupsCountProvider call(int profileId) =>
      ProxyGroupsCountProvider._(argument: profileId, from: this);

  @override
  String toString() => r'proxyGroupsCountProvider';
}

@ProviderFor(Profiles)
const profilesProvider = ProfilesProvider._();

final class ProfilesProvider
    extends $NotifierProvider<Profiles, List<Profile>> {
  const ProfilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilesHash();

  @$internal
  @override
  Profiles create() => Profiles();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Profile> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Profile>>(value),
    );
  }
}

String _$profilesHash() => r'9ba0fedd671eab4aa809eb2ce7962f8a7a71665d';

abstract class _$Profiles extends $Notifier<List<Profile>> {
  List<Profile> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<Profile>, List<Profile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Profile>, List<Profile>>,
              List<Profile>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(Scripts)
const scriptsProvider = ScriptsProvider._();

final class ScriptsProvider
    extends $StreamNotifierProvider<Scripts, List<Script>> {
  const ScriptsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'scriptsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$scriptsHash();

  @$internal
  @override
  Scripts create() => Scripts();
}

String _$scriptsHash() => r'a784e9986eae864229a1035cc28ce4f3ec4644a0';

abstract class _$Scripts extends $StreamNotifier<List<Script>> {
  Stream<List<Script>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Script>>, List<Script>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Script>>, List<Script>>,
              AsyncValue<List<Script>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(GlobalRules)
const globalRulesProvider = GlobalRulesProvider._();

final class GlobalRulesProvider
    extends $StreamNotifierProvider<GlobalRules, List<Rule>> {
  const GlobalRulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalRulesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalRulesHash();

  @$internal
  @override
  GlobalRules create() => GlobalRules();
}

String _$globalRulesHash() => r'39d27f04f14d4498dc9dd89cea8e9cc2cc9da548';

abstract class _$GlobalRules extends $StreamNotifier<List<Rule>> {
  Stream<List<Rule>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Rule>>, List<Rule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Rule>>, List<Rule>>,
              AsyncValue<List<Rule>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ProfileAddedRules)
const profileAddedRulesProvider = ProfileAddedRulesFamily._();

final class ProfileAddedRulesProvider
    extends $StreamNotifierProvider<ProfileAddedRules, List<Rule>> {
  const ProfileAddedRulesProvider._({
    required ProfileAddedRulesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'profileAddedRulesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileAddedRulesHash();

  @override
  String toString() {
    return r'profileAddedRulesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileAddedRules create() => ProfileAddedRules();

  @override
  bool operator ==(Object other) {
    return other is ProfileAddedRulesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileAddedRulesHash() => r'6909191ccf493d8b9dd657265f3da1ae27485d73';

final class ProfileAddedRulesFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileAddedRules,
          AsyncValue<List<Rule>>,
          List<Rule>,
          Stream<List<Rule>>,
          int
        > {
  const ProfileAddedRulesFamily._()
    : super(
        retry: null,
        name: r'profileAddedRulesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileAddedRulesProvider call(int profileId) =>
      ProfileAddedRulesProvider._(argument: profileId, from: this);

  @override
  String toString() => r'profileAddedRulesProvider';
}

abstract class _$ProfileAddedRules extends $StreamNotifier<List<Rule>> {
  late final _$args = ref.$arg as int;
  int get profileId => _$args;

  Stream<List<Rule>> build(int profileId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<Rule>>, List<Rule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Rule>>, List<Rule>>,
              AsyncValue<List<Rule>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ProfileCustomRules)
const profileCustomRulesProvider = ProfileCustomRulesFamily._();

final class ProfileCustomRulesProvider
    extends $StreamNotifierProvider<ProfileCustomRules, List<Rule>> {
  const ProfileCustomRulesProvider._({
    required ProfileCustomRulesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'profileCustomRulesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileCustomRulesHash();

  @override
  String toString() {
    return r'profileCustomRulesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileCustomRules create() => ProfileCustomRules();

  @override
  bool operator ==(Object other) {
    return other is ProfileCustomRulesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileCustomRulesHash() =>
    r'b267939b552c7967a85caff5a249c0534686753b';

final class ProfileCustomRulesFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileCustomRules,
          AsyncValue<List<Rule>>,
          List<Rule>,
          Stream<List<Rule>>,
          int
        > {
  const ProfileCustomRulesFamily._()
    : super(
        retry: null,
        name: r'profileCustomRulesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileCustomRulesProvider call(int profileId) =>
      ProfileCustomRulesProvider._(argument: profileId, from: this);

  @override
  String toString() => r'profileCustomRulesProvider';
}

abstract class _$ProfileCustomRules extends $StreamNotifier<List<Rule>> {
  late final _$args = ref.$arg as int;
  int get profileId => _$args;

  Stream<List<Rule>> build(int profileId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<Rule>>, List<Rule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Rule>>, List<Rule>>,
              AsyncValue<List<Rule>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ProxyGroups)
const proxyGroupsProvider = ProxyGroupsFamily._();

final class ProxyGroupsProvider
    extends $StreamNotifierProvider<ProxyGroups, List<ProxyGroup>> {
  const ProxyGroupsProvider._({
    required ProxyGroupsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'proxyGroupsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$proxyGroupsHash();

  @override
  String toString() {
    return r'proxyGroupsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProxyGroups create() => ProxyGroups();

  @override
  bool operator ==(Object other) {
    return other is ProxyGroupsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$proxyGroupsHash() => r'b747de5d114e8e6d764befca26e9a8dc81d9d127';

final class ProxyGroupsFamily extends $Family
    with
        $ClassFamilyOverride<
          ProxyGroups,
          AsyncValue<List<ProxyGroup>>,
          List<ProxyGroup>,
          Stream<List<ProxyGroup>>,
          int
        > {
  const ProxyGroupsFamily._()
    : super(
        retry: null,
        name: r'proxyGroupsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProxyGroupsProvider call(int profileId) =>
      ProxyGroupsProvider._(argument: profileId, from: this);

  @override
  String toString() => r'proxyGroupsProvider';
}

abstract class _$ProxyGroups extends $StreamNotifier<List<ProxyGroup>> {
  late final _$args = ref.$arg as int;
  int get profileId => _$args;

  Stream<List<ProxyGroup>> build(int profileId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<List<ProxyGroup>>, List<ProxyGroup>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ProxyGroup>>, List<ProxyGroup>>,
              AsyncValue<List<ProxyGroup>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ProfileDisabledRuleIds)
const profileDisabledRuleIdsProvider = ProfileDisabledRuleIdsFamily._();

final class ProfileDisabledRuleIdsProvider
    extends $StreamNotifierProvider<ProfileDisabledRuleIds, List<int>> {
  const ProfileDisabledRuleIdsProvider._({
    required ProfileDisabledRuleIdsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'profileDisabledRuleIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileDisabledRuleIdsHash();

  @override
  String toString() {
    return r'profileDisabledRuleIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProfileDisabledRuleIds create() => ProfileDisabledRuleIds();

  @override
  bool operator ==(Object other) {
    return other is ProfileDisabledRuleIdsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileDisabledRuleIdsHash() =>
    r'5093cc1d77ec69a2c1db6efa86a3f5916475d4f0';

final class ProfileDisabledRuleIdsFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileDisabledRuleIds,
          AsyncValue<List<int>>,
          List<int>,
          Stream<List<int>>,
          int
        > {
  const ProfileDisabledRuleIdsFamily._()
    : super(
        retry: null,
        name: r'profileDisabledRuleIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProfileDisabledRuleIdsProvider call(int profileId) =>
      ProfileDisabledRuleIdsProvider._(argument: profileId, from: this);

  @override
  String toString() => r'profileDisabledRuleIdsProvider';
}

abstract class _$ProfileDisabledRuleIds extends $StreamNotifier<List<int>> {
  late final _$args = ref.$arg as int;
  int get profileId => _$args;

  Stream<List<int>> build(int profileId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<List<int>>, List<int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<int>>, List<int>>,
              AsyncValue<List<int>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
