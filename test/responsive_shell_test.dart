import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silenthelp/shared/widgets/responsive_shell.dart';

void main() {
  testWidgets('ResponsiveShell constrains content on large screens', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(1400, 900)),
        child: MaterialApp(
          home: ResponsiveShell(
            child: SizedBox(height: 100),
          ),
        ),
      ),
    );

    final responsiveShell = find.byType(ResponsiveShell);
    final constrainedBoxes = tester.widgetList<ConstrainedBox>(
      find.descendant(of: responsiveShell, matching: find.byType(ConstrainedBox)),
    );
    expect(constrainedBoxes, isNotEmpty);
    expect(constrainedBoxes.first.constraints.maxWidth, 800.0);
  });
}
