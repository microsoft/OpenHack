package main

import (
	"flag"
	"fmt"
	"net/url"
	"os"
	"strings"

	"github.com/golang/glog"
	prometheusMiddleware "github.com/iris-contrib/middleware/prometheus"
	"github.com/kataras/iris/v12"
	"github.com/prometheus/client_golang/prometheus/promhttp"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
)

func newApp(simulator Simulator, prom *prometheusMiddleware.Prometheus) *iris.Application {
	app := iris.Default()
	app.RegisterView(iris.HTML("./views", ".html").Reload(true))

	app.Use(prom.ServeHTTP)
	app.Get("/metrics", iris.FromStd(promhttp.Handler()))

	app.Get("/", func(ctx iris.Context) {
		if err := ctx.View("index.html"); err != nil {
			ctx.StatusCode(iris.StatusInternalServerError)
			ctx.WriteString(err.Error())
		}
	})

	app.Post("/start", func(ctx iris.Context) {
		simconfig := SimConfig{}
		err := ctx.ReadForm(&simconfig)
		if err != nil && !iris.IsErrPath(err) /* see: https://github.com/kataras/iris/issues/1157 */ {
			ctx.StatusCode(iris.StatusInternalServerError)
			ctx.ViewData("message", fmt.Sprintf(err.Error()))
			ctx.View("index.html")
			return
		}

		if simconfig.Rps > 1000 {
			ctx.StatusCode(iris.StatusBadRequest)
			ctx.ViewData("message", fmt.Sprintf("Rps must be under 1000"))
			ctx.View("index.html")
			return
		}

		if simconfig.Homepage == "" && simconfig.Trips == "" {
			ctx.StatusCode(iris.StatusBadRequest)
			ctx.ViewData("message", fmt.Sprintf("Please select atleast one endpont (homepage or trips)"))
			ctx.View("index.html")
			return
		}

		if simconfig.Homepage != "" && simconfig.Homepage != "homepage" {
			ctx.StatusCode(iris.StatusBadRequest)
			ctx.ViewData("message", fmt.Sprintf("Invalid data"))
			ctx.View("index.html")
			return
		}

		if simconfig.Trips != "" && simconfig.Trips != "trips" {
			ctx.StatusCode(iris.StatusBadRequest)
			ctx.ViewData("message", fmt.Sprintf("Invalid data"))
			ctx.View("index.html")
			return
		}

		simconfig.Baseurl = strings.TrimSuffix(simconfig.Baseurl, "/")
		_, err = url.ParseRequestURI(simconfig.Baseurl)
		if err != nil {
			ctx.StatusCode(iris.StatusBadRequest)
			ctx.ViewData("message", fmt.Sprintf("Please pass a valid url"))
			ctx.View("index.html")
			return
		}

		// Start the simulator
		if !simulator.IsRunning() {
			glog.V(0).Infof("Starting simulator: %v\n", simconfig)

			sims := genSims(simconfig, simulator.RandomUser, simulator.RandomTrip)

			simulator.StartSimulator(simconfig, sims)

			ctx.ViewData("message", fmt.Sprintf("Started for %#v with RPS of %#v", simconfig.Baseurl, simconfig.Rps))
			ctx.View("index.html")
			return
		}

		// if here then simulator was running.
		ctx.ViewData("message", fmt.Sprintf("Simulator was already running. Please stop first."))
		ctx.View("index.html")
		return
	})

	app.Post("/stop", func(ctx iris.Context) {
		// Stop the simulator
		if simulator.IsRunning() {
			simulator.Stop()
		}

		ctx.ViewData("message", fmt.Sprintf("Stopped.  Please note that it may take up to a min for all simulations to fully stop."))
		ctx.View("index.html")
	})

	app.Get("/healthcheck", func(ctx iris.Context) {
		ctx.JSON(iris.Map{
			"Message": "Healthcheck",
			"Status":  "Healthy",
		})
	})

	return app
}

func genSims(config SimConfig, getRandomUser func() *UserProfile, getRandomTrip func() *Trip) []Sims {
	rate, duration := calculateConfig(config)

	return []Sims{
		{
			targeter: newHomepageTargeter(config),
			rate:     rate,
			duration: duration,
			simType:  Tripviewer,
			runwith:  "homepage",
		},
		{
			targeter: newUserTargeter(config),
			rate:     rate,
			duration: duration,
			simType:  Userprofile,
			runwith:  "trips",
		},
		{
			targeter: newTripsTargeter(config, getRandomUser),
			rate:     fastAddRate,
			duration: duration,
			simType:  Trips,
			runwith:  "trips",
		},
		{
			targeter: newTripsPointsTargeter(config, getRandomTrip),
			rate:     fastAddRate,
			duration: duration,
			simType:  TripPoints,
			runwith:  "trips",
		},
		{
			targeter: newPoiTargeter(config, getRandomTrip),
			rate:     slowAddRate,
			duration: duration,
			simType:  PointsOfInterest,
			runwith:  "trips",
		},
		{
			targeter: newUserUpdateTargeter(config),
			rate:     slowAddRate,
			duration: duration,
			simType:  UserJava,
			runwith:  "trips",
		},
	}
}

func main() {
	flag.Parse()
	// Set up prometheus metric server
	opsProcessed := promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "simulator_requests_total",
			Help: "The total number of simulator requets",
		},
		[]string{"service", "status"},
	)
	prom := prometheusMiddleware.New("simulator", 0.3, 1.2, 5.0)

	simulator := NewSimulator(opsProcessed)
	app := newApp(simulator, prom)
	port := os.Getenv("PORT")

	app.Run(iris.Addr(fmt.Sprintf(":%s", port)))
	glog.Flush()
}
