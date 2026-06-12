package router

import (
	"github.com/abdelrzz9/math_app/mathverse-api/internal/config"
	"github.com/abdelrzz9/math_app/mathverse-api/internal/domain"
	"github.com/abdelrzz9/math_app/mathverse-api/internal/middleware"
	"github.com/abdelrzz9/math_app/mathverse-api/internal/pkg/mathclient"
	authHandler "github.com/abdelrzz9/math_app/mathverse-api/internal/module/auth/handler"
	authRepo "github.com/abdelrzz9/math_app/mathverse-api/internal/module/auth/repository"
	authUsecase "github.com/abdelrzz9/math_app/mathverse-api/internal/module/auth/usecase"
	calcHandler "github.com/abdelrzz9/math_app/mathverse-api/internal/module/calculator/handler"
	calcUsecase "github.com/abdelrzz9/math_app/mathverse-api/internal/module/calculator/usecase"
	derivHandler "github.com/abdelrzz9/math_app/mathverse-api/internal/module/derivatives/handler"
	derivUsecase "github.com/abdelrzz9/math_app/mathverse-api/internal/module/derivatives/usecase"
	graphHandler "github.com/abdelrzz9/math_app/mathverse-api/internal/module/graph/handler"
	graphUsecase "github.com/abdelrzz9/math_app/mathverse-api/internal/module/graph/usecase"
	historyHandler "github.com/abdelrzz9/math_app/mathverse-api/internal/module/history/handler"
	historyRepo "github.com/abdelrzz9/math_app/mathverse-api/internal/module/history/repository"
	historyUsecase "github.com/abdelrzz9/math_app/mathverse-api/internal/module/history/usecase"
	integralHandler "github.com/abdelrzz9/math_app/mathverse-api/internal/module/integrals/handler"
	integralUsecase "github.com/abdelrzz9/math_app/mathverse-api/internal/module/integrals/usecase"
	limitHandler "github.com/abdelrzz9/math_app/mathverse-api/internal/module/limits/handler"
	limitUsecase "github.com/abdelrzz9/math_app/mathverse-api/internal/module/limits/usecase"
	matrixHandler "github.com/abdelrzz9/math_app/mathverse-api/internal/module/matrix/handler"
	matrixUsecase "github.com/abdelrzz9/math_app/mathverse-api/internal/module/matrix/usecase"
	statHandler "github.com/abdelrzz9/math_app/mathverse-api/internal/module/statistics/handler"
	statUsecase "github.com/abdelrzz9/math_app/mathverse-api/internal/module/statistics/usecase"
	taylorHandler "github.com/abdelrzz9/math_app/mathverse-api/internal/module/taylor/handler"
	taylorUsecase "github.com/abdelrzz9/math_app/mathverse-api/internal/module/taylor/usecase"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/rs/zerolog"
)

type Dependencies struct {
	Config *config.AppConfig
	DBPool *pgxpool.Pool
	Logger zerolog.Logger
}

