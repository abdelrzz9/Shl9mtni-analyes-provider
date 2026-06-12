import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mathverse_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mathverse_flutter/features/auth/presentation/pages/register_page.dart';
import 'package:mocktail/mocktail.dart';

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
      child: const MaterialApp(home: RegisterPage()),
    );
  }

  testWidgets('RegisterPage renders all form fields', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text('Display Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Already have an account? Sign In'), findsOneWidget);
  });

  testWidgets('RegisterPage shows validation errors on empty submit',
      (tester) async {
    await tester.pumpWidget(createTestWidget());

    final buttons = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.tap(buttons);
    await tester.pump();

    expect(find.text('name is required'), findsOneWidget);
    expect(find.text('email is required'), findsOneWidget);
    expect(find.text('password is required'), findsOneWidget);
  });

  testWidgets('RegisterPage validates name length', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.enterText(
        find.byType(TextFormField).first, 'A');
    final buttons = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.tap(buttons);
    await tester.pump();

    expect(find.text('name must be at least 2 characters'), findsOneWidget);
  });

  testWidgets('RegisterPage validates email format', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.enterText(
        find.byType(TextFormField).at(0), 'Valid Name');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'invalid-email');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(
        find.byType(TextFormField).at(3), 'password123');
    final buttons = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.tap(buttons);
    await tester.pump();

    expect(find.text('enter a valid email'), findsOneWidget);
  });

  testWidgets('RegisterPage validates password length', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.enterText(
        find.byType(TextFormField).at(0), 'Valid Name');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'test@example.com');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'short');
    await tester.enterText(
        find.byType(TextFormField).at(3), 'short');
    final buttons = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.tap(buttons);
    await tester.pump();

    expect(find.text('password must be at least 8 characters'), findsOneWidget);
  });

  testWidgets('RegisterPage validates password match', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.enterText(
        find.byType(TextFormField).at(0), 'Valid Name');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'test@example.com');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(
        find.byType(TextFormField).at(3), 'different');
    final buttons = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.tap(buttons);
    await tester.pump();

    expect(find.text('passwords do not match'), findsOneWidget);
  });

  testWidgets('RegisterPage calls cubit on valid submit', (tester) async {
    when(() => mockAuthCubit.register(any(), any(), any()))
        .thenAnswer((_) async {});

    await tester.pumpWidget(createTestWidget());

    await tester.enterText(
        find.byType(TextFormField).at(0), 'Test User');
    await tester.enterText(
        find.byType(TextFormField).at(1), 'test@example.com');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(
        find.byType(TextFormField).at(3), 'password123');
    final buttons = find.widgetWithText(ElevatedButton, 'Create Account');
    await tester.tap(buttons);
    await tester.pump();

    verify(() =>
            mockAuthCubit.register('test@example.com', 'password123', 'Test User'))
        .called(1);
  });

  testWidgets('RegisterPage shows loading indicator', (tester) async {
    when(() => mockAuthCubit.state).thenReturn(const AuthLoading());

    await tester.pumpWidget(createTestWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('RegisterPage disables button while loading', (tester) async {
    when(() => mockAuthCubit.state).thenReturn(const AuthLoading());

    await tester.pumpWidget(createTestWidget());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('RegisterPage shows error message', (tester) async {
    when(() => mockAuthCubit.state)
        .thenReturn(const AuthError('email already registered'));

    await tester.pumpWidget(createTestWidget());

    expect(find.text('email already registered'), findsOneWidget);
  });
}
