import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mathverse_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mathverse_flutter/features/auth/presentation/pages/login_page.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    when(() => mockAuthCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthCubit.state).thenReturn(const AuthInitial());
    when(() => mockAuthCubit.close()).thenAnswer((_) async {});
  });

  Widget createTestWidget() {
    return BlocProvider<AuthCubit>.value(
      value: mockAuthCubit,
      child: const MaterialApp(home: LoginPage()),
    );
  }

  testWidgets('LoginPage renders all form fields', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('MathVerse'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
  });

  testWidgets('LoginPage shows validation errors on empty submit',
      (tester) async {
    await tester.pumpWidget(createTestWidget());

    final buttons = find.widgetWithText(ElevatedButton, 'Sign In');
    await tester.tap(buttons);
    await tester.pump();

    expect(find.text('email is required'), findsOneWidget);
    expect(find.text('password is required'), findsOneWidget);
  });

  testWidgets('LoginPage validates email format', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
    final buttons = find.widgetWithText(ElevatedButton, 'Sign In');
    await tester.tap(buttons);
    await tester.pump();

    expect(find.text('enter a valid email'), findsOneWidget);
  });

  testWidgets('LoginPage calls cubit on valid submit', (tester) async {
    when(() => mockAuthCubit.login(any(), any())).thenAnswer((_) async {});

    await tester.pumpWidget(createTestWidget());

    await tester.enterText(
        find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(
        find.byType(TextFormField).last, 'password123');
    final buttons = find.widgetWithText(ElevatedButton, 'Sign In');
    await tester.tap(buttons);
    await tester.pump();

    verify(() => mockAuthCubit.login('test@example.com', 'password123'))
        .called(1);
  });

  testWidgets('LoginPage shows loading indicator', (tester) async {
    when(() => mockAuthCubit.state).thenReturn(const AuthLoading());

    await tester.pumpWidget(createTestWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LoginPage disables button while loading', (tester) async {
    when(() => mockAuthCubit.state).thenReturn(const AuthLoading());

    await tester.pumpWidget(createTestWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('LoginPage shows error message', (tester) async {
    when(() => mockAuthCubit.state)
        .thenReturn(const AuthError('invalid credentials'));

    await tester.pumpWidget(createTestWidget());

    expect(find.text('invalid credentials'), findsOneWidget);
  });
}
