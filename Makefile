run-mobile:
	flutter run --dart-define-from-file=env/dev.json

run-web:
	flutter run --dart-define-from-file=env/dev.json -d chrome

gen:
	dart run build_runner watch

analyze:
	flutter analyze