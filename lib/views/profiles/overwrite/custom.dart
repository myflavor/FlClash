part of 'overwrite.dart';

class _CustomContent extends ConsumerWidget {
  final int profileId;

  const _CustomContent(this.profileId);

  void _handleUseDefault() async {
    final configMap = await coreController.getConfig(profileId);
    final clashConfig = ClashConfig.fromJson(configMap);
    await database.setProfileCustomData(
      profileId,
      clashConfig.proxyGroups,
      clashConfig.rules,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxyGroupNum = ref.watch(
      proxyGroupsProvider(
        profileId,
      ).select((state) => state.value?.length ?? -1),
    );
    final ruleNum = ref.watch(
      profileCustomRulesProvider(
        profileId,
      ).select((state) => state.value?.length ?? -1),
    );
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Column(
            children: [InfoHeader(info: Info(label: '自定义'))],
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: _MoreActionButton(
            label: '代理组',
            onPressed: () {},
            trailing: Card.filled(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: BoxConstraints(minWidth: 44),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Text(
                    textAlign: TextAlign.center,
                    '$proxyGroupNum',
                    style: context.textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 4)),
        SliverToBoxAdapter(
          child: _MoreActionButton(
            label: '规则',
            onPressed: () {},
            trailing: Card.filled(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                constraints: BoxConstraints(minWidth: 44),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  '$ruleNum',
                  style: context.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 32)),
        if (proxyGroupNum == 0 && ruleNum == 0)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: MaterialBanner(
                elevation: 0,
                dividerColor: Colors.transparent,
                content: Text('检测到没有数据'),
                actions: [
                  CommonMinFilledButtonTheme(
                    child: FilledButton.tonal(
                      onPressed: _handleUseDefault,
                      child: Text('一键填入'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // SliverToBoxAdapter(child: SizedBox(height: 8)),
        // SliverToBoxAdapter(
        //   child: Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        //     child: CommonCard(
        //       radius: 18,
        //       child: ListTile(
        //         minTileHeight: 0,
        //         minVerticalPadding: 0,
        //         titleTextStyle: context.textTheme.bodyMedium?.toJetBrainsMono,
        //         contentPadding: const EdgeInsets.symmetric(
        //           horizontal: 16,
        //           vertical: 16,
        //         ),
        //         title: Row(
        //           crossAxisAlignment: CrossAxisAlignment.center,
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Flexible(
        //               child: Text('自定义规则', style: context.textTheme.bodyLarge),
        //             ),
        //             Icon(Icons.arrow_forward_ios, size: 18),
        //           ],
        //         ),
        //       ),
        //       onPressed: () {},
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class _CustomProxyGroups extends ConsumerStatefulWidget {
  final int profileId;

  const _CustomProxyGroups(this.profileId);

  @override
  ConsumerState createState() => _CustomProxyGroupsState();
}

class _CustomProxyGroupsState extends ConsumerState<_CustomProxyGroups> {
  @override
  void initState() {
    super.initState();
  }

  void _handleReorder(int oldIndex, int newIndex) {
    ref
        .read(proxyGroupsProvider(widget.profileId).notifier)
        .order(oldIndex, newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final proxyGroups =
        ref.watch(proxyGroupsProvider(widget.profileId)).value ?? [];
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverReorderableGrid(
        onReorder: _handleReorder,
        itemCount: proxyGroups.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 16 / 8,
        ),
        proxyDecorator: commonProxyDecorator,
        itemBuilder: (_, index) {
          final proxyGroup = proxyGroups[index];
          return ReorderableGridDelayedDragStartListener(
            key: ValueKey(proxyGroup),
            index: index,
            child: CommonCard(
              radius: 12,
              type: CommonCardType.filled,
              padding: EdgeInsets.all(16),
              onPressed: () {},
              child: Text(proxyGroup.name),
            ),
          );
        },
      ),
    );
  }
}

class _CustomRules extends ConsumerWidget {
  final int profileId;

  const _CustomRules({required this.profileId});

  @override
  Widget build(context, ref) {
    final rules = ref.watch(profileCustomRulesProvider(profileId)).value ?? [];
    return SuperSliverList(
      extentEstimation: (_, _) => 100,
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        final rule = rules[index];
        return RuleItem(
          isSelected: false,
          rule: rule,
          onSelected: () {},
          onEdit: (_) {},
        );
      }, childCount: rules.length),
    );
  }
}
