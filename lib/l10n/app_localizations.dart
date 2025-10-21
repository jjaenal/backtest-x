import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocDelegate();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const supportedLocales = [
    Locale('en'),
    Locale('id'),
  ];

  // Simple in-memory maps; in production use gen_l10n
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Backtest‑X',
      'tagline': 'Analyze • Backtest • Optimize',
      'data_upload_title': 'Upload Market Data',
      'coach_timeframe_header': 'Coach Marks — Timeframe Impact',
      'coach_timeframe_body':
          'Timeframe affects indicators (EMA/RSI/VWAP, etc). 1H vs 4H can produce different signals. Use a consistent timeframe.',
      'coach_timeframe_learn': 'Learn timeframe',
      'upload_no_file_selected': 'No file selected',
      'upload_csv_format_hint':
          'CSV format: Date, Open, High, Low, Close, Volume',
      'upload_select_csv_file': 'Select CSV File',
      'upload_action_process': 'Upload & Process',
      'validation_passed': 'Validation Passed',
      'validation_failed': 'Validation Failed',
      'validation_total_candles': 'Total Candles: {count}',
      'validation_errors_label': 'Errors:',
      'recent_uploads': 'Recent Uploads',
      'candles_count_label': '{count} candles',
      'no_market_data_info':
          'No market data yet. You can activate sample data to try the app.',
      'activate_sample_data_label': 'Activate Sample Data ({sample})',
      'empty_no_uploads': 'No uploads yet',
      'empty_upload_message':
          'Select a CSV file and fill symbol to upload market data.',
      'empty_upload_primary_label': 'Select CSV File',
      'input_symbol_label': 'Symbol',
      'input_symbol_hint': 'e.g. EURUSD, BTCUSDT',
      'input_timeframe_label': 'Timeframe',
      // Pattern Scanner View
      'pattern_scanner_title': 'Pattern Scanner',
      'ps_select_market_data': 'Select Market Data',
      'ps_no_market_data':
          'No market data available. Please upload data first.',
      'ps_select_market_hint': 'Select market data...',
      'ps_filters_header': 'Filters:',
      'ps_filter_bullish': 'Bullish',
      'ps_filter_bearish': 'Bearish',
      'ps_filter_indecision': 'Indecision',
      'ps_empty_select_market': 'Select market data to scan',
      'ps_empty_select_hint': 'Choose a market data from dropdown above',
      'ps_no_patterns_found': 'No patterns found',
      'ps_try_adjust_filters': 'Try adjusting your filters',
      'ps_candle_time': 'Time',
      'ps_candle_open': 'Open',
      'ps_candle_close': 'Close',
      'ps_candle_high': 'High',
      'ps_candle_low': 'Low',
      'ps_candle_body': 'Body',
      'ps_signal_bullish': 'Bullish',
      'ps_signal_bearish': 'Bearish',
      'ps_signal_indecision': 'Indecision',
      'ps_strength_weak': 'Weak',
      'ps_strength_medium': 'Medium',
      'ps_strength_strong': 'Strong',
      'ps_patterns_guide_title': 'Candlestick Patterns Guide',
      'ps_pattern_spinning_top': 'Spinning Top',
      'ps_pattern_strong_bullish_cont': 'Strong Bullish Continuation',
      'ps_pattern_strong_bearish_cont': 'Strong Bearish Continuation',
      'ps_desc_strong_cont':
          'Little to no wicks. Strong momentum in one direction. Indicates continuation of current trend.',
      // Market Analysis View
      'market_analysis_title': 'Market Analysis',
      'ma_refresh_tooltip': 'Refresh',
      'ma_chart_settings_tooltip': 'Chart Settings',
      'ma_select_market_label': 'Select Market',
      'ma_no_market_data': 'No market data available',
      'ma_select_market_hint': 'Select market...',
      'ma_empty_select_market': 'Select market to analyze',
      'ma_price_statistics': 'Price Statistics',
      'ma_trend_analysis': 'Trend Analysis',
      'ma_volatility': 'Volatility',
      'ma_volume': 'Volume',
      'ma_data_quality': 'Data Quality',
      'ma_overview_current_label': 'Current',
      'ma_overview_change_label': 'Change',
      'ma_trend_strength_label': 'Strength',
      'ma_trend_uptrend': 'Uptrend',
      'ma_trend_downtrend': 'Downtrend',
      'ma_trend_sideways': 'Sideways',
      'ma_strength_unknown': 'Unknown',
      'ma_volatility_high': 'High',
      'ma_volatility_medium': 'Medium',
      'ma_volatility_low': 'Low',
      'ma_volatility_unknown': 'Unknown',
      'ma_price_highest': 'Highest',
      'ma_price_lowest': 'Lowest',
      'ma_price_average': 'Average',
      'ma_price_range': 'Range',
      'ma_volatility_level_label': 'Level',
      'ma_volatility_atr_label': 'ATR',
      'ma_volume_total': 'Total Volume',
      'ma_volume_average': 'Average Volume',
      'ma_quality_valid_data': 'Valid Data',
      'ma_quality_complete_no_gaps': 'Complete (No Gaps)',
      'ma_quality_candles': 'Candles',
      'ps_desc_spinning_top':
          'Small body with long wicks on both sides. Indicates uncertainty and potential reversal.',
      'startup_init_services': 'Initialize services',
      'startup_load_cache': 'Load cache',
      'startup_prepare_ui': 'Prepare UI',
      // Signup View
      'signup_title': 'Sign Up',
      'signup_confirm_password_label': 'Confirm Password',
      // Login View
      'login_title': 'Sign In',
      'login_post_redirect_banner':
          'After login, you will be redirected to the requested page.',
      'login_email_label': 'Email',
      'login_password_label': 'Password',
      'login_forgot_password': 'Forgot Password?',
      'login_sign_in_email': 'Sign In with Email',
      'login_sign_up_email': 'Sign Up with Email',
      'login_continue_google': 'Continue with Google',
      'login_continue_github': 'Continue with GitHub',
      'login_continue_apple': 'Continue with Apple',
      // Home user menu
      'home_user_menu_tooltip': 'Account',
      'home_user_unknown': 'Unknown',
      'home_user_sign_out': 'Sign Out',
      'home_user_sign_in': 'Sign In',
      'home_user_sign_up': 'Sign Up',
      'home_user_change_password': 'Change Password',
      // User View - Account deletion
      'user_delete_account': 'Delete Account',
      'user_delete_account_title': 'Delete Account',
      'user_delete_account_desc':
          'Direct account deletion is not available in this app. You can clear local data and sign out.',
      'user_delete_not_supported':
          'Direct account deletion is not available in this client.',
      'user_clear_local_data': 'Clear Local Data',
      'user_clear_all_data_success': 'Local data cleared.',
      'user_clear_all_data_error': 'Failed to clear local data.',
      'user_clear_all_confirm_title': 'Confirm Clear Local Data',
      'user_clear_all_confirm_desc':
          'This will delete strategies, results, market data, and drafts stored on this device. Continue?',
      'user_clear_all_confirm_button': 'Clear',
      // Email Verification
      'user_email_verification': 'Email Verification',
      'user_email_status_verified': 'Verified',
      'user_email_status_unverified': 'Not Verified',
      'user_email_resend': 'Resend Verification Email',
      'user_email_resend_success': 'Verification email sent.',
      'user_email_resend_error': 'Failed to send verification email.',
      'home_change_password_success': 'Password updated successfully.',
      'change_password_title': 'Set New Password',
      'change_password_description':
          'Enter a new password and confirm to update your account.',
      'change_password_new_label': 'New Password',
      'change_password_confirm_label': 'Confirm New Password',
      'change_password_save_button': 'Save Password',
      'change_password_saving': 'Saving...',
      'error_password_min': 'Password must be at least 6 characters.',
      'error_password_confirm_mismatch':
          'Password confirmation does not match.',
      'password_strength_weak': 'Weak',
      'password_strength_medium': 'Medium',
      'password_strength_strong': 'Strong',
      // Common errors
      'error_invalid_email': 'Invalid email format.',
      'error_password_min_signup':
          'Password must be at least 6 characters for signup.',
      'error_auth_invalid_credentials': 'Incorrect email or password.',
      'error_auth_email_registered': 'Email is already registered.',
      'error_auth_email_not_confirmed': 'Email not verified. Check your inbox.',
      'error_auth_generic': 'Authentication error. Please try again.',
      'error_generic': 'Something went wrong. Please try again.',
      'home_title': 'Backtest‑X',
      'home_tooltip_onboarding': 'Onboarding',
      'home_tooltip_options': 'Options',
      'home_help_options': 'Help',
      'home_action_upload_title': 'Upload Data',
      'home_action_upload_subtitle': 'Import historical market data',
      'home_action_scanner_title': 'Pattern Scanner',
      'home_action_scanner_subtitle': 'Detect candlestick patterns',
      'home_action_strategy_title': 'Create Strategy',
      'home_action_strategy_subtitle': 'Build your trading strategy',
      'home_action_analysis_title': 'Market Analysis',
      'home_action_analysis_subtitle': 'Analyze market data',
      'home_action_workspace_title': 'Workspace',
      'home_action_workspace_subtitle': 'Manage strategies',
      'home_recent_strategies': 'Recent Strategies',
      'home_cache_warming': 'Cache: warming up',
      'home_cache_ready': 'Cache: ready',
      'home_cache_empty': 'Cache: empty',
      'home_option_pause_bg': 'Pause Background Loading',
      'home_option_enable_bg': 'Enable Background Loading',
      'home_option_load_cache': 'Load Cache Now',
      'home_cache_info_title': 'Cache Info',
      'language_menu_system': 'Use System Language',
      'language_menu_english': 'English',
      'language_menu_indonesian': 'Indonesian',
      'theme_menu_system': 'Use System Theme',
      "theme_menu_light": "Light",
      "theme_menu_dark": "Dark",
      'startup_steps_done': 'All steps completed. Preparing app…',
      'home_loading_cache': 'Loading cache…',
      'home_running_backtest': 'Running backtest...',
      'stats_strategies': 'Strategies',
      'stats_data_sets': 'Data Sets',
      'stats_tests_run': 'Tests Run',
      'last_result_header': 'Last Result',
      'edit_label': 'Edit',
      'created_label': 'Created: {date}',
      'env_prod': 'Prod',
      'env_dev': 'Dev',
      'getting_started_title': 'Getting Started',
      'empty_both':
          'No data and strategies yet. Upload data and create your first strategy.',
      'empty_no_data': 'No market data yet. Upload CSV to start backtesting.',
      'empty_no_strategy':
          'No strategies yet. Create your first strategy to get started.',
      'metrics_trades': 'Trades',
      'metrics_win_rate': 'Win Rate',
      'metrics_pnl': 'PnL',
      'metrics_profit_factor': 'Profit Factor',
      'metrics_max_drawdown': 'Max Drawdown',
      'view_details': 'View Details',
      'more_label': 'More',
      'delete_label': 'Delete',
      'load_more': 'Load more',
      "clear_label": "Clear",
      "error_retry": "Try Again",
      "error_dismiss": "Dismiss",
      "dialog_got_it": "Got it",

      'workspace_tests': 'Tests',
      'workspace_avg_pnl': 'Avg P&L',
      'workspace_win_rate': 'Win Rate',
      'workspace_pnl': 'P&L',
      'workspace_pf': 'PF',
      'workspace_no_results': 'No backtest results yet',
      'workspace_search_hint': 'Search strategies...',
      'workspace_search_no_results_tip': 'Try a different search term',
      'workspace_quick_test_button': 'Quick Test',
      'workspace_quick_test_result_title': 'Quick Test Result',
      'workspace_export_filtered_results_csv': 'Export filtered results (CSV)',
      'workspace_filter_profit_only': 'Profit Only',
      'workspace_filter_pf_positive': 'PF > 1',
      'workspace_filter_win_rate_50': 'Win Rate > 50%',
      'copy_strategy_link': 'Copy Strategy Link',
      'copy_result_link': 'Copy Result Link',
      'common_expand': 'Expand',
      'common_collapse': 'Collapse',
      'common_all_symbols': 'All Symbols',
      'workspace_compare_exit_tooltip': 'Exit Compare',
      'workspace_compare_enter_tooltip': 'Compare Results',
      'workspace_empty_no_strategies': 'No strategies yet',
      'workspace_empty_no_strategies_found': 'No strategies found',
      'workspace_empty_create_first_message':
          'Create your first trading strategy',
      'workspace_run_batch': 'Run Batch',
      'duplicate_label': 'Duplicate',
      'workspace_compare_count_label': 'Compare ({count})',
      'workspace_compare_banner_text': 'Select 2-4 results to compare',
      'workspace_compare_banner_selected_suffix': '({selected}/4 selected)',
      "workspace_backtest_results_count": "Backtest Results ({shown}/{total})",

      'filter_start_date': 'Start Date',
      'filter_end_date': 'End Date',
      'filter_start_label': 'Start:',
      'filter_end_label': 'End:',

      'copy_trades_csv': 'Copy Trades CSV',
      'copy_summary': 'Copy Summary',
      'export_csv': 'Export CSV',
      'export_tsv': 'Export TSV',
      'export_all_trades_csv': 'Export All Trades CSV',
      'export_tf_stats_csv': 'Export TF Stats CSV',
      'export_results_csv': 'Export Results CSV',
      // Comparison View
      'compare_view_title': 'Compare Results',
      'compare_export_csv_tooltip': 'Export Comparison CSV',
      'compare_copy_summary_tooltip': 'Copy Comparison Summary',
      'compare_menu_export': 'Export Comparison',
      'comparison_csv_exported': 'Comparison CSV exported',
      'comparison_csv_export_failed': 'Export comparison CSV failed',
      'best_performers_header': 'Best Performers',
      'best_highest_pnl': 'Highest P&L',
      'best_win_rate': 'Best Win Rate',
      'best_profit_factor': 'Best Profit Factor',
      'best_lowest_drawdown': 'Lowest Drawdown',
      'compare_detailed_metrics': 'Detailed Metrics',
      'compare_metric_column': 'Metric',
      'compare_total_pnl': 'Total P&L',
      'compare_return_percent': 'Return %',
      'compare_win_rate': 'Win Rate',
      'compare_total_trades': 'Total Trades',
      'compare_profit_factor': 'Profit Factor',
      'compare_max_drawdown': 'Max Drawdown',
      'compare_sharpe_ratio': 'Sharpe Ratio',
      'compare_avg_win': 'Avg Win',
      'compare_avg_loss': 'Avg Loss',
      'compare_largest_win': 'Largest Win',
      'compare_largest_loss': 'Largest Loss',
      'compare_expectancy': 'Expectancy',
      'per_tf_stats_header': 'Per-Timeframe Stats',
      'chart_metric_label': 'Chart Metric:',
      'sort_tf_label': 'Sort: TF',
      'sort_value_up_label': 'Sort: Value ↑',
      'sort_value_down_label': 'Sort: Value ↓',
      'agg_avg_label': 'Agg: Avg',
      'agg_max_label': 'Agg: Max',
      'menu_export_chart_csv': 'Export Chart CSV',
      'timeframe_label': 'Timeframe',
      'grouped_chart_share_png_text': 'BacktestX Grouped Chart',
      'grouped_chart_pdf_title': 'Grouped Per‑TF: {metric}',
      'grouped_chart_csv_share_text': 'BacktestX Grouped TF Chart CSV',
      'empty_grouped_title': 'No grouped data to display',
      'empty_grouped_tip_filtered':
          'Adjust the timeframe filters above or change metric.',
      'empty_grouped_tip_run':
          'Run comparison with results that include per‑TF stats, or change metric.',
      'result_index_label': 'Result {index}',

      // WorkspaceViewModel messages
      'strategy_results_exported': 'Strategy results exported to CSV',
      'tf_stats_exported': 'TF Stats exported to CSV',
      'trades_exported': 'All trades exported to CSV',
      'no_results_to_export': 'No results to export for this strategy',
      'no_per_tf_stats_found': 'No per-timeframe stats found',
      'no_trades_found_or_cache': 'No trades found or data missing in cache',
      'trades_csv_copied': 'Trades CSV copied to clipboard',
      'summary_copied': 'Summary copied to clipboard',
      'copy_failed': 'Copy failed: {error}',
      'copy_failed_generic': 'Copy failed',
      'export_failed': 'Export failed: {error}',
      'strategy_duplicated': 'Strategy duplicated',
      'strategy_deleted': 'Strategy deleted',
      'batch_complete_saved': 'Batch complete: {completed}/{total} saved',
      'batch_complete_saved_skipped':
          'Batch complete: {completed}/{total} saved (skipped {skipped} invalid)',
      'result_deleted': 'Result deleted',
      'maximum_compare': 'Maximum 4 results can be compared',
      'error_loading_selected_results': 'Error loading selected results',
      'data_validation_report_title': 'Data Validation Report',
      // Quick Test summaries
      'qt_zero_trade_title': 'Quick Test: 0 Trade',
      'qt_zero_trade_desc':
          'No trades generated for this strategy and data. Result will not be saved and detail view is unavailable.',
      'qt_done_title': 'Quick Test Completed',
      'qt_done_desc':
          'Profit Factor {pf}, Win Rate {winRate}%. View full results?',
      'qt_snackbar_summary':
          'Quick test completed — PF {pf}, WinRate {winRate}%',
      'qt_run_failed_title': 'Quick test failed',
      'qt_not_saved_zero_trade': 'Quick test result not saved (0 trade)',
      'delete_title': 'Delete Result',
      'cancel_title': 'Cancel',
      'delete_result_desc': 'Delete this backtest result?',

      'metric_tooltip_tests': 'Number of backtests executed for this strategy.',
      'metric_tooltip_avg_pnl':
          'Average profit/loss percentage across backtests.',
      'metric_tooltip_win_rate':
          'Average percentage of winning trades across results.',
      'metric_tooltip_return_pct':
          'Total profit/loss as percentage of initial capital.',
      'metric_tooltip_pnl': 'Total profit or loss in currency for this result.',
      'metric_tooltip_pf':
          'Profit Factor = gross profit divided by gross loss.',
      'metric_tooltip_max_drawdown':
          'Largest peak-to-trough decline during backtest (percentage).',
      'metric_tooltip_sharpe_ratio':
          'Risk-adjusted return; higher indicates better risk efficiency.',
      'metric_tooltip_avg_win': 'Average profit per winning trade.',
      'metric_tooltip_avg_loss': 'Average loss per losing trade.',
      'metric_tooltip_largest_win': 'Largest single-trade profit.',
      'metric_tooltip_largest_loss': 'Largest single-trade loss.',
      'metric_tooltip_expectancy':
          'Average expected profit per trade; positive indicates an edge.',
      'metric_tooltip_default': 'Metric description',

      'relative_today': 'Today',
      'relative_yesterday': 'Yesterday',
      'relative_days_ago': '{count} days ago',
      'relative_weeks_ago': '{count} weeks ago',
      'relative_months_ago': '{count} months ago',

      'backtest_results_title': 'Backtest Results',
      'export_label': 'Export',
      'export_per_tf_stats_tooltip': 'Export per-timeframe stats',
      'export_trade_history_tooltip': 'Export trade history',

      'menu_export_chart_png': 'Export Chart PNG…',
      'menu_export_panel_png': 'Export Panel PNG…',
      // Strategy Builder View
      'sb_edit_strategy_title': 'Edit Strategy',
      'sb_create_strategy_title': 'Create Strategy',
      'sb_strategy_details_header': 'Strategy Details',
      'sb_entry_rules_header': 'Entry Rules',
      'sb_exit_rules_header': 'Exit Rules',
      'sb_no_entry_rules_yet': 'No entry rules yet',
      'sb_no_exit_rules_yet': 'No exit rules yet',
      'sb_tap_to_add_rule': 'Tap + to add a rule',
      'sb_quick_backtest_preview_header': 'Quick Backtest Preview',
      'sb_exit_confirm_title': 'Exit Strategy Builder?',
      'sb_exit_confirm_content':
          'An autosave draft exists. Are you sure you want to close?',
      'common_cancel': 'Cancel',
      'sb_discard_and_exit': 'Discard & Exit',
      'common_close': 'Close',
      'sb_autosave_settings_header': 'Autosave Settings',
      'sb_enable_autosave_title': 'Enable Autosave',
      'sb_autosave_description':
          'Automatically save draft when changes are made',
      'sb_menu_tooltip': 'Menu',
      'sb_import_confirm_title': 'Confirm Import',
      'sb_import_confirm_content':
          'New template will overwrite current builder. Continue?',
      'sb_overwrite': 'Overwrite',
      'sb_import_template_json_title': 'Import Template JSON',
      'sb_apply': 'Apply',
      'sb_builder_tips': 'Builder Tips',
      'sb_export_json': 'Export JSON',
      'sb_copy_json': 'Copy JSON',
      'sb_save_json': 'Save .json',
      'sb_import_from_file': 'Import from .json file',
      'sb_import_json_ellipsis': 'Import JSON...',
      'sb_saved_at_prefix': 'Saved at ',
      'sb_retry': 'Retry',
      'sb_discard_autosave_tooltip': 'Discard current autosave draft',
      'sb_discard': 'Discard',
      'sb_discard_draft': 'Discard Draft',
      'sb_strategy_name_label': 'Strategy Name',
      'sb_strategy_name_hint': 'e.g. RSI Mean Reversion',
      'sb_initial_capital_label': 'Initial Capital',
      'sb_risk_type_label': 'Risk Type',
      'sb_risk_management_title': 'Risk Management',
      'sb_lot_size_label': 'Lot Size',
      'sb_atr_multiple_label': 'ATR Multiple',
      'sb_risk_percentage_label': 'Risk Percentage',
      'sb_take_profit_points': 'Take Profit (points)',
      'sb_select_market_data': 'Select Market Data',
      'sb_reset_preview': 'Reset Preview',
      'sb_view_full_results': 'View Full Results',
      'sb_indicator_label': 'Indicator',
      'sb_main_period_label': 'Main Period',
      'sb_main_period_hint': 'e.g. 14 or 20',
      'sb_timeframe_optional_label': 'Timeframe (optional)',
      'sb_use_base_timeframe': 'Use base timeframe',
      'sb_operator_label': 'Operator',
      'sb_number_label': 'Number',
      'sb_value_label': 'Value',
      'sb_value_hint': 'e.g. 30, 70, 50',
      'sb_operator_tooltip_rising':
          'Rising: current indicator > previous. No comparison needed.',
      'sb_operator_tooltip_falling':
          'Falling: current indicator < previous. No comparison needed.',
      'sb_operator_tooltip_cross_above':
          'Cross Above: indicator crosses above comparator (indicator/threshold).',
      'sb_operator_tooltip_cross_below':
          'Cross Below: indicator crosses below comparator (indicator/threshold).',
      'sb_operator_tooltip_default':
          'Standard comparison against a number or indicator.',
      'sb_operator_name_greater_than': 'Greater Than (>)',
      'sb_operator_name_less_than': 'Less Than (<)',
      'sb_operator_name_greater_or_equal': 'Greater or Equal (>=)',
      'sb_operator_name_less_or_equal': 'Less or Equal (<=)',
      'sb_operator_name_equals': 'Equals (=)',
      'sb_operator_name_cross_above': 'Cross Above',
      'sb_operator_name_cross_below': 'Cross Below',
      'sb_operator_name_rising': 'Rising',
      'sb_operator_name_falling': 'Falling',
      'sb_compare_with_label': 'Compare With',
      'sb_period_label': 'Period',
      'sb_anchor_mode_label': 'Anchor Mode',
      'sb_start_of_backtest': 'Start of Backtest',
      'sb_anchor_by_date': 'Anchor by Date',
      'sb_anchor_date_label': 'Anchor Date (ISO)',
      'sb_anchor_date_hint': 'YYYY-MM-DD or ISO',
      'sb_optional_timeframe_tooltip':
          'Optional: use timeframe >= base data to avoid auto-resampling.',
      'sb_cross_operator_help':
          'For cross: choose Indicator for indicator vs indicator; Number for threshold (e.g., zero-line).',
      'sb_error_gt_zero': 'Must be > 0',
      // Strategy Builder — rule warnings/errors
      'sb_warning_tf_greater_than_base':
          'Timeframe rule must be greater than base timeframe; will be adjusted to {base_tf}.',
      'sb_warning_rsi_between_20_80':
          'RSI threshold value should be between 20 and 80.',
      'sb_warning_operator_equals_not_supported':
          'Operator equals is not supported for price/indicator comparison.',
      'sb_warning_bbands_specify_band':
          'Comparison with Bollinger Bands must specify upper or lower band.',
      'sb_period_must_be_set_gt0': 'Period must be set (>0 recommended).',
      'sb_error_value_must_be_set': 'Value must be set.',
      'sb_error_rsi_between_0_100': 'Value RSI must be between 0 and 100.',
      'sb_error_adx_between_0_100': 'Value ADX must be between 0 and 100.',
      'sb_error_pick_comparison_indicator': 'Pick comparison indicator.',
      'sb_required_field': 'Required',
      'sb_required_selection': 'Selection required',
      'sb_invalid_date_format': 'Invalid date format',
      'sb_rule_title': 'Rule {index}',
      'sb_dynamic_atr_presets': 'Dynamic ATR% Presets',
      'sb_then_logic_label': 'Then (Logic)',
      'common_none': 'None',
      'sb_search_template_hint': 'Search templates...',
      'sb_show_all_categories': 'Show all categories',
      'sb_filter_prefix': 'Filter: ',
      'sb_items_available': '{count} available',
      'sb_results_count_label': '{count} results',
      'common_clear': 'Clear',
      'sb_apply_filters': 'Apply',
      'sb_clear_filters': 'Clear filters',
      'sb_pick_template_tooltip': 'Pick Template',
      'sb_run_preview_tooltip': 'Run Preview',
      'sb_test_strategy_button_tooltip': 'Run quick backtest',
      'sb_stats_signals': 'Signals',
      'sb_stats_trades': 'Trades',
      'sb_stats_wins': 'Wins',
      'sb_stats_winrate': 'WinRate',
      'sb_stats_expectancy': 'Expectancy',
      'sb_stats_avgwin': 'AvgWin',
      'sb_stats_avgloss': 'AvgLoss',
      'sb_stats_rr': 'R/R',
      // Strategy Builder — buttons and messages
      'sb_save_strategy_button': 'Save Strategy',
      'sb_update_strategy_button': 'Update Strategy',
      'sb_strategy_saved': 'Strategy saved!',
      'sb_strategy_updated': 'Strategy updated!',
      'sb_error_summary_header': 'Fixes required before save/preview',
      'sb_form_reset_ready': 'Form reset. Ready for a new strategy!',
      'sb_dialog_paste_json': 'Paste JSON here then tap',
      'menu_export_chart_pdf': 'Export Chart PDF…',
      'menu_export_chart_panel_pdf': 'Export Chart + Panel PDF…',
      'menu_export_panel_pdf': 'Export Panel PDF…',
      'menu_export_backtest_pdf': 'Export Backtest PDF',

      'prompt_export_chart_png': 'Export Chart PNG',
      'prompt_export_panel_png': 'Export Panel PNG',
      'prompt_export_chart_pdf': 'Export Chart PDF',
      'prompt_export_panel_pdf': 'Export Panel PDF',
      'prompt_export_chart_panel_pdf': 'Export Chart + Panel PDF',

      // Bottom sheets (en)
      'notice_pick_option': 'Select one option:',
      'indicator_settings_title': 'Chart Indicators',
      'common_reset_to_default': 'Reset to default',
      'common_apply': 'Apply',
      'quick_open_in_builder': 'Open in Builder',
      // Indicator Settings sheet (en)
      'is_overlays': 'Overlays',
      'is_oscillators': 'Oscillators',
      'is_chart_options': 'Chart Options',
      'is_sma': 'SMA',
      'is_ema': 'EMA',
      'is_bollinger_bands': 'Bollinger Bands',
      'is_macd': 'MACD',
      'is_simple_moving_average': 'Simple Moving Average',
      'is_exponential_moving_average': 'Exponential Moving Average',
      'is_volatility_bands': 'Volatility bands',
      'is_period': 'Period',
      'is_stddev': 'StdDev',
      'is_fast': 'Fast',
      'is_slow': 'Slow',
      'is_signal': 'Signal',
      'is_high_quality_rendering': 'High Quality Rendering',
      'is_high_quality_subtitle': 'Maximum detail, lower performance',
      'is_show_volume': 'Show Volume (if available)',
      'is_show_volume_subtitle': 'Show volume panel below chart',
      // Candlestick Pattern Guide sheet (en)
      'cp_guide_title': 'Candlestick Patterns Guide',
      'cp_hammer_title': 'Hammer',
      'cp_hammer_desc':
          'Bullish reversal pattern after a downtrend; long lower shadow.',
      'cp_shooting_star_title': 'Shooting Star',
      'cp_shooting_star_desc':
          'Bearish reversal pattern after an uptrend; long upper shadow.',
      'cp_doji_title': 'Doji',
      'cp_doji_desc':
          'Indecision in the market; open and close are nearly equal.',
      'cp_marubozu_title': 'Marubozu',
      'cp_marubozu_desc': 'Strong momentum candle with little or no shadows.',

      // Onboarding bottom sheet (en)
      'onboarding_import_data': 'Import Data',
      'onboarding_quick_start_templates': 'Quick‑Start Templates',
      'onboarding_learn': 'Learn',
      'onboarding_data_title': 'Data Onboarding',
      'onboarding_csv_tips':
          'CSV format: Date, Open, High, Low, Close, Volume (optional). Timeframe affects indicators and backtest results.',
      'onboarding_view_csv_example': 'View CSV Example',
      'onboarding_back': 'Back',
      'onboarding_next': 'Next',
      'onboarding_mark_done': 'Mark Done',
      'onboarding_step_progress': 'Step {current} of {total}',
      'onboarding_remind_later': 'Remind Me Later',
      'onboarding_step1_title': 'Select & Upload Data',
      'onboarding_step1_desc':
          'Upload OHLC CSV and pick a consistent timeframe. Data will be cached for quick preview.',
      'onboarding_step2_title': 'Pick Template / Indicator',
      'onboarding_step2_desc':
          'Start with Quick‑Start Templates or choose indicators to form strategy rules.',
      'onboarding_step3_title': 'Run Preview',
      'onboarding_step3_desc':
          'Use Quick Preview to see instant summary before saving.',
      'more_trades': '+ {count} more trades',
      // strategy template
      "template_breakout_basic_name": "Breakout — SMA Range",
      "template_breakout_basic_desc":
          "Entry when price breaks above SMA, exit when falling back below.",
      "template_breakout_hh_range_atr_name":
          "Breakout — HH/HL Range + ATR Filter",
      "template_breakout_hh_range_atr_desc":
          "Entry when Close crossAbove HighestHigh(20) if ATR(14) < threshold (default loose); Exit when Close crossBelow LowestLow(20).",
      "template_breakout_hh_range_atr_pct_name":
          "Breakout — HH/HL Range + ATR% Filter",
      "template_breakout_hh_range_atr_pct_desc":
          "Entry when Close crossAbove HighestHigh(20) if ATR%(14) < 2%; Exit when Close crossBelow LowestLow(20). ATR% = ATR/Close, consistent across instruments.",
      "template_mean_reversion_rsi_name": "Mean Reversion — RSI",
      "template_mean_reversion_rsi_desc":
          "Entry when RSI < 30 (oversold), exit when RSI > 50.",
      "template_macd_signal_name": "MACD Signal",
      "template_macd_signal_desc":
          "Entry when MACD crossAbove Signal, exit crossBelow.",
      "template_trend_ema_cross_name": "Trend Follow — EMA(20/50) Cross",
      "template_trend_ema_cross_desc":
          "Entry when EMA(20) crossAbove EMA(50), exit crossBelow.",
      "template_trend_ema_adx_filter_name":
          "Trend Follow — EMA Cross + ADX Filter",
      "template_trend_ema_adx_filter_desc":
          "Entry: EMA(20) crossAbove EMA(50) with ADX(14) > 20; Exit: EMA(20) crossBelow EMA(50).",
      "template_trend_ema_atr_pct_filter_name":
          "Trend Follow — EMA Cross + ATR% Filter",
      "template_trend_ema_atr_pct_filter_desc":
          "Entry: ATR%(14) < 2.0 and EMA(20) crossAbove EMA(50); Exit: EMA(20) crossBelow EMA(50).",
      "template_momentum_rsi_macd_name": "Momentum — RSI & MACD",
      "template_momentum_rsi_macd_desc":
          "Entry RSI > 55 and MACD crossAbove Signal; exit RSI < 45 or MACD crossBelow Signal.",
      "template_macd_hist_momentum_name":
          "MACD Momentum — Signal + Histogram Filter",
      "template_macd_hist_momentum_desc":
          "Entry: MACD crossAbove Signal + Histogram > threshold; Exit: MACD crossBelow Signal or Histogram < −threshold.",
      "template_mean_reversion_bb_rsi_name": "Mean Reversion — BB Lower + RSI",
      "template_mean_reversion_bb_rsi_desc":
          "Entry when Close < BB Lower (20) and RSI < 35; exit RSI > 50.",
      "template_ema_vs_sma_cross_name": "EMA vs SMA — Cross",
      "template_ema_vs_sma_cross_desc":
          "Entry when EMA crossAbove SMA(50), exit crossBelow SMA(50).",
      "template_macd_hist_rising_filter_name":
          "MACD Momentum — Histogram Rising + Signal + Filter",
      "template_macd_hist_rising_filter_desc":
          "Entry: Histogram Rising + MACD crossAbove Signal + Histogram > threshold; Exit: Histogram Falling or MACD crossBelow Signal or Histogram < −threshold.",
      "template_rsi_rising_50_filter_name": "RSI Momentum — Rising + 50 Filter",
      "template_rsi_rising_50_filter_desc":
          "Entry: RSI Rising + RSI > 50; Exit: RSI Falling or RSI < 50.",
      "template_ema_rising_price_filter_name":
          "EMA Momentum — EMA Rising + Price Filter",
      "template_ema_rising_price_filter_desc":
          "Entry: EMA Rising + Close > EMA(20); Exit: EMA Falling or Close < EMA(20).",
      "template_ema_ribbon_stack_name":
          "Trend Follow — EMA Ribbon (8/13/21/34/55)",
      "template_ema_ribbon_stack_desc":
          "Entry when EMA(8)>EMA(13)>EMA(21)>EMA(34)>EMA(55) and Close > EMA(21); Exit when Close < EMA(21).",
      "template_bb_squeeze_breakout_name":
          "Bollinger Squeeze — Width Rising + Breakout",
      "template_bb_squeeze_breakout_desc":
          "Main entry: Bollinger Width(20) rising and Close crossAbove BB Lower(20). Fallback: Close crossAbove SMA(20). Exit when Close < SMA(20). (Looser: without ATR% filter)",
      "template_rsi_divergence_approx_name":
          "RSI Divergence (Approx) — Rising RSI, Falling Price",
      "template_rsi_divergence_approx_desc":
          "Main entry: RSI rising and Close falling (simple bullish divergence signal). Fallback: RSI crossAbove 50 OR Close crossAbove SMA(20). Exit when RSI > 60.",
      "template_vwap_pullback_breakout_name":
          "VWAP Pullback — Close CrossAbove VWAP",
      "template_vwap_pullback_breakout_desc":
          "Entry when Close crossAbove VWAP(20) after consolidation; Exit when Close crossBelow VWAP(20).",
      "template_anchored_vwap_pullback_cross_name":
          "Anchored VWAP — Pullback Cross",
      "template_anchored_vwap_pullback_cross_desc":
          "Entry when Close crossAbove Anchored VWAP (anchor = start of backtest); Exit when Close crossBelow Anchored VWAP.",
      "template_stoch_kd_cross_adx_name": "Stochastic Cross — K/D + ADX Filter",
      "template_stoch_kd_cross_adx_desc":
          "Entry when %K(14) crossAbove %D(3) with ADX(14) > 20; Exit when %K crossBelow %D."
    },
    'id': {
      'appTitle': 'Backtest‑X',
      'tagline': 'Analisis • Backtest • Optimasi',
      'data_upload_title': 'Unggah Data Pasar',
      'coach_timeframe_header': 'Coach Marks — Dampak Timeframe',
      'coach_timeframe_body':
          'Timeframe mempengaruhi indikator (EMA/RSI/VWAP, dll). Data 1H vs 4H dapat menghasilkan sinyal berbeda. Gunakan timeframe yang konsisten.',
      'coach_timeframe_learn': 'Pelajari timeframe',
      'upload_no_file_selected': 'Belum ada file yang dipilih',
      'upload_csv_format_hint':
          'Format CSV: Date, Open, High, Low, Close, Volume',
      'upload_select_csv_file': 'Pilih File CSV',
      'upload_action_process': 'Unggah & Proses',
      'validation_passed': 'Validasi Berhasil',
      'validation_failed': 'Validasi Gagal',
      'validation_total_candles': 'Total Candles: {count}',
      'validation_errors_label': 'Error:',
      'recent_uploads': 'Upload Terbaru',
      'candles_count_label': '{count} candle',
      'no_market_data_info':
          'Tidak ada data pasar. Anda dapat mengaktifkan sample data untuk mencoba aplikasi.',
      'activate_sample_data_label': 'Aktifkan Sample Data ({sample})',
      'empty_no_uploads': 'Belum ada upload data',
      'empty_upload_message':
          'Pilih file CSV dan isi simbol untuk mengunggah market data.',
      'empty_upload_primary_label': 'Pilih File CSV',
      'input_symbol_label': 'Simbol',
      'input_symbol_hint': 'cth. EURUSD, BTCUSDT',
      'input_timeframe_label': 'Timeframe',
      'startup_init_services': 'Inisialisasi layanan',
      'startup_load_cache': 'Muat cache',
      'startup_prepare_ui': 'Siapkan UI',
      // Signup View
      'signup_title': 'Buat Akun',
      'signup_confirm_password_label': 'Konfirmasi Password',
      // Login View
      'login_title': 'Sign In',
      'login_post_redirect_banner':
          'Setelah login, kamu akan diarahkan ke halaman yang diminta.',
      'login_email_label': 'Email',
      'login_password_label': 'Password',
      'login_forgot_password': 'Lupa Password?',
      'login_sign_in_email': 'Sign In dengan Email',
      'login_sign_up_email': 'Sign Up dengan Email',
      'login_continue_google': 'Lanjutkan dengan Google',
      'login_continue_github': 'Lanjutkan dengan GitHub',
      'login_continue_apple': 'Lanjutkan dengan Apple',
      // Home user menu
      'home_user_menu_tooltip': 'Akun',
      'home_user_unknown': 'Tidak diketahui',
      'home_user_sign_out': 'Keluar',
      'home_user_sign_in': 'Masuk',
      'home_user_sign_up': 'Daftar',
      'home_user_change_password': 'Ubah Kata Sandi',
      // User View - Penghapusan akun
      'user_delete_account': 'Hapus Akun',
      'user_delete_account_title': 'Hapus Akun',
      'user_delete_account_desc':
          'Penghapusan akun langsung belum tersedia di aplikasi ini. Kamu bisa bersihkan data lokal dan keluar.',
      'user_delete_not_supported':
          'Penghapusan akun langsung belum tersedia di aplikasi ini.',
      'user_clear_local_data': 'Bersihkan Data Lokal',
      'user_clear_all_data_success': 'Data lokal dibersihkan.',
      'user_clear_all_data_error': 'Gagal membersihkan data lokal.',
      'user_clear_all_confirm_title': 'Konfirmasi Bersihkan Data Lokal',
      'user_clear_all_confirm_desc':
          'Ini akan menghapus strategi, hasil backtest, data pasar, dan draft yang tersimpan di perangkat ini. Lanjutkan?',
      'user_clear_all_confirm_button': 'Bersihkan',
      // Verifikasi Email
      'user_email_verification': 'Verifikasi Email',
      'user_email_status_verified': 'Terverifikasi',
      'user_email_status_unverified': 'Belum Terverifikasi',
      'user_email_resend': 'Kirim Ulang Email Verifikasi',
      'user_email_resend_success': 'Email verifikasi telah dikirim.',
      'user_email_resend_error': 'Gagal mengirim email verifikasi.',
      'home_change_password_success': 'Password berhasil diubah.',
      'change_password_title': 'Atur Password Baru',
      'change_password_description':
          'Masukkan password baru dan konfirmasi untuk mengubah password akun.',
      'change_password_new_label': 'Password Baru',
      'change_password_confirm_label': 'Konfirmasi Password Baru',
      'change_password_save_button': 'Simpan Password',
      'change_password_saving': 'Menyimpan...',
      'error_password_min': 'Password minimal 6 karakter.',
      'error_password_confirm_mismatch': 'Konfirmasi password tidak cocok.',
      'password_strength_weak': 'Lemah',
      'password_strength_medium': 'Sedang',
      'password_strength_strong': 'Kuat',
      // Common errors
      'error_invalid_email': 'Format email tidak valid.',
      'error_password_min_signup':
          'Password minimal 6 karakter untuk pendaftaran.',
      'error_auth_invalid_credentials': 'Email atau password salah.',
      'error_auth_email_registered': 'Email sudah terdaftar.',
      'error_auth_email_not_confirmed':
          'Email belum terverifikasi. Cek inbox untuk verifikasi.',
      'error_auth_generic': 'Terjadi kesalahan saat autentikasi. Coba lagi.',
      'error_generic': 'Terjadi kesalahan. Coba lagi.',
      'home_title': 'Backtest‑X',
      'home_tooltip_onboarding': 'Onboarding',
      'home_tooltip_options': 'Opsi',
      'home_help_options': 'Bantuan',
      'home_action_upload_title': 'Unggah Data',
      'home_action_upload_subtitle': 'Impor data pasar historis',
      'home_action_scanner_title': 'Pendeteksi Pola',
      'home_action_scanner_subtitle': 'Deteksi pola candlestick',
      'home_action_strategy_title': 'Buat Strategi',
      'home_action_strategy_subtitle': 'Bangun strategi trading Anda',
      'home_action_analysis_title': 'Analisis Pasar',
      'home_action_analysis_subtitle': 'Analisis data pasar',
      'home_action_workspace_title': 'Workspace',
      'home_action_workspace_subtitle': 'Kelola strategi',
      'home_recent_strategies': 'Strategi Terbaru',
      'home_cache_warming': 'Cache: pemanasan',
      'home_cache_ready': 'Cache: siap',
      'home_cache_empty': 'Cache: kosong',
      'home_option_pause_bg': 'Jeda Loading Background',
      'home_option_enable_bg': 'Aktifkan Loading Background',
      'home_option_load_cache': 'Muat Cache Sekarang',
      'home_cache_info_title': 'Info Cache',
      'language_menu_system': 'Gunakan Bahasa Sistem',
      'language_menu_english': 'Bahasa Inggris',
      'language_menu_indonesian': 'Bahasa Indonesia',
      'theme_menu_system': 'Gunakan Tema Sistem',
      "theme_menu_light": "Terang",
      "theme_menu_dark": "Gelap",
      'startup_steps_done': 'Semua langkah selesai. Menyiapkan aplikasi…',
      'home_loading_cache': 'Memuat cache…',
      'home_running_backtest': 'Menjalankan backtest...',
      'stats_strategies': 'Strategi',
      'stats_data_sets': 'Set Data',
      'stats_tests_run': 'Tes Dijalankan',
      'last_result_header': 'Hasil Terakhir',
      'edit_label': 'Ubah',
      'created_label': 'Dibuat: {date}',
      'env_prod': 'Prod',
      'env_dev': 'Dev',
      'getting_started_title': 'Mulai',
      'empty_both':
          'Belum ada data dan strategi. Unggah data dan buat strategi pertama.',
      'empty_no_data':
          'Belum ada data market. Unggah CSV untuk mulai backtest.',
      'empty_no_strategy':
          'Belum ada strategi. Buat strategi pertama untuk memulai.',
      'metrics_trades': 'Transaksi',
      'metrics_win_rate': 'Win Rate',
      'metrics_pnl': 'PnL',
      'metrics_profit_factor': 'Faktor Profit',
      'metrics_max_drawdown': 'Drawdown Maks',
      'view_details': 'Lihat Detail',
      'more_label': 'Lainnya',
      'delete_label': 'Hapus',
      'load_more': 'Muat lagi',
      "clear_label": "Bersihkan",
      "error_retry": "Coba Lagi",
      "error_dismiss": "Tutup",
      "dialog_got_it": "Mengerti",

      'workspace_tests': 'Tes',
      'workspace_avg_pnl': 'Rata-rata P&L',
      'workspace_win_rate': 'Win Rate',
      'workspace_pnl': 'P&L',
      'workspace_pf': 'PF',
      'workspace_no_results': 'Belum ada hasil backtest',
      'workspace_search_hint': 'Cari strategi...',
      'workspace_search_no_results_tip': 'Coba kata kunci lain',
      'workspace_quick_test_button': 'Uji Cepat',
      'workspace_quick_test_result_title': 'Hasil Uji Cepat',
      'workspace_export_filtered_results_csv': 'Ekspor hasil terfilter (CSV)',
      'workspace_filter_profit_only': 'Hanya Profit',
      'workspace_filter_pf_positive': 'PF > 1',
      'workspace_filter_win_rate_50': 'Win Rate > 50%',
      'copy_strategy_link': 'Salin Tautan Strategi',
      'copy_result_link': 'Salin Tautan Hasil',
      'common_expand': 'Perluas',
      'common_collapse': 'Ciutkan',
      'common_all_symbols': 'Semua Simbol',
      'workspace_compare_exit_tooltip': 'Keluar Banding',
      'workspace_compare_enter_tooltip': 'Bandingkan Hasil',
      'workspace_empty_no_strategies': 'Belum ada strategi',
      'workspace_empty_no_strategies_found': 'Strategi tidak ditemukan',
      'workspace_empty_create_first_message':
          'Buat strategi trading pertama Anda',
      'workspace_run_batch': 'Jalankan Batch',
      'duplicate_label': 'Duplikat',
      'workspace_compare_count_label': 'Bandingkan ({count})',
      'workspace_compare_banner_text': 'Pilih 2–4 hasil untuk dibandingkan',
      'workspace_compare_banner_selected_suffix': '({selected}/4 terpilih)',
      "workspace_backtest_results_count": "Hasil Backtest ({shown}/{total})",

      'filter_start_date': 'Tanggal Mulai',
      'filter_end_date': 'Tanggal Selesai',
      'filter_start_label': 'Mulai:',
      'filter_end_label': 'Selesai:',

      'copy_trades_csv': 'Salin CSV Transaksi',
      'copy_summary': 'Salin Ringkasan',
      'export_csv': 'Ekspor CSV',
      'export_tsv': 'Ekspor TSV',
      'export_all_trades_csv': 'Ekspor Semua Transaksi CSV',
      'export_tf_stats_csv': 'Ekspor Statistik TF CSV',
      'export_results_csv': 'Ekspor Hasil CSV',

      // Comparison View
      'compare_view_title': 'Bandingkan Hasil',
      'compare_export_csv_tooltip': 'Ekspor CSV Perbandingan',
      'compare_copy_summary_tooltip': 'Salin Ringkasan Perbandingan',
      'compare_menu_export': 'Ekspor Perbandingan',
      'comparison_csv_exported': 'CSV perbandingan berhasil diekspor',
      'comparison_csv_export_failed': 'Ekspor CSV perbandingan gagal',
      'best_performers_header': 'Performa Terbaik',
      'best_highest_pnl': 'P&L Tertinggi',
      'best_win_rate': 'Win Rate Terbaik',
      'best_profit_factor': 'Profit Factor Terbaik',
      'best_lowest_drawdown': 'Drawdown Terendah',
      'compare_detailed_metrics': 'Metrik Detail',
      'compare_metric_column': 'Metrik',
      'compare_total_pnl': 'Total P&L',
      'compare_return_percent': 'Return %',
      'compare_win_rate': 'Win Rate',
      'compare_total_trades': 'Total Transaksi',
      'compare_profit_factor': 'Faktor Profit',
      'compare_max_drawdown': 'Drawdown Maks',
      'compare_sharpe_ratio': 'Rasio Sharpe',
      'compare_avg_win': 'Avg Win',
      'compare_avg_loss': 'Avg Loss',
      'compare_largest_win': 'Win Terbesar',
      'compare_largest_loss': 'Loss Terbesar',
      'compare_expectancy': 'Ekspektansi',
      'per_tf_stats_header': 'Statistik Per‑Timeframe',
      'chart_metric_label': 'Metrik Grafik:',
      'sort_tf_label': 'Urut: TF',
      'sort_value_up_label': 'Urut: Nilai ↑',
      'sort_value_down_label': 'Urut: Nilai ↓',
      'agg_avg_label': 'Agg: Rata',
      'agg_max_label': 'Agg: Maks',
      'menu_export_chart_csv': 'Ekspor Chart CSV',
      'timeframe_label': 'Timeframe',
      'grouped_chart_share_png_text': 'BacktestX Grafik Kelompok',
      'grouped_chart_pdf_title': 'Gabungan Per‑TF: {metric}',
      'grouped_chart_csv_share_text': 'BacktestX Grafik TF Kelompok CSV',
      'empty_grouped_title': 'Tidak ada data kelompok untuk ditampilkan',
      'empty_grouped_tip_filtered':
          'Sesuaikan filter timeframe di atas atau ganti metrik.',
      'empty_grouped_tip_run':
          'Jalankan perbandingan dengan hasil yang punya statistik per‑TF, atau ganti metrik.',
      'result_index_label': 'Hasil {index}',

      // WorkspaceViewModel messages
      'strategy_results_exported': 'Hasil strategi diekspor ke CSV',
      'tf_stats_exported': 'Statistik TF diekspor ke CSV',
      'trades_exported': 'Semua transaksi diekspor ke CSV',
      'no_results_to_export':
          'Tidak ada hasil untuk diekspor pada strategi ini',
      'no_per_tf_stats_found': 'Tidak ada statistik per-timeframe ditemukan',
      'no_trades_found_or_cache':
          'Tidak ada transaksi atau data di cache hilang',
      'trades_csv_copied': 'CSV transaksi disalin ke clipboard',
      'summary_copied': 'Ringkasan disalin ke clipboard',
      'copy_failed': 'Gagal menyalin: {error}',
      'copy_failed_generic': 'Gagal menyalin',
      'export_failed': 'Ekspor gagal: {error}',
      'strategy_duplicated': 'Strategi diduplikasi',
      'strategy_deleted': 'Strategi dihapus',
      'batch_complete_saved': 'Batch selesai: {completed}/{total} tersimpan',
      'batch_complete_saved_skipped':
          'Batch selesai: {completed}/{total} tersimpan (lewati {skipped} tidak valid)',
      'result_deleted': 'Hasil dihapus',
      'maximum_compare': 'Maksimal 4 hasil dapat dibandingkan',
      'error_loading_selected_results': 'Error memuat hasil terpilih',
      'data_validation_report_title': 'Laporan Validasi Data',
      // Quick Test summaries
      'qt_zero_trade_title': 'Quick Test: 0 Trade',
      'qt_zero_trade_desc':
          'Tidak ada trade yang dihasilkan untuk strategi dan data ini. Hasil tidak akan disimpan dan tampilan detail tidak tersedia.',
      'qt_done_title': 'Quick Test Selesai',
      'qt_done_desc':
          'Profit Factor {pf}, Win Rate {winRate}%. Lihat hasil lengkap?',
      'qt_snackbar_summary': 'Quick test selesai — PF {pf}, WinRate {winRate}%',
      'qt_run_failed_title': 'Quick test gagal',
      'qt_not_saved_zero_trade': 'Hasil quick test tidak disimpan (0 trade)',
      'delete_title': 'Hapus Hasil',
      'cancel_title': 'Batal',
      'delete_result_desc': 'Hapus hasil backtest ini?',

      'metric_tooltip_tests':
          'Jumlah backtest yang dijalankan untuk strategi ini.',
      'metric_tooltip_avg_pnl':
          'Rata-rata persentase profit/kerugian di seluruh backtest.',
      'metric_tooltip_win_rate':
          'Rata-rata persentase transaksi menang di seluruh hasil.',
      'metric_tooltip_pnl':
          'Total profit atau rugi dalam mata uang untuk hasil ini.',
      'metric_tooltip_pf': 'Profit Factor = total profit dibagi total rugi.',
      'metric_tooltip_return_pct':
          'Total profit/rugi sebagai persentase dari modal awal.',
      'metric_tooltip_max_drawdown':
          'Penurunan puncak ke lembah terbesar selama backtest (persentase).',
      'metric_tooltip_sharpe_ratio':
          'Return disesuaikan risiko; lebih tinggi menunjukkan efisiensi risiko lebih baik.',
      'metric_tooltip_avg_win': 'Rata-rata profit per transaksi menang.',
      'metric_tooltip_avg_loss': 'Rata-rata rugi per transaksi kalah.',
      'metric_tooltip_largest_win': 'Profit terbesar dari satu transaksi.',
      'metric_tooltip_largest_loss': 'Rugi terbesar dari satu transaksi.',
      'metric_tooltip_expectancy':
          'Ekspektasi profit rata-rata per transaksi; bernilai positif menunjukkan keunggulan.',
      'metric_tooltip_total_trades':
          'Jumlah transaksi ditutup yang termasuk dalam ringkasan.',
      'metric_tooltip_default': 'Deskripsi metrik',

      'relative_today': 'Hari ini',
      'relative_yesterday': 'Kemarin',
      'relative_days_ago': '{count} hari lalu',
      'relative_weeks_ago': '{count} minggu lalu',
      'relative_months_ago': '{count} bulan lalu',

      'backtest_results_title': 'Hasil Backtest',
      'export_label': 'Ekspor',
      'export_per_tf_stats_tooltip': 'Ekspor statistik per-timeframe',
      'export_trade_history_tooltip': 'Ekspor riwayat transaksi',

      'menu_export_chart_png': 'Ekspor Chart PNG…',
      'menu_export_panel_png': 'Ekspor Panel PNG…',
      // Strategy Builder View
      'sb_edit_strategy_title': 'Edit Strategi',
      'sb_create_strategy_title': 'Buat Strategi',
      'sb_strategy_details_header': 'Detail Strategi',
      'sb_entry_rules_header': 'Aturan Masuk',
      'sb_exit_rules_header': 'Aturan Keluar',
      'sb_no_entry_rules_yet': 'Belum ada aturan masuk',
      'sb_no_exit_rules_yet': 'Belum ada aturan keluar',
      'sb_tap_to_add_rule': 'Ketuk + untuk menambah aturan',
      'sb_quick_backtest_preview_header': 'Pratinjau Cepat Backtest',
      'sb_exit_confirm_title': 'Keluar dari Strategy Builder?',
      'sb_exit_confirm_content':
          'Ada draft di autosave. Yakin ingin menutup layar?',
      'common_cancel': 'Batal',
      'sb_discard_and_exit': 'Discard & Keluar',
      'common_close': 'Tutup',
      'sb_autosave_settings_header': 'Pengaturan Autosave',
      'sb_enable_autosave_title': 'Aktifkan Autosave',
      'sb_autosave_description':
          'Secara otomatis simpan draft ketika perubahan dilakukan',
      'sb_menu_tooltip': 'Menu',
      'sb_import_confirm_title': 'Konfirmasi Impor',
      'sb_import_confirm_content':
          'Template baru akan menimpa builder saat ini. Lanjutkan?',
      'sb_overwrite': 'Timpa',
      'sb_import_template_json_title': 'Impor Template JSON',
      'sb_apply': 'Terapkan',
      'sb_builder_tips': 'Tips Builder',
      'sb_export_json': 'Ekspor JSON',
      'sb_copy_json': 'Salin JSON',
      'sb_save_json': 'Simpan .json',
      'sb_import_from_file': 'Impor dari file .json',
      'sb_import_json_ellipsis': 'Impor JSON...',
      'sb_saved_at_prefix': 'Tersimpan pada ',
      'sb_retry': 'Ulangi',
      'sb_discard_autosave_tooltip': 'Hapus draft autosave saat ini',
      'sb_discard': 'Buang',
      'sb_discard_draft': 'Buang Draft',
      'sb_strategy_name_label': 'Nama Strategi',
      'sb_strategy_name_hint': 'mis. RSI Mean Reversion',
      'sb_initial_capital_label': 'Modal Awal',
      'sb_risk_type_label': 'Tipe Risiko',
      'sb_risk_management_title': 'Manajemen Risiko',
      'sb_lot_size_label': 'Ukuran Lot',
      'sb_atr_multiple_label': 'Kelipatan ATR',
      'sb_risk_percentage_label': 'Persentase Risiko',
      'sb_take_profit_points': 'Take Profit (poin)',
      'sb_select_market_data': 'Pilih Data Market',
      'sb_reset_preview': 'Reset Preview',
      'sb_view_full_results': 'Lihat Hasil Lengkap',
      'sb_indicator_label': 'Indikator',
      'sb_main_period_label': 'Periode Utama',
      'sb_main_period_hint': 'mis. 14 atau 20',
      'sb_timeframe_optional_label': 'Timeframe (opsional)',
      'sb_use_base_timeframe': 'Gunakan timeframe dasar',
      'sb_operator_label': 'Operator',
      'sb_number_label': 'Angka',
      'sb_value_label': 'Nilai',
      'sb_value_hint': 'mis. 30, 70, 50',
      'sb_operator_tooltip_rising':
          'Rising: nilai indikator sekarang > nilai sebelumnya. Tidak butuh pembanding.',
      'sb_operator_tooltip_falling':
          'Falling: nilai indikator sekarang < nilai sebelumnya. Tidak butuh pembanding.',
      'sb_operator_tooltip_cross_above':
          'Cross Above: indikator menembus ke atas pembanding (indikator/ambang).',
      'sb_operator_tooltip_cross_below':
          'Cross Below: indikator menembus ke bawah pembanding (indikator/ambang).',
      'sb_operator_tooltip_default':
          'Perbandingan standar terhadap angka atau indikator.',
      'sb_operator_name_greater_than': 'Lebih Besar (>)',
      'sb_operator_name_less_than': 'Lebih Kecil (<)',
      'sb_operator_name_greater_or_equal': 'Lebih Besar atau Sama (>=)',
      'sb_operator_name_less_or_equal': 'Lebih Kecil atau Sama (<=)',
      'sb_operator_name_equals': 'Sama Dengan (=)',
      'sb_operator_name_cross_above': 'Menembus Ke Atas',
      'sb_operator_name_cross_below': 'Menembus Ke Bawah',
      'sb_operator_name_rising': 'Naik',
      'sb_operator_name_falling': 'Turun',
      'sb_compare_with_label': 'Bandingkan Dengan',
      'sb_period_label': 'Periode',
      'sb_anchor_mode_label': 'Mode Anchor',
      'sb_start_of_backtest': 'Awal Backtest',
      'sb_anchor_by_date': 'Anchor berdasarkan Tanggal',
      'sb_anchor_date_label': 'Tanggal Anchor (ISO)',
      'sb_anchor_date_hint': 'YYYY-MM-DD atau ISO',
      'sb_optional_timeframe_tooltip':
          'Opsional: gunakan timeframe >= data dasar untuk menghindari resampling otomatis.',
      'sb_cross_operator_help':
          'Untuk operator cross: pilih Indicator untuk cross antar indikator, atau Number untuk ambang (mis. zero-line).',
      'sb_error_gt_zero': 'Harus > 0',
      // Strategy Builder — rule warnings/errors (ID)
      'sb_warning_tf_greater_than_base':
          'Timeframe rule harus lebih besar dari timeframe dasar; akan disesuaikan menjadi {base_tf}.',
      'sb_warning_rsi_between_20_80':
          'Nilai ambang RSI sebaiknya antara 20 dan 80.',
      'sb_warning_operator_equals_not_supported':
          'Operator equals tidak didukung untuk perbandingan harga/indikator.',
      'sb_warning_bbands_specify_band':
          'Perbandingan dengan Bollinger Bands harus memilih upper atau lower band.',
      'sb_period_must_be_set_gt0': 'Periode harus diisi (disarankan > 0).',
      'sb_error_value_must_be_set': 'Nilai harus diisi.',
      'sb_error_rsi_between_0_100': 'Nilai RSI harus antara 0 dan 100.',
      'sb_error_adx_between_0_100': 'Nilai ADX harus antara 0 dan 100.',
      'sb_error_pick_comparison_indicator': 'Pilih indikator pembanding.',
      'sb_required_field': 'Wajib diisi',
      'sb_required_selection': 'Wajib pilih',
      'sb_invalid_date_format': 'Format tanggal tidak valid',
      'sb_rule_title': 'Aturan {index}',
      'sb_dynamic_atr_presets': 'Dynamic ATR% Presets',
      'sb_then_logic_label': 'Lalu (Logika)',
      'common_none': 'Tidak ada',
      'sb_search_template_hint': 'Cari template...',
      'sb_show_all_categories': 'Tampilkan semua kategori',
      'sb_filter_prefix': 'Filter: ',
      'sb_items_available': '{count} tersedia',
      'sb_results_count_label': '{count} hasil',
      'common_clear': 'Bersihkan',
      'sb_apply_filters': 'Terapkan',
      'sb_clear_filters': 'Bersihkan filter',
      'sb_pick_template_tooltip': 'Pilih Template',
      'sb_run_preview_tooltip': 'Jalankan Preview',
      'sb_test_strategy_button_tooltip': 'Jalankan backtest cepat',
      'sb_test_strategy_button_isrunning_tooltip': 'Preview sedang berjalan',
      'sb_stats_signals': 'Sinyal',
      'sb_stats_trades': 'Transaksi',
      'sb_stats_wins': 'Menang',
      'sb_stats_winrate': 'WinRate',
      // Strategy Builder — buttons and messages
      'sb_save_strategy_button': 'Simpan Strategi',
      'sb_update_strategy_button': 'Perbarui Strategi',
      'sb_strategy_saved': 'Strategi disimpan!',
      'sb_strategy_updated': 'Strategi diperbarui!',
      'sb_error_summary_header': 'Perbaiki diperlukan sebelum simpan/preview',
      'sb_form_reset_ready': 'Form direset. Siap untuk strategi baru!',
      'sb_dialog_paste_json': 'Tempel JSON di sini lalu tekan',
      'menu_export_chart_pdf': 'Ekspor Chart PDF…',
      'menu_export_chart_panel_pdf': 'Ekspor Chart + Panel PDF…',
      'menu_export_panel_pdf': 'Ekspor Panel PDF…',
      'menu_export_backtest_pdf': 'Ekspor Backtest PDF',

      'prompt_export_chart_png': 'Ekspor Chart PNG',
      'prompt_export_panel_png': 'Ekspor Panel PNG',
      'prompt_export_chart_pdf': 'Ekspor Chart PDF',
      'prompt_export_panel_pdf': 'Ekspor Panel PDF',
      'prompt_export_chart_panel_pdf': 'Ekspor Chart + Panel PDF',

      // Bottom sheets (id)
      'notice_pick_option': 'Pilih salah satu opsi:',
      'indicator_settings_title': 'Indikator Chart',
      'common_reset_to_default': 'Reset ke default',
      'common_apply': 'Terapkan',
      'quick_open_in_builder': 'Buka di Builder',
      // Indicator Settings sheet (id)
      'is_overlays': 'Overlay',
      'is_oscillators': 'Osilator',
      'is_chart_options': 'Opsi Chart',
      'is_sma': 'SMA',
      'is_ema': 'EMA',
      'is_bollinger_bands': 'Bollinger Bands',
      'is_macd': 'MACD',
      'is_simple_moving_average': 'Rata-rata berjalan sederhana',
      'is_exponential_moving_average': 'Rata-rata berjalan eksponensial',
      'is_volatility_bands': 'Pita volatilitas',
      'is_period': 'Periode',
      'is_stddev': 'StdDev',
      'is_fast': 'Cepat',
      'is_slow': 'Lambat',
      'is_signal': 'Sinyal',
      'is_high_quality_rendering': 'Rendering berkualitas tinggi',
      'is_high_quality_subtitle': 'Detail maksimal, performa lebih rendah',
      'is_show_volume': 'Tampilkan Volume (jika tersedia)',
      'is_show_volume_subtitle': 'Tampilkan panel volume di bawah chart',
      // Candlestick Pattern Guide sheet (id)
      'cp_guide_title': 'Panduan Pola Candlestick',
      'cp_hammer_title': 'Hammer',
      'cp_hammer_desc':
          'Pola pembalikan bullish setelah tren turun; ekor bawah panjang.',
      'cp_shooting_star_title': 'Shooting Star',
      'cp_shooting_star_desc':
          'Pola pembalikan bearish setelah tren naik; ekor atas panjang.',
      'cp_doji_title': 'Doji',
      'cp_doji_desc': 'Kebimbangan pasar; harga buka dan tutup hampir sama.',
      'cp_marubozu_title': 'Marubozu',
      'cp_marubozu_desc':
          'Kandil momentum kuat dengan sedikit atau tanpa ekor.',

      // Onboarding bottom sheet (id)
      'onboarding_import_data': 'Impor Data',
      'onboarding_quick_start_templates': 'Quick‑Start Templates',
      'onboarding_learn': 'Pelajari',
      'onboarding_data_title': 'Data Onboarding',
      'onboarding_csv_tips':
          'Format CSV: Date, Open, High, Low, Close, Volume (opsional). Timeframe mempengaruhi indikator dan hasil backtest.',
      'onboarding_view_csv_example': 'Lihat Contoh CSV',
      'onboarding_back': 'Kembali',
      'onboarding_next': 'Lanjut',
      'onboarding_mark_done': 'Tandai Selesai',
      'onboarding_step_progress': 'Langkah {current} dari {total}',
      'onboarding_remind_later': 'Nanti Saja',
      'onboarding_step1_title': 'Pilih & Upload Data',
      'onboarding_step1_desc':
          'Unggah OHLC CSV dan pilih timeframe yang konsisten. Data akan di-cache untuk preview cepat.',
      'onboarding_step2_title': 'Pilih Template / Indikator',
      'onboarding_step2_desc':
          'Mulai dengan Quick‑Start Templates atau pilih indikator untuk membentuk aturan strategi.',
      'onboarding_step3_title': 'Jalankan Preview',
      'onboarding_step3_desc':
          'Gunakan Quick Preview untuk melihat ringkasan instan sebelum menyimpan.',

      'more_trades': '+ {count} transaksi lagi',
      // Pattern Scanner View
      'pattern_scanner_title': 'Pendeteksi Pola',
      'ps_select_market_data': 'Pilih Data Pasar',
      'ps_no_market_data': 'Tidak ada data pasar. Unggah data terlebih dahulu.',
      'ps_select_market_hint': 'Pilih data pasar…',
      'ps_filters_header': 'Filter:',
      'ps_filter_bullish': 'Bullish',
      'ps_filter_bearish': 'Bearish',
      'ps_filter_indecision': 'Indecision',
      'ps_empty_select_market': 'Pilih data pasar untuk discan',
      'ps_empty_select_hint': 'Pilih data pasar dari dropdown di atas',
      'ps_no_patterns_found': 'Tidak ada pola ditemukan',
      'ps_try_adjust_filters': 'Coba sesuaikan filter Anda',
      'ps_candle_time': 'Waktu',
      'ps_candle_open': 'Open',
      'ps_candle_close': 'Close',
      'ps_candle_high': 'High',
      'ps_candle_low': 'Low',
      'ps_candle_body': 'Body',
      'ps_signal_bullish': 'Bullish',
      'ps_signal_bearish': 'Bearish',
      'ps_signal_indecision': 'Indecision',
      'ps_strength_weak': 'Lemah',
      'ps_strength_medium': 'Sedang',
      'ps_strength_strong': 'Kuat',
      'ps_patterns_guide_title': 'Panduan Pola Candlestick',
      'ps_pattern_spinning_top': 'Spinning Top',
      'ps_pattern_strong_bullish_cont': 'Bullish Kuat Berlanjut',
      'ps_pattern_strong_bearish_cont': 'Bearish Kuat Berlanjut',
      'ps_desc_strong_cont':
          'Sedikit atau tanpa sumbu. Momentum kuat ke satu arah. Mengindikasikan kelanjutan tren saat ini.',
      'ps_desc_spinning_top':
          'Body kecil dengan sumbu panjang di kedua sisi. Mengindikasikan ketidakpastian dan potensi pembalikan.',
      // Market Analysis View
      'market_analysis_title': 'Analisis Pasar',
      'ma_refresh_tooltip': 'Segarkan',
      'ma_chart_settings_tooltip': 'Pengaturan Chart',
      'ma_select_market_label': 'Pilih Pasar',
      'ma_no_market_data': 'Tidak ada data pasar',
      'ma_select_market_hint': 'Pilih pasar...',
      'ma_empty_select_market': 'Pilih pasar untuk dianalisis',
      'ma_price_statistics': 'Statistik Harga',
      'ma_trend_analysis': 'Analisis Tren',
      'ma_volatility': 'Volatilitas',
      'ma_volume': 'Volume',
      'ma_data_quality': 'Kualitas Data',
      'ma_overview_current_label': 'Saat Ini',
      'ma_overview_change_label': 'Perubahan',
      'ma_trend_strength_label': 'Kekuatan',
      'ma_trend_uptrend': 'Tren Naik',
      'ma_trend_downtrend': 'Tren Turun',
      'ma_trend_sideways': 'Mendatar',
      'ma_strength_unknown': 'Tidak diketahui',
      'ma_volatility_high': 'Tinggi',
      'ma_volatility_medium': 'Sedang',
      'ma_volatility_low': 'Rendah',
      'ma_volatility_unknown': 'Tidak diketahui',
      'ma_price_highest': 'Tertinggi',
      'ma_price_lowest': 'Terendah',
      'ma_price_average': 'Rata-rata',
      'ma_price_range': 'Rentang',
      'ma_volatility_level_label': 'Level',
      'ma_volatility_atr_label': 'ATR',
      'ma_volume_total': 'Total Volume',
      'ma_volume_average': 'Rata-rata Volume',
      'ma_quality_valid_data': 'Data Valid',
      'ma_quality_complete_no_gaps': 'Lengkap (Tanpa Celah)',
      'ma_quality_candles': 'Candle',
      // strategy template
      "template_breakout_basic_name": "Breakout — SMA Range",
      "template_breakout_basic_desc":
          "Entry saat harga menembus di atas SMA, exit saat kembali di bawah.",
      "template_breakout_hh_range_atr_name":
          "Breakout — HH/HL Range + ATR Filter",
      "template_breakout_hh_range_atr_desc":
          "Entry saat Close crossAbove HighestHigh(20) bila ATR(14) < ambang (default longgar); Exit saat Close crossBelow LowestLow(20).",
      "template_breakout_hh_range_atr_pct_name":
          "Breakout — HH/HL Range + ATR% Filter",
      "template_breakout_hh_range_atr_pct_desc":
          "Entry saat Close crossAbove HighestHigh(20) bila ATR%(14) < 2%; Exit saat Close crossBelow LowestLow(20). ATR% = ATR/Close, konsisten lintas instrumen.",
      "template_mean_reversion_rsi_name": "Mean Reversion — RSI",
      "template_mean_reversion_rsi_desc":
          "Entry saat RSI < 30 (oversold), exit saat RSI > 50.",
      "template_macd_signal_name": "MACD Signal",
      "template_macd_signal_desc":
          "Entry saat MACD crossAbove Signal, exit crossBelow.",
      "template_trend_ema_cross_name": "Trend Follow — EMA(20/50) Cross",
      "template_trend_ema_cross_desc":
          "Entry saat EMA(20) crossAbove EMA(50), exit saat crossBelow.",
      "template_trend_ema_adx_filter_name":
          "Trend Follow — EMA Cross + ADX Filter",
      "template_trend_ema_adx_filter_desc":
          "Entry: EMA(20) crossAbove EMA(50) dengan ADX(14) > 20; Exit: EMA(20) crossBelow EMA(50).",
      "template_trend_ema_atr_pct_filter_name":
          "Trend Follow — EMA Cross + ATR% Filter",
      "template_trend_ema_atr_pct_filter_desc":
          "Entry: ATR%(14) < 2.0 dan EMA(20) crossAbove EMA(50); Exit: EMA(20) crossBelow EMA(50).",
      "template_momentum_rsi_macd_name": "Momentum — RSI & MACD",
      "template_momentum_rsi_macd_desc":
          "Entry RSI > 55 dan MACD crossAbove Signal; exit RSI < 45 atau MACD crossBelow Signal.",
      "template_macd_hist_momentum_name":
          "MACD Momentum — Signal + Histogram Filter",
      "template_macd_hist_momentum_desc":
          "Entry: MACD crossAbove Signal + Histogram > ambang; Exit: MACD crossBelow Signal atau Histogram < −ambang.",
      "template_mean_reversion_bb_rsi_name": "Mean Reversion — BB Lower + RSI",
      "template_mean_reversion_bb_rsi_desc":
          "Entry saat Close < BB Lower (20) dan RSI < 35; exit RSI > 50.",
      "template_ema_vs_sma_cross_name": "EMA vs SMA — Cross",
      "template_ema_vs_sma_cross_desc":
          "Entry saat EMA crossAbove SMA(50), exit saat crossBelow SMA(50).",
      "template_macd_hist_rising_filter_name":
          "MACD Momentum — Histogram Rising + Signal + Filter",
      "template_macd_hist_rising_filter_desc":
          "Entry: Histogram Rising + MACD crossAbove Signal + Histogram > ambang; Exit: Histogram Falling atau MACD crossBelow Signal atau Histogram < −ambang.",
      "template_rsi_rising_50_filter_name": "RSI Momentum — Rising + 50 Filter",
      "template_rsi_rising_50_filter_desc":
          "Entry: RSI Rising + RSI > 50; Exit: RSI Falling atau RSI < 50.",
      "template_ema_rising_price_filter_name":
          "EMA Momentum — EMA Rising + Price Filter",
      "template_ema_rising_price_filter_desc":
          "Entry: EMA Rising + Close > EMA(20); Exit: EMA Falling atau Close < EMA(20).",
      "template_ema_ribbon_stack_name":
          "Trend Follow — EMA Ribbon (8/13/21/34/55)",
      "template_ema_ribbon_stack_desc":
          "Entry saat EMA(8)>EMA(13)>EMA(21)>EMA(34)>EMA(55) dan Close > EMA(21); Exit saat Close < EMA(21).",
      "template_bb_squeeze_breakout_name":
          "Bollinger Squeeze — Width Rising + Breakout",
      "template_bb_squeeze_breakout_desc":
          "Entry utama: Bollinger Width(20) rising dan Close crossAbove BB Lower(20). Fallback: Close crossAbove SMA(20). Exit saat Close < SMA(20). (Lebih longgar: tanpa filter ATR%)",
      "template_rsi_divergence_approx_name":
          "RSI Divergence (Approx) — Rising RSI, Falling Price",
      "template_rsi_divergence_approx_desc":
          "Entry utama: RSI rising dan Close falling (indikasi divergensi bullish sederhana). Fallback: RSI crossAbove 50 ATAU Close crossAbove SMA(20). Exit saat RSI > 60.",
      "template_vwap_pullback_breakout_name":
          "VWAP Pullback — Close CrossAbove VWAP",
      "template_vwap_pullback_breakout_desc":
          "Entry saat Close crossAbove VWAP(20) setelah konsolidasi; Exit saat Close crossBelow VWAP(20).",
      "template_anchored_vwap_pullback_cross_name":
          "Anchored VWAP — Pullback Cross",
      "template_anchored_vwap_pullback_cross_desc":
          "Entry saat Close crossAbove Anchored VWAP (anchor = awal backtest); Exit saat Close crossBelow Anchored VWAP.",
      "template_stoch_kd_cross_adx_name": "Stochastic Cross — K/D + ADX Filter",
      "template_stoch_kd_cross_adx_desc":
          "Entry saat %K(14) crossAbove %D(3) dengan ADX(14) > 20; Exit saat %K crossBelow %D."
    },
  };

  String _text(String key) =>
      _localizedValues[locale.languageCode]?[key] ??
      _localizedValues['en']![key] ??
      key;

  // Expose getters for convenience
  String get appTitle => _text('appTitle');
  String get tagline => _text('tagline');
  String get homeTitle => _text('home_title');
  String get homeTooltipOnboarding => _text('home_tooltip_onboarding');
  String get homeTooltipOptions => _text('home_tooltip_options');
  String get homeHelpOptions => _text('home_help_options');
  String get homeActionUploadTitle => _text('home_action_upload_title');
  String get homeActionUploadSubtitle => _text('home_action_upload_subtitle');
  String get homeActionScannerTitle => _text('home_action_scanner_title');
  String get homeActionScannerSubtitle => _text('home_action_scanner_subtitle');
  String get homeActionStrategyTitle => _text('home_action_strategy_title');
  String get homeActionStrategySubtitle =>
      _text('home_action_strategy_subtitle');
  String get homeActionAnalysisTitle => _text('home_action_analysis_title');
  String get homeActionAnalysisSubtitle =>
      _text('home_action_analysis_subtitle');
  String get homeActionWorkspaceTitle => _text('home_action_workspace_title');
  String get homeActionWorkspaceSubtitle =>
      _text('home_action_workspace_subtitle');
  String get homeRecentStrategies => _text('home_recent_strategies');
  String get homeCacheWarming => _text('home_cache_warming');
  String get homeCacheReady => _text('home_cache_ready');
  String get homeCacheEmpty => _text('home_cache_empty');
  String get homeOptionPauseBg => _text('home_option_pause_bg');
  String get homeOptionEnableBg => _text('home_option_enable_bg');
  String get homeOptionLoadCache => _text('home_option_load_cache');
  String get homeCacheInfoTitle => _text('home_cache_info_title');
  String get languageMenuSystem => _text('language_menu_system');
  String get languageMenuEnglish => _text('language_menu_english');
  String get languageMenuIndonesian => _text('language_menu_indonesian');
  String get themeMenuSystem => _text('theme_menu_system');
  String get themeMenuLight => _text('theme_menu_light');
  String get themeMenuDark => _text('theme_menu_dark');
  String get startupStepsDone => _text('startup_steps_done');
  String get startupInitServices => _text('startup_init_services');
  String get startupLoadCache => _text('startup_load_cache');
  String get startupPrepareUi => _text('startup_prepare_ui');

  // Signup View
  String get signupTitle => _text('signup_title');
  String get signupConfirmPasswordLabel =>
      _text('signup_confirm_password_label');

  // Login View
  String get loginTitle => _text('login_title');
  String get loginPostRedirectBanner => _text('login_post_redirect_banner');
  String get loginEmailLabel => _text('login_email_label');
  String get loginPasswordLabel => _text('login_password_label');
  String get loginForgotPassword => _text('login_forgot_password');
  String get loginSignInEmail => _text('login_sign_in_email');
  String get loginSignUpEmail => _text('login_sign_up_email');
  String get loginContinueGoogle => _text('login_continue_google');
  String get loginContinueGithub => _text('login_continue_github');
  String get loginContinueApple => _text('login_continue_apple');

  // Home user menu
  String get homeUserMenuTooltip => _text('home_user_menu_tooltip');
  String get homeUserUnknown => _text('home_user_unknown');
  String get homeUserSignOut => _text('home_user_sign_out');
  String get homeUserSignIn => _text('home_user_sign_in');
  String get homeUserSignUp => _text('home_user_sign_up');
  String get homeUserChangePassword => _text('home_user_change_password');
  // User View - Delete Account
  String get userDeleteAccount => _text('user_delete_account');
  String get userDeleteAccountTitle => _text('user_delete_account_title');
  String get userDeleteAccountDesc => _text('user_delete_account_desc');
  String get userDeleteNotSupported => _text('user_delete_not_supported');
  String get userClearLocalData => _text('user_clear_local_data');
  String get userClearAllDataSuccess => _text('user_clear_all_data_success');
  String get userClearAllDataError => _text('user_clear_all_data_error');
  String get userClearAllConfirmTitle => _text('user_clear_all_confirm_title');
  String get userClearAllConfirmDesc => _text('user_clear_all_confirm_desc');
  String get userClearAllConfirmButton =>
      _text('user_clear_all_confirm_button');
  String get userEmailVerification => _text('user_email_verification');
  String get userEmailStatusVerified => _text('user_email_status_verified');
  String get userEmailStatusUnverified => _text('user_email_status_unverified');
  String get userEmailResend => _text('user_email_resend');
  String get userEmailResendSuccess => _text('user_email_resend_success');
  String get userEmailResendError => _text('user_email_resend_error');
  String get homeChangePasswordSuccess => _text('home_change_password_success');
  String get changePasswordTitle => _text('change_password_title');
  String get changePasswordDescription => _text('change_password_description');
  String get changePasswordNewLabel => _text('change_password_new_label');
  String get changePasswordConfirmLabel =>
      _text('change_password_confirm_label');
  String get changePasswordSaveButton => _text('change_password_save_button');
  String get changePasswordSaving => _text('change_password_saving');
  String get commonCancel => _text('common_cancel');
  String get errorPasswordMin => _text('error_password_min');
  String get errorPasswordConfirmMismatch =>
      _text('error_password_confirm_mismatch');
  String get passwordStrengthWeak => _text('password_strength_weak');
  String get passwordStrengthMedium => _text('password_strength_medium');
  String get passwordStrengthStrong => _text('password_strength_strong');

  // Common errors
  String get errorInvalidEmail => _text('error_invalid_email');
  String get errorPasswordMinSignup => _text('error_password_min_signup');
  String get errorAuthInvalidCredentials =>
      _text('error_auth_invalid_credentials');
  String get errorAuthEmailRegistered => _text('error_auth_email_registered');
  String get errorAuthEmailNotConfirmed =>
      _text('error_auth_email_not_confirmed');
  String get errorAuthGeneric => _text('error_auth_generic');
  String get errorGeneric => _text('error_generic');

  // Data Upload View
  String get dataUploadTitle => _text('data_upload_title');
  String get coachTimeframeHeader => _text('coach_timeframe_header');
  String get coachTimeframeBody => _text('coach_timeframe_body');
  String get coachTimeframeLearn => _text('coach_timeframe_learn');
  String get uploadNoFileSelected => _text('upload_no_file_selected');
  String get uploadCsvFormatHint => _text('upload_csv_format_hint');
  String get uploadSelectCsvFile => _text('upload_select_csv_file');
  String get uploadActionProcess => _text('upload_action_process');
  String get validationPassed => _text('validation_passed');
  String get validationFailed => _text('validation_failed');
  String validationTotalCandles(int count) =>
      _text('validation_total_candles').replaceAll('{count}', '$count');
  String get validationErrorsLabel => _text('validation_errors_label');
  String get recentUploads => _text('recent_uploads');
  String candlesCountLabel(int count) =>
      _text('candles_count_label').replaceAll('{count}', '$count');
  String get noMarketDataInfo => _text('no_market_data_info');
  String activateSampleDataLabel(String sample) =>
      _text('activate_sample_data_label').replaceAll('{sample}', sample);
  String get emptyNoUploads => _text('empty_no_uploads');
  String get emptyUploadMessage => _text('empty_upload_message');
  String get emptyUploadPrimaryLabel => _text('empty_upload_primary_label');
  String get inputSymbolLabel => _text('input_symbol_label');
  String get inputSymbolHint => _text('input_symbol_hint');
  String get inputTimeframeLabel => _text('input_timeframe_label');
  String get homeLoadingCache => _text('home_loading_cache');
  String get homeRunningBacktest => _text('home_running_backtest');
  String get statsStrategies => _text('stats_strategies');
  String get statsDataSets => _text('stats_data_sets');
  String get statsTestsRun => _text('stats_tests_run');
  String get lastResultHeader => _text('last_result_header');
  String get editLabel => _text('edit_label');
  String createdLabel(String date) =>
      _text('created_label').replaceAll('{date}', date);
  String get envProd => _text('env_prod');
  String get envDev => _text('env_dev');
  String get gettingStartedTitle => _text('getting_started_title');
  String get emptyBoth => _text('empty_both');
  String get emptyNoData => _text('empty_no_data');
  String get emptyNoStrategy => _text('empty_no_strategy');
  String get metricsTrades => _text('metrics_trades');
  String get metricsWinRate => _text('metrics_win_rate');
  String get metricsPnl => _text('metrics_pnl');
  String get metricsProfitFactor => _text('metrics_profit_factor');
  String get metricsMaxDrawdown => _text('metrics_max_drawdown');
  String get viewDetails => _text('view_details');
  String get moreLabel => _text('more_label');
  String get deleteLabel => _text('delete_label');
  String get loadMore => _text('load_more');

  String get workspaceTestsLabel => _text('workspace_tests');
  String get workspaceAvgPnlLabel => _text('workspace_avg_pnl');
  String get workspaceWinRateLabel => _text('workspace_win_rate');
  String get workspacePnlLabel => _text('workspace_pnl');
  String get workspacePfLabel => _text('workspace_pf');
  String get workspaceNoResults => _text('workspace_no_results');
  String get workspaceSearchHint => _text('workspace_search_hint');
  String get workspaceSearchNoResultsTip =>
      _text('workspace_search_no_results_tip');
  String get workspaceQuickTestButton => _text('workspace_quick_test_button');
  String get workspaceQuickTestResultTitle =>
      _text('workspace_quick_test_result_title');

  // Sorting labels (Workspace)
  String get sortName => _text('sort_name');
  String get sortDateCreated => _text('sort_date_created');
  String get sortDateModified => _text('sort_date_modified');
  String get sortPerformance => _text('sort_performance');
  String get sortTestsRun => _text('sort_tests_run');

  // Common copy/snackbar messages
  String get copyStrategyLinkCopied => _text('copy_strategy_link_copied');
  String get copyResultLinkCopied => _text('copy_result_link_copied');
  String copyFailed(String error) =>
      _text('copy_failed').replaceAll('{error}', error);

  // Market data / quick test notices
  String get mdRequiredTitle => _text('md_required_title');
  String get mdRequiredDesc => _text('md_required_desc');
  String get mdUploadButton => _text('md_upload_button');

  String get qtSelectDataTitle => _text('qt_select_data_title');
  String get qtSelectDataDesc => _text('qt_select_data_desc');
  String get qtUseThisData => _text('qt_use_this_data');
  String get qtUploadNew => _text('qt_upload_new');

  String get mdEmptyTitle => _text('md_empty_title');
  String get mdEmptyDesc => _text('md_empty_desc');
  String get mdGoToUpload => _text('md_go_to_upload');
  String get commonClose => _text('common_close');

  String get qtZeroTradeTitle => _text('qt_zero_trade_title');
  String get qtZeroTradeDesc => _text('qt_zero_trade_desc');
  String get qtDoneTitle => _text('qt_done_title');
  String qtDoneDesc(String pf, String winRate) => _text('qt_done_desc')
      .replaceAll('{pf}', pf)
      .replaceAll('{winRate}', winRate);
  String qtSnackbarSummary(String pf, String winRate) =>
      _text('qt_snackbar_summary')
          .replaceAll('{pf}', pf)
          .replaceAll('{winRate}', winRate);
  String get qtRunFailedTitle => _text('qt_run_failed_title');
  String get qtNotSavedZeroTrade => _text('qt_not_saved_zero_trade');
  String get qtSavedToDb => _text('qt_saved_to_db');
  String get qtSaveFailedTitle => _text('qt_save_failed_title');

  // Validation report
  String get dataValidationReportTitle => _text('data_validation_report_title');

  // Quick run template messages
  String templateNotFound(String name, String keys, String total) =>
      _text('template_not_found')
          .replaceAll('{name}', name)
          .replaceAll('{keys}', keys)
          .replaceAll('{total}', total);
  String quickRunFailed(String name, String error) => _text('quick_run_failed')
      .replaceAll('{name}', name)
      .replaceAll('{error}', error);

  // Batch/export messages
  String get pleaseUploadMarketData => _text('please_upload_market_data');
  String get batchAlreadyRunning => _text('batch_already_running');
  String batchCompleteSaved(String completed, String total) =>
      _text('batch_complete_saved')
          .replaceAll('{completed}', completed)
          .replaceAll('{total}', total);
  String batchCompleteSavedSkipped(
          String completed, String total, String skipped) =>
      _text('batch_complete_saved_skipped')
          .replaceAll('{completed}', completed)
          .replaceAll('{total}', total)
          .replaceAll('{skipped}', skipped);
  String get noResultsToExport => _text('no_results_to_export');
  String get strategyResultsExported => _text('strategy_results_exported');
  String exportFailed(String error) =>
      _text('export_failed').replaceAll('{error}', error);
  String get tfStatsExported => _text('tf_stats_exported');
  String get tradesExported => _text('trades_exported');
  String get tradesCsvCopied => _text('trades_csv_copied');
  String get summaryCopied => _text('summary_copied');
  String get copyFailedGeneric => _text('copy_failed_generic');
  String get noTradesFoundOrCache => _text('no_trades_found_or_cache');
  String get noPerTfStatsFound => _text('no_per_tf_stats_found');

  // Delete/confirm dialogs
  String get deleteStrategyTitle => _text('delete_strategy_title');
  String deleteStrategyDesc(String name, String resultsCount) =>
      _text('delete_strategy_desc')
          .replaceAll('{name}', name)
          .replaceAll('{resultsCount}', resultsCount);
  String deleteStrategyDescNoResults(String name) =>
      _text('delete_strategy_desc_no_results').replaceAll('{name}', name);
  String get deleteTitle => _text('delete_title');
  String get cancelTitle => _text('cancel_title');
  String get deleteResultDesc => _text('delete_result_desc');
  String get strategyDuplicated => _text('strategy_duplicated');
  String get strategyDeleted => _text('strategy_deleted');
  String get resultDeleted => _text('result_deleted');
  String get maximumCompare => _text('maximum_compare');
  String get errorLoadingSelectedResults =>
      _text('error_loading_selected_results');
  String get workspaceExportFilteredResultsCsv =>
      _text('workspace_export_filtered_results_csv');
  String get workspaceFilterProfitOnly => _text('workspace_filter_profit_only');
  String get workspaceFilterPfPositive => _text('workspace_filter_pf_positive');
  String get workspaceFilterWinRate50 => _text('workspace_filter_win_rate_50');
  String get workspaceCompareExitTooltip =>
      _text('workspace_compare_exit_tooltip');
  String get workspaceCompareEnterTooltip =>
      _text('workspace_compare_enter_tooltip');
  String get workspaceEmptyNoStrategies =>
      _text('workspace_empty_no_strategies');
  String get workspaceEmptyNoStrategiesFound =>
      _text('workspace_empty_no_strategies_found');
  String get workspaceEmptyCreateFirstMessage =>
      _text('workspace_empty_create_first_message');
  String get workspaceRunBatch => _text('workspace_run_batch');
  String get duplicateLabel => _text('duplicate_label');
  String get workspaceCompareBannerText =>
      _text('workspace_compare_banner_text');

  String get filterStartDate => _text('filter_start_date');
  String get filterEndDate => _text('filter_end_date');
  String get filterStartLabel => _text('filter_start_label');
  String get filterEndLabel => _text('filter_end_label');

  String get copyTradesCsv => _text('copy_trades_csv');
  String get copySummary => _text('copy_summary');
  String get exportCsv => _text('export_csv');
  String get exportTsv => _text('export_tsv');
  String get exportAllTradesCsv => _text('export_all_trades_csv');
  String get exportTfStatsCsv => _text('export_tf_stats_csv');
  String get exportResultsCsv => _text('export_results_csv');
  String get copyStrategyLink => _text('copy_strategy_link');
  String get copyResultLink => _text('copy_result_link');
  String get commonExpand => _text('common_expand');
  String get commonCollapse => _text('common_collapse');
  String get commonAllSymbols => _text('common_all_symbols');

  String get metricTooltipTests => _text('metric_tooltip_tests');
  String get metricTooltipAvgPnl => _text('metric_tooltip_avg_pnl');
  String get metricTooltipWinRate => _text('metric_tooltip_win_rate');
  String get metricTooltipPnl => _text('metric_tooltip_pnl');
  String get metricTooltipPf => _text('metric_tooltip_pf');
  String get metricTooltipReturnPct => _text('metric_tooltip_return_pct');
  String get metricTooltipMaxDrawdown => _text('metric_tooltip_max_drawdown');
  String get metricTooltipSharpeRatio => _text('metric_tooltip_sharpe_ratio');
  String get metricTooltipAvgWin => _text('metric_tooltip_avg_win');
  String get metricTooltipAvgLoss => _text('metric_tooltip_avg_loss');
  String get metricTooltipLargestWin => _text('metric_tooltip_largest_win');
  String get metricTooltipLargestLoss => _text('metric_tooltip_largest_loss');
  String get metricTooltipExpectancy => _text('metric_tooltip_expectancy');
  String get metricTooltipTotalTrades => _text('metric_tooltip_total_trades');
  String get metricTooltipDefault => _text('metric_tooltip_default');

  String workspaceCompareCountLabel(int count) =>
      _text('workspace_compare_count_label').replaceAll('{count}', '$count');
  String workspaceCompareBannerSelectedSuffix(int selected) =>
      _text('workspace_compare_banner_selected_suffix')
          .replaceAll('{selected}', '$selected');

  // Added getters for newly introduced localization keys
  String get clearLabel => _text('clear_label');
  String get dialogGotIt => _text('dialog_got_it');
  String get errorRetry => _text('error_retry');
  String get errorDismiss => _text('error_dismiss');
  String workspaceBacktestResultsCount(int shown, int total) =>
      _text('workspace_backtest_results_count')
          .replaceAll('{shown}', '$shown')
          .replaceAll('{total}', '$total');

  String get relativeToday => _text('relative_today');
  String get relativeYesterday => _text('relative_yesterday');
  String relativeDaysAgo(int count) =>
      _text('relative_days_ago').replaceAll('{count}', '$count');
  String relativeWeeksAgo(int count) =>
      _text('relative_weeks_ago').replaceAll('{count}', '$count');
  String relativeMonthsAgo(int count) =>
      _text('relative_months_ago').replaceAll('{count}', '$count');

  String get backtestResultsTitle => _text('backtest_results_title');
  String get exportLabel => _text('export_label');
  String get exportPerTfStatsTooltip => _text('export_per_tf_stats_tooltip');
  String get exportTradeHistoryTooltip => _text('export_trade_history_tooltip');

  String get menuExportChartPng => _text('menu_export_chart_png');
  String get menuExportPanelPng => _text('menu_export_panel_png');
  // Comparison View getters
  String get compareViewTitle => _text('compare_view_title');
  String get compareExportCsvTooltip => _text('compare_export_csv_tooltip');
  String get compareCopySummaryTooltip => _text('compare_copy_summary_tooltip');
  String get compareMenuExport => _text('compare_menu_export');
  String get comparisonCsvExported => _text('comparison_csv_exported');
  String get comparisonCsvExportFailed => _text('comparison_csv_export_failed');
  String get bestPerformersHeader => _text('best_performers_header');
  String get bestHighestPnl => _text('best_highest_pnl');
  String get bestWinRate => _text('best_win_rate');
  String get bestProfitFactor => _text('best_profit_factor');
  String get bestLowestDrawdown => _text('best_lowest_drawdown');
  String get compareDetailedMetrics => _text('compare_detailed_metrics');
  String get compareMetricColumn => _text('compare_metric_column');
  String get compareTotalPnl => _text('compare_total_pnl');
  String get compareReturnPercent => _text('compare_return_percent');
  String get compareWinRate => _text('compare_win_rate');
  String get compareTotalTrades => _text('compare_total_trades');
  String get compareProfitFactor => _text('compare_profit_factor');
  String get compareMaxDrawdown => _text('compare_max_drawdown');
  String get compareSharpeRatio => _text('compare_sharpe_ratio');
  String get compareAvgWin => _text('compare_avg_win');
  String get compareAvgLoss => _text('compare_avg_loss');
  String get compareLargestWin => _text('compare_largest_win');
  String get compareLargestLoss => _text('compare_largest_loss');
  String get compareExpectancy => _text('compare_expectancy');
  String get perTfStatsHeader => _text('per_tf_stats_header');
  String get chartMetricLabel => _text('chart_metric_label');
  String get sortTfLabel => _text('sort_tf_label');
  String get sortValueUpLabel => _text('sort_value_up_label');
  String get sortValueDownLabel => _text('sort_value_down_label');
  String get aggAvgLabel => _text('agg_avg_label');
  String get aggMaxLabel => _text('agg_max_label');
  String get menuExportChartCsv => _text('menu_export_chart_csv');
  String get timeframeLabel => _text('timeframe_label');
  String get groupedChartSharePngText => _text('grouped_chart_share_png_text');
  String groupedChartPdfTitle(String metric) =>
      _text('grouped_chart_pdf_title').replaceAll('{metric}', metric);
  String get groupedChartCsvShareText => _text('grouped_chart_csv_share_text');
  String get emptyGroupedTitle => _text('empty_grouped_title');
  String get emptyGroupedTipFiltered => _text('empty_grouped_tip_filtered');
  String get emptyGroupedTipRun => _text('empty_grouped_tip_run');
  String resultIndexLabel(int index) =>
      _text('result_index_label').replaceAll('{index}', '$index');

  // SB stats chips (used in per‑TF chips)
  String get sbStatsExpectancy => _text('sb_stats_expectancy');
  String get sbStatsAvgWin => _text('sb_stats_avgwin');
  String get sbStatsAvgLoss => _text('sb_stats_avgloss');
  String get sbStatsRr => _text('sb_stats_rr');
  // Strategy Builder getters
  String get sbEditStrategyTitle => _text('sb_edit_strategy_title');
  String get sbCreateStrategyTitle => _text('sb_create_strategy_title');
  String get sbStrategyDetailsHeader => _text('sb_strategy_details_header');
  String get sbEntryRulesHeader => _text('sb_entry_rules_header');
  String get sbExitRulesHeader => _text('sb_exit_rules_header');
  String get sbNoEntryRulesYet => _text('sb_no_entry_rules_yet');
  String get sbNoExitRulesYet => _text('sb_no_exit_rules_yet');
  String get sbTapToAddRule => _text('sb_tap_to_add_rule');
  String get sbQuickBacktestPreviewHeader =>
      _text('sb_quick_backtest_preview_header');
  String get sbExitConfirmTitle => _text('sb_exit_confirm_title');
  String get sbExitConfirmContent => _text('sb_exit_confirm_content');
  String get sbDiscardAndExit => _text('sb_discard_and_exit');
  String get sbAutosaveSettingsHeader => _text('sb_autosave_settings_header');
  String get sbEnableAutosaveTitle => _text('sb_enable_autosave_title');
  String get sbAutosaveDescription => _text('sb_autosave_description');
  String get sbMenuTooltip => _text('sb_menu_tooltip');
  String get sbImportConfirmTitle => _text('sb_import_confirm_title');
  String get sbImportConfirmContent => _text('sb_import_confirm_content');
  String get sbOverwrite => _text('sb_overwrite');
  String get sbImportTemplateJsonTitle =>
      _text('sb_import_template_json_title');
  String get sbApply => _text('sb_apply');
  String get sbBuilderTips => _text('sb_builder_tips');
  String get sbExportJson => _text('sb_export_json');
  String get sbCopyJson => _text('sb_copy_json');
  String get sbSaveJson => _text('sb_save_json');
  String get sbImportFromFile => _text('sb_import_from_file');
  String get sbImportJsonEllipsis => _text('sb_import_json_ellipsis');
  String get sbSavedAtPrefix => _text('sb_saved_at_prefix');
  String get sbRetry => _text('sb_retry');
  String get sbDiscardAutosaveTooltip => _text('sb_discard_autosave_tooltip');
  String get sbDiscard => _text('sb_discard');
  String get sbDiscardDraft => _text('sb_discard_draft');
  String get sbStrategyNameLabel => _text('sb_strategy_name_label');
  String get sbStrategyNameHint => _text('sb_strategy_name_hint');
  String get sbInitialCapitalLabel => _text('sb_initial_capital_label');
  String get sbRiskTypeLabel => _text('sb_risk_type_label');
  String get sbRiskManagementTitle => _text('sb_risk_management_title');
  String get sbLotSizeLabel => _text('sb_lot_size_label');
  String get sbAtrMultipleLabel => _text('sb_atr_multiple_label');
  String get sbRiskPercentageLabel => _text('sb_risk_percentage_label');
  String get sbTakeProfitPoints => _text('sb_take_profit_points');
  String get sbSelectMarketData => _text('sb_select_market_data');
  String get sbResetPreview => _text('sb_reset_preview');
  String get sbViewFullResults => _text('sb_view_full_results');
  String get sbIndicatorLabel => _text('sb_indicator_label');
  String get sbMainPeriodLabel => _text('sb_main_period_label');
  String get sbMainPeriodHint => _text('sb_main_period_hint');
  String get sbTimeframeOptionalLabel => _text('sb_timeframe_optional_label');
  String get sbUseBaseTimeframe => _text('sb_use_base_timeframe');
  String get sbOperatorLabel => _text('sb_operator_label');
  String get sbNumberLabel => _text('sb_number_label');
  String get sbValueLabel => _text('sb_value_label');
  String get sbValueHint => _text('sb_value_hint');
  String get sbOperatorTooltipRising => _text('sb_operator_tooltip_rising');
  String get sbOperatorTooltipFalling => _text('sb_operator_tooltip_falling');
  String get sbOperatorTooltipCrossAbove =>
      _text('sb_operator_tooltip_cross_above');
  String get sbOperatorTooltipCrossBelow =>
      _text('sb_operator_tooltip_cross_below');
  String get sbOperatorTooltipDefault => _text('sb_operator_tooltip_default');
  // Strategy Builder — operator names
  String get sbOperatorNameGreaterThan =>
      _text('sb_operator_name_greater_than');
  String get sbOperatorNameLessThan => _text('sb_operator_name_less_than');
  String get sbOperatorNameGreaterOrEqual =>
      _text('sb_operator_name_greater_or_equal');
  String get sbOperatorNameLessOrEqual =>
      _text('sb_operator_name_less_or_equal');
  String get sbOperatorNameEquals => _text('sb_operator_name_equals');
  String get sbOperatorNameCrossAbove => _text('sb_operator_name_cross_above');
  String get sbOperatorNameCrossBelow => _text('sb_operator_name_cross_below');
  String get sbOperatorNameRising => _text('sb_operator_name_rising');
  String get sbOperatorNameFalling => _text('sb_operator_name_falling');
  String get sbCompareWithLabel => _text('sb_compare_with_label');
  String get sbPeriodLabel => _text('sb_period_label');
  String get sbAnchorModeLabel => _text('sb_anchor_mode_label');
  String get sbStartOfBacktest => _text('sb_start_of_backtest');
  String get sbAnchorByDate => _text('sb_anchor_by_date');
  String get sbAnchorDateLabel => _text('sb_anchor_date_label');
  String get sbAnchorDateHint => _text('sb_anchor_date_hint');
  String get sbOptionalTimeframeTooltip =>
      _text('sb_optional_timeframe_tooltip');
  String get sbCrossOperatorHelp => _text('sb_cross_operator_help');
  String get sbErrorMustBeGreaterThanZero => _text('sb_error_gt_zero');
  String get sbRequiredField => _text('sb_required_field');
  String get sbRequiredSelection => _text('sb_required_selection');
  String get sbInvalidDateFormat => _text('sb_invalid_date_format');
  // Strategy Builder — rule warnings/errors
  String sbWarningTfGreaterThanBase(String baseTf) =>
      _text('sb_warning_tf_greater_than_base').replaceAll('{base_tf}', baseTf);
  String get sbWarningRsiBetween20And80 =>
      _text('sb_warning_rsi_between_20_80');
  String get sbWarningOperatorEqualsNotSupported =>
      _text('sb_warning_operator_equals_not_supported');
  String get sbWarningBbandsSpecifyBand =>
      _text('sb_warning_bbands_specify_band');
  String get sbPeriodMustBeSetGtZero => _text('sb_period_must_be_set_gt0');
  String get sbErrorValueMustBeSet => _text('sb_error_value_must_be_set');
  String get sbErrorRsiBetween0And100 => _text('sb_error_rsi_between_0_100');
  String get sbErrorAdxBetween0And100 => _text('sb_error_adx_between_0_100');
  String get sbErrorPickComparisonIndicator =>
      _text('sb_error_pick_comparison_indicator');
  String sbRuleTitle(int index) =>
      _text('sb_rule_title').replaceAll('{index}', '$index');
  String get sbDynamicAtrPresets => _text('sb_dynamic_atr_presets');
  String get sbThenLogicLabel => _text('sb_then_logic_label');
  String get commonNone => _text('common_none');
  String get sbSearchTemplateHint => _text('sb_search_template_hint');
  String get sbShowAllCategories => _text('sb_show_all_categories');
  String get sbFilterPrefix => _text('sb_filter_prefix');
  String sbItemsAvailable(int count) =>
      _text('sb_items_available').replaceAll('{count}', '$count');
  String sbResultsCountLabel(int count) =>
      _text('sb_results_count_label').replaceAll('{count}', '$count');
  String get commonClear => _text('common_clear');
  String get sbApplyFilters => _text('sb_apply_filters');
  String get sbClearFilters => _text('sb_clear_filters');
  String get sbPickTemplateTooltip => _text('sb_pick_template_tooltip');
  String get sbRunPreviewTooltip => _text('sb_run_preview_tooltip');
  String get sbTestStrategyButtonTooltip =>
      _text('sb_test_strategy_button_tooltip');
  String get sbTestStrategyButtonIsRunningTooltip =>
      _text('sb_test_strategy_button_isrunning_tooltip');
  String get sbStatsSignals => _text('sb_stats_signals');
  String get sbStatsTrades => _text('sb_stats_trades');
  String get sbStatsWins => _text('sb_stats_wins');
  String get sbStatsWinRate => _text('sb_stats_winrate');
  String get menuExportChartPdf => _text('menu_export_chart_pdf');
  String get menuExportChartPanelPdf => _text('menu_export_chart_panel_pdf');
  String get menuExportPanelPdf => _text('menu_export_panel_pdf');
  String get menuExportBacktestPdf => _text('menu_export_backtest_pdf');

  // Strategy Builder — buttons and messages
  String get sbSaveStrategyButton => _text('sb_save_strategy_button');
  String get sbUpdateStrategyButton => _text('sb_update_strategy_button');
  String get sbStrategySaved => _text('sb_strategy_saved');
  String get sbStrategyUpdated => _text('sb_strategy_updated');
  String get sbErrorSummaryHeader => _text('sb_error_summary_header');
  String get sbFormResetReady => _text('sb_form_reset_ready');
  String get sbDialogPasteJson => _text('sb_dialog_paste_json');

  String get promptExportChartPng => _text('prompt_export_chart_png');
  String get promptExportPanelPng => _text('prompt_export_panel_png');
  String get promptExportChartPdf => _text('prompt_export_chart_pdf');
  String get promptExportPanelPdf => _text('prompt_export_panel_pdf');
  String get promptExportChartPanelPdf =>
      _text('prompt_export_chart_panel_pdf');

  String moreTrades(int count) =>
      _text('more_trades').replaceAll('{count}', '$count');

  // Pattern Scanner getters
  String get patternScannerTitle => _text('pattern_scanner_title');
  String get psSelectMarketData => _text('ps_select_market_data');
  String get psNoMarketData => _text('ps_no_market_data');
  String get psSelectMarketHint => _text('ps_select_market_hint');
  String get psFiltersHeader => _text('ps_filters_header');
  String get psFilterBullish => _text('ps_filter_bullish');
  String get psFilterBearish => _text('ps_filter_bearish');
  String get psFilterIndecision => _text('ps_filter_indecision');
  String get psEmptySelectMarket => _text('ps_empty_select_market');
  String get psEmptySelectHint => _text('ps_empty_select_hint');
  String get psNoPatternsFound => _text('ps_no_patterns_found');
  String get psTryAdjustFilters => _text('ps_try_adjust_filters');
  String get psCandleTime => _text('ps_candle_time');
  String get psCandleOpen => _text('ps_candle_open');
  String get psCandleClose => _text('ps_candle_close');
  String get psCandleHigh => _text('ps_candle_high');
  String get psCandleLow => _text('ps_candle_low');
  String get psCandleBody => _text('ps_candle_body');
  String get psSignalBullish => _text('ps_signal_bullish');
  String get psSignalBearish => _text('ps_signal_bearish');
  String get psSignalIndecision => _text('ps_signal_indecision');
  String get psStrengthWeak => _text('ps_strength_weak');
  String get psStrengthMedium => _text('ps_strength_medium');
  String get psStrengthStrong => _text('ps_strength_strong');
  String get psPatternsGuideTitle => _text('ps_patterns_guide_title');
  String get psPatternSpinningTop => _text('ps_pattern_spinning_top');
  String get psPatternStrongBullishCont =>
      _text('ps_pattern_strong_bullish_cont');
  String get psPatternStrongBearishCont =>
      _text('ps_pattern_strong_bearish_cont');
  String get psDescStrongCont => _text('ps_desc_strong_cont');
  String get psDescSpinningTop => _text('ps_desc_spinning_top');

  // Market Analysis getters
  String get marketAnalysisTitle => _text('market_analysis_title');
  String get maRefreshTooltip => _text('ma_refresh_tooltip');
  String get maChartSettingsTooltip => _text('ma_chart_settings_tooltip');
  String get maSelectMarketLabel => _text('ma_select_market_label');
  String get maNoMarketData => _text('ma_no_market_data');
  String get maSelectMarketHint => _text('ma_select_market_hint');
  String get maEmptySelectMarket => _text('ma_empty_select_market');
  String get maPriceStatistics => _text('ma_price_statistics');
  String get maTrendAnalysis => _text('ma_trend_analysis');
  String get maVolatility => _text('ma_volatility');
  String get maVolume => _text('ma_volume');
  String get maDataQuality => _text('ma_data_quality');
  String get maOverviewCurrentLabel => _text('ma_overview_current_label');
  String get maOverviewChangeLabel => _text('ma_overview_change_label');
  String get maTrendStrengthLabel => _text('ma_trend_strength_label');
  String get maTrendUptrend => _text('ma_trend_uptrend');
  String get maTrendDowntrend => _text('ma_trend_downtrend');
  String get maTrendSideways => _text('ma_trend_sideways');
  String get maStrengthUnknown => _text('ma_strength_unknown');
  String get maVolatilityHigh => _text('ma_volatility_high');
  String get maVolatilityMedium => _text('ma_volatility_medium');
  String get maVolatilityLow => _text('ma_volatility_low');
  String get maVolatilityUnknown => _text('ma_volatility_unknown');
  String get maPriceHighest => _text('ma_price_highest');
  String get maPriceLowest => _text('ma_price_lowest');
  String get maPriceAverage => _text('ma_price_average');
  String get maPriceRange => _text('ma_price_range');
  String get maVolatilityLevelLabel => _text('ma_volatility_level_label');
  String get maVolatilityAtrLabel => _text('ma_volatility_atr_label');
  String get maVolumeTotal => _text('ma_volume_total');
  String get maVolumeAverage => _text('ma_volume_average');
  String get maQualityValidData => _text('ma_quality_valid_data');
  String get maQualityCompleteNoGaps => _text('ma_quality_complete_no_gaps');
  String get maQualityCandles => _text('ma_quality_candles');
}

