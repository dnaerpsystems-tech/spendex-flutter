import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ===========================================================================
// Widget Test Helper Extension
// ===========================================================================

/// Extension on WidgetTester for convenient app pumping
extension PumpApp on WidgetTester {
  /// Pump a widget wrapped in MaterialApp with ProviderScope
  ///
  /// [widget] - The widget to test
  /// [overrides] - Provider overrides for testing
  /// [theme] - Custom theme data (optional)
  /// [locale] - Custom locale (optional)
  Future<void> pumpApp(
    Widget widget, {
    List<Override>? overrides,
    ThemeData? theme,
    Locale? locale,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          theme: theme ?? _defaultTheme,
          locale: locale,
          home: widget,
        ),
      ),
    );
    await pump();
  }

  /// Pump a widget wrapped in MaterialApp without ProviderScope
  Future<void> pumpMaterialApp(
    Widget widget, {
    ThemeData? theme,
  }) async {
    await pumpWidget(
      MaterialApp(
        theme: theme ?? _defaultTheme,
        home: widget,
      ),
    );
    await pump();
  }

  /// Pump a widget inside a Scaffold
  Future<void> pumpScaffold(
    Widget widget, {
    List<Override>? overrides,
    ThemeData? theme,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          theme: theme ?? _defaultTheme,
          home: Scaffold(
            body: widget,
          ),
        ),
      ),
    );
    await pump();
  }

  /// Pump and settle with timeout
  Future<void> pumpAndSettleWithTimeout([Duration? duration]) async {
    await pumpAndSettle(duration ?? const Duration(seconds: 5));
  }

  /// Pump multiple frames
  Future<void> pumpFrames(int count) async {
    for (var i = 0; i < count; i++) {
      await pump(const Duration(milliseconds: 16));
    }
  }

  /// Find text and tap
  Future<void> tapText(String text) async {
    final finder = find.text(text);
    expect(finder, findsOneWidget);
    await tap(finder);
    await pump();
  }

  /// Find by key and tap
  Future<void> tapByKey(Key key) async {
    final finder = find.byKey(key);
    expect(finder, findsOneWidget);
    await tap(finder);
    await pump();
  }

  /// Enter text in a TextField found by key
  Future<void> enterTextByKey(Key key, String text) async {
    final finder = find.byKey(key);
    expect(finder, findsOneWidget);
    await enterText(finder, text);
    await pump();
  }

  /// Enter text in a TextField found by hint text
  Future<void> enterTextByHint(String hint, String text) async {
    final finder = find.widgetWithText(TextField, hint);
    expect(finder, findsOneWidget);
    await enterText(finder, text);
    await pump();
  }

  /// Scroll until widget is visible
  Future<void> scrollUntilVisible(
    Finder finder, {
    double delta = 100,
    int maxScrolls = 50,
  }) async {
    var scrollCount = 0;
    while (finder.evaluate().isEmpty && scrollCount < maxScrolls) {
      await drag(find.byType(Scrollable).first, Offset(0, -delta));
      await pump();
      scrollCount++;
    }
  }
}

// ===========================================================================
// Default Theme for Tests
// ===========================================================================

final ThemeData _defaultTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
);

// ===========================================================================
// Custom Finders
// ===========================================================================

/// Custom finder for finding widgets by semantic label
Finder findBySemanticLabel(String label) {
  return find.bySemanticsLabel(label);
}

/// Custom finder for finding widgets with specific text content
Finder findTextContaining(String text) {
  return find.byWidgetPredicate(
    (widget) {
      if (widget is Text) {
        return widget.data?.contains(text) ?? false;
      }
      return false;
    },
  );
}

/// Custom finder for finding buttons with specific text
Finder findButtonWithText(String text) {
  return find.widgetWithText(ElevatedButton, text);
}

/// Custom finder for finding TextFormField with specific label
Finder findTextFieldWithLabel(String label) {
  return find.byWidgetPredicate(
    (widget) {
      if (widget is TextField) {
        final decoration = widget.decoration;
        if (decoration is InputDecoration) {
          return decoration.labelText == label;
        }
      }
      return false;
    },
  );
}

// ===========================================================================
// Test Matchers
// ===========================================================================

/// Matcher for checking if a widget is visible
Matcher isVisible = findsOneWidget;

/// Matcher for checking if a widget is not visible
Matcher isNotVisible = findsNothing;

/// Matcher for checking if multiple widgets exist
Matcher findsMultiple(int count) => findsNWidgets(count);

// ===========================================================================
// Navigation Test Helpers
// ===========================================================================

/// Verify navigation to a specific route
Future<void> verifyNavigationTo(
  WidgetTester tester,
  Type pageType,
) async {
  await tester.pumpAndSettle();
  expect(find.byType(pageType), findsOneWidget);
}

/// Go back in navigation
Future<void> goBack(WidgetTester tester) async {
  final backButton = find.byTooltip('Back');
  if (backButton.evaluate().isNotEmpty) {
    await tester.tap(backButton);
    await tester.pumpAndSettle();
  }
}
