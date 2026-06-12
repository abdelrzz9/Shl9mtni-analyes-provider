package router

import (
	"github.com/abdelrzz9/math_app/backend/internal/config"
	"github.com/abdelrzz9/math_app/backend/internal/domain"
	"github.com/abdelrzz9/math_app/backend/internal/middleware"
	calcHandler "github.com/abdelrzz9/math_app/backend/internal/module/calculator/handler"
	calcRepo "github.com/abdelrzz9/math_app/backend/internal/module/calculator/repository"
	calcUsecase "github.com/abdelrzz9/math_app/backend/internal/module/calculator/usecase"
	derivHandler "github.com/abdelrzz9/math_app/backend/internal/module/derivatives/handler"
	derivUsecase "github.com/abdelrzz9/math_app/backend/internal/module/derivatives/usecase"
	graphHandler "github.com/abdelrzz9/math_app/backend/internal/module/graph/handler"
	graphUsecase "github.com/abdelrzz9/math_app/backend/internal/module/graph/usecase"
	historyHandler "github.com/abdelrzz9/math_app/backend/internal/module/history/handler"
	historyRepo "github.com/abdelrzz9/math_app/backend/internal/module/history/repository"
	historyUsecase "github.com/abdelrzz9/math_app/backend/internal/module/history/usecase"
	integralHandler "github.com/abdelrzz9/math_app/backend/internal/module/integrals/handler"
	integralUsecase "github.com/abdelrzz9/math_app/backend/internal/module/integrals/usecase"
	limitHandler "github.com/abdelrzz9/math_app/backend/internal/module/limits/handler"
	limitUsecase "github.com/abdelrzz9/math_app/backend/internal/module/limits/usecase"
	matrixHandler "github.com/abdelrzz9/math_app/backend/internal/module/matrix/handler"
	matrixUsecase "github.com/abdelrzz9/math_app/backend/internal/module/matrix/usecase"
	statHandler "github.com/abdelrzz9/math_app/backend/internal/module/statistics/handler"
	statUsecase "github.com/abdelrzz9/math_app/backend/internal/module/statistics/usecase"
	taylorHandler "github.com/abdelrzz9/math_app/backend/internal/module/taylor/handler"
	taylorUsecase "github.com/abdelrzz9/math_app/backend/internal/module/taylor/usecase"
	"github.com/gin-gonic/gin"
)

func SetupRouter(cfg *config.AppConfig) *gin.Engine {
	r := gin.Default()

	r.Use(middleware.CORSMiddleware())
	r.Use(middleware.AuthMiddleware(cfg.JWTSecret))

	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, domain.NewHealthResponse())
	})

	v1 := r.Group("/api/v1")

	calculatorRepo := calcRepo.NewCalculatorService()
	calculatorUc := calcUsecase.NewCalculatorUsecase(calculatorRepo)
	calculatorH := calcHandler.NewCalculatorHandler(calculatorUc)
	calcGroup := v1.Group("/calculator")
	{
		calcGroup.POST("/evaluate", calculatorH.Evaluate)
		calcGroup.POST("/validate", calculatorH.Validate)
	}

	derivUc := derivUsecase.NewDerivativeUsecase(cfg.MathEngineURL)
	derivH := derivHandler.NewDerivativeHandler(derivUc)
	derivGroup := v1.Group("/derivatives")
	{
		derivGroup.POST("/differentiate", derivH.Differentiate)
	}

	integralUc := integralUsecase.NewIntegralUsecase(cfg.MathEngineURL)
	integralH := integralHandler.NewIntegralHandler(integralUc)
	intGroup := v1.Group("/integrals")
	{
		intGroup.POST("/integrate", integralH.Integrate)
	}

	limitUc := limitUsecase.NewLimitUsecase(cfg.MathEngineURL)
	limitH := limitHandler.NewLimitHandler(limitUc)
	limitGroup := v1.Group("/limits")
	{
		limitGroup.POST("/evaluate", limitH.Evaluate)
	}

	taylorUc := taylorUsecase.NewTaylorUsecase(cfg.MathEngineURL)
	taylorH := taylorHandler.NewTaylorHandler(taylorUc)
	taylorGroup := v1.Group("/taylor")
	{
		taylorGroup.POST("/expand", taylorH.Expand)
	}

	matrixUc := matrixUsecase.NewMatrixUsecase()
	matrixH := matrixHandler.NewMatrixHandler(matrixUc)
	matrixGroup := v1.Group("/matrix")
	{
		matrixGroup.POST("/add", matrixH.Add)
		matrixGroup.POST("/multiply", matrixH.Multiply)
		matrixGroup.POST("/determinant", matrixH.Determinant)
		matrixGroup.POST("/inverse", matrixH.Inverse)
		matrixGroup.POST("/transpose", matrixH.Transpose)
	}

	statUc := statUsecase.NewStatisticUsecase()
	statH := statHandler.NewStatisticHandler(statUc)
	statGroup := v1.Group("/statistics")
	{
		statGroup.POST("/calculate", statH.Calculate)
	}

	graphUc := graphUsecase.NewGraphUsecase()
	graphH := graphHandler.NewGraphHandler(graphUc)
	graphGroup := v1.Group("/graph")
	{
		graphGroup.POST("/plot", graphH.Plot)
	}

	historyRepoImpl := historyRepo.NewInMemoryHistoryRepo()
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

	return r
}
