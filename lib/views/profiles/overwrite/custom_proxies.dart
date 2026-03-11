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
        maxWidth: 400,
      ),
      builder: (context) {
        return ProfileIdProvider(
          profileId: profileId,
          child: ProxyGroupProvider(
            proxyGroup: proxyGroup,
            child: _EditProxyGroupNestedSheet(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxyGroups = ref.watch(proxyGroupsProvider(profileId)).value ?? [];
    return CommonScaffold(
      title: '策略组',
      body: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        padding: EdgeInsets.only(bottom: 16),
        itemBuilder: (_, index) {
          final proxyGroup = proxyGroups[index];
          return ReorderableDelayedDragStartListener(
            key: ValueKey(proxyGroup),
            index: index,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: CommonCard(
                radius: 16,
                padding: EdgeInsets.all(16),
                onPressed: () {
                  _handleEditProxyGroup(context, proxyGroup);
                },
                child: ListTile(
                  minTileHeight: 0,
                  minVerticalPadding: 0,
                  titleTextStyle: context.textTheme.bodyMedium?.toJetBrainsMono,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  title: Text(proxyGroup.name),
                  subtitle: Text(proxyGroup.type.name),
                ),
              ),
            ),
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

  Future<void> _handlePop(
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
                  _handlePop(context, nestedNavigatorKey.currentState);
                },
              ),
            ),
            SheetViewport(
              child: PagedSheet(
                decoration: MaterialSheetDecoration(
                  size: SheetSize.stretch,
                  borderRadius: sheetProvider.type == SheetType.bottomSheet
                      ? BorderRadius.vertical(top: Radius.circular(28))
                      : BorderRadius.zero,
                  clipBehavior: Clip.antiAlias,
                ),
                navigator: nestedNavigator,
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
  late ProxyGroup _proxyGroup;

  final _nameController = TextEditingController();
  final _hideController = ValueNotifier<bool>(false);
  final _disableUDPController = ValueNotifier<bool>(false);
  final _proxiesController = ValueNotifier<List<String>>([]);
  final _useController = ValueNotifier<List<String>>([]);
  final _typeController = ValueNotifier<GroupType>(GroupType.Selector);
  final _allProxiesController = ValueNotifier<bool>(false);
  final _allProviderController = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameController.text = _proxyGroup.name;
      _hideController.value = _proxyGroup.hidden ?? false;
      _disableUDPController.value = _proxyGroup.disableUDP ?? false;
      _typeController.value = _proxyGroup.type;
      _proxiesController.value = _proxyGroup.proxies ?? [];
      _useController.value = _proxyGroup.use ?? [];
      if (_proxyGroup.includeAll == true) {
        _allProxiesController.value = true;
        _allProviderController.value = true;
      } else {
        _allProxiesController.value = _proxyGroup.includeAllProxies ?? false;
        _allProviderController.value = _proxyGroup.includeAllProviders ?? false;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _proxyGroup = ProxyGroupProvider.of(context)!.proxyGroup;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hideController.dispose();
    _disableUDPController.dispose();
    _typeController.dispose();
    _proxiesController.dispose();
    _useController.dispose();
    _allProxiesController.dispose();
    _allProviderController.dispose();
    super.dispose();
  }

  Future<void> _showTypeOptions() async {
    final value = await globalState.showCommonDialog<GroupType>(
      child: OptionsDialog<GroupType>(
        title: '类型',
        options: GroupType.values,
        textBuilder: (item) => item.name,
        value: _typeController.value,
      ),
    );
    if (value == null) {
      return;
    }
    _typeController.value = value;
  }

  Widget _buildItem({
    required Widget title,
    Widget? trailing,
    final VoidCallback? onPressed,
  }) {
    return CommonInputListItem(
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
    Navigator.of(context).push(
      PagedSheetRoute(
        builder: (context) => _EditProxiesView(_proxyGroup.proxies ?? []),
      ),
    );
  }

  void _handleToProvidersView() {}

  Widget _buildProvidersItem() {
    return _buildItem(
      title: Text('选择代理集'),
      trailing: ValueListenableBuilder(
        valueListenable: _allProviderController,
        builder: (_, allProviders, _) {
          return ValueListenableBuilder(
            valueListenable: _useController,
            builder: (_, use, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  !allProviders
                      ? Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Container(
                            constraints: BoxConstraints(minWidth: 32),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 3,
                              ),
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
              );
            },
          );
        },
      ),
      onPressed: _handleToProvidersView,
    );
  }

  Widget _buildProxiesItem() {
    return _buildItem(
      title: Text('选择代理'),
      trailing: ValueListenableBuilder(
        valueListenable: _allProxiesController,
        builder: (_, allProxies, _) {
          return ValueListenableBuilder(
            valueListenable: _proxiesController,
            builder: (_, proxies, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  !allProxies
                      ? Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Container(
                            constraints: BoxConstraints(minWidth: 32),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 3,
                              ),
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
              );
            },
          );
        },
      ),
      onPressed: _handleToProxiesView,
    );
  }

  Widget _buildGroupTypeItem() {
    return _buildItem(
      title: Text('类型'),
      onPressed: () {
        _showTypeOptions();
      },
      trailing: ValueListenableBuilder(
        valueListenable: _typeController,
        builder: (_, type, _) {
          return Text(type.name);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _proxyGroup = ProxyGroupProvider.of(context)!.proxyGroup;
    final isBottomSheet =
        SheetProvider.of(context)?.type == SheetType.bottomSheet;
    return AdaptiveSheetScaffold(
      actions: [IconButtonData(icon: Icons.check, onPressed: () {})],
      body: SizedBox(
        height: isBottomSheet
            ? appController.viewSize.height * 0.65
            : double.maxFinite,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 20),
          children: [
            generateSectionV3(
              title: '通用',
              items: [
                _buildItem(
                  title: Text('名称'),
                  trailing: TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.end,
                    decoration: InputDecoration.collapsed(
                      border: NoInputBorder(),
                      hintText: '输入策略组名称',
                    ),
                  ),
                ),
                _buildGroupTypeItem(),
                _buildItem(title: Text('图标')),
                _buildItem(
                  title: Text('从列表中隐藏'),
                  onPressed: () {
                    _hideController.value = !_hideController.value;
                  },
                  trailing: ValueListenableBuilder(
                    valueListenable: _hideController,
                    builder: (_, value, _) {
                      return Switch(
                        value: value,
                        onChanged: (value) {
                          _hideController.value = value;
                        },
                      );
                    },
                  ),
                ),
                _buildItem(
                  title: Text('禁用UDP'),
                  onPressed: () {
                    _disableUDPController.value = !_disableUDPController.value;
                  },
                  trailing: ValueListenableBuilder(
                    valueListenable: _disableUDPController,
                    builder: (_, value, _) {
                      return Switch(
                        value: value,
                        onChanged: (value) {
                          _disableUDPController.value = value;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            generateSectionV3(
              title: '节点',
              items: [
                _buildProxiesItem(),
                _buildProvidersItem(),
                _buildItem(
                  title: Text('节点过滤器'),
                  trailing: TextFormField(
                    textAlign: TextAlign.end,
                    decoration: InputDecoration.collapsed(
                      border: NoInputBorder(),
                      hintText: '可选',
                    ),
                  ),
                ),
                _buildItem(
                  title: Text('排除过滤器'),
                  trailing: TextFormField(
                    textAlign: TextAlign.end,
                    decoration: InputDecoration.collapsed(
                      border: NoInputBorder(),
                      hintText: '可选',
                    ),
                  ),
                ),
                _buildItem(
                  title: Text('排除类型'),
                  trailing: TextFormField(
                    textAlign: TextAlign.end,
                    decoration: InputDecoration.collapsed(
                      border: NoInputBorder(),
                      hintText: '可选',
                    ),
                  ),
                ),
                _buildItem(
                  title: Text('预期状态'),
                  trailing: TextFormField(
                    textAlign: TextAlign.end,
                    decoration: InputDecoration.collapsed(
                      border: NoInputBorder(),
                      hintText: '可选',
                    ),
                  ),
                ),
              ],
            ),
            generateSectionV3(
              title: '其他',
              items: [
                _buildItem(
                  title: Text('测速链接'),
                  trailing: TextFormField(
                    textAlign: TextAlign.end,
                    decoration: InputDecoration.collapsed(
                      border: NoInputBorder(),
                      hintText: '可选',
                    ),
                  ),
                ),
                _buildItem(
                  title: Text('最大失败次数'),
                  trailing: TextFormField(
                    textAlign: TextAlign.end,
                    decoration: InputDecoration.collapsed(
                      border: NoInputBorder(),
                      hintText: '可选',
                    ),
                  ),
                ),
                _buildItem(
                  title: Text('使用时测速'),
                  trailing: Switch(value: false, onChanged: (_) {}),
                ),
                _buildItem(
                  title: Text('测速间隔'),
                  trailing: TextFormField(
                    textAlign: TextAlign.end,
                    decoration: InputDecoration.collapsed(
                      border: NoInputBorder(),
                      hintText: '可选',
                    ),
                  ),
                ),
              ],
            ),
            generateSectionV3(
              title: '操作',
              items: [
                _buildItem(
                  title: Text('删除'),
                  onPressed: () {
                    _disableUDPController.value = !_disableUDPController.value;
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
  final List<String> proxyNames;

  const _EditProxiesView(this.proxyNames);

  @override
  ConsumerState<_EditProxiesView> createState() => _EditProxiesViewState();
}

class _EditProxiesViewState extends ConsumerState<_EditProxiesView> {
  void _handleToAddProxiesView() {
    Navigator.of(context).push(
      PagedSheetRoute(
        builder: (context) =>
            _AddProxiesView(addedProxyNames: widget.proxyNames),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final proxyNames = widget.proxyNames;
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
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: CommonCard(
                  radius: 20,
                  type: CommonCardType.filled,
                  child: ListItem.switchItem(
                    minTileHeight: 54,
                    title: Text('包含所有代理'),
                    delegate: SwitchDelegate(value: false, onChanged: (_) {}),
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
            SliverReorderableList(
              itemBuilder: (_, index) {
                final proxyName = proxyNames[index];
                return Container(
                  key: Key(proxyName),
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  color: Colors.transparent,
                  child: Row(
                    spacing: 8,
                    children: [
                      Flexible(
                        child: CommonCard(
                          radius: 18,
                          onPressed: () {},
                          child: ListTile(
                            leading: CommonMinIconButtonTheme(
                              child: IconButton.filledTonal(
                                onPressed: () {},
                                icon: Icon(Icons.remove, size: 18),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            minTileHeight:
                                32 + globalState.measure.bodyMediumHeight,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            title: Text(proxyName),
                            subtitle: Text(
                              proxyTypeMap[proxyName] ??
                                  proxyName.toLowerCase(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemExtent:
                  24 +
                  globalState.measure.bodyMediumHeight +
                  globalState.measure.bodyLargeHeight,
              itemCount: proxyNames.length,
              onReorder: (int oldIndex, int newIndex) {},
            ),
            SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}

class _AddProxiesView extends ConsumerWidget {
  final List<String> addedProxyNames;

  const _AddProxiesView({required this.addedProxyNames});

  @override
  Widget build(BuildContext context, ref) {
    final isBottomSheet =
        SheetProvider.of(context)?.type == SheetType.bottomSheet;
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final currentGroupName = ProxyGroupProvider.of(context)!.proxyGroup.name;
    final proxiesAndGroupsMap = ref.watch(
      clashConfigProvider(profileId).select(
        (state) =>
            VM2(state.value?.proxies ?? [], state.value?.proxyGroups ?? []),
      ),
    );
    final allProxies = proxiesAndGroupsMap.a;
    final allProxyGroups = proxiesAndGroupsMap.b;
    final proxies = allProxies
        .where((item) => !addedProxyNames.contains(item.name))
        .toList();
    final groups = allProxyGroups
        .where((item) => currentGroupName != item.name)
        .toList();
    return SizedBox(
      height: isBottomSheet
          ? appController.viewSize.height * 0.80
          : double.maxFinite,
      child: AdaptiveSheetScaffold(
        title: '添加代理',
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (groups.isNotEmpty) ...[
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: InfoHeader(info: Info(label: '策略组')),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((_, index) {
                  final group = groups[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    color: Colors.transparent,
                    child: Row(
                      spacing: 8,
                      children: [
                        Flexible(
                          child: CommonCard(
                            radius: 18,
                            onPressed: () {},
                            child: ListTile(
                              trailing: CommonMinIconButtonTheme(
                                child: IconButton.filledTonal(
                                  onPressed: () {},
                                  icon: Icon(Icons.add, size: 18),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              minTileHeight:
                                  32 + globalState.measure.bodyMediumHeight,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              title: Text(group.name),
                              subtitle: Text(group.type.value),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }, childCount: groups.length),
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
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    color: Colors.transparent,
                    child: Row(
                      spacing: 8,
                      children: [
                        Flexible(
                          child: CommonCard(
                            radius: 18,
                            onPressed: () {},
                            child: ListTile(
                              trailing: CommonMinIconButtonTheme(
                                child: IconButton.filledTonal(
                                  onPressed: () {},
                                  icon: Icon(Icons.add, size: 18),
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              minTileHeight:
                                  32 + globalState.measure.bodyMediumHeight,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              title: Text(proxy.name),
                              subtitle: Text(proxy.type),
                            ),
                          ),
                        ),
                      ],
                    ),
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