class _AppLocDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'id'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocDelegate old) => false;
}

// Bottom sheets and onboarding getters placed via extension
extension AppLocalizationsBottomSheets on AppLocalizations {
  // Notice
  String get noticePickOption => _text('notice_pick_option');

  // Indicator settings
  String get indicatorSettingsTitle => _text('indicator_settings_title');
  String get commonResetToDefault => _text('common_reset_to_default');
  String get commonApply => _text('common_apply');
  String get isOverlays => _text('is_overlays');
  String get isOscillators => _text('is_oscillators');
  String get isChartOptions => _text('is_chart_options');
  String get isSma => _text('is_sma');
  String get isEma => _text('is_ema');
  String get isBollingerBands => _text('is_bollinger_bands');
  String get isMacd => _text('is_macd');
  String get isSimpleMovingAverage => _text('is_simple_moving_average');
  String get isExponentialMovingAverage =>
      _text('is_exponential_moving_average');
  String get isVolatilityBands => _text('is_volatility_bands');
  String get isPeriod => _text('is_period');
  String get isStddev => _text('is_stddev');
  String get isFast => _text('is_fast');
  String get isSlow => _text('is_slow');
  String get isSignal => _text('is_signal');
  String get isHighQualityRendering => _text('is_high_quality_rendering');
  String get isHighQualitySubtitle => _text('is_high_quality_subtitle');
  String get isShowVolume => _text('is_show_volume');
  String get isShowVolumeSubtitle => _text('is_show_volume_subtitle');

