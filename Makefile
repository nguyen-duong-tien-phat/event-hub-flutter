run:
	flutter run --dart-define-from-file=env/dev.json

gen:
	dart run build_runner watch

gen-once:
	dart run build_runner build --delete-conflicting-outputs

analyze:
	flutter analyze

test:
	flutter test
