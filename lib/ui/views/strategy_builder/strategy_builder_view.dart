import 'package:backtestx/models/candle.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'strategy_builder_viewmodel.dart';
import 'package:backtestx/helpers/timeframe_helper.dart' as tfHelper;
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/helpers/strategy_templates.dart';
import 'package:backtestx/ui/widgets/common/candlestick_chart/candlestick_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class StrategyBuilderView extends StackedView<StrategyBuilderViewModel> {
  final String? strategyId;

  const StrategyBuilderView({Key? key, this.strategyId}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StrategyBuilderViewModel viewModel,
    Widget? child,
  ) {
    return WillPopScope(
      onWillPop: () async {
        if (viewModel.hasAutosaveDraft) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Keluar dari Strategy Builder?'),
              content: const Text(
                'Ada draft di autosave. Yakin ingin menutup layar?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    // Buang draft lalu keluar
                    await viewModel.discardDraft();
                    Navigator.of(ctx).pop(true);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Discard & Keluar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await viewModel.resetTemplateFilters();
          }
          return confirm ?? false;
        }
        await viewModel.resetTemplateFilters();
        return true;
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title:
                Text(viewModel.isEditing ? 'Edit Strategy' : 'Create Strategy'),
            actions: [
              if (viewModel.hasAutosaveDraft)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: TextButton.icon(
                    onPressed: viewModel.restoreDraftIfAvailable,
                    icon: const Icon(Icons.restore),
                    label: const Text('Pulihkan Draft'),
                  ),
                ),
              Tooltip(
                message: 'Pilih Template',
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
                message: 'Run Preview',
                child: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed:
                      (viewModel.isRunningPreview || viewModel.hasFatalErrors)
                          ? null
                          : () {
                              if (viewModel.availableData.isEmpty) {
                                viewModel.loadAvailableData();
                              }
                              viewModel.quickPreviewBacktest();
                            },
                ),
              ),
              Tooltip(
                message: 'Builder Tips',
                child: IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: viewModel.startBuilderTour,
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
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.settings, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Autosave Settings',
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
                                  title: const Text('Enable Autosave'),
                                  subtitle: const Text(
                                    'Simpan draft otomatis saat ada perubahan',
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
                tooltip: 'Menu',
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  switch (value) {
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
                              proceed = await showDialog<bool>(
                                    context: context,
                                    builder: (c2) => AlertDialog(
                                      title: const Text('Konfirmasi Impor'),
                                      content: const Text(
                                          'Template baru akan menimpa builder saat ini. Lanjutkan?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(c2).pop(false),
                                          child: const Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(c2).pop(true),
                                          child: const Text('Timpa'),
                                        ),
                                      ],
                                    ),
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
                          title: const Text('Impor Template JSON'),
                          content: SizedBox(
                            width: 480,
                            child: TextField(
                              controller: importController,
                              minLines: 5,
                              maxLines: 12,
                              decoration: const InputDecoration(
                                hintText:
                                    'Tempel JSON template di sini lalu tekan Terapkan',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final text = importController.text.trim();
                                if (text.isNotEmpty) {
                                  var proceed = true;
                                  if (viewModel.hasUnsavedBuilder) {
                                    proceed = await showDialog<bool>(
                                          context: context,
                                          builder: (c2) => AlertDialog(
                                            title:
                                                const Text('Konfirmasi Impor'),
                                            content: const Text(
                                                'Template baru akan menimpa builder saat ini. Lanjutkan?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(c2).pop(false),
                                                child: const Text('Batal'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.of(c2).pop(true),
                                                child: const Text('Timpa'),
                                              ),
                                            ],
                                          ),
                                        ) ??
                                        false;
                                  }
                                  if (proceed) {
                                    await viewModel.importStrategyJson(text);
                                  }
                                }
                                if (Navigator.of(ctx).canPop()) {
                                  Navigator.of(ctx).pop();
                                }
                              },
                              child: const Text('Terapkan'),
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
                  if (viewModel.canSave) {
                    items.add(
                      const PopupMenuItem<String>(
                        value: 'export',
                        child: Text('Export JSON'),
                      ),
                    );
                    items.add(
                      const PopupMenuItem<String>(
                        value: 'copy',
                        child: Text('Copy JSON'),
                      ),
                    );
                    if (!kIsWeb) {
                      items.add(
                        const PopupMenuItem<String>(
                          value: 'save',
                          child: Text('Save .json'),
                        ),
                      );
                    }
                    items.add(const PopupMenuDivider());
                  }
                  if (!kIsWeb) {
                    items.add(
                      const PopupMenuItem<String>(
                        value: 'import_file',
                        child: Text('Import dari file .json'),
                      ),
                    );
                  }
                  items.add(
                    const PopupMenuItem<String>(
                      value: 'import',
                      child: Text('Import JSON...'),
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
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                                  duration: const Duration(milliseconds: 180),
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
                                      final icon = status.contains('Auto-saved')
                                          ? Icons.check_circle
                                          : status.contains('Autosave off')
                                              ? Icons.save_outlined
                                              : status.contains('failed')
                                                  ? Icons.error_outline
                                                  : Icons.info_outline;
                                      final relative = (() {
                                        final ts = viewModel.lastAutosaveAt;
                                        if (ts == null) return '';
                                        final d = DateTime.now().difference(ts);
                                        if (d.inSeconds < 60) {
                                          return '${d.inSeconds}s lalu';
                                        } else if (d.inMinutes < 60) {
                                          return '${d.inMinutes}m lalu';
                                        } else if (d.inHours < 24) {
                                          return '${d.inHours}h lalu';
                                        } else {
                                          return '${d.inDays}d lalu';
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
                                                ? 'Terakhir: $relative'
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
                                              message: 'Tersimpan pada $abs',
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
                                  label: const Text('Retry'),
                                  onPressed: viewModel.retryAutosave,
                                ),
                              // Discard (TextButton) hanya saat ada draft autosave
                              if (viewModel.hasAutosaveDraft)
                                Tooltip(
                                  message: 'Hapus draft autosave saat ini',
                                  child: TextButton(
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title:
                                                  const Text('Discard Draft?'),
                                              content: const Text(
                                                  'Draft autosave saat ini akan dihapus dan tidak bisa dikembalikan.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx)
                                                          .pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx)
                                                          .pop(true),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .error,
                                                  ),
                                                  child: const Text('Discard'),
                                                ),
                                              ],
                                            ),
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
                                    child: const Text('Discard Draft'),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Strategy Name
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Strategy Details',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: viewModel.nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Strategy Name',
                                    hintText: 'e.g. RSI Mean Reversion',
                                    prefixIcon: Icon(Icons.label),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller:
                                      viewModel.initialCapitalController,
                                  decoration: const InputDecoration(
                                    labelText: 'Initial Capital',
                                    hintText: '10000',
                                    prefixIcon: Icon(Icons.attach_money),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Risk Management
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Risk Management',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),

                                // Risk Type
                                DropdownButtonFormField<RiskType>(
                                  value: viewModel.riskType,
                                  decoration: const InputDecoration(
                                    labelText: 'Risk Type',
                                    prefixIcon: Icon(Icons.trending_up),
                                  ),
                                  items: RiskType.values.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Text(_formatRiskType(type)),
                                    );
                                  }).toList(),
                                  onChanged: viewModel.setRiskType,
                                ),

                                const SizedBox(height: 16),

                                TextField(
                                  controller: viewModel.riskValueController,
                                  decoration: InputDecoration(
                                    labelText:
                                        viewModel.riskType == RiskType.fixedLot
                                            ? 'Lot Size'
                                            : (viewModel.riskType ==
                                                    RiskType.atrBased
                                                ? 'ATR Multiple'
                                                : 'Risk Percentage'),
                                    hintText:
                                        viewModel.riskType == RiskType.fixedLot
                                            ? '0.1'
                                            : (viewModel.riskType ==
                                                    RiskType.atrBased
                                                ? '2.0'
                                                : '2.0'),
                                    prefixIcon: const Icon(Icons.percent),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),

                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            viewModel.stopLossController,
                                        decoration: InputDecoration(
                                          labelText: viewModel.riskType ==
                                                  RiskType.atrBased
                                              ? 'ATR Multiple'
                                              : 'Stop Loss (points)',
                                          hintText: viewModel.riskType ==
                                                  RiskType.atrBased
                                              ? '2.0'
                                              : '100',
                                          prefixIcon:
                                              const Icon(Icons.arrow_downward),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            viewModel.takeProfitController,
                                        decoration: const InputDecoration(
                                          labelText: 'Take Profit (points)',
                                          hintText: '200',
                                          prefixIcon: Icon(Icons.arrow_upward),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Entry Rules
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Entry Rules',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.add_circle),
                                          onPressed: viewModel.addEntryRule,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (viewModel.appliedTemplateDescription !=
                                    null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (viewModel
                                                      .appliedTemplateName !=
                                                  null)
                                                Text(
                                                  viewModel
                                                      .appliedTemplateName!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSecondaryContainer,
                                                      ),
                                                ),
                                              const SizedBox(height: 4),
                                              Text(
                                                viewModel
                                                    .appliedTemplateDescription!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSecondaryContainer
                                                          .withValues(
                                                              alpha: 0.9),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (viewModel.entryRules.isEmpty)
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
                                          const SizedBox(height: 8),
                                          Text(
                                            'No entry rules yet',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.6)),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tap + to add a rule',
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
                                  ...viewModel.entryRules
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    return _buildRuleCard(
                                      context,
                                      viewModel,
                                      entry.key,
                                      entry.value,
                                      true,
                                    );
                                  }).toList(),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Exit Rules
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Exit Rules',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle),
                                      onPressed: viewModel.addExitRule,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
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
                                          const SizedBox(height: 8),
                                          Text(
                                            'No exit rules yet',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.6)),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tap + to add a rule',
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
                                    return _buildRuleCard(
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

                        const SizedBox(height: 24),

                        // Quick Backtest Preview Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quick Backtest Preview',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),

                                // Load available data on first build
                                Builder(builder: (context) {
                                  if (viewModel.availableData.isEmpty) {
                                    viewModel.loadAvailableData();
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Data selection dropdown
                                      DropdownButtonFormField<String>(
                                        value: viewModel.availableData.any(
                                                (d) =>
                                                    d.id ==
                                                    viewModel.selectedDataId)
                                            ? viewModel.selectedDataId
                                            : null,
                                        decoration: const InputDecoration(
                                          labelText: 'Select Market Data',
                                          prefixIcon: Icon(Icons.bar_chart),
                                        ),
                                        items:
                                            viewModel.availableData.map((data) {
                                          return DropdownMenuItem(
                                            value: data.id,
                                            child: Text(
                                                '${data.symbol} ${data.timeframe} (${data.candles.length} candles)'),
                                          );
                                        }).toList(),
                                        onChanged: viewModel.setSelectedData,
                                      ),

                                      const SizedBox(height: 16),

                                      // Test button
                                      SizedBox(
                                        width: double.infinity,
                                        child: Tooltip(
                                          message: (() {
                                            if (viewModel.hasFatalErrors) {
                                              final errs =
                                                  viewModel.getAllFatalErrors();
                                              final shown =
                                                  errs.take(2).join('\n• ');
                                              return 'Perbaiki error sebelum testing:\n• ' +
                                                  shown +
                                                  (errs.length > 2
                                                      ? '...'
                                                      : '');
                                            }
                                            if (viewModel.isRunningPreview) {
                                              return 'Preview sedang berjalan';
                                            }
                                            return 'Jalankan quick test';
                                          })(),
                                          child: ElevatedButton.icon(
                                            onPressed: (viewModel
                                                        .isRunningPreview ||
                                                    viewModel.hasFatalErrors)
                                                ? null
                                                : viewModel
                                                    .quickPreviewBacktest,
                                            icon: viewModel.isRunningPreview
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : const Icon(Icons.play_arrow),
                                            label:
                                                Text(viewModel.isRunningPreview
                                                    ? 'Running...'
                                                    : (() {
                                                        final errs = viewModel
                                                            .getAllFatalErrors();
                                                        if (errs.isNotEmpty) {
                                                          return 'Perbaiki ${errs.length} error';
                                                        }
                                                        return 'Test Strategy';
                                                      })()),
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Lightweight data preview (recent candles)
                                      Builder(builder: (context) {
                                        if (viewModel.selectedDataId == null) {
                                          return const SizedBox(height: 0);
                                        }
                                        final data = viewModel.availableData
                                            .where((d) =>
                                                d.id ==
                                                viewModel.selectedDataId)
                                            .toList();
                                        if (data.isEmpty ||
                                            data.first.candles.isEmpty) {
                                          return Container(
                                            margin:
                                                const EdgeInsets.only(top: 12),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceVariant
                                                  .withValues(alpha: 0.18),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(12)),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.info_outline,
                                                    size: 18,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(
                                                            alpha: 0.8)),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Data terpilih belum memiliki candles untuk pratinjau.',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        final md = data.first;
                                        // Dynamic downsampling based on base timeframe
                                        final baseMin =
                                            tfHelper.parseTimeframeToMinutes(
                                                md.timeframe);
                                        int recentCount;
                                        if (baseMin <= 5) {
                                          recentCount = 360; // ~30 hours of M5
                                        } else if (baseMin <= 15) {
                                          recentCount = 240; // ~2.5 days of M15
                                        } else if (baseMin <= 60) {
                                          recentCount = 180; // ~1 week of H1
                                        } else {
                                          recentCount =
                                              120; // reduce for higher TFs
                                        }
                                        final recent =
                                            md.getRecentCandles(recentCount);
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Icon(Icons.timeline,
                                                    size: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(
                                                            alpha: 0.8)),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Preview Harga (${md.timeframe}) — ${md.dateRangeLabel}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 200,
                                              child: CandlestickChart(
                                                candles: recent,
                                                showVolume: false,
                                                highQuality: baseMin > 60,
                                                maxDrawCandles: 600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 12,
                                              runSpacing: 8,
                                              children: [
                                                _buildStatChip(
                                                  context,
                                                  'Candles',
                                                  '${md.candlesCount}',
                                                ),
                                                _buildStatChip(
                                                  context,
                                                  'Close (last)',
                                                  md.candles.isNotEmpty
                                                      ? md.candles.last.close
                                                          .toStringAsFixed(2)
                                                      : '-',
                                                ),
                                                _buildStatChip(
                                                  context,
                                                  'Change %',
                                                  md.totalPriceChangePercent
                                                      .toStringAsFixed(2),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }),

                                      // Preview results
                                      if (viewModel.previewResult != null) ...[
                                        const SizedBox(height: 16),
                                        const Divider(),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Preview Results',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        // Quick performance badges (Win Rate & Profit Factor)
                                        Builder(builder: (context) {
                                          final summary =
                                              viewModel.previewResult!.summary;
                                          final winRate = summary.winRate.isNaN
                                              ? 0
                                              : summary.winRate;
                                          final pf = summary.profitFactor.isNaN
                                              ? 0
                                              : summary.profitFactor;
                                          final wrColor = winRate >= 50
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .tertiary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .error;
                                          final pfColor = pf >= 1.0
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .tertiary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .error;
                                          return Wrap(
                                            spacing: 12,
                                            runSpacing: 8,
                                            children: [
                                              _buildStatChip(
                                                context,
                                                'Win Rate',
                                                '${winRate.toStringAsFixed(1)}%',
                                                color: wrColor,
                                                icon: Icons.percent,
                                              ),
                                              _buildStatChip(
                                                context,
                                                'Profit Factor',
                                                pf.toStringAsFixed(2),
                                                color: pfColor,
                                                icon: Icons.trending_up,
                                              ),
                                            ],
                                          );
                                        }),
                                        const SizedBox(height: 8),
                                        // Actions: open full results & reset preview
                                        Row(
                                          children: [
                                            TextButton.icon(
                                              onPressed:
                                                  viewModel.viewFullResults,
                                              icon:
                                                  const Icon(Icons.open_in_new),
                                              label: const Text(
                                                  'Lihat Hasil Lengkap'),
                                            ),
                                            const SizedBox(width: 12),
                                            TextButton.icon(
                                              onPressed: viewModel.resetPreview,
                                              icon: const Icon(Icons.refresh),
                                              label:
                                                  const Text('Reset Preview'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Base TF vs Rule TF badges
                                        Builder(builder: (context) {
                                          final baseData = viewModel
                                              .availableData
                                              .where((d) =>
                                                  d.id ==
                                                  viewModel.selectedDataId)
                                              .toList();
                                          final String? baseTf =
                                              baseData.isNotEmpty
                                                  ? baseData.first.timeframe
                                                  : null;

                                          final entryRuleTfs = viewModel
                                              .entryRules
                                              .asMap()
                                              .entries
                                              .where((e) =>
                                                  e.value.timeframe != null)
                                              .map((e) => (
                                                    tf: e.value.timeframe!,
                                                    warn: viewModel
                                                        .getRuleWarningsFor(
                                                            e.key, true)
                                                        .any((w) => w.contains(
                                                            'Timeframe rule lebih kecil')),
                                                  ))
                                              .toList();
                                          final exitRuleTfs = viewModel
                                              .exitRules
                                              .asMap()
                                              .entries
                                              .where((e) =>
                                                  e.value.timeframe != null)
                                              .map((e) => (
                                                    tf: e.value.timeframe!,
                                                    warn: viewModel
                                                        .getRuleWarningsFor(
                                                            e.key, false)
                                                        .any((w) => w.contains(
                                                            'Timeframe rule lebih kecil')),
                                                  ))
                                              .toList();

                                          final chips = <Widget>[];
                                          if (baseTf != null) {
                                            chips.add(_buildTfChip(context,
                                                'Base: $baseTf', false));
                                          }
                                          for (final r in entryRuleTfs) {
                                            chips.add(_buildTfChip(context,
                                                'Entry TF: ${r.tf}', r.warn));
                                          }
                                          for (final r in exitRuleTfs) {
                                            chips.add(_buildTfChip(context,
                                                'Exit TF: ${r.tf}', r.warn));
                                          }

                                          if (chips.isEmpty)
                                            return const SizedBox();
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: chips,
                                            ),
                                          );
                                        }),

                                        // Per‑timeframe counts (entry vs exit rules per TF)
                                        Builder(builder: (context) {
                                          String _resolveBaseTf() {
                                            final baseData = viewModel
                                                .availableData
                                                .where((d) =>
                                                    d.id ==
                                                    viewModel.selectedDataId)
                                                .toList();
                                            return baseData.isNotEmpty
                                                ? baseData.first.timeframe
                                                : '';
                                          }

                                          String _resolveRuleTf(
                                              String? tfRaw, String baseTf) {
                                            return (tfRaw == null ||
                                                    tfRaw.isEmpty)
                                                ? baseTf
                                                : tfRaw;
                                          }

                                          final baseTf = _resolveBaseTf();
                                          final entryTfCounts = <String, int>{};
                                          final exitTfCounts = <String, int>{};

                                          for (final r
                                              in viewModel.entryRules) {
                                            final tf = _resolveRuleTf(
                                                r.timeframe, baseTf);
                                            if (tf.isNotEmpty) {
                                              entryTfCounts[tf] =
                                                  (entryTfCounts[tf] ?? 0) + 1;
                                            }
                                          }
                                          for (final r in viewModel.exitRules) {
                                            final tf = _resolveRuleTf(
                                                r.timeframe, baseTf);
                                            if (tf.isNotEmpty) {
                                              exitTfCounts[tf] =
                                                  (exitTfCounts[tf] ?? 0) + 1;
                                            }
                                          }

                                          if (entryTfCounts.isEmpty &&
                                              exitTfCounts.isEmpty) {
                                            return const SizedBox.shrink();
                                          }

                                          Chip _tfChip(String tf, int count) {
                                            bool warn = false;
                                            if (baseTf.isNotEmpty) {
                                              final baseMin = tfHelper
                                                  .parseTimeframeToMinutes(
                                                      baseTf);
                                              final tfMin = tfHelper
                                                  .parseTimeframeToMinutes(tf);
                                              warn = tfMin < baseMin;
                                            }
                                            final bg = warn
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .errorContainer
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .secondaryContainer;
                                            final fg = warn
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onErrorContainer
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSecondaryContainer;
                                            return Chip(
                                              backgroundColor: bg,
                                              label: Text(
                                                '$tf • ${count} rule${count > 1 ? 's' : ''}',
                                                style: TextStyle(color: fg),
                                              ),
                                            );
                                          }

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 8),
                                              Text(
                                                'Per‑Timeframe Rule Counts',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                              const SizedBox(height: 6),
                                              if (entryTfCounts.isNotEmpty) ...[
                                                Text('Entry Rules',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall),
                                                const SizedBox(height: 4),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: entryTfCounts
                                                      .entries
                                                      .map((e) => _tfChip(
                                                          e.key, e.value))
                                                      .toList(),
                                                ),
                                              ],
                                              if (exitTfCounts.isNotEmpty) ...[
                                                const SizedBox(height: 8),
                                                Text('Exit Rules',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall),
                                                const SizedBox(height: 4),
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: exitTfCounts.entries
                                                      .map((e) => _tfChip(
                                                          e.key, e.value))
                                                      .toList(),
                                                ),
                                              ],
                                            ],
                                          );
                                        }),

                                        // Summary stats
                                        Row(
                                          children: [
                                            _buildStatCard(
                                              context,
                                              'Win Rate',
                                              '${viewModel.previewResult!.summary.winRate.toStringAsFixed(1)}%',
                                              viewModel.previewResult!.summary.winRate >=
                                                      50
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                            ),
                                            _buildStatCard(
                                              context,
                                              'PnL',
                                              '\$${viewModel.previewResult!.summary.totalPnl.toStringAsFixed(2)}',
                                              viewModel.previewResult!.summary
                                                          .totalPnl >=
                                                      0
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                            ),
                                            _buildStatCard(
                                              context,
                                              'Max DD',
                                              '${viewModel.previewResult!.summary.maxDrawdownPercentage.toStringAsFixed(2)}%',
                                              viewModel.previewResult!.summary
                                                          .maxDrawdownPercentage <=
                                                      20
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                            ),
                                            _buildStatCard(
                                              context,
                                              'Trades',
                                              '${viewModel.previewResult!.summary.totalTrades}',
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                            _buildStatCard(
                                              context,
                                              'PF',
                                              viewModel.previewResult!.summary
                                                  .profitFactor
                                                  .toStringAsFixed(2),
                                              viewModel.previewResult!.summary
                                                          .profitFactor >
                                                      1
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                            ),
                                          ],
                                        ),

                                        // Per‑TF signals & performance (from preview)
                                        Builder(builder: (context) {
                                          final stats =
                                              viewModel.previewTfStats;
                                          if (stats.isEmpty)
                                            return const SizedBox.shrink();

                                          Widget _statChip(
                                              String tf, Map<String, num> s) {
                                            final bg = Theme.of(context)
                                                .colorScheme
                                                .surfaceVariant;
                                            final fg = Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant;
                                            final winRate =
                                                (s['winRate'] ?? 0).toDouble();
                                            final pf = (s['profitFactor'] ?? 0)
                                                .toDouble();
                                            final ex = (s['expectancy'] ?? 0)
                                                .toDouble();
                                            return Card(
                                              color: bg,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 12),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(tf,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                                color: fg,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                    const SizedBox(height: 4),
                                                    Wrap(
                                                      spacing: 8,
                                                      runSpacing: 6,
                                                      crossAxisAlignment:
                                                          WrapCrossAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                            'Signals: ${s['signals'] ?? 0}',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall),
                                                        const SizedBox(
                                                            width: 12),
                                                        Text(
                                                            'Trades: ${s['trades'] ?? 0}',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall),
                                                        const SizedBox(
                                                            width: 12),
                                                        Text(
                                                            'Wins: ${s['wins'] ?? 0}',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall),
                                                        const SizedBox(
                                                            width: 12),
                                                        Text(
                                                            'WinRate: ${winRate.toStringAsFixed(1)}%',
                                                            style:
                                                                Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall!
                                                                    .copyWith(
                                                                      color: winRate >=
                                                                              50
                                                                          ? Theme.of(context)
                                                                              .colorScheme
                                                                              .primary
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .error,
                                                                    )),
                                                        const SizedBox(
                                                            width: 12),
                                                        Text(
                                                            'PF: ${pf.isFinite ? pf.toStringAsFixed(2) : '—'}',
                                                            style:
                                                                Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall!
                                                                    .copyWith(
                                                                      color: pf >
                                                                              1
                                                                          ? Theme.of(context)
                                                                              .colorScheme
                                                                              .primary
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .error,
                                                                    )),
                                                        const SizedBox(
                                                            width: 12),
                                                        Text(
                                                            'Expectancy: ${ex.isFinite ? ex.toStringAsFixed(2) : '—'}',
                                                            style:
                                                                Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall!
                                                                    .copyWith(
                                                                      color: ex >
                                                                              0
                                                                          ? Theme.of(context)
                                                                              .colorScheme
                                                                              .primary
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .error,
                                                                    )),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 12),
                                              Text(
                                                  'Per‑Timeframe Signals & Performance',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium),
                                              const SizedBox(height: 6),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: stats.entries
                                                    .map((e) => _statChip(
                                                        e.key, e.value))
                                                    .toList(),
                                              ),
                                            ],
                                          );
                                        }),

                                        const SizedBox(height: 16),

                                        // Save as Template (exports/copies JSON)
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed:
                                                viewModel.exportStrategyJson,
                                            icon: const Icon(Icons.save_alt),
                                            label: const Text(
                                                'Simpan sebagai Template'),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        // View full results button
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed:
                                                viewModel.viewFullResults,
                                            icon: const Icon(Icons.analytics),
                                            label:
                                                const Text('View Full Results'),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Save Button
                        Tooltip(
                          message: (() {
                            if (viewModel.hasFatalErrors) {
                              final errs = viewModel.getAllFatalErrors();
                              final shown = errs.take(2).join('\n• ');
                              return 'Perbaiki error sebelum menyimpan:\n• ' +
                                  shown +
                                  (errs.length > 2 ? '...' : '');
                            }
                            if (!viewModel.canSave) {
                              return 'Lengkapi nama, modal awal, dan entry rules';
                            }
                            if (viewModel.isBusy) {
                              return 'Sedang menyimpan...';
                            }
                            return 'Simpan strategi';
                          })(),
                          child: ElevatedButton(
                            onPressed: (viewModel.canSave &&
                                    !viewModel.isBusy &&
                                    !viewModel.hasFatalErrors)
                                ? () => viewModel.saveStrategy(context)
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: (() {
                              if (viewModel.isBusy) {
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
                                  'Perbaiki ${errs.length} error',
                                  style: const TextStyle(fontSize: 16),
                                );
                              }
                              if (!viewModel.canSave) {
                                return const Text(
                                  'Lengkapi data dulu',
                                  style: TextStyle(fontSize: 16),
                                );
                              }
                              return Text(
                                viewModel.isEditing
                                    ? 'Update Strategy'
                                    : 'Save Strategy',
                                style: const TextStyle(fontSize: 16),
                              );
                            })(),
                          ),
                        ),

                        // Error summary banner for quick fix guidance
                        const SizedBox(height: 12),
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          size: 18, color: scheme.error),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Perbaikan diperlukan sebelum simpan/preview',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(color: scheme.error),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...errs.map((e) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6.0),
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

                        const SizedBox(height: 8),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRuleCard(
    BuildContext context,
    StrategyBuilderViewModel viewModel,
    int index,
    RuleBuilder rule,
    bool isEntry,
  ) {
    final hasRuleErrors = viewModel.getRuleErrorsFor(index, isEntry).isNotEmpty;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).colorScheme.surface,
      shape: hasRuleErrors
          ? RoundedRectangleBorder(
              side: BorderSide(
                color:
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.25),
              ),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rule ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () {
                    if (isEntry) {
                      viewModel.removeEntryRule(index);
                    } else {
                      viewModel.removeExitRule(index);
                    }
                  },
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Indicator dropdown
            DropdownButtonFormField<IndicatorType>(
              value: rule.indicator,
              decoration: const InputDecoration(
                labelText: 'Indicator',
                isDense: false,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              items: IndicatorType.values.map((indicator) {
                return DropdownMenuItem(
                  value: indicator,
                  child: Text(_formatIndicator(indicator)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.updateRuleIndicator(index, value, isEntry);
                }
              },
            ),

            const SizedBox(height: 12),

            // Main indicator period (optional for types that use period)
            Builder(builder: (context) {
              final needsMainPeriod = {
                IndicatorType.rsi,
                IndicatorType.sma,
                IndicatorType.ema,
                IndicatorType.atr,
                IndicatorType.atrPct,
                IndicatorType.adx,
                IndicatorType.bollingerBands,
                IndicatorType.bollingerWidth,
                IndicatorType.vwap,
                IndicatorType.stochasticK,
                IndicatorType.stochasticD,
              }.contains(rule.indicator);
              if (!needsMainPeriod) return const SizedBox.shrink();
              return TextField(
                controller: rule.mainPeriodController,
                decoration: InputDecoration(
                  labelText: 'Main Period',
                  hintText: 'e.g. 14 or 20',
                  isDense: false,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  errorText:
                      (rule.mainPeriod != null && (rule.mainPeriod ?? 0) <= 0)
                          ? 'Harus > 0'
                          : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    viewModel.updateRuleMainPeriod(index, value, isEntry),
              );
            }),

            const SizedBox(height: 12),

            // Timeframe (optional)
            Builder(builder: (context) {
              final warnings = viewModel.getRuleWarningsFor(index, isEntry);
              final tfWarning = warnings.firstWhere(
                (w) => w.contains('Timeframe rule lebih kecil'),
                orElse: () => '',
              );
              return Tooltip(
                message: tfWarning.isNotEmpty
                    ? tfWarning
                    : 'Opsional: gunakan timeframe >= data dasar untuk menghindari resampling otomatis.',
                child: DropdownButtonFormField<String?>(
                  value: rule.timeframe,
                  decoration: const InputDecoration(
                    labelText: 'Timeframe (opsional)',
                    isDense: false,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Gunakan timeframe dasar'),
                    ),
                    ...['M1', 'M5', 'M15', 'M30', 'H1', 'H4', 'D1']
                        .map((tf) => DropdownMenuItem<String?>(
                              value: tf,
                              child: Text(tf),
                            ))
                        .toList(),
                  ],
                  onChanged: (value) {
                    viewModel.updateRuleTimeframe(index, value, isEntry);
                  },
                ),
              );
            }),

            const SizedBox(height: 12),

            // Operator dropdown (with tooltip for Rising/Falling)
            Tooltip(
              message: _operatorTooltip(rule.operator),
              child: DropdownButtonFormField<ComparisonOperator>(
                value: rule.operator,
                decoration: const InputDecoration(
                  labelText: 'Operator',
                  isDense: false,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
                items: ComparisonOperator.values.map((op) {
                  return DropdownMenuItem(
                    value: op,
                    child: Text(_formatOperator(op)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    viewModel.updateRuleOperator(index, value, isEntry);
                  }
                },
              ),
            ),

            const SizedBox(height: 12),

            // Value type toggle (hidden for Rising/Falling)
            if (rule.operator != ComparisonOperator.rising &&
                rule.operator != ComparisonOperator.falling)
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text('Number'),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text('Indicator'),
                        ),
                      ],
                      selected: {rule.isNumberValue},
                      onSelectionChanged: (Set<bool> selection) {
                        viewModel.updateRuleValueType(
                            index, selection.first, isEntry);
                      },
                    ),
                  ),
                ],
              ),
            if (rule.operator == ComparisonOperator.crossAbove ||
                rule.operator == ComparisonOperator.crossBelow) ...[
              const SizedBox(height: 6),
              Text(
                'Untuk operator cross: pilih Indicator untuk cross antar indikator, atau Number untuk ambang (mis. zero-line).',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ],

            const SizedBox(height: 12),

            // Value input (hidden for Rising/Falling)
            if (rule.operator != ComparisonOperator.rising &&
                rule.operator != ComparisonOperator.falling)
              if (rule.isNumberValue)
                TextField(
                  controller: rule.numberController,
                  decoration: InputDecoration(
                    labelText: 'Value',
                    hintText: 'e.g. 30, 70, 50',
                    isDense: false,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    errorText: rule.numberValue == null ? 'Wajib diisi' : null,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      viewModel.updateRuleNumberValue(index, value, isEntry),
                ),
            if (rule.isNumberValue &&
                rule.indicator == IndicatorType.macdHistogram) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _presetChip(context, '0', () {
                    rule.numberController.text = '0';
                    viewModel.updateRuleNumberValue(index, '0', isEntry);
                  }),
                  _presetChip(context, '0.0003', () {
                    rule.numberController.text = '0.0003';
                    viewModel.updateRuleNumberValue(index, '0.0003', isEntry);
                  }),
                  _presetChip(context, '0.0005', () {
                    rule.numberController.text = '0.0005';
                    viewModel.updateRuleNumberValue(index, '0.0005', isEntry);
                  }),
                  _presetChip(context, '0.001', () {
                    rule.numberController.text = '0.001';
                    viewModel.updateRuleNumberValue(index, '0.001', isEntry);
                  }),
                ],
              ),
              const SizedBox(height: 8),
            ],
            // Preset thresholds for ATR% convenience
            if (rule.isNumberValue &&
                rule.indicator == IndicatorType.atrPct) ...[
              const SizedBox(height: 8),
              // Dynamic ATR% presets based on selected data + timeframe
              Builder(builder: (context) {
                final period = rule.mainPeriod ?? 14;
                final tf = rule.timeframe;
                if (viewModel.selectedDataId == null) {
                  return const SizedBox();
                }
                return FutureBuilder<List<double>>(
                  future: viewModel.getAtrPctPercentiles(period, tf),
                  builder: (context, snap) {
                    final vals = snap.data ?? const [];
                    if (vals.isEmpty) return const SizedBox();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dynamic ATR% Presets',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _presetChip(
                                context, '${vals[0].toStringAsFixed(1)}% (P25)',
                                () {
                              final v = vals[0].toStringAsFixed(1);
                              rule.numberController.text = v;
                              viewModel.updateRuleNumberValue(
                                  index, v, isEntry);
                            }),
                            _presetChip(
                                context, '${vals[1].toStringAsFixed(1)}% (P50)',
                                () {
                              final v = vals[1].toStringAsFixed(1);
                              rule.numberController.text = v;
                              viewModel.updateRuleNumberValue(
                                  index, v, isEntry);
                            }),
                            _presetChip(
                                context, '${vals[2].toStringAsFixed(1)}% (P75)',
                                () {
                              final v = vals[2].toStringAsFixed(1);
                              rule.numberController.text = v;
                              viewModel.updateRuleNumberValue(
                                  index, v, isEntry);
                            }),
                            _presetChip(
                                context, '${vals[3].toStringAsFixed(1)}% (P90)',
                                () {
                              final v = vals[3].toStringAsFixed(1);
                              rule.numberController.text = v;
                              viewModel.updateRuleNumberValue(
                                  index, v, isEntry);
                            }),
                          ],
                        ),
                      ],
                    );
                  },
                );
              }),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _presetChip(context, '1.0%', () {
                    rule.numberController.text = '1.0';
                    viewModel.updateRuleNumberValue(index, '1.0', isEntry);
                  }),
                  _presetChip(context, '1.5%', () {
                    rule.numberController.text = '1.5';
                    viewModel.updateRuleNumberValue(index, '1.5', isEntry);
                  }),
                  _presetChip(context, '2.0%', () {
                    rule.numberController.text = '2.0';
                    viewModel.updateRuleNumberValue(index, '2.0', isEntry);
                  }),
                  _presetChip(context, '3.0%', () {
                    rule.numberController.text = '3.0';
                    viewModel.updateRuleNumberValue(index, '3.0', isEntry);
                  }),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (rule.operator != ComparisonOperator.rising &&
                rule.operator != ComparisonOperator.falling &&
                !rule.isNumberValue) ...[
              // const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<IndicatorType>(
                      value: rule.compareIndicator,
                      decoration: InputDecoration(
                        labelText: 'Compare With',
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        errorText: rule.compareIndicator == null
                            ? 'Wajib pilih'
                            : null,
                      ),
                      items: IndicatorType.values.map((indicator) {
                        return DropdownMenuItem(
                          value: indicator,
                          child: Text(_formatIndicator(indicator)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.updateRuleCompareIndicator(
                              index, value, isEntry);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: rule.periodController,
                      decoration: InputDecoration(
                        labelText: 'Period',
                        hintText: '14',
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        errorText: (rule.compareIndicator != null &&
                                (rule.period == null ||
                                    (rule.period ?? 0) <= 0))
                            ? 'Harus > 0'
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          viewModel.updateRulePeriod(index, value, isEntry),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (rule.compareIndicator == IndicatorType.anchoredVwap) ...[
                DropdownButtonFormField<AnchorMode?>(
                  value: rule.anchorMode,
                  decoration: const InputDecoration(
                    labelText: 'Anchor Mode',
                    isDense: false,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AnchorMode.startOfBacktest,
                      child: Text('Start of Backtest'),
                    ),
                    DropdownMenuItem(
                      value: AnchorMode.byDate,
                      child: Text('Anchor by Date'),
                    ),
                  ],
                  onChanged: (mode) {
                    viewModel.updateRuleAnchorMode(index, mode, isEntry);
                  },
                ),
                const SizedBox(height: 12),
                if (rule.anchorMode == AnchorMode.byDate)
                  TextField(
                    controller: rule.anchorDateController,
                    decoration: InputDecoration(
                      labelText: 'Anchor Date (ISO)',
                      hintText: 'YYYY-MM-DD or ISO',
                      isDense: false,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      errorText: rule.anchorDateController.text.isNotEmpty &&
                              DateTime.tryParse(
                                      rule.anchorDateController.text.trim()) ==
                                  null
                          ? 'Format tanggal tidak valid'
                          : null,
                    ),
                    keyboardType: TextInputType.datetime,
                    onChanged: (value) =>
                        viewModel.updateRuleAnchorDate(index, value, isEntry),
                  ),
              ],
            ],
            // Preset thresholds for ADX convenience
            if (rule.isNumberValue && rule.indicator == IndicatorType.adx) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _presetChip(context, '20', () {
                    rule.numberController.text = '20';
                    viewModel.updateRuleNumberValue(index, '20', isEntry);
                  }),
                  _presetChip(context, '25', () {
                    rule.numberController.text = '25';
                    viewModel.updateRuleNumberValue(index, '25', isEntry);
                  }),
                  _presetChip(context, '30', () {
                    rule.numberController.text = '30';
                    viewModel.updateRuleNumberValue(index, '30', isEntry);
                  }),
                  _presetChip(context, '40', () {
                    rule.numberController.text = '40';
                    viewModel.updateRuleNumberValue(index, '40', isEntry);
                  }),
                ],
              ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 12),
            // Logical operator (for chaining rules)
            if (isEntry && index < viewModel.entryRules.length - 1 ||
                !isEntry && index < viewModel.exitRules.length - 1) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<LogicalOperator?>(
                value: rule.logicalOperator,
                decoration: const InputDecoration(
                  labelText: 'Then (Logic)',
                  isDense: false,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  ...LogicalOperator.values.map((op) {
                    return DropdownMenuItem(
                      value: op,
                      child: Text(op.name.toUpperCase()),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  viewModel.updateRuleLogicalOperator(index, value, isEntry);
                },
              ),
            ],

            // Validation messages
            Builder(builder: (context) {
              final warnings = viewModel.getRuleWarningsFor(index, isEntry);
              final errors = viewModel.getRuleErrorsFor(index, isEntry);
              if (warnings.isEmpty && errors.isEmpty) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (warnings.isNotEmpty) ...[
                      Text(
                        'Peringatan:',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.tertiary),
                      ),
                      const SizedBox(height: 6),
                      ...warnings.map((w) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  size: 16,
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  w,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                    if (errors.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Error:',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.error),
                      ),
                      const SizedBox(height: 6),
                      ...errors.map((e) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.error),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ]
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatRiskType(RiskType type) {
    switch (type) {
      case RiskType.fixedLot:
        return 'Fixed Lot Size';
      case RiskType.percentageRisk:
        return 'Percentage Risk';
      case RiskType.atrBased:
        return 'ATR-Based Sizing';
    }
  }

  String _formatIndicator(IndicatorType indicator) {
    final map = {
      IndicatorType.close: 'Close',
      IndicatorType.open: 'Open',
      IndicatorType.high: 'High',
      IndicatorType.low: 'Low',
      IndicatorType.rsi: 'RSI',
      IndicatorType.sma: 'SMA',
      IndicatorType.ema: 'EMA',
      IndicatorType.macd: 'MACD',
      IndicatorType.macdSignal: 'MACD Signal',
      IndicatorType.macdHistogram: 'MACD Histogram',
      IndicatorType.atr: 'ATR',
      IndicatorType.atrPct: 'ATR%',
      IndicatorType.adx: 'ADX',
      IndicatorType.bollingerBands: 'Bollinger Bands',
      IndicatorType.bollingerWidth: 'Bollinger Width',
      IndicatorType.vwap: 'VWAP',
      IndicatorType.anchoredVwap: 'Anchored VWAP',
      IndicatorType.stochasticK: 'Stochastic %K',
      IndicatorType.stochasticD: 'Stochastic %D',
    };
    return map[indicator] ?? indicator.name;
  }

  String _formatOperator(ComparisonOperator op) {
    final map = {
      ComparisonOperator.greaterThan: 'Greater Than (>)',
      ComparisonOperator.lessThan: 'Less Than (<)',
      ComparisonOperator.greaterThanOrEqual: 'Greater or Equal (>=)',
      ComparisonOperator.lessThanOrEqual: 'Less or Equal (<=)',
      ComparisonOperator.equals: 'Equals (=)',
      ComparisonOperator.crossAbove: 'Cross Above',
      ComparisonOperator.crossBelow: 'Cross Below',
      ComparisonOperator.rising: 'Rising',
      ComparisonOperator.falling: 'Falling',
    };
    return map[op] ?? op.name;
  }

  String _operatorTooltip(ComparisonOperator op) {
    switch (op) {
      case ComparisonOperator.rising:
        return 'Rising: nilai indikator sekarang > nilai sebelumnya. Tidak butuh nilai pembanding.';
      case ComparisonOperator.falling:
        return 'Falling: nilai indikator sekarang < nilai sebelumnya. Tidak butuh nilai pembanding.';
      case ComparisonOperator.crossAbove:
        return 'Cross Above: indikator menembus ke atas pembanding (indikator/ambang).';
      case ComparisonOperator.crossBelow:
        return 'Cross Below: indikator menembus ke bawah pembanding (indikator/ambang).';
      default:
        return 'Operator perbandingan standar terhadap angka atau indikator.';
    }
  }

  // Helper: preset chip for quick threshold selection
  Widget _presetChip(BuildContext context, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      ),
      backgroundColor: theme.colorScheme.surfaceVariant,
      shape: StadiumBorder(
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.5),
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
    );
  }

  // Bottom sheet untuk memilih dan menerapkan template
  void _showTemplateSheet(
    BuildContext context,
    StrategyBuilderViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final entries = StrategyTemplates.all.entries.toList();
        var query = viewModel.selectedTemplateQuery;
        var selectedCats = viewModel.selectedTemplateCategories.toSet();
        var searchController = TextEditingController(text: query);
        return StatefulBuilder(
          builder: (ctx, setState) {
            // Stabilize sheet height to avoid jumpy resize during search
            final sheetHeight = MediaQuery.of(ctx).size.height * 0.85;
            final filtered = query.isEmpty
                ? entries
                : entries.where((e) {
                    final name = e.value.name.toLowerCase();
                    final desc = e.value.description.toLowerCase();
                    final q = query.toLowerCase();
                    return name.contains(q) || desc.contains(q);
                  }).toList();
            return SafeArea(
              bottom: false,
              child: SizedBox(
                height: sheetHeight,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome),
                          const SizedBox(width: 8),
                          Text(
                            'Pilih Template Strategi',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Text(
                            '${entries.length} tersedia',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: 'Tutup',
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Top MVP quick picks telah dipindahkan ke AppBar.
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Cari template...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: query.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() => query = '');
                                    searchController.clear();
                                    viewModel.setTemplateSearchQuery('');
                                  },
                                ),
                        ),
                        onChanged: (val) {
                          setState(() => query = val);
                          viewModel.setTemplateSearchQuery(val);
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Builder(builder: (_) {
                          // Kategorikan berdasarkan nama template
                          String categorize(StrategyTemplate t) {
                            final n = t.name.toLowerCase();
                            if (n.contains('breakout')) return 'Breakout';
                            if (n.contains('mean reversion'))
                              return 'Mean Reversion';
                            if (n.contains('trend')) return 'Trend';
                            if (n.contains('momentum')) return 'Momentum';
                            return 'Other';
                          }

                          // Helper: highlight occurrences of query in text
                          TextSpan _highlightSpan(
                            String text,
                            String query,
                            TextStyle? normal,
                            TextStyle? highlight,
                          ) {
                            if (query.isEmpty) {
                              return TextSpan(text: text, style: normal);
                            }
                            final lower = text.toLowerCase();
                            final q = query.toLowerCase();
                            int start = 0;
                            final spans = <TextSpan>[];
                            while (true) {
                              final idx = lower.indexOf(q, start);
                              if (idx < 0) {
                                spans.add(TextSpan(
                                    text: text.substring(start),
                                    style: normal));
                                break;
                              }
                              if (idx > start) {
                                spans.add(TextSpan(
                                    text: text.substring(start, idx),
                                    style: normal));
                              }
                              spans.add(TextSpan(
                                  text: text.substring(idx, idx + q.length),
                                  style: highlight));
                              start = idx + q.length;
                            }
                            return TextSpan(children: spans);
                          }

                          final Map<String,
                                  List<MapEntry<String, StrategyTemplate>>>
                              groups = {};
                          for (final e in filtered) {
                            final cat = categorize(e.value);
                            groups.putIfAbsent(cat, () => []).add(e);
                          }
                          final order = [
                            'Breakout',
                            'Trend',
                            // Mean Reversion dan Momentum ditampilkan setelah kategori prioritas
                            'Mean Reversion',
                            'Momentum',
                            'Other'
                          ].where((c) => groups.containsKey(c)).toList();
                          // Filter chips per kategori (dengan badge jumlah)
                          final chips = <Widget>[
                            Tooltip(
                              message: 'Tampilkan semua kategori',
                              child: ChoiceChip(
                                avatar: selectedCats.isEmpty
                                    ? const Icon(Icons.check, size: 16)
                                    : null,
                                label: Text(
                                  'All',
                                  style: TextStyle(
                                    color: selectedCats.isEmpty
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onSecondaryContainer
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                ),
                                selected: selectedCats.isEmpty,
                                selectedColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceVariant,
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: (selectedCats.isEmpty
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                            : Theme.of(context)
                                                .colorScheme
                                                .outline)
                                        .withOpacity(
                                            selectedCats.isEmpty ? 0.7 : 0.5),
                                    width: selectedCats.isEmpty ? 1.2 : 1.0,
                                  ),
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                onSelected: (_) {
                                  setState(() => selectedCats.clear());
                                  viewModel.setSelectedTemplateCategories(
                                      selectedCats.toList());
                                },
                              ),
                            ),
                            ...order.map((cat) => Tooltip(
                                  message: 'Filter: ' + cat,
                                  child: ChoiceChip(
                                    avatar: selectedCats.contains(cat)
                                        ? const Icon(Icons.check, size: 16)
                                        : null,
                                    label: Text(
                                      '$cat (${groups[cat]!.length})',
                                      style: TextStyle(
                                        color: selectedCats.contains(cat)
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onSecondaryContainer
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                      ),
                                    ),
                                    selected: selectedCats.contains(cat),
                                    selectedColor: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                    shape: StadiumBorder(
                                      side: BorderSide(
                                        color: (selectedCats.contains(cat)
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .outline)
                                            .withOpacity(
                                                selectedCats.contains(cat)
                                                    ? 0.7
                                                    : 0.5),
                                        width: selectedCats.contains(cat)
                                            ? 1.2
                                            : 1.0,
                                      ),
                                    ),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    onSelected: (sel) {
                                      setState(() {
                                        if (sel) {
                                          selectedCats.add(cat);
                                        } else {
                                          selectedCats.remove(cat);
                                        }
                                      });
                                      viewModel.setSelectedTemplateCategories(
                                          selectedCats.toList());
                                    },
                                  ),
                                )),
                          ];

                          final widgets = <Widget>[];
                          // Recently Applied section
                          final recentKeys = viewModel.recentTemplateKeys;
                          final recentEntries = recentKeys
                              .map((k) => StrategyTemplates.all[k] != null
                                  ? MapEntry(k, StrategyTemplates.all[k]!)
                                  : null)
                              .whereType<MapEntry<String, StrategyTemplate>>()
                              .toList();
                          if (recentEntries.isNotEmpty) {
                            widgets.add(Row(
                              children: [
                                Text(
                                  'Recently Applied',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    viewModel.clearRecentTemplates();
                                    setState(() {});
                                  },
                                  child: const Text('Clear'),
                                ),
                              ],
                            ));
                            widgets.addAll(recentEntries.expand((e) {
                              final tpl = e.value;
                              return [
                                ListTile(
                                  leading: const Icon(Icons.history),
                                  title: RichText(
                                    text: _highlightSpan(
                                      tpl.name,
                                      query,
                                      Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                      Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                    ),
                                  ),
                                  subtitle: RichText(
                                    text: _highlightSpan(
                                      tpl.description,
                                      query,
                                      Theme.of(context).textTheme.bodySmall,
                                      Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                    ),
                                  ),
                                  trailing: TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      viewModel.applyTemplate(e.key);
                                    },
                                    child: const Text('Terapkan'),
                                  ),
                                  onTap: () {
                                    Navigator.of(ctx).pop();
                                    viewModel.applyTemplate(e.key);
                                  },
                                ),
                                const Divider(height: 1),
                              ];
                            }));
                            widgets.add(const SizedBox(height: 8));
                          }
                          for (final cat in order) {
                            if (selectedCats.isNotEmpty &&
                                !selectedCats.contains(cat)) {
                              continue;
                            }
                            widgets.add(Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                '$cat (${groups[cat]!.length})',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ));
                            widgets.addAll(groups[cat]!.expand((e) {
                              final tpl = e.value;
                              return [
                                ListTile(
                                  title: RichText(
                                    text: _highlightSpan(
                                      tpl.name,
                                      query,
                                      Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                      Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                    ),
                                  ),
                                  subtitle: RichText(
                                    text: _highlightSpan(
                                      tpl.description,
                                      query,
                                      Theme.of(context).textTheme.bodySmall,
                                      Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                    ),
                                  ),
                                  trailing: TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      viewModel.applyTemplate(e.key);
                                    },
                                    child: const Text('Terapkan'),
                                  ),
                                  onTap: () {
                                    Navigator.of(ctx).pop();
                                    viewModel.applyTemplate(e.key);
                                  },
                                ),
                                const Divider(height: 1),
                              ];
                            }));
                          }
                          // Hitung jumlah item yang terlihat sesuai filter
                          final int visibleCount = selectedCats.isEmpty
                              ? filtered.length
                              : order
                                  .where((c) => selectedCats.contains(c))
                                  .map((c) => groups[c]!.length)
                                  .fold(0, (a, b) => a + b);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (query.isNotEmpty ||
                                      selectedCats.isNotEmpty)
                                    Tooltip(
                                      message: 'Bersihkan filter',
                                      child: ActionChip(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .errorContainer,
                                        avatar: Icon(
                                          Icons.filter_alt_off,
                                          size: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onErrorContainer,
                                        ),
                                        label: Text(
                                          'Reset Filter',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onErrorContainer,
                                          ),
                                        ),
                                        shape: StadiumBorder(
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                        elevation: 1,
                                        pressElevation: 3,
                                        shadowColor: Theme.of(context)
                                            .colorScheme
                                            .error
                                            .withOpacity(0.25),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () {
                                          setState(() {
                                            selectedCats.clear();
                                            query = '';
                                          });
                                          searchController.clear();
                                          viewModel
                                              .setSelectedTemplateCategories(
                                                  []);
                                          viewModel.setTemplateSearchQuery('');
                                        },
                                      ),
                                    ),
                                  ...chips,
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$visibleCount hasil',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: (() {
                                  if (filtered.isEmpty || widgets.isEmpty) {
                                    return Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.info_outline,
                                              size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Tidak ada template yang cocok dengan kata kunci.',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return ListView(
                                    children: widgets,
                                  );
                                })(),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to build stat cards for preview results
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: valueColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: compact stat chip used in Quick Preview card
  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value, {
    Color? color,
    IconData? icon,
  }) {
    final bg = (color ?? Theme.of(context).colorScheme.secondary)
        .withValues(alpha: 0.10);
    final textColor = color ?? Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: textColor.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 14, color: textColor.withValues(alpha: 0.9)),
          if (icon != null) const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  // Helper: timeframe chip used in preview badges
  Widget _buildTfChip(BuildContext context, String label, bool isWarn) {
    final bg = isWarn
        ? Theme.of(context).colorScheme.error.withValues(alpha: 0.12)
        : Theme.of(context)
            .colorScheme
            .secondaryContainer
            .withValues(alpha: 0.18);
    final border = isWarn
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.outline;
    final textColor = isWarn
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isWarn ? Icons.warning_amber : Icons.schedule,
              size: 14, color: textColor.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  @override
  StrategyBuilderViewModel viewModelBuilder(BuildContext context) =>
      StrategyBuilderViewModel(strategyId);

  @override
  void onViewModelReady(StrategyBuilderViewModel viewModel) =>
      viewModel.initialize();
}