  // Quick Start Templates
  String get quickOpenInBuilder => _text('quick_open_in_builder');

  // Onboarding
  String get onboardingImportData => _text('onboarding_import_data');
  String get onboardingQuickStartTemplates =>
      _text('onboarding_quick_start_templates');
  String get onboardingLearn => _text('onboarding_learn');
  String get onboardingDataTitle => _text('onboarding_data_title');
  String get onboardingCsvTips => _text('onboarding_csv_tips');
  String get onboardingViewCsvExample => _text('onboarding_view_csv_example');
  String get onboardingBack => _text('onboarding_back');
  String get onboardingNext => _text('onboarding_next');
  String get onboardingMarkDone => _text('onboarding_mark_done');
  String onboardingStepProgress(int current, int total) =>
      _text('onboarding_step_progress')
          .replaceAll('{current}', '$current')
          .replaceAll('{total}', '$total');
  String get onboardingRemindLater => _text('onboarding_remind_later');
  String get onboardingStep1Title => _text('onboarding_step1_title');
  String get onboardingStep1Desc => _text('onboarding_step1_desc');
  String get onboardingStep2Title => _text('onboarding_step2_title');
  String get onboardingStep2Desc => _text('onboarding_step2_desc');
  String get onboardingStep3Title => _text('onboarding_step3_title');
  String get onboardingStep3Desc => _text('onboarding_step3_desc');

