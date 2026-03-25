part of 'overwrite.dart';

class _CustomProxyGroupsView extends ConsumerWidget {
  final int profileId;

  const _CustomProxyGroupsView(this.profileId);

  void _handleReorder(
    WidgetRef ref,
    int profileId,
    int oldIndex,
    int newIndex,
  ) {
    ref.read(proxyGroupsProvider(profileId).notifier).order(oldIndex, newIndex);
  }

  void _handleEditProxyGroup(BuildContext context, ProxyGroup proxyGroup) {
    showSheet(
      context: context,
      props: SheetProps(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        maxWidth: double.maxFinite,
      ),
      builder: (context) {
        return ProfileIdProvider(
          profileId: profileId,
          child: ProviderScope(
            overrides: [
              proxyGroupProvider.overrideWithBuild((_, __) => proxyGroup),
            ],
            child: _EditProxyGroupNestedSheet(),
          ),
        );
      },
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required ProxyGroup proxyGroup,
    required int index,
    required int total,
    required VoidCallback onPressed,
  }) {
    final position = ItemPosition.get(index, total);
    return ItemPositionProvider(
      key: ValueKey(proxyGroup.name),
      position: position,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: DecorationListItem(
          onPressed: onPressed,
          minVerticalPadding: 8,
          title: Text(proxyGroup.name),
          subtitle: Text(proxyGroup.type.name),
          trailing: ReorderableDelayedDragStartListener(
            index: index,
            child: Icon(Icons.drag_handle),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxyGroups = ref.watch(proxyGroupsProvider(profileId)).value ?? [];
    return CommonScaffold(
      title: '策略组',
      body: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        padding: EdgeInsets.symmetric(vertical: 16),
        itemBuilder: (context, index) {
          final proxyGroup = proxyGroups[index];
          return _buildItem(
            context: context,
            proxyGroup: proxyGroup,
            total: proxyGroups.length,
            index: index,
            onPressed: () {
              _handleEditProxyGroup(context, proxyGroup);
            },
          );
        },
        itemCount: proxyGroups.length,
        onReorder: (oldIndex, newIndex) {
          _handleReorder(ref, profileId, oldIndex, newIndex);
        },
      ),
    );
  }
}

class _EditProxyGroupNestedSheet extends StatelessWidget {
  const _EditProxyGroupNestedSheet();

  Future<void> _handleClose(
    BuildContext context,
    NavigatorState? navigatorState,
  ) async {
    if (navigatorState != null && navigatorState.canPop()) {
      final res = await globalState.showMessage(
        message: TextSpan(text: '确定要退出当前窗口吗?'),
      );
      if (res != true) {
        return;
      }
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handlePop(
    BuildContext context,
    NavigatorState? navigatorState,
  ) async {
    if (navigatorState != null && navigatorState.canPop()) {
      navigatorState.pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> nestedNavigatorKey = GlobalKey();
    final nestedNavigator = Navigator(
      key: nestedNavigatorKey,
      onGenerateInitialRoutes: (navigator, initialRoute) {
        return [
          PagedSheetRoute(
            builder: (context) {
              return _EditProxyGroupView();
            },
          ),
        ];
      },
    );
    final sheetProvider = SheetProvider.of(context);
    return CommonPopScope(
      onPop: (_) async {
        _handlePop(context, nestedNavigatorKey.currentState);
        return false;
      },
      child: sheetProvider!.copyWith(
        nestedNavigatorPopCallback: () {
          Navigator.of(context).pop();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () async {
                  _handleClose(context, nestedNavigatorKey.currentState);
                },
              ),
            ),
            SizedBox(
              width: sheetProvider.type == SheetType.sideSheet ? 400 : null,
              child: SheetViewport(
                child: PagedSheet(
                  decoration: MaterialSheetDecoration(
                    size: SheetSize.stretch,
                    color: sheetProvider.type == SheetType.bottomSheet
                        ? context.colorScheme.surfaceContainerLow
                        : context.colorScheme.surface,
                    borderRadius: sheetProvider.type == SheetType.bottomSheet
                        ? BorderRadius.vertical(top: Radius.circular(28))
                        : BorderRadius.zero,
                    clipBehavior: Clip.antiAlias,
                  ),
                  navigator: nestedNavigator,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProxyGroupView extends ConsumerStatefulWidget {
  const _EditProxyGroupView();

  @override
  ConsumerState createState() => _EditProxyGroupViewState();
}

class _EditProxyGroupViewState extends ConsumerState<_EditProxyGroupView> {
  Future<void> _showTypeOptions(GroupType type) async {
    final value = await globalState.showCommonDialog<GroupType>(
      child: OptionsDialog<GroupType>(
        title: '类型',
        options: GroupType.values,
        textBuilder: (item) => item.name,
        value: type,
      ),
    );
    if (value == null) {
      return;
    }
    ref
        .read(proxyGroupProvider.notifier)
        .update((state) => state.copyWith(type: value));
  }

  Widget _buildItem({
    required Widget title,
    Widget? trailing,
    final VoidCallback? onPressed,
  }) {
    return DecorationListItem(
      onPressed: onPressed,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 16,
        children: [
          title,
          if (trailing != null)
            Flexible(
              child: IconTheme(
                data: IconThemeData(
                  size: 16,
                  color: context.colorScheme.onSurface.opacity60,
                ),
                child: Container(
                  alignment: Alignment.centerRight,
                  height: globalState.measure.bodyLargeHeight + 24,
                  child: trailing,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleToProxiesView() {
    Navigator.of(
      context,
    ).push(PagedSheetRoute(builder: (context) => _EditProxiesView()));
  }

  void _handleToProvidersView() {}

  Widget _buildProvidersItem(bool includeAllProviders, List<String> use) {
    return _buildItem(
      title: Text('选择代理集'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          !includeAllProviders
              ? Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 32),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                      child: Text(
                        textAlign: TextAlign.center,
                        '${use.length}',
                        style: context.textTheme.bodySmall,
                      ),
                    ),
                  ),
                )
              : Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: Colors.greenAccent.shade200,
                ),
          Icon(Icons.arrow_forward_ios),
        ],
      ),
      onPressed: _handleToProvidersView,
    );
  }

  Widget _buildFilterItem(String? filter) {
    return _buildItem(
      title: Text('节点过滤器'),
      trailing: TextFormField(
        textAlign: TextAlign.end,
        initialValue: filter,
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update((state) => state.copyWith(filter: value));
        },
        decoration: InputDecoration.collapsed(
          border: NoInputBorder(),
          hintText: '可选',
        ),
      ),
    );
  }

  Widget _buildMaxFailedTimesItem(int? maxFailedTimes) {
    return _buildItem(
      title: Text('最大失败次数'),
      trailing: TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.end,
        initialValue: maxFailedTimes?.toString(),
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update(
                (state) => state.copyWith(maxFailedTimes: int.tryParse(value)),
              );
        },
        decoration: InputDecoration.collapsed(
          border: NoInputBorder(),
          hintText: '可选',
        ),
      ),
    );
  }

  Widget _buildUrlItem(String? url) {
    return _buildItem(
      title: Text('测试链接'),
      trailing: TextFormField(
        keyboardType: TextInputType.url,
        textAlign: TextAlign.end,
        initialValue: url,
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update((state) => state.copyWith(url: value));
        },
        decoration: InputDecoration.collapsed(
          border: NoInputBorder(),
          hintText: '可选',
        ),
      ),
    );
  }

  Widget _buildIntervalItem(int? interval) {
    return _buildItem(
      title: Text('测试间隔'),
      trailing: TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textAlign: TextAlign.end,
        initialValue: interval?.toString(),
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update((state) => state.copyWith(interval: int.tryParse(value)));
        },
        decoration: InputDecoration.collapsed(
          border: NoInputBorder(),
          hintText: '可选',
        ),
      ),
    );
  }

  Widget _buildExcludeFilterItem(String? excludeFilter) {
    return _buildItem(
      title: Text('排除节点过滤器'),
      trailing: TextFormField(
        textAlign: TextAlign.end,
        initialValue: excludeFilter,
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update((state) => state.copyWith(excludeFilter: value));
        },
        decoration: InputDecoration.collapsed(
          border: NoInputBorder(),
          hintText: '可选',
        ),
      ),
    );
  }

  Widget _buildExcludeTypeItem(String? type) {
    return _buildItem(
      title: Text('排除类型'),
      trailing: TextFormField(
        textAlign: TextAlign.end,
        initialValue: type,
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update((state) => state.copyWith(excludeType: value));
        },
        decoration: InputDecoration.collapsed(
          border: NoInputBorder(),
          hintText: '可选',
        ),
      ),
    );
  }

  Widget _buildExpectedStatusItem(String? expectedStatus) {
    return _buildItem(
      title: Text('预期状态'),
      trailing: TextFormField(
        textAlign: TextAlign.end,
        initialValue: expectedStatus,
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update((state) => state.copyWith(expectedStatus: value));
        },
        decoration: InputDecoration.collapsed(
          border: NoInputBorder(),
          hintText: '可选',
        ),
      ),
    );
  }

  Widget _buildProxiesItem(bool includeAllProxies, List<String> proxies) {
    return _buildItem(
      title: Text('选择代理'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          !includeAllProxies
              ? Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 32),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                      child: Text(
                        textAlign: TextAlign.center,
                        '${proxies.length}',
                        style: context.textTheme.bodySmall,
                      ),
                    ),
                  ),
                )
              : Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: Colors.greenAccent.shade200,
                ),
          Icon(Icons.arrow_forward_ios),
        ],
      ),
      onPressed: _handleToProxiesView,
    );
  }

  Widget _buildTypeItem(GroupType type) {
    return _buildItem(
      title: Text('类型'),
      onPressed: () {
        _showTypeOptions(type);
      },
      trailing: Text(type.name),
    );
  }

  Widget _buildIconItem(String? icon) {
    return _buildItem(
      title: Text('图标'),
      onPressed: () {
        // _showTypeOptions(type);
      },
      trailing: Text(
        icon ?? '可选',
        style: context.textTheme.bodyLarge?.copyWith(
          color: icon == null ? context.colorScheme.onSurfaceVariant : null,
        ),
      ),
    );
  }

  Widget _buildNameItem(String name) {
    return _buildItem(
      title: Text('名称'),
      trailing: TextFormField(
        initialValue: name,
        onChanged: (value) {
          ref
              .read(proxyGroupProvider.notifier)
              .update((state) => state.copyWith(name: value));
        },
        textAlign: TextAlign.end,
        decoration: InputDecoration.collapsed(
          border: NoInputBorder(),
          hintText: '输入策略组名称',
        ),
      ),
    );
  }

  Widget _buildHiddenItem(bool? hidden) {
    void handleChangeHidden() {
      ref
          .read(proxyGroupProvider.notifier)
          .update((state) => state.copyWith(hidden: !(hidden ?? false)));
    }

    return _buildItem(
      title: Text('从列表中隐藏'),
      onPressed: handleChangeHidden,
      trailing: Switch(
        value: hidden ?? false,
        onChanged: (_) {
          handleChangeHidden();
        },
      ),
    );
  }

  Widget _buildLazyItem(bool? lazy) {
    void handleChangeLazy() {
      ref
          .read(proxyGroupProvider.notifier)
          .update((state) => state.copyWith(lazy: !(lazy ?? false)));
    }

    return _buildItem(
      title: Text('使用时测试'),
      onPressed: handleChangeLazy,
      trailing: Switch(
        value: lazy ?? false,
        onChanged: (_) {
          handleChangeLazy();
        },
      ),
    );
  }

  Widget _buildDisableUDPItem(bool? disableUDP) {
    void handleChangeDisableUDP() {
      ref
          .read(proxyGroupProvider.notifier)
          .update(
            (state) => state.copyWith(disableUDP: !(disableUDP ?? false)),
          );
    }

    return _buildItem(
      title: Text('禁用UDP'),
      onPressed: handleChangeDisableUDP,
      trailing: Switch(
        value: disableUDP ?? false,
        onChanged: (_) {
          handleChangeDisableUDP();
        },
      ),
    );
  }

  void _handleDelete(int profileId, String name) {
    ref.read(proxyGroupsProvider(profileId).notifier).del(name);
    final popCb = SheetProvider.of(context)?.nestedNavigatorPopCallback;
    if (popCb != null) {
      popCb();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBottomSheet =
        SheetProvider.of(context)?.type == SheetType.bottomSheet;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final proxyGroup = ref.watch(proxyGroupProvider);
    return AdaptiveSheetScaffold(
      sheetTransparentToolBar: true,
      actions: [IconButtonData(icon: Icons.check, onPressed: () {})],
      body: SizedBox(
        height: isBottomSheet
            ? appController.viewSize.height * 0.65
            : double.maxFinite,
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(bottom: 20, top: context.sheetTopPadding),
          children: [
            generateSectionV3(
              title: '通用',
              items: [
                _buildNameItem(proxyGroup.name),
                _buildTypeItem(proxyGroup.type),
                _buildIconItem(proxyGroup.icon),
                _buildHiddenItem(proxyGroup.hidden),
                _buildDisableUDPItem(proxyGroup.disableUDP),
              ],
            ),
            generateSectionV3(
              title: '节点',
              items: [
                _buildProxiesItem(
                  proxyGroup.includeAllProxies ?? false,
                  proxyGroup.proxies ?? [],
                ),
                _buildProvidersItem(
                  proxyGroup.includeAllProviders ?? false,
                  proxyGroup.use ?? [],
                ),
                _buildFilterItem(proxyGroup.filter),
                _buildExcludeFilterItem(proxyGroup.excludeFilter),
                _buildExcludeTypeItem(proxyGroup.excludeType),
                _buildExpectedStatusItem(proxyGroup.expectedStatus),
              ],
            ),
            generateSectionV3(
              title: '其他',
              items: [
                _buildUrlItem(proxyGroup.url),
                _buildMaxFailedTimesItem(proxyGroup.maxFailedTimes),
                _buildLazyItem(proxyGroup.lazy),
                _buildIntervalItem(proxyGroup.interval),
              ],
            ),
            generateSectionV3(
              title: '操作',
              items: [
                _buildItem(
                  title: Text(
                    '删除',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                  onPressed: () {
                    _handleDelete(profileId, proxyGroup.name);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      title: '编辑策略组',
    );
  }
}

class _EditProxiesView extends ConsumerStatefulWidget {
  const _EditProxiesView();

  @override
  ConsumerState<_EditProxiesView> createState() => _EditProxiesViewState();
}

class _EditProxiesViewState extends ConsumerState<_EditProxiesView>
    with UniqueKeyStateMixin {
  @override
  void initState() {
    super.initState();
    ref.listenManual(itemsProvider(key), (prev, next) {
      if (!SetEquality().equals(prev, next)) {
        _handleRealRemove();
      }
    });
  }

  void _handleToAddProxiesView() {
    Navigator.of(
      context,
    ).push(PagedSheetRoute(builder: (context) => _AddProxiesView()));
  }

  void _handleRemove(String proxyName) {
    ref.read(itemsProvider(key).notifier).update((state) {
      final newSet = Set.from(state);
      newSet.add(proxyName);
      return newSet;
    });
  }

  void _handleRealRemove() {
    debouncer.call(
      'EditProxiesViewState_handleRealRemove',
      () {
        if (!ref.context.mounted) {
          return;
        }
        final dismissItems = ref.read(itemsProvider(key));
        ref.read(proxyGroupProvider.notifier).update((state) {
          final newProxies = List<String>.from(state.proxies ?? []);
          newProxies.removeWhere((state) => dismissItems.contains(state));
          return state.copyWith(proxies: newProxies);
        });
        ref.read(itemsProvider(key).notifier).update((state) => <dynamic>{});
      },
      duration: Duration(milliseconds: 450),
    );
  }

  Widget _buildItem({
    required String proxyName,
    required String? proxyType,
    required int index,
    required int length,
    required ItemPosition position,
    required bool dismiss,
  }) {
    return ExternalDismissible(
      dismiss: dismiss,
      key: ValueKey(proxyName),
      onDismissed: _handleRealRemove,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ItemPositionProvider(
          position: position,
          child: DecorationListItem(
            minVerticalPadding: 8,
            title: Text(proxyName),
            subtitle: Text(proxyType ?? proxyName.toLowerCase()),
            leading: CommonMinIconButtonTheme(
              child: IconButton.filledTonal(
                onPressed: () {
                  _handleRemove(proxyName);
                },
                icon: Icon(Icons.remove, size: 18),
                padding: EdgeInsets.zero,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReorderableDelayedDragStartListener(
                  index: index,
                  child: Icon(Icons.drag_handle, size: 24),
                ),
                SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    ref.read(proxyGroupProvider.notifier).update((state) {
      final nextItems = List<String>.from(state.proxies ?? []);
      final item = nextItems.removeAt(oldIndex);
      nextItems.insert(newIndex, item);
      return state.copyWith(proxies: nextItems);
    });
  }

  void _handleChangeIncludeAllProxies() {
    ref
        .read(proxyGroupProvider.notifier)
        .update(
          (state) => state.copyWith(
            includeAllProxies: !(state.includeAllProxies ?? false),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final vm2 = ref.watch(
      proxyGroupProvider.select(
        (state) => VM2(state.includeAllProxies ?? false, state.proxies ?? []),
      ),
    );
    final dismissItems = ref.watch(itemsProvider(key));
    final includeAllProxies = vm2.a;
    final proxyNames = vm2.b;
    final proxyTypeMap =
        ref.watch(
          clashConfigProvider(
            profileId,
          ).select((state) => state.value?.proxyTypeMap),
        ) ??
        {};
    final isBottomSheet =
        SheetProvider.of(context)?.type == SheetType.bottomSheet;
    return SizedBox(
      height: isBottomSheet
          ? appController.viewSize.height * 0.85
          : double.maxFinite,
      child: AdaptiveSheetScaffold(
        title: '编辑代理',
        sheetTransparentToolBar: true,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: context.sheetTopPadding + 8),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: CommonCard(
                  radius: 20,
                  type: CommonCardType.filled,
                  child: ListItem.switchItem(
                    minTileHeight: 54,
                    title: Text('包含所有代理'),
                    delegate: SwitchDelegate(
                      value: includeAllProxies,
                      onChanged: (_) {
                        _handleChangeIncludeAllProxies();
                      },
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: InfoHeader(
                  info: Info(label: '节点'),
                  actions: [
                    CommonMinFilledButtonTheme(
                      child: FilledButton.tonal(
                        onPressed: _handleToAddProxiesView,
                        child: Text('添加'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (proxyNames.isNotEmpty)
              SliverReorderableList(
                itemBuilder: (_, index) {
                  final proxyName = proxyNames[index];
                  final position = ItemPosition.calculateVisualPosition(
                    index,
                    proxyNames,
                    dismissItems,
                  );
                  return _buildItem(
                    position: position,
                    dismiss: dismissItems.contains(proxyName),
                    proxyName: proxyName,
                    proxyType: proxyTypeMap[proxyName],
                    index: index,
                    length: proxyNames.length,
                  );
                },
                itemCount: proxyNames.length,
                onReorder: (int oldIndex, int newIndex) {
                  _handleReorder(oldIndex, newIndex);
                },
              )
            else
              SliverFillRemaining(child: NullStatus(label: '代理为空')),
            SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}

class _AddProxiesView extends ConsumerStatefulWidget {
  const _AddProxiesView();

  @override
  ConsumerState<_AddProxiesView> createState() => _AddProxiesViewState();
}

class _AddProxiesViewState extends ConsumerState<_AddProxiesView>
    with UniqueKeyStateMixin {
  @override
  void initState() {
    super.initState();
    ref.listenManual(itemsProvider('${key}_groups'), (prev, next) {
      if (!SetEquality().equals(prev, next)) {
        _handleRealAdd('groups');
      }
    });
    ref.listenManual(itemsProvider('${key}_proxies'), (prev, next) {
      if (!SetEquality().equals(prev, next)) {
        _handleRealAdd('proxies');
      }
    });
  }

  void _handleAdd(String name, String scene) {
    final realKey = '${key}_$scene';
    ref.read(itemsProvider(realKey).notifier).update((state) {
      final newSet = Set.from(state);
      newSet.add(name);
      return newSet;
    });
  }

  void _handleRealAdd(String scene) {
    debouncer.call(
      'AddProxiesViewState_handleRealAdd_$scene',
      () {
        if (!ref.context.mounted) {
          return;
        }
        final realKey = '${key}_$scene';
        final dismissItems = ref.read(itemsProvider(realKey));
        ref.read(proxyGroupProvider.notifier).update((state) {
          return state.copyWith(
            proxies: [...state.proxies ?? [], ...dismissItems],
          );
        });
        ref
            .read(itemsProvider(realKey).notifier)
            .update((state) => <dynamic>{});
      },
      duration: Duration(milliseconds: 350),
    );
  }

  Widget _buildItem({
    required String title,
    required String subtitle,
    required ItemPosition position,
    required bool dismiss,
    required VoidCallback onAdd,
  }) {
    return ExternalDismissible(
      effect: ExternalDismissibleEffect.resize,
      key: ValueKey(title),
      dismiss: dismiss,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ItemPositionProvider(
          position: position,
          child: DecorationListItem(
            minVerticalPadding: 8,
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: CommonMinIconButtonTheme(
              child: IconButton.filledTonal(
                onPressed: onAdd,
                icon: Icon(Icons.add, size: 18),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBottomSheet =
        SheetProvider.of(context)?.type == SheetType.bottomSheet;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final dismissGroups = ref.watch(itemsProvider('${key}_groups'));
    final dismissProxies = ref.watch(itemsProvider('${key}_proxies'));
    final allProxiesAndProxyGroups = ref.watch(
      clashConfigProvider(profileId).select(
        (state) =>
            VM2(state.value?.proxies ?? [], state.value?.proxyGroups ?? []),
      ),
    );
    final allProxies = allProxiesAndProxyGroups.a;
    final allProxyGroups = allProxiesAndProxyGroups.b;
    final excludeProxyNames = ref.watch(
      proxyGroupProvider.select((state) {
        return [...?state.proxies, state.name];
      }),
    );
    final proxyGroups = allProxyGroups
        .where((item) => !excludeProxyNames.contains(item.name))
        .toList();
    final proxies = allProxies
        .where((item) => !excludeProxyNames.contains(item.name))
        .toList();
    final groupNames = proxyGroups.map((item) => item.name).toList();
    final proxyNames = proxies.map((item) => item.name).toList();
    return SizedBox(
      height: isBottomSheet
          ? appController.viewSize.height * 0.80
          : double.maxFinite,
      child: AdaptiveSheetScaffold(
        sheetTransparentToolBar: true,
        title: '添加代理',
        body: proxies.isEmpty && proxyGroups.isEmpty
            ? NullStatus(label: appLocalizations.noData)
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(height: context.sheetTopPadding),
                  ),
                  if (proxyGroups.isNotEmpty) ...[
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: InfoHeader(info: Info(label: '策略组')),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((_, index) {
                        final proxyGroup = proxyGroups[index];
                        final position = ItemPosition.calculateVisualPosition(
                          index,
                          groupNames,
                          dismissGroups,
                        );
                        return _buildItem(
                          title: proxyGroup.name,
                          subtitle: proxyGroup.type.value,
                          position: position,
                          dismiss: dismissGroups.contains(proxyGroup.name),
                          onAdd: () {
                            _handleAdd(proxyGroup.name, 'groups');
                          },
                        );
                      }, childCount: proxyGroups.length),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 8)),
                  ],
                  if (proxies.isNotEmpty) ...[
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: InfoHeader(info: Info(label: '代理')),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((_, index) {
                        final proxy = proxies[index];
                        final position = ItemPosition.calculateVisualPosition(
                          index,
                          proxyNames,
                          dismissProxies,
                        );
                        return _buildItem(
                          title: proxy.name,
                          subtitle: proxy.type,
                          position: position,
                          dismiss: dismissProxies.contains(proxy.name),
                          onAdd: () {
                            _handleAdd(proxy.name, 'proxies');
                          },
                        );
                      }, childCount: proxies.length),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
