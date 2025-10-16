import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'strategy_builder_viewmodel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:backtestx/l10n/app_localizations.dart';
import 'rule_card_builder.dart';
import 'dialog_builder.dart' as sb_dialog;
import 'risk_management_card.dart';
import 'entry_rules_card.dart';
import 'quick_preview_card.dart';
import 'package:stacked_services/stacked_services.dart' hide DialogBuilder;
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.bottomsheets.dart';
import 'strategy_builder_constants.dart';

class StrategyBuilderView extends StackedView<StrategyBuilderViewModel> {
  final String? strategyId;

  const StrategyBuilderView({Key? key, this.strategyId}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StrategyBuilderViewModel viewModel,
    Widget? child,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        if (viewModel.hasAutosaveDraft) {
          final confirm =
              await sb_dialog.DialogBuilder.showExitConfirmation(context) ??
                  false;
          if (confirm) {
            await viewModel.resetTemplateFilters();
          }
          return confirm;
        }
        await viewModel.resetTemplateFilters();
        return true;
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            actions: [
              // if (viewModel.hasAutosaveDraft)
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 4.0),
              //     child: TextButton.icon(
              //       onPressed: viewModel.restoreDraftIfAvailable,
              //       icon: const Icon(Icons.restore),
              //       label: const Text('Pulihkan Draft'),
              //     ),
              //   ),
              Tooltip(
                message: l10n.sbPickTemplateTooltip,
                child: IconButton(
                  icon: const Icon(Icons.auto_awesome),
                  onPressed: () => _showTemplateSheet(
                    context,
                    viewModel,
                  ),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Tooltip(
                message: l10n.sbRunPreviewTooltip,
                child: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: (viewModel.isRunningPreview ||
                          viewModel.hasFatalErrors ||
                          !viewModel.canSave)
                      ? null
                      : () {
                          if (viewModel.availableData.isEmpty) {
                            viewModel.loadAvailableData();
                          }
                          viewModel.quickPreviewBacktest();
                        },
                ),
              ),

              IconButton(
                icon: const Icon(Icons.more_time),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: false,
                    builder: (ctx) {
                      var enabled = viewModel.autosaveEnabled;
                      return StatefulBuilder(
                        builder: (ctx, setState) {
                          return Padding(
                            padding: const EdgeInsets.all(
                                StrategyBuilderConstants.cardPadding),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.settings, size: 20),
                                    const SizedBox(
                                        width: StrategyBuilderConstants
                                            .smallSpacing),
                                    Text(
                                      l10n.sbAutosaveSettingsHeader,
                                      style:
                                          Theme.of(ctx).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SwitchListTile.adaptive(
                                  value: enabled,
                                  onChanged: (v) {
                                    setState(() {
                                      enabled = v;
                                    });
                                    viewModel.toggleAutosave(v);
                                  },
                                  title: Text(l10n.sbEnableAutosaveTitle),
                                  subtitle: Text(
                                    l10n.sbAutosaveDescription,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              // Template selector (Top MVP quick picks)
              // PopupMenuButton<String>(
              //   tooltip: 'Top MVP Templates',
              //   icon: const Icon(Icons.stacked_bar_chart_outlined),
              //   itemBuilder: (context) {
              //     // Pinned Top MVP templates
              //     final topKeys = [
              //       'breakout_basic',
              //       'trend_ema_cross',
              //       'ema_ribbon_stack',
              //     ];
              //     final topEntries = topKeys
              //         .map((k) => StrategyTemplates.all[k] != null
              //             ? MapEntry(k, StrategyTemplates.all[k]!)
              //             : null)
              //         .whereType<MapEntry<String, StrategyTemplate>>()
              //         .toList();
              //     final widgets = <PopupMenuEntry<String>>[];
              //     for (final e in topEntries) {
              //       final tpl = e.value;
              //       widgets.add(
              //         PopupMenuItem<String>(
              //           value: e.key,
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text(
              //                 tpl.name,
              //                 style: Theme.of(context)
              //                     .textTheme
              //                     .bodyMedium
              //                     ?.copyWith(fontWeight: FontWeight.w600),
              //               ),
              //               const SizedBox(height: 4),
              //               Text(
              //                 tpl.description,
              //                 style: Theme.of(context).textTheme.bodySmall,
              //               ),
              //             ],
              //           ),
              //         ),
              //       );
              //     }
              //     widgets.add(const PopupMenuDivider());
              //     widgets.add(const PopupMenuItem<String>(
              //       value: 'open_picker',
              //       child: Text('Buka Template Picker...'),
              //     ));
              //     return widgets;
              //   },
              //   onSelected: (value) {
              //     if (value == 'open_picker') {
              //       _showTemplateSheet(context, viewModel);
              //     } else {
              //       viewModel.applyTemplate(value);
              //     }
              //   },
              // ),
              // Unified actions menu to reduce AppBar crowding

              PopupMenuButton<String>(
                tooltip: l10n.sbMenuTooltip,
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  switch (value) {
                    case 'tips':
                      await viewModel.startBuilderTour();
                      break;
                    case 'export':
                      await viewModel.exportStrategyJson();
                      break;
                    case 'copy':
                      await viewModel.copyStrategyJson();
                      break;
                    case 'save':
                      if (!kIsWeb) {
                        await viewModel.saveStrategyJsonToFile();
                      }
                      break;
                    case 'import_file':
                      if (!kIsWeb) {
                        final picked = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: const ['json'],
                          withData: true,
                        );
                        if (picked != null && picked.files.isNotEmpty) {
                          final file = picked.files.first;
                          final bytes = file.bytes;
                          final content =
                              bytes != null ? utf8.decode(bytes) : null;
                          if (content != null && content.isNotEmpty) {
                            var proceed = true;
                            if (viewModel.hasUnsavedBuilder) {
                              proceed = await sb_dialog.DialogBuilder
                                      .showConfirmationDialog(
                                    context,
                                    title: l10n.sbImportConfirmTitle,
                                    content: l10n.sbImportConfirmContent,
                                    confirmLabel: l10n.sbOverwrite,
                                  ) ??
                                  false;
                            }
                            if (proceed) {
                              await viewModel.importStrategyJson(content);
                            }
                          }
                        }
                      }
                      break;
                    case 'import':
                      final importController = TextEditingController();
                      await showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.sbImportTemplateJsonTitle),
                          content: SizedBox(
                            width: 480,
                            child: TextField(
                              controller: importController,
                              minLines: 5,
                              maxLines: 12,
                              decoration: InputDecoration(
                                hintText:
                                    '${l10n.sbDialogPasteJson} ${l10n.sbApply}',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: Text(l10n.commonCancel),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final text = importController.text.trim();
                                if (text.isNotEmpty) {
                                  var proceed = true;
                                  if (viewModel.hasUnsavedBuilder) {
                                    proceed = await sb_dialog.DialogBuilder
                                            .showConfirmationDialog(
                                          context,
                                          title: l10n.sbImportConfirmTitle,
                                          content: l10n.sbImportConfirmContent,
                                          confirmLabel: l10n.sbOverwrite,
                                        ) ??
                                        false;
                                  }
                                  if (proceed) {
                                    await viewModel.importStrategyJson(text);
                                  }
                                }
                                if (ctx.mounted && Navigator.of(ctx).canPop()) {
                                  if (ctx.mounted) {
                                    Navigator.of(ctx).pop();
                                  }
                                }
                              },
                              child: Text(l10n.sbApply),
                            ),
                          ],
                        ),
                      );
                      break;
                    case 'delete':
                      if (viewModel.isEditing) {
                        await viewModel.deleteStrategy(context);
                      }
                      break;
                  }
                },
                itemBuilder: (ctx) {
                  final items = <PopupMenuEntry<String>>[];
                  items.add(
                    PopupMenuItem<String>(
                      value: 'tips',
                      child: Text(l10n.sbBuilderTips),
                    ),
                  );
                  items.add(const PopupMenuDivider());
                  if (viewModel.canSave) {
                    items.add(
                      PopupMenuItem<String>(
                        value: 'export',
                        child: Text(l10n.sbExportJson),
                      ),
                    );
                    items.add(
                      PopupMenuItem<String>(
                        value: 'copy',
                        child: Text(l10n.sbCopyJson),
                      ),
                    );
                    if (!kIsWeb) {
                      items.add(
                        PopupMenuItem<String>(
                          value: 'save',
                          child: Text(l10n.sbSaveJson),
                        ),
                      );
                    }
                    items.add(const PopupMenuDivider());
                  }
                  if (!kIsWeb) {
                    items.add(
                      PopupMenuItem<String>(
                        value: 'import_file',
                        child: Text(l10n.sbImportFromFile),
                      ),
                    );
                  }
                  items.add(
                    PopupMenuItem<String>(
                      value: 'import',
                      child: Text(l10n.sbImportJsonEllipsis),
                    ),
                  );
                  if (viewModel.isEditing) {
                    items.add(const PopupMenuDivider());
                    items.add(
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(
                          'Delete Strategy',
                          style: TextStyle(
                            color: Theme.of(ctx).colorScheme.error,
                          ),
                        ),
                      ),
                    );
                  }
                  return items;
                },
              ),
            ],
          ),
          body: viewModel.isBusy
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: viewModel.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(
                          StrategyBuilderConstants.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            viewModel.isEditing
                                ? l10n.sbEditStrategyTitle
                                : l10n.sbCreateStrategyTitle,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          // Autosave section (compact status bar + settings)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // Status (animated)
                                if (viewModel.autosaveEnabled)
                                  AnimatedSwitcher(
                                    duration: StrategyBuilderConstants
                                        .animationDuration,
                                    child: (() {
                                      if (viewModel.isAutoSaving) {
                                        return Row(
                                          key: const ValueKey('saving'),
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              height: 14,
                                              width: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Saving…',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      if (viewModel.autosaveStatus.isNotEmpty) {
                                        final status = viewModel.autosaveStatus;
                                        final icon = status
                                                .contains('Auto-saved')
                                            ? Icons.check_circle
                                            : status.contains('Autosave off')
                                                ? Icons.save_outlined
                                                : status.contains('failed')
                                                    ? Icons.error_outline
                                                    : Icons.info_outline;
                                        final relative = (() {
                                          final ts = viewModel.lastAutosaveAt;
                                          if (ts == null) return '';
                                          final d =
                                              DateTime.now().difference(ts);
                                          if (d.inSeconds < 60) {
                                            return '${d.inSeconds}s ago';
                                          } else if (d.inMinutes < 60) {
                                            return '${d.inMinutes}m ago';
                                          } else if (d.inHours < 24) {
                                            return '${d.inHours}h ago';
                                          } else {
                                            return '${d.inDays}d ago';
                                          }
                                        })();
                                        final ts = viewModel.lastAutosaveAt;
                                        final abs = ts == null
                                            ? null
                                            : '${ts.year.toString().padLeft(4, '0')}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} '
                                                '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}';
                                        final statusRow = Row(
                                          key: const ValueKey('status'),
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              icon,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              relative.isNotEmpty
                                                  ? 'Last: $relative'
                                                  : status,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              overflow: TextOverflow.fade,
                                              softWrap: false,
                                            ),
                                          ],
                                        );
                                        return abs == null
                                            ? statusRow
                                            : Tooltip(
                                                message:
                                                    l10n.sbSavedAtPrefix + abs,
                                                child: statusRow,
                                              );
                                      }
                                      return const SizedBox.shrink();
                                    })(),
                                  ),
                                // Retry inline saat gagal
                                if (viewModel.autosaveEnabled &&
                                    viewModel.autosaveStatus.contains('failed'))
                                  TextButton.icon(
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: Text(l10n.sbRetry),
                                    onPressed: viewModel.retryAutosave,
                                  ),
                                // Discard (TextButton) hanya saat ada draft autosave
                                if (viewModel.hasAutosaveDraft)
                                  Tooltip(
                                    message: l10n.sbDiscardAutosaveTooltip,
                                    child: TextButton(
                                      onPressed: () async {
                                        final confirmed =
                                            await sb_dialog.DialogBuilder
                                                    .showConfirmationDialog(
                                                  context,
                                                  title: 'Discard Draft?',
                                                  content:
                                                      'Draft autosave saat ini akan dihapus dan tidak bisa dikembalikan.',
                                                  confirmLabel: l10n.sbDiscard,
                                                  isDangerous: true,
                                                ) ??
                                                false;
                                        if (confirmed) {
                                          await viewModel.discardDraft();
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                      child: Text(l10n.sbDiscardDraft),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // Strategy Name
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  StrategyBuilderConstants.cardPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.sbStrategyDetailsHeader,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: viewModel.nameController,
                                    decoration: InputDecoration(
                                      labelText: l10n.sbStrategyNameLabel,
                                      hintText: l10n.sbStrategyNameHint,
                                      prefixIcon: const Icon(Icons.label),
                                    ),
                                  ),
                                  const SizedBox(
                                      height:
                                          StrategyBuilderConstants.itemSpacing),
                                  TextField(
                                    controller:
                                        viewModel.initialCapitalController,
                                    decoration: InputDecoration(
                                      labelText: l10n.sbInitialCapitalLabel,
                                      hintText: '10000',
                                      prefixIcon:
                                          const Icon(Icons.attach_money),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(
                              height: StrategyBuilderConstants.itemSpacing),

                          // Risk Management
                          RiskManagementCard(viewModel: viewModel),

                          const SizedBox(
                              height: StrategyBuilderConstants.itemSpacing),

                          // Entry Rules
                          EntryRulesCard(viewModel: viewModel),

                          const SizedBox(
                              height: StrategyBuilderConstants.itemSpacing),

                          // Exit Rules
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  StrategyBuilderConstants.cardPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.sbExitRulesHeader,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle),
                                        onPressed: viewModel.addExitRule,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: StrategyBuilderConstants
                                          .smallSpacing),
                                  if (viewModel.exitRules.isEmpty)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(32.0),
                                        child: Column(
                                          children: [
                                            Icon(Icons.add_box,
                                                size: 48,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.4)),
                                            const SizedBox(
                                                height: StrategyBuilderConstants
                                                    .smallSpacing),
                                            Text(
                                              l10n.sbNoExitRulesYet,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.6)),
                                            ),
                                            const SizedBox(
                                                height: StrategyBuilderConstants
                                                    .microSpacing),
                                            Text(
                                              l10n.sbTapToAddRule,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.5),
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    ...viewModel.exitRules
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      return RuleCardBuilder.build(
                                        context,
                                        viewModel,
                                        entry.key,
                                        entry.value,
                                        false,
                                      );
                                    }).toList(),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(
                              height: StrategyBuilderConstants.sectionSpacing),

                          // Quick Backtest Preview Card
                          QuickPreviewCard(
                            viewModel: viewModel,
                            onPickTemplate: () =>
                                _showTemplateSheet(context, viewModel),
                          ),

                          const SizedBox(
                              height: StrategyBuilderConstants.sectionSpacing),

                          // Save Button
                          Tooltip(
                            message: (() {
                              if (viewModel.hasFatalErrors) {
                                final errs = viewModel.getAllFatalErrors();
                                final shown = errs.take(2).join('\n• ');
                                return 'Fix errors before saving:\n• $shown${errs.length > 2 ? '...' : ''}';
                              }
                              if (!viewModel.canSave) {
                                return 'Leave fields empty to use defaults';
                              }
                              if (viewModel.isSaving) {
                                return 'Saving...';
                              }
                              return 'Save strategy';
                            })(),
                            child: ElevatedButton(
                              onPressed: (viewModel.canSave &&
                                      !viewModel.isSaving &&
                                      !viewModel.hasFatalErrors)
                                  ? () => viewModel.saveStrategy(context)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical:
                                        StrategyBuilderConstants.itemSpacing),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: (() {
                                if (viewModel.isSaving) {
                                  return const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  );
                                }
                                final errs = viewModel.getAllFatalErrors();
                                if (errs.isNotEmpty) {
                                  return Text(
                                    'Fix ${errs.length} error',
                                    style: const TextStyle(fontSize: 16),
                                  );
                                }
                                if (!viewModel.canSave) {
                                  return const Text(
                                    'Fill in required fields',
                                    style: TextStyle(fontSize: 16),
                                  );
                                }
                                return Text(
                                  viewModel.isEditing
                                      ? AppLocalizations.of(context)!
                                          .sbUpdateStrategyButton
                                      : AppLocalizations.of(context)!
                                          .sbSaveStrategyButton,
                                  style: const TextStyle(fontSize: 16),
                                );
                              })(),
                            ),
                          ),