  // Candlestick Pattern Guide
  String get cpGuideTitle => _text('cp_guide_title');
  String get cpHammerTitle => _text('cp_hammer_title');
  String get cpHammerDesc => _text('cp_hammer_desc');
  String get cpShootingStarTitle => _text('cp_shooting_star_title');
  String get cpShootingStarDesc => _text('cp_shooting_star_desc');
  String get cpDojiTitle => _text('cp_doji_title');
  String get cpDojiDesc => _text('cp_doji_desc');
  String get cpMarubozuTitle => _text('cp_marubozu_title');
  String get cpMarubozuDesc => _text('cp_marubozu_desc');

  // strategy template
  String get templateBreakoutBasicName => _text('template_breakout_basic_name');
  String get templateBreakoutBasicDesc => _text('template_breakout_basic_desc');
  String get templateBreakoutHhRangeAtrName =>
      _text('template_breakout_hh_range_atr_name');
  String get templateBreakoutHhRangeAtrDesc =>
      _text('template_breakout_hh_range_atr_desc');
  String get templateBreakoutHhRangeAtrPctName =>
      _text('template_breakout_hh_range_atr_pct_name');
  String get templateBreakoutHhRangeAtrPctDesc =>
      _text('template_breakout_hh_range_atr_pct_desc');
  String get templateMeanReversionRsiName =>
      _text('template_mean_reversion_rsi_name');
  String get templateMeanReversionRsiDesc =>
      _text('template_mean_reversion_rsi_desc');
  String get templateMacdSignalName => _text('template_macd_signal_name');
  String get templateMacdSignalDesc => _text('template_macd_signal_desc');
  String get templateTrendEmaCrossName =>
      _text('template_trend_ema_cross_name');
  String get templateTrendEmaCrossDesc =>
      _text('template_trend_ema_cross_desc');
  String get templateTrendEmaAdxFilterName =>
      _text('template_trend_ema_adx_filter_name');
  String get templateTrendEmaAdxFilterDesc =>
      _text('template_trend_ema_adx_filter_desc');
  String get templateTrendEmaAtrPctFilterName =>
      _text('template_trend_ema_atr_pct_filter_name');
  String get templateTrendEmaAtrPctFilterDesc =>
      _text('template_trend_ema_atr_pct_filter_desc');
  String get templateMomentumRsiMacdName =>
      _text('template_momentum_rsi_macd_name');
  String get templateMomentumRsiMacdDesc =>
      _text('template_momentum_rsi_macd_desc');
  String get templateMacdHistMomentumName =>
      _text('template_macd_hist_momentum_name');
  String get templateMacdHistMomentumDesc =>
      _text('template_macd_hist_momentum_desc');
  String get templateMeanReversionBbRsiName =>
      _text('template_mean_reversion_bb_rsi_name');
  String get templateMeanReversionBbRsiDesc =>
      _text('template_mean_reversion_bb_rsi_desc');
  String get templateEmaVsSmaCrossName =>
      _text('template_ema_vs_sma_cross_name');
  String get templateEmaVsSmaCrossDesc =>
      _text('template_ema_vs_sma_cross_desc');
  String get templateMacdHistRisingFilterName =>
      _text('template_macd_hist_rising_filter_name');
  String get templateMacdHistRisingFilterDesc =>
      _text('template_macd_hist_rising_filter_desc');
  String get templateRsiRising50FilterName =>
      _text('template_rsi_rising_50_filter_name');
  String get templateRsiRising50FilterDesc =>
      _text('template_rsi_rising_50_filter_desc');
  String get templateEmaRisingPriceFilterName =>
      _text('template_ema_rising_price_filter_name');
  String get templateEmaRisingPriceFilterDesc =>
      _text('template_ema_rising_price_filter_desc');
  String get templateEmaRibbonStackName =>
      _text('template_ema_ribbon_stack_name');
  String get templateEmaRibbonStackDesc =>
      _text('template_ema_ribbon_stack_desc');
  String get templateBbSqueezeBreakoutName =>
      _text('template_bb_squeeze_breakout_name');
  String get templateBbSqueezeBreakoutDesc =>
      _text('template_bb_squeeze_breakout_desc');
  String get templateRsiDivergenceApproxName =>
      _text('template_rsi_divergence_approx_name');
  String get templateRsiDivergenceApproxDesc =>
      _text('template_rsi_divergence_approx_desc');
  String get templateVwapPullbackBreakoutName =>
      _text('template_vwap_pullback_breakout_name');
  String get templateVwapPullbackBreakoutDesc =>
      _text('template_vwap_pullback_breakout_desc');
  String get templateAnchoredVwapPullbackCrossName =>
      _text('template_anchored_vwap_pullback_cross_name');
  String get templateAnchoredVwapPullbackCrossDesc =>
      _text('template_anchored_vwap_pullback_cross_desc');
  String get templateStochKdCrossAdxName =>
      _text('template_stoch_kd_cross_adx_name');
  String get templateStochKdCrossAdxDesc =>
      _text('template_stoch_kd_cross_adx_desc');
}
