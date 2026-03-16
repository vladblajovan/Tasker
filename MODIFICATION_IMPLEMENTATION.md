# Modification Implementation: Renaming App to Tasker

## Guidelines
After completing a task, if you added any TODOs to the code or didn't fully implement anything, make sure to add new tasks so that you can come back and complete them later.

## Journal
*   [2026-03-16]: Plan created.

---

## Phase 1: Pre-checks and Flutter Level Renaming
- [ ] Run all tests to ensure the project is in a good state before starting modifications.
- [ ] Update `pubspec.yaml` to change `name: test_app` to `name: tasker`.
- [ ] Run a search and replace across the `lib/` and `test/` directories to change `package:test_app/` to `package:tasker/`.
- [ ] Create/modify unit tests for testing the code added or modified in this phase, if relevant.
- [ ] Run the `dart fix --apply` tool to clean up the code.
- [ ] Run the `flutter analyze` tool one more time and fix any issues.
- [ ] Run any tests to make sure they all pass.
- [ ] Run `dart format .` to make sure that the formatting is correct.
- [ ] Re-read the MODIFICATION_IMPLEMENTATION.md file to see what, if anything, has changed in the implementation plan, and if it has changed, take care of anything the changes imply.
- [ ] Update the MODIFICATION_IMPLEMENTATION.md file with the current state, including any learnings, surprises, or deviations in the Journal section. Check off any checkboxes of items that have been completed.
- [ ] Use `git diff` to verify the changes that have been made, and create a suitable commit message for any changes, following any guidelines you have about commit messages. Be sure to properly escape dollar signs and backticks, and present the change message to the user for approval.
- [ ] Wait for approval. Don't commit the changes or move on to the next phase of implementation until the user approves the commit.
- [ ] After commiting the change, if an app is running, use the hot_reload tool to reload it.

## Phase 2: Android Level Renaming
- [ ] Update `android/app/build.gradle.kts`: change `namespace` and `applicationId` to `com.example.tasker`.
- [ ] Update `android/app/src/main/AndroidManifest.xml`: change `android:label` to `Tasker`.
- [ ] Move `MainActivity.kt` from `android/app/src/main/kotlin/com/example/test_app/` to `android/app/src/main/kotlin/com/example/tasker/`.
- [ ] Update `package` declaration in `MainActivity.kt` to `package com.example.tasker`.
- [ ] Create/modify unit tests for testing the code added or modified in this phase, if relevant.
- [ ] Run the `dart fix --apply` tool to clean up the code.
- [ ] Run the `flutter analyze` tool one more time and fix any issues.
- [ ] Run any tests to make sure they all pass.
- [ ] Run `dart format .` to make sure that the formatting is correct.
- [ ] Re-read the MODIFICATION_IMPLEMENTATION.md file to see what, if anything, has changed in the implementation plan, and if it has changed, take care of anything the changes imply.
- [ ] Update the MODIFICATION_IMPLEMENTATION.md file with the current state, including any learnings, surprises, or deviations in the Journal section. Check off any checkboxes of items that have been completed.
- [ ] Use `git diff` to verify the changes that have been made, and create a suitable commit message for any changes, following any guidelines you have about commit messages. Be sure to properly escape dollar signs and backticks, and present the change message to the user for approval.
- [ ] Wait for approval. Don't commit the changes or move on to the next phase of implementation until the user approves the commit.
- [ ] After commiting the change, if an app is running, use the hot_reload tool to reload it.

## Phase 3: iOS & Web Level Renaming
- [ ] Update `ios/Runner.xcodeproj/project.pbxproj`: replace `com.example.testApp` with `com.example.tasker`.
- [ ] Update `ios/Runner/Info.plist`: change `CFBundleName` to `Tasker` and `CFBundleDisplayName` to `Tasker`.
- [ ] Update `web/index.html`: change `<title>` content to `Tasker`.
- [ ] Update `web/manifest.json`: change `name` and `short_name` to `Tasker`.
- [ ] Create/modify unit tests for testing the code added or modified in this phase, if relevant.
- [ ] Run the `dart fix --apply` tool to clean up the code.
- [ ] Run the `flutter analyze` tool one more time and fix any issues.
- [ ] Run any tests to make sure they all pass.
- [ ] Run `dart format .` to make sure that the formatting is correct.
- [ ] Re-read the MODIFICATION_IMPLEMENTATION.md file to see what, if anything, has changed in the implementation plan, and if it has changed, take care of anything the changes imply.
- [ ] Update the MODIFICATION_IMPLEMENTATION.md file with the current state, including any learnings, surprises, or deviations in the Journal section. Check off any checkboxes of items that have been completed.
- [ ] Use `git diff` to verify the changes that have been made, and create a suitable commit message for any changes, following any guidelines you have about commit messages. Be sure to properly escape dollar signs and backticks, and present the change message to the user for approval.
- [ ] Wait for approval. Don't commit the changes or move on to the next phase of implementation until the user approves the commit.
- [ ] After commiting the change, if an app is running, use the hot_reload tool to reload it.

## Phase 4: Final Cleanup and Root Renaming
- [ ] Run `flutter clean` and `flutter pub get` to clear out caches.
- [ ] Ensure the app builds successfully (e.g., using `flutter build apk` or running tests).
- [ ] Update any `README.md` file for the package with relevant information from the modification (if any).
- [ ] Update any `GEMINI.md` file in the project directory so that it still correctly describes the app, its purpose, and implementation details and the layout of the files.
- [ ] Ask the user to inspect the package (and running app, if any) and say if they are satisfied with it, or if any modifications are needed.
- [ ] Rename the root workspace folder from `test_app` to `Tasker`. *(Note: This step may require the user to re-open their editor/workspace after execution).*