func SetupRouter(deps *Dependencies) *gin.Engine {
	r := gin.New()

	r.Use(middleware.RecoveryMiddleware(deps.Logger))
	r.Use(middleware.LoggingMiddleware(deps.Logger))
	r.Use(middleware.SecurityHeadersMiddleware())
	r.Use(middleware.RequestSizeLimitMiddleware(1 << 20))
	r.Use(middleware.CORSMiddleware(deps.Config.CORSAllowedOrigins))
	r.Use(middleware.NewRateLimiter(deps.Config.RateLimitRequestsPerMin).Middleware())
	r.Use(middleware.MetricsMiddleware())
	r.Use(middleware.AuthMiddleware(deps.Config.JWTSecret))

	r.GET("/health", func(c *gin.Context) {

	r.GET("/metrics", middleware.PrometheusHandler())
		checks := map[string]string{"api": "ok"}

		if deps.DBPool != nil {
			if err := deps.DBPool.Ping(c.Request.Context()); err != nil {
				checks["database"] = "unavailable"
			} else {
				checks["database"] = "ok"
			}
		}

		resp := domain.NewHealthResponse()
		resp.Checks = checks
		c.JSON(200, resp)
	})

	v1 := r.Group("/api/v1")

	mc := mathclient.New(deps.Config.MathEngineURL, deps.Config.EngineTimeout)

	if deps.DBPool != nil {
		authRepoImpl := authRepo.NewPostgresAuthRepository(deps.DBPool)
		authUc := authUsecase.NewAuthUsecase(authRepoImpl, deps.Config)
		authH := authHandler.NewAuthHandler(authUc)
		authGroup := v1.Group("/auth")
		{
			authGroup.POST("/register", authH.Register)
			authGroup.POST("/login", authH.Login)
			authGroup.POST("/refresh", authH.RefreshToken)
			authGroup.POST("/logout", authH.Logout)
			authGroup.GET("/profile", authH.Profile)
		}

		historyRepoImpl := historyRepo.NewPostgresHistoryRepository(deps.DBPool)
		historyUc := historyUsecase.NewHistoryUsecase(historyRepoImpl)
		historyH := historyHandler.NewHistoryHandler(historyUc)
		historyGroup := v1.Group("/history")
		{
			historyGroup.GET("", historyH.List)
			historyGroup.POST("", historyH.Add)
			historyGroup.DELETE("/clear", historyH.Clear)
			historyGroup.DELETE("/:id", historyH.Delete)
			historyGroup.POST("/:id/favorite", historyH.ToggleFavorite)
		}
	}

	calculatorUc := calcUsecase.NewCalculatorUsecase(mc)
	calculatorH := calcHandler.NewCalculatorHandler(calculatorUc)
	calcGroup := v1.Group("/calculator")
	{
		calcGroup.POST("/evaluate", calculatorH.Evaluate)
		calcGroup.POST("/validate", calculatorH.Validate)
	}

	derivUc := derivUsecase.NewDerivativeUsecase(mc)
	derivH := derivHandler.NewDerivativeHandler(derivUc)
	derivGroup := v1.Group("/derivatives")
	{
		derivGroup.POST("/differentiate", derivH.Differentiate)
	}

	integralUc := integralUsecase.NewIntegralUsecase(mc)
	integralH := integralHandler.NewIntegralHandler(integralUc)
	intGroup := v1.Group("/integrals")
	{
		intGroup.POST("/integrate", integralH.Integrate)
	}

	limitUc := limitUsecase.NewLimitUsecase(mc)
	limitH := limitHandler.NewLimitHandler(limitUc)
	limitGroup := v1.Group("/limits")
	{
		limitGroup.POST("/evaluate", limitH.Evaluate)
	}

	taylorUc := taylorUsecase.NewTaylorUsecase(mc)
	taylorH := taylorHandler.NewTaylorHandler(taylorUc)
	taylorGroup := v1.Group("/taylor")
	{
		taylorGroup.POST("/expand", taylorH.Expand)
	}

	matrixUc := matrixUsecase.NewMatrixUsecase(mc)
	matrixH := matrixHandler.NewMatrixHandler(matrixUc)
	matrixGroup := v1.Group("/matrix")
	{
		matrixGroup.POST("/add", matrixH.Add)
		matrixGroup.POST("/multiply", matrixH.Multiply)
		matrixGroup.POST("/determinant", matrixH.Determinant)
		matrixGroup.POST("/inverse", matrixH.Inverse)
		matrixGroup.POST("/transpose", matrixH.Transpose)
	}

	statUc := statUsecase.NewStatisticUsecase(mc)
	statH := statHandler.NewStatisticHandler(statUc)
	statGroup := v1.Group("/statistics")
	{
		statGroup.POST("/calculate", statH.Calculate)
	}

	graphUc := graphUsecase.NewGraphUsecase(mc)
	graphH := graphHandler.NewGraphHandler(graphUc)
	graphGroup := v1.Group("/graph")
	{
		graphGroup.POST("/plot", graphH.Plot)
	}

	return r
}
