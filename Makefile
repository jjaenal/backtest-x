clean:
	flutter clean

get:
	flutter pub get

stack:
	stacked generate

# Run all golden tests with GOLDEN_TEST mode (bypass disk I/O)
goldens:
	flutter test test/golden --reporter=expanded --dart-define=GOLDEN_TEST=true

# Update golden baselines for all golden tests
goldens-update:
	flutter test test/golden --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true

# --- Per-file HomeView golden helpers ---
# Run
# Run all HomeView golden scenarios sequentially
goldens-home:
	flutter test test/golden/home_view_golden_test.dart --reporter=expanded --dart-define=GOLDEN_TEST=true && \
	flutter test test/golden/home_view_empty_golden_test.dart --reporter=expanded --dart-define=GOLDEN_TEST=true && \
	flutter test test/golden/home_view_populated_golden_test.dart --reporter=expanded --dart-define=GOLDEN_TEST=true && \
	flutter test test/golden/home_view_populated_warmup_golden_test.dart --reporter=expanded --dart-define=GOLDEN_TEST=true && \
	flutter test test/golden/home_view_populated_postwarmup_golden_test.dart --reporter=expanded --dart-define=GOLDEN_TEST=true && \
	flutter test test/golden/home_view_warmup_golden_test.dart --reporter=expanded --dart-define=GOLDEN_TEST=true

golden-home-default:
	flutter test test/golden/home_view_golden_test.dart --reporter=expanded --dart-define=GOLDEN_TEST=true

golden-home-empty:
	flutter test test/golden/home_view_empty_golden_test.dart --reporter=expanded --dart-define=GOLDEN_TEST=true

golden-home-populated:
	flutter test test/golden/home_view_populated_golden_test.dart --reporter=expanded --dart-define=GOLDEN_TEST=true

golden-home-populated-warmup:
	flutter test test/golden/home_view_populated_warmup_golden_test.dart --reporter=expanded --dart-define=GOLDEN_TEST=true

golden-home-populated-postwarmup:
	flutter test test/golden/home_view_populated_postwarmup_golden_test.dart --reporter=expanded --dart-define=GOLDEN_TEST=true

golden-home-warmup:
	flutter test test/golden/home_view_warmup_golden_test.dart --reporter=expanded --dart-define=GOLDEN_TEST=true

# Update
# Update baselines for all HomeView golden scenarios sequentially
goldens-update-home:
	flutter test test/golden/home_view_golden_test.dart --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true && \
	flutter test test/golden/home_view_empty_golden_test.dart --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true && \
	flutter test test/golden/home_view_populated_golden_test.dart --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true && \
	flutter test test/golden/home_view_populated_warmup_golden_test.dart --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true && \
	flutter test test/golden/home_view_populated_postwarmup_golden_test.dart --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true && \
	flutter test test/golden/home_view_warmup_golden_test.dart --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true

golden-update-home-default:
	flutter test test/golden/home_view_golden_test.dart --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true

golden-update-home-empty:
	flutter test test/golden/home_view_empty_golden_test.dart --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true

golden-update-home-populated:
	flutter test test/golden/home_view_populated_golden_test.dart --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true

golden-update-home-populated-warmup:
	flutter test test/golden/home_view_populated_warmup_golden_test.dart --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true

golden-update-home-populated-postwarmup:
	flutter test test/golden/home_view_populated_postwarmup_golden_test.dart --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true

golden-update-home-warmup:
	flutter test test/golden/home_view_warmup_golden_test.dart --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true


# Filter by test name (run)
goldens-name:
	@if [ -z "$(NAME)" ]; then echo "NAME is required. Usage: make goldens-name NAME=\"pattern\""; exit 1; fi
	flutter test test/golden --reporter=expanded --dart-define=GOLDEN_TEST=true --name="$(NAME)"

# Filter by test name (update baselines)
goldens-update-name:
	@if [ -z "$(NAME)" ]; then echo "NAME is required. Usage: make goldens-update-name NAME=\"pattern\""; exit 1; fi
	flutter test test/golden --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true --name="$(NAME)"

# Filter by file path (run)
goldens-file:
	@if [ -z "$(FILE)" ]; then echo "FILE is required. Usage: make goldens-file FILE=test/golden/<file>.dart"; exit 1; fi
	flutter test $(FILE) --reporter=expanded --dart-define=GOLDEN_TEST=true

# Filter by file path (update baselines)
goldens-update-file:
	@if [ -z "$(FILE)" ]; then echo "FILE is required. Usage: make goldens-update-file FILE=test/golden/<file>.dart"; exit 1; fi
	flutter test $(FILE) --update-goldens --reporter=expanded --dart-define=GOLDEN_TEST=true

# Run web with dart-define for Supabase (dev convenience)
run-web:
	@if [ -z "$(URL)" ] || [ -z "$(KEY)" ]; then echo "URL and KEY are required. Usage: make run-web URL=<supabase_url> KEY=<anon_key>"; exit 1; fi
	flutter run -d web-server --web-hostname localhost --web-port 8081 --dart-define SUPABASE_URL=$(URL) --dart-define SUPABASE_ANON_KEY=$(KEY)

run-chrome:
	@if [ -z "$(URL)" ] || [ -z "$(KEY)" ]; then echo "URL and KEY are required. Usage: make run-chrome URL=<supabase_url> KEY=<anon_key>"; exit 1; fi
	flutter run -d chrome --web-port 8081 --dart-define SUPABASE_URL=$(URL) --dart-define SUPABASE_ANON_KEY=$(KEY)