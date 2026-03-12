import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'scaffold.dart';
import 'side_sheet.dart';

@immutable
class SheetProps {
  final double? maxWidth;
  final double? maxHeight;
  final bool isScrollControlled;
  final bool useSafeArea;
  final Color? backgroundColor;
  final bool blur;

  const SheetProps({
    this.maxWidth,
    this.maxHeight,
    this.backgroundColor,
    this.useSafeArea = true,
    this.isScrollControlled = false,
    this.blur = true,
  });
}

@immutable
class ExtendProps {
  final double? maxWidth;
  final bool useSafeArea;
  final bool blur;
  final bool forceFull;

  const ExtendProps({
    this.maxWidth,
    this.useSafeArea = true,
    this.blur = true,
    this.forceFull = false,
  });
}

enum SheetType { page, bottomSheet, sideSheet }

Future<T?> showSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  SheetProps props = const SheetProps(),
}) {
  final isMobile = appController.isMobile;
  return switch (isMobile) {
    true => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: props.isScrollControlled,
      builder: (_) {
        return SheetProvider(
          type: SheetType.bottomSheet,
          child: builder(context),
        );
      },
      backgroundColor: props.backgroundColor,
      showDragHandle: false,
      useSafeArea: props.useSafeArea,
    ),
    false => showModalSideSheet<T>(
      useSafeArea: props.useSafeArea,
      isScrollControlled: props.isScrollControlled,
      context: context,
      backgroundColor: props.backgroundColor,
      constraints: BoxConstraints(maxWidth: props.maxWidth ?? 360),
      filter: props.blur ? commonFilter : null,
      builder: (_) {
        return SheetProvider(
          type: SheetType.sideSheet,
          child: builder(context),
        );
      },
    ),
  };
}

Future<T?> showExtend<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  ExtendProps props = const ExtendProps(),
}) {
  final isMobile = appController.isMobile;
  return switch (isMobile || props.forceFull) {
    true => BaseNavigator.push(
      context,
      SheetProvider(type: SheetType.page, child: builder(context)),
    ),
    false => showModalSideSheet<T>(
      useSafeArea: props.useSafeArea,
      context: context,
      constraints: BoxConstraints(maxWidth: props.maxWidth ?? 360),
      filter: props.blur ? commonFilter : null,
      builder: (context) {
        return SheetProvider(
          type: SheetType.sideSheet,
          child: builder(context),
        );
      },
    ),
  };
}

class AdaptiveSheetScaffold extends StatefulWidget {
  final Widget body;
  final String title;
  final bool bottomSheetBackdrop;
  final List<IconButtonData> actions;

  const AdaptiveSheetScaffold({
    super.key,
    required this.body,
    required this.title,
    this.bottomSheetBackdrop = false,
    this.actions = const [],
  });

  @override
  State<AdaptiveSheetScaffold> createState() => _AdaptiveSheetScaffoldState();
}

class _AdaptiveSheetScaffoldState extends State<AdaptiveSheetScaffold> {
  IconData get backIconData {
    if (kIsWeb) {
      return Icons.arrow_back;
    }
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return Icons.arrow_back;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return Icons.arrow_back_ios_new_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.colorScheme.surface;
    final sheetProvider = SheetProvider.of(context);
    final nestedNavigatorPopCallback =
        sheetProvider?.nestedNavigatorPopCallback;
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    final type = sheetProvider?.type ?? SheetType.page;
    final useCloseIcon =
        type != SheetType.page &&
        (nestedNavigatorPopCallback != null &&
                route?.impliesAppBarDismissal == false ||
            nestedNavigatorPopCallback == null);
    Widget buildIconButton(IconButtonData data) {
      if (type == SheetType.bottomSheet) {
        return IconButton.filledTonal(
          onPressed: data.onPressed,
          style: IconButton.styleFrom(
            visualDensity: VisualDensity.standard,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: Icon(data.icon),
        );
      }
      return IconButton(
        onPressed: data.onPressed,
        style: IconButton.styleFrom(
          visualDensity: VisualDensity.standard,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: Icon(data.icon),
      );
    }

    final actions = widget.actions.map(buildIconButton).toList();

    final popButton = type != SheetType.page
        ? (useCloseIcon
              ? buildIconButton(
                  IconButtonData(
                    icon: Icons.close,
                    onPressed: () {
                      if (nestedNavigatorPopCallback != null) {
                        nestedNavigatorPopCallback();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                )
              : buildIconButton(
                  IconButtonData(
                    icon: backIconData,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ))
        : null;

    final suffixPop = type != SheetType.page && actions.isEmpty && useCloseIcon;
    final appBar = AppBar(
      backgroundColor:
          type == SheetType.bottomSheet && widget.bottomSheetBackdrop == true
          ? backgroundColor.opacity80
          : backgroundColor,
      forceMaterialTransparency: type == SheetType.bottomSheet ? true : false,
      leading: suffixPop ? null : popButton,
      automaticallyImplyLeading: type == SheetType.page ? true : false,
      centerTitle: true,
      toolbarHeight: type == SheetType.bottomSheet ? 48 : null,
      title: Text(widget.title),
      titleTextStyle: type == SheetType.bottomSheet
          ? context.textTheme.titleLarge?.adjustSize(-4)
          : null,
      actions: !suffixPop ? genActions(actions) : genActions([?popButton]),
    );
    if (type == SheetType.bottomSheet) {
      final handleSize = Size(28, 4);
      final sheetAppBar = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Container(
              alignment: Alignment.center,
              height: handleSize.height,
              width: handleSize.width,
              decoration: ShapeDecoration(
                color: context.colorScheme.onSurfaceVariant,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(handleSize.height / 2),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: appBar),
          SizedBox(height: 6),
        ],
      );
      return ScrollConfiguration(
        behavior: HiddenBarScrollBehavior(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.bottomSheetBackdrop) ...[
              sheetAppBar,
              Flexible(child: widget.body),
            ] else ...[
              Flexible(
                child: Stack(
                  children: [
                    widget.body,
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                        child: BackdropFilter(
                          filter: commonFilter,
                          child: sheetAppBar,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      );
    }
    return CommonScaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: widget.body,
    );
  }
}
