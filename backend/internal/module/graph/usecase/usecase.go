package usecase

import (
	"fmt"
	"math"
	"strconv"
	"strings"
	"text/scanner"
)

type GraphUsecase struct{}

func NewGraphUsecase() *GraphUsecase {
	return &GraphUsecase{}
}

type PlotRequest struct {
	Function string  `json:"function"`
	XMin     float64 `json:"xMin"`
	XMax     float64 `json:"xMax"`
	Step     float64 `json:"step"`
}

type Point struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}

type PlotResult struct {
	Function string  `json:"function"`
	XMin     float64 `json:"xMin"`
	XMax     float64 `json:"xMax"`
	Step     float64 `json:"step"`
	Points   []Point `json:"points"`
}

func (uc *GraphUsecase) Plot(function string, xMin, xMax, step float64) (*PlotResult, error) {
	if step <= 0 {
		step = 0.1
	}
	if xMin >= xMax {
		return nil, fmt.Errorf("xMin must be less than xMax")
	}

	var points []Point
	for x := xMin; x <= xMax; x += step {
		y, err := evalFunction(function, x)
		if err == nil && !math.IsNaN(y) && !math.IsInf(y, 0) {
			points = append(points, Point{X: roundTo(x, 4), Y: roundTo(y, 4)})
		}
	}

	return &PlotResult{
		Function: function,
		XMin:     xMin,
		XMax:     xMax,
		Step:     step,
		Points:   points,
	}, nil
}

func roundTo(f float64, decimals int) float64 {
	pow := math.Pow(10, float64(decimals))
	return math.Round(f*pow) / pow
}

type lexer struct {
	scanner.Scanner
	result float64
}

type tokenType int

const (
	tokNumber tokenType = iota
	tokIdent
	tokPlus
	tokMinus
	tokMul
	tokDiv
	tokPow
	tokLParen
	tokRParen
	tokComma
	tokEOF
)

type token struct {
	typ tokenType
	val string
	num float64
}

type funcEnv struct {
	vars map[string]float64
}

func evalFunction(expr string, x float64) (float64, error) {
	expr = strings.TrimSpace(expr)
	if expr == "" {
		return 0, fmt.Errorf("empty expression")
	}

	env := &funcEnv{vars: map[string]float64{"x": x, "pi": math.Pi, "e": math.E}}
	parser := newFuncParser(expr)
	result, err := parser.parseExpression(env)
	if err != nil {
		return 0, err
	}
	return result, nil
}

type funcParser struct {
	tokens []token
	pos    int
}

func newFuncParser(expr string) *funcParser {
	var toks []token
	var s scanner.Scanner
	s.Init(strings.NewReader(expr))
	s.Mode = scanner.ScanInts | scanner.ScanFloats | scanner.ScanIdents

	for {
		r := s.Scan()
		if r == scanner.EOF {
			toks = append(toks, token{typ: tokEOF})
			break
		}
		tokText := s.TokenText()
		switch r {
		case '+':
			toks = append(toks, token{typ: tokPlus, val: "+"})
		case '-':
			toks = append(toks, token{typ: tokMinus, val: "-"})
		case '*':
			toks = append(toks, token{typ: tokMul, val: "*"})
		case '/':
			toks = append(toks, token{typ: tokDiv, val: "/"})
		case '^':
			toks = append(toks, token{typ: tokPow, val: "^"})
		case '(':
			toks = append(toks, token{typ: tokLParen, val: "("})
		case ')':
			toks = append(toks, token{typ: tokRParen, val: ")"})
		case ',':
			toks = append(toks, token{typ: tokComma, val: ","})
		case scanner.Int, scanner.Float:
			num, _ := strconv.ParseFloat(tokText, 64)
			toks = append(toks, token{typ: tokNumber, val: tokText, num: num})
		case scanner.Ident:
			toks = append(toks, token{typ: tokIdent, val: tokText})
		}
	}

	return &funcParser{tokens: toks}
}

func (p *funcParser) peek() token {
	return p.tokens[p.pos]
}

func (p *funcParser) advance() token {
	tok := p.tokens[p.pos]
	p.pos++
	return tok
}

func (p *funcParser) parseExpression(env *funcEnv) (float64, error) {
	result, err := p.parseTerm(env)
	if err != nil {
		return 0, err
	}

	for {
		tok := p.peek()
		if tok.typ == tokPlus {
			p.advance()
			right, err := p.parseTerm(env)
			if err != nil {
				return 0, err
			}
			result += right
		} else if tok.typ == tokMinus {
			p.advance()
			right, err := p.parseTerm(env)
			if err != nil {
				return 0, err
			}
			result -= right
		} else {
			break
		}
	}
	return result, nil
}

func (p *funcParser) parseTerm(env *funcEnv) (float64, error) {
	result, err := p.parsePower(env)
	if err != nil {
		return 0, err
	}

	for {
		tok := p.peek()
		if tok.typ == tokMul {
			p.advance()
			right, err := p.parsePower(env)
			if err != nil {
				return 0, err
			}
			result *= right
		} else if tok.typ == tokDiv {
			p.advance()
			right, err := p.parsePower(env)
			if err != nil {
				return 0, err
			}
			if right == 0 {
				return 0, fmt.Errorf("division by zero")
			}
			result /= right
		} else {
			break
		}
	}
	return result, nil
}

func (p *funcParser) parsePower(env *funcEnv) (float64, error) {
	result, err := p.parseUnary(env)
	if err != nil {
		return 0, err
	}

	if p.peek().typ == tokPow {
		p.advance()
		right, err := p.parsePower(env)
		if err != nil {
			return 0, err
		}
		result = math.Pow(result, right)
	}
	return result, nil
}

func (p *funcParser) parseUnary(env *funcEnv) (float64, error) {
	if p.peek().typ == tokMinus {
		p.advance()
		result, err := p.parseAtom(env)
		if err != nil {
			return 0, err
		}
		return -result, nil
	}
	if p.peek().typ == tokPlus {
		p.advance()
	}
	return p.parseAtom(env)
}

func (p *funcParser) parseAtom(env *funcEnv) (float64, error) {
	tok := p.peek()

	if tok.typ == tokNumber {
		p.advance()
		return tok.num, nil
	}

	if tok.typ == tokIdent {
		p.advance()
		name := tok.val

		if p.peek().typ == tokLParen {
			p.advance()
			var args []float64
			for {
				arg, err := p.parseExpression(env)
				if err != nil {
					return 0, err
				}
				args = append(args, arg)
				if p.peek().typ == tokComma {
					p.advance()
				} else {
					break
				}
			}
			if p.peek().typ != tokRParen {
				return 0, fmt.Errorf("expected ')'")
			}
			p.advance()
			return callFunc(name, args)
		}

		if val, ok := env.vars[name]; ok {
			return val, nil
		}

		return 0, fmt.Errorf("undefined: %s", name)
	}

	if tok.typ == tokLParen {
		p.advance()
		result, err := p.parseExpression(env)
		if err != nil {
			return 0, err
		}
		if p.peek().typ != tokRParen {
			return 0, fmt.Errorf("expected ')'")
		}
		p.advance()
		return result, nil
	}

	return 0, fmt.Errorf("unexpected token: %s", tok.val)
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
