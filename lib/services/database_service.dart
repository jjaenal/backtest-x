import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/strategy.dart';
import '../models/trade.dart';

/// Service untuk interaksi dengan Supabase database
/// Handles CRUD operations untuk profiles, strategies, dan backtest results
class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // =====================================================
  // USER PROFILE OPERATIONS
  // =====================================================

  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final response =
          await _supabase.from('profiles').select().eq('id', user.id).single();

      return UserProfile.fromJson(response);
    } catch (e) {
      // Profile belum ada, return null
      return null;
    }
  }

  /// Create or update user profile
  Future<UserProfile> upsertUserProfile(UserProfile profile) async {
    final response = await _supabase
        .from('profiles')
        .upsert(profile.toJson())
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  /// Update user preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase
        .from('profiles')
        .update({'preferences': preferences}).eq('id', user.id);
  }

  // =====================================================
  // STRATEGY OPERATIONS
  // =====================================================

  /// Get user's strategies
  Future<List<Strategy>> getUserStrategies() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabase
        .from('strategies')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return response.map<Strategy>((json) => Strategy.fromJson(json)).toList();
  }

  /// Get public strategies (templates)
  Future<List<Strategy>> getPublicStrategies({int limit = 20}) async {
    final response = await _supabase
        .from('strategies')
        .select()
        .eq('is_public', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return response.map<Strategy>((json) => Strategy.fromJson(json)).toList();
  }

  /// Get strategy by ID (with access check)
  Future<Strategy?> getStrategy(String strategyId) async {
    try {
      final response = await _supabase
          .from('strategies')
          .select()
          .eq('id', strategyId)
          .single();

      return Strategy.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Create new strategy
  Future<Strategy> createStrategy(Strategy strategy) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check quota berdasarkan subscription tier
    final profile = await getCurrentUserProfile();
    if (profile != null) {
      final currentCount = await _getUserStrategyCount();
      final maxStrategies = profile.subscriptionTier.maxStrategies;

      if (maxStrategies > 0 && currentCount >= maxStrategies) {
        throw Exception(
            'Strategy limit reached for ${profile.subscriptionTier.name} tier');
      }
    }

    final strategyData = strategy.toJson();
    strategyData['user_id'] = user.id;

    final response = await _supabase
        .from('strategies')
        .insert(strategyData)
        .select()
        .single();

    return Strategy.fromJson(response);
  }

  /// Update strategy
  Future<Strategy> updateStrategy(Strategy strategy) async {
    final response = await _supabase
        .from('strategies')
        .update(strategy.toJson())
        .eq('id', strategy.id)
        .select()
        .single();

    return Strategy.fromJson(response);
  }

  /// Delete strategy
  Future<void> deleteStrategy(String strategyId) async {
    await _supabase.from('strategies').delete().eq('id', strategyId);
  }

  /// Get user's strategy count (untuk quota checking)
  Future<int> _getUserStrategyCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    final response = await _supabase.rpc('get_user_strategy_count');

    return response as int;
  }

  // =====================================================
  // BACKTEST RESULTS OPERATIONS
  // =====================================================

  /// Get backtest results for strategy
  Future<List<BacktestResult>> getStrategyBacktestResults(
    String strategyId, {
    int limit = 50,
  }) async {
    final response = await _supabase
        .from('backtest_results')
        .select()
        .eq('strategy_id', strategyId)
        .order('created_at', ascending: false)
        .limit(limit);

    return response
        .map<BacktestResult>((json) => BacktestResult.fromJson(json))
        .toList();
  }

  /// Get user's all backtest results
  Future<List<BacktestResult>> getUserBacktestResults({
    int limit = 100,
    String? symbol,
    String? timeframe,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    var query =
        _supabase.from('backtest_results').select().eq('user_id', user.id);

    if (symbol != null) {
      query = query.eq('symbol', symbol);
    }
    if (timeframe != null) {
      query = query.eq('timeframe', timeframe);
    }

    final response =
        await query.order('created_at', ascending: false).limit(limit);

    return response
        .map<BacktestResult>((json) => BacktestResult.fromJson(json))
        .toList();
  }

  /// Save backtest result
  Future<BacktestResult> saveBacktestResult(BacktestResult result) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check quota berdasarkan subscription tier
    final profile = await getCurrentUserProfile();
    if (profile != null) {
      final currentCount = await _getUserBacktestCount();
      final maxResults = profile.subscriptionTier.maxBacktestResults;

      if (maxResults > 0 && currentCount >= maxResults) {
        throw Exception(
            'Backtest result limit reached for ${profile.subscriptionTier.name} tier');
      }
    }

    final resultData = result.toJson();
    resultData['user_id'] = user.id;

    final response = await _supabase
        .from('backtest_results')
        .insert(resultData)
        .select()
        .single();

    return BacktestResult.fromJson(response);
  }

  /// Delete backtest result
  Future<void> deleteBacktestResult(String resultId) async {
    await _supabase.from('backtest_results').delete().eq('id', resultId);
  }

  /// Get user's backtest count (untuk quota checking)
  Future<int> _getUserBacktestCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    final response = await _supabase.rpc('get_user_backtest_count');

    return response as int;
  }

  // =====================================================
  // STRATEGY SHARING OPERATIONS (Opsional)
  // =====================================================

  /// Share strategy dengan user lain
  Future<void> shareStrategy({
    required String strategyId,
    required String shareWithEmail,
    required String shareType, // 'view', 'copy', 'collaborate'
    DateTime? expiresAt,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get target user ID by email
    final targetUserResponse = await _supabase
        .from('profiles')
        .select('id')
        .eq('email', shareWithEmail)
        .single();

    final targetUserId = targetUserResponse['id'];

    await _supabase.from('strategy_shares').insert({
      'strategy_id': strategyId,
      'shared_by': user.id,
      'shared_with': targetUserId,
      'share_type': shareType,
      'expires_at': expiresAt?.toIso8601String(),
    });
  }

  /// Get strategies shared with current user
  Future<List<Strategy>> getSharedStrategies() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await _supabase.from('strategies').select('''
          *,
          strategy_shares!inner(
            share_type,
            expires_at,
            shared_by
          )
        ''').eq('strategy_shares.shared_with', user.id);

    return response.map<Strategy>((json) => Strategy.fromJson(json)).toList();
  }
}
