part of 'overwrite.dart';

class _StandardContent extends ConsumerStatefulWidget {
  const _StandardContent();

  @override
  ConsumerState createState() => _StandardContentState();
}

class _StandardContentState extends ConsumerState<_StandardContent> {
  final _key = utils.id;
  late int _profileId;

  Future<void> _handleAddOrUpdate([Rule? rule]) async {
    final res = await globalState.showCommonDialog<Rule>(
      child: AddOrEditRuleDialog(rule: rule),
    );
    if (res == null) {
      return;
    }
    ref.read(profileAddedRulesProvider(_profileId).notifier).put(res);
  }

  void _handleSelected(int ruleId) {
    ref.read(itemsProvider(_key).notifier).update((selectedRules) {
      final newSelectedRules = Set<int>.from(selectedRules)
        ..addOrRemove(ruleId);
      return newSelectedRules;
    });
  }

  void _handleSelectAll() {
    final ids =
        ref
            .read(profileAddedRulesProvider(_profileId))
            .value
            ?.map((item) => item.id)
            .toSet() ??
        {};
    ref.read(itemsProvider(_key).notifier).update((selected) {
      return selected.containsAll(ids) ? {} : ids;
    });
  }

  Future<void> _handleDelete() async {
    final res = await globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(
        text: appLocalizations.deleteMultipTip(appLocalizations.rule),
      ),
    );
    if (res != true) {
      return;
    }
    final selectedRules = ref.read(itemsProvider(_key));
    ref
        .read(profileAddedRulesProvider(_profileId).notifier)
        .delAll(selectedRules.cast<int>());
    ref.read(itemsProvider(_key).notifier).value = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileId = ProfileIdProvider.of(context)!.profileId;
  }

  void _handleToEditGlobalAddedRules() {
    BaseNavigator.push(context, _EditGlobalAddedRules(_profileId));
  }

  @override
  Widget build(BuildContext context) {
    _profileId = ProfileIdProvider.of(context)!.profileId;
    final addedRules =
        ref.watch(profileAddedRulesProvider(_profileId)).value ?? [];
    final selectedRules = ref.watch(itemsProvider(_key));
    return CommonPopScope(
      onPop: (_) {
        if (selectedRules.isNotEmpty) {
          ref.read(itemsProvider(_key).notifier).value = {};
          return false;
        }
        Navigator.of(context).pop();
        return false;
      },
      child: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Column(
              children: [
                InfoHeader(
                  info: Info(label: appLocalizations.addedRules),
                  actions: [
                    if (selectedRules.isNotEmpty) ...[
                      CommonMinIconButtonTheme(
                        child: IconButton.filledTonal(
                          onPressed: () {
                            _handleDelete();
                          },
                          icon: Icon(Icons.delete),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                    CommonMinFilledButtonTheme(
                      child: selectedRules.isNotEmpty
                          ? FilledButton(
                              onPressed: () {
                                _handleSelectAll();
                              },
                              child: Text(appLocalizations.selectAll),
                            )
                          : FilledButton.tonal(
                              onPressed: () {
                                _handleAddOrUpdate();
                              },
                              child: Text(appLocalizations.add),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 8)),
          Consumer(
            builder: (_, ref, _) {
              return SliverReorderableList(
                itemCount: addedRules.length,
                itemBuilder: (_, index) {
                  final rule = addedRules[index];
                  return ReorderableDelayedDragStartListener(
                    key: ObjectKey(rule),
                    index: index,
                    child: RuleItem(
                      isEditing: selectedRules.isNotEmpty,
                      isSelected: selectedRules.contains(rule.id),
                      rule: rule,
                      onSelected: () {
                        _handleSelected(rule.id);
                      },
                      onEdit: (rule) {
                        _handleAddOrUpdate(rule);
                      },
                    ),
                  );
                },
                onReorder: ref
                    .read(profileAddedRulesProvider(_profileId).notifier)
                    .order,
              );
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: CommonCard(
                radius: 18,
                onPressed: _handleToEditGlobalAddedRules,
                child: ListTile(
                  minTileHeight: 0,
                  minVerticalPadding: 0,
                  titleTextStyle: context.textTheme.bodyMedium?.toJetBrainsMono,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          appLocalizations.controlGlobalAddedRules,
                          style: context.textTheme.bodyLarge,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditGlobalAddedRules extends ConsumerWidget {
  final int profileId;

  const _EditGlobalAddedRules(this.profileId);

  void _handleChange(WidgetRef ref, int profileId, bool status, int ruleId) {
    if (status) {
      ref.read(profileDisabledRuleIdsProvider(profileId).notifier).put(ruleId);
    } else {
      ref.read(profileDisabledRuleIdsProvider(profileId).notifier).del(ruleId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final disabledRuleIds =
        ref.watch(profileDisabledRuleIdsProvider(profileId)).value ?? [];
    final rules = ref.watch(globalRulesProvider).value ?? [];
    return BaseScaffold(
      title: appLocalizations.editGlobalRules,
      body: rules.isEmpty
          ? NullStatus(
              label: appLocalizations.nullTip(appLocalizations.rule),
              illustration: RuleEmptyIllustration(),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final rule = rules[index];
                return RuleStatusItem(
                  status: !disabledRuleIds.contains(rule.id),
                  rule: rule,
                  onChange: (status) {
                    _handleChange(ref, profileId, !status, rule.id);
                  },
                );
              },
              itemCount: rules.length,
            ),
    );
  }
}
