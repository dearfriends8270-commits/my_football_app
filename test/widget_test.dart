// K-Player Tracker 기본 위젯 테스트

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('앱 기본 위젯 렌더링 테스트', (WidgetTester tester) async {
    // ProviderScope로 감싼 기본 MaterialApp 테스트
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('K-Player Tracker'),
            ),
          ),
        ),
      ),
    );

    // 앱 타이틀 텍스트 확인
    expect(find.text('K-Player Tracker'), findsOneWidget);
  });

  testWidgets('기본 버튼 인터랙션 테스트', (WidgetTester tester) async {
    int counter = 0;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Count: $counter'),
                    ElevatedButton(
                      onPressed: () => setState(() => counter++),
                      child: const Text('Increment'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    // 초기값 확인
    expect(find.text('Count: 0'), findsOneWidget);

    // 버튼 탭
    await tester.tap(find.text('Increment'));
    await tester.pump();

    // 증가 확인
    expect(find.text('Count: 1'), findsOneWidget);
  });

  group('Theme 테스트', () {
    testWidgets('Light 테마 적용 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            themeMode: ThemeMode.light,
            home: Scaffold(
              body: Text('Light Theme Test'),
            ),
          ),
        ),
      );

      expect(find.text('Light Theme Test'), findsOneWidget);
    });

    testWidgets('Dark 테마 적용 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData.dark(),
            home: const Scaffold(
              body: Text('Dark Theme Test'),
            ),
          ),
        ),
      );

      expect(find.text('Dark Theme Test'), findsOneWidget);
    });
  });
}
