// ignore_for_file: deprecated_member_use

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/overwrite/rule.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/config/scripts.dart';
import 'package:fl_clash/views/profiles/preview.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

part 'custom.dart';
part 'custom_groups.dart';
part 'script.dart';
part 'standard.dart';
part 'widgets.dart';

class OverwriteView extends ConsumerStatefulWidget {
  final int profileId;

  const OverwriteView({super.key, required this.profileId});

  @override
  ConsumerState<OverwriteView> createState() => _OverwriteViewState();
}

class _OverwriteViewState extends ConsumerState<OverwriteView> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _handlePreview() async {
    final profile = ref.read(profileProvider(widget.profileId));
    if (profile == null) {
      return;
    }
    BaseNavigator.push<String>(context, PreviewProfileView(profile: profile));
  }

  @override
  Widget build(BuildContext context) {
    return ProfileIdProvider(
      profileId: widget.profileId,
      child: CommonScaffold(
        title: appLocalizations.override,
        actions: [
          CommonMinFilledButtonTheme(
            child: FilledButton(
              onPressed: _handlePreview,
              child: Text(appLocalizations.preview),
            ),
          ),
          SizedBox(width: 8),
        ],
        body: CustomScrollView(slivers: [_Title(), _Content()]),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    appController.autoApplyProfile();
  }
}

class _Title extends ConsumerWidget {
  const _Title();

  String _getTitle(OverwriteType type) {
    return switch (type) {
      OverwriteType.standard => appLocalizations.standard,
      OverwriteType.script => appLocalizations.script,
      OverwriteType.custom => appLocalizations.overwriteTypeCustom,
    };
  }

  IconData _getIcon(OverwriteType type) {
    return switch (type) {
      OverwriteType.standard => Icons.stars,
      OverwriteType.script => Icons.rocket,
      OverwriteType.custom => Icons.dashboard_customize,
    };
  }

  String _getDesc(OverwriteType type) {
    return switch (type) {
      OverwriteType.standard => appLocalizations.standardModeDesc,
      OverwriteType.script => appLocalizations.scriptModeDesc,
      OverwriteType.custom => appLocalizations.overwriteTypeCustomDesc,
    };
  }

  void _handleChangeType(WidgetRef ref, int profileId, OverwriteType type) {
    ref.read(profilesProvider.notifier).updateProfile(profileId, (state) {
      return state.copyWith(overwriteType: type);
    });
  }

  @override
  Widget build(context, ref) {
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final overwriteType = ref.watch(overwriteTypeProvider(profileId));
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoHeader(info: Info(label: appLocalizations.overrideMode)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 16,
              children: [
                for (final type in OverwriteType.values)
                  CommonCard(
                    isSelected: overwriteType == type,
                    onPressed: () {
                      _handleChangeType(ref, profileId, type);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(_getIcon(type)),
                          const SizedBox(width: 8),
                          Flexible(child: Text(_getTitle(type))),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _getDesc(overwriteType),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant.opacity80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content();

  @override
  Widget build(BuildContext context, ref) {
    final profileId = ProfileIdProvider.of(context)!.profileId;
    final overwriteType = ref.watch(overwriteTypeProvider(profileId));
    ref.listen(clashConfigProvider(profileId), (_, _) {});
    return switch (overwriteType) {
      OverwriteType.standard => _StandardContent(),
      OverwriteType.script => _ScriptContent(),
      OverwriteType.custom => _CustomContent(),
    };
  }
}