                          // Error summary banner for quick fix guidance
                          const SizedBox(
                              height: StrategyBuilderConstants.mediumSpacing),
                          Builder(builder: (context) {
                            final errs = viewModel.getAllFatalErrors();
                            if (errs.isEmpty) return const SizedBox.shrink();
                            final scheme = Theme.of(context).colorScheme;
                            return Card(
                              color: scheme.errorContainer,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: scheme.error.withValues(alpha: 0.5),
                                ),
                                borderRadius: BorderRadius.circular(
                                    StrategyBuilderConstants.cornerRadiusSmall),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                    StrategyBuilderConstants.mediumSpacing),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.error_outline,
                                            size: 18, color: scheme.error),
                                        const SizedBox(
                                            width: StrategyBuilderConstants
                                                .smallSpacing),
                                        Text(
                                          AppLocalizations.of(context)!
                                              .sbErrorSummaryHeader,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(color: scheme.error),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                        height: StrategyBuilderConstants
                                            .smallSpacing),
                                    ...errs.map((e) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: StrategyBuilderConstants
                                                  .tinySpacing),
                                          child: Text(
                                            '• $e',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: scheme.onErrorContainer
                                                      .withValues(alpha: 0.9),
                                                ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            );
                          }),

                          const SizedBox(
                              height: StrategyBuilderConstants.smallSpacing),

                          const SizedBox(
                              height: StrategyBuilderConstants.sectionSpacing),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // Bottom sheet untuk memilih dan menerapkan template
  void _showTemplateSheet(
    BuildContext context,
    StrategyBuilderViewModel viewModel,
  ) {
    locator<BottomSheetService>().showCustomSheet(
      variant: BottomSheetType.templatePicker,
      barrierDismissible: true,
      isScrollControlled: true,
      // Pass the current StrategyBuilderViewModel to the sheet via request.data
      data: viewModel,
    );
  }

  @override
  StrategyBuilderViewModel viewModelBuilder(BuildContext context) =>
      StrategyBuilderViewModel(strategyId);

  @override
  void onViewModelReady(StrategyBuilderViewModel viewModel) =>
      viewModel.initialize();
}
