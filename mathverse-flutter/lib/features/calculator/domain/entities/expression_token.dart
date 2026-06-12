import 'package:equatable/equatable.dart';

enum TokenType {
  number,
  plus,
  minus,
  multiply,
  divide,
  power,
  sqrt,
  sin,
  cos,
  tan,
  log,
  ln,
  factorial,
  parenthesisLeft,
  parenthesisRight,
  constant,
  variable,
  function,
}

class ExpressionToken extends Equatable {
  final TokenType type;
  final String value;

  const ExpressionToken({required this.type, required this.value});

  @override
  List<Object?> get props => [type, value];
}
