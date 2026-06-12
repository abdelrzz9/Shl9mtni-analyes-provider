package repository

import (
	"fmt"
	"go/ast"
	"go/parser"
	"go/token"
	"math"
	"strconv"
	"strings"
)

func evaluateExpression(expr string) (float64, string, error) {
	result, err := eval(expr)
	if err != nil {
		return 0, "", fmt.Errorf("evaluation error: %w", err)
	}
	latex := toLatex(expr, result)
	return result, latex, nil
}

func validateExpression(expr string) bool {
	_, err := parser.ParseExpr(expr)
	if err != nil {
		return false
	}
	return true
}

type env map[string]float64

func eval(expr string) (float64, error) {
	node, err := parser.ParseExpr(expr)
	if err != nil {
		return 0, err
	}
	return evalNode(node, env{
		"pi": math.Pi,
		"e":  math.E,
	})
}

func evalNode(node ast.Node, vars env) (float64, error) {
	switch n := node.(type) {
	case *ast.Ident:
		if v, ok := vars[n.Name]; ok {
			return v, nil
		}
		return 0, fmt.Errorf("undefined variable: %s", n.Name)

	case *ast.BasicLit:
		return strconv.ParseFloat(n.Value, 64)

	case *ast.ParenExpr:
		return evalNode(n.X, vars)

	case *ast.UnaryExpr:
		val, err := evalNode(n.X, vars)
		if err != nil {
			return 0, err
		}
		switch n.Op {
		case token.SUB:
			return -val, nil
		case token.ADD:
			return val, nil
		default:
			return 0, fmt.Errorf("unknown unary operator: %v", n.Op)
		}

	case *ast.BinaryExpr:
		left, err := evalNode(n.X, vars)
		if err != nil {
			return 0, err
		}
		right, err := evalNode(n.Y, vars)
		if err != nil {
			return 0, err
		}
		switch n.Op {
		case token.ADD:
			return left + right, nil
		case token.SUB:
			return left - right, nil
		case token.MUL:
			return left * right, nil
		case token.QUO:
			if right == 0 {
				return 0, fmt.Errorf("division by zero")
			}
			return left / right, nil
		case token.REM:
			return float64(int64(left) % int64(right)), nil
		case token.XOR:
			return math.Pow(left, right), nil
		default:
			return 0, fmt.Errorf("unknown binary operator: %v", n.Op)
		}

	case *ast.CallExpr:
		fn, ok := n.Fun.(*ast.Ident)
		if !ok {
			return 0, fmt.Errorf("invalid function call")
		}
		args := make([]float64, len(n.Args))
		for i, arg := range n.Args {
			v, err := evalNode(arg, vars)
			if err != nil {
				return 0, err
			}
			args[i] = v
		}
		return callFunc(fn.Name, args)

	default:
		return 0, fmt.Errorf("unsupported expression node: %T", node)
	}
}

func callFunc(name string, args []float64) (float64, error) {
	switch strings.ToLower(name) {
	case "sin":
		if len(args) != 1 {
			return 0, fmt.Errorf("sin expects 1 argument")
		}
		return math.Sin(args[0]), nil
	case "cos":
		if len(args) != 1 {
			return 0, fmt.Errorf("cos expects 1 argument")
		}
		return math.Cos(args[0]), nil
	case "tan":
		if len(args) != 1 {
			return 0, fmt.Errorf("tan expects 1 argument")
		}
		return math.Tan(args[0]), nil
	case "sqrt":
		if len(args) != 1 {
			return 0, fmt.Errorf("sqrt expects 1 argument")
		}
		return math.Sqrt(args[0]), nil
	case "log":
		if len(args) != 1 {
			return 0, fmt.Errorf("log expects 1 argument")
		}
		return math.Log(args[0]), nil
	case "log10":
		if len(args) != 1 {
			return 0, fmt.Errorf("log10 expects 1 argument")
		}
		return math.Log10(args[0]), nil
	case "abs":
		if len(args) != 1 {
			return 0, fmt.Errorf("abs expects 1 argument")
		}
		return math.Abs(args[0]), nil
	case "pow":
		if len(args) != 2 {
			return 0, fmt.Errorf("pow expects 2 arguments")
		}
		return math.Pow(args[0], args[1]), nil
	case "exp":
		if len(args) != 1 {
			return 0, fmt.Errorf("exp expects 1 argument")
		}
		return math.Exp(args[0]), nil
	case "floor":
		if len(args) != 1 {
			return 0, fmt.Errorf("floor expects 1 argument")
		}
		return math.Floor(args[0]), nil
	case "ceil":
		if len(args) != 1 {
			return 0, fmt.Errorf("ceil expects 1 argument")
		}
		return math.Ceil(args[0]), nil
	default:
		return 0, fmt.Errorf("unknown function: %s", name)
	}
}

func toLatex(expr string, result float64) string {
	latex := expr
	latex = strings.ReplaceAll(latex, "*", "\\cdot ")
	latex = strings.ReplaceAll(latex, "/", "\\frac{}{}")
	if strings.Contains(latex, "\\frac{}{}") {
		parts := strings.Split(latex, "\\frac{}{}")
		if len(parts) == 2 {
			latex = "\\frac{" + parts[0] + "}{" + parts[1] + "}"
		}
	}
	return fmt.Sprintf("%s = %g", latex, result)
}
