run:
	flutter run --dart-define-from-file=env/dev.json

gen:
	dart run build_runner watch

analyze:
	flutter analyze