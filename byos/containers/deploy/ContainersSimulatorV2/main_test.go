package main

import (
	prometheusMiddleware "github.com/iris-contrib/middleware/prometheus"
	"github.com/kataras/iris/v12/httptest"
	"testing"
)

func Test_hompage(t *testing.T) {
	fs, prom := newFakeSim()
	app := newApp(fs, prom)
	a := httptest.New(t, app)

	a.GET("/").Expect().Status(httptest.StatusOK)
}

func Test_healthCheck(t *testing.T) {
	fs, prom := newFakeSim()
	app := newApp(fs, prom)
	a := httptest.New(t, app)

	a.GET("/healthcheck").Expect().Status(httptest.StatusOK).JSON().
		Object().ContainsKey("Status").ValueEqual("Status", "Healthy")
}

func Test_WhenNotRunningItShouldnotCallStoppedSimulator(t *testing.T) {
	fs, prom := newFakeSim()
	app := newApp(fs, prom)
	a := httptest.New(t, app)

	fs.isRunning = false
	a.POST("/stop").Expect().Status(httptest.StatusOK)

	if fs.stopCalled != 0 {
		t.Errorf("stop called  = %v, want %v", fs.stopCalled, 0)
	}
}

func Test_WhenRunningItShouldCallStoppedSimulator(t *testing.T) {
	fs, prom := newFakeSim()
	app := newApp(fs, prom)
	a := httptest.New(t, app)

	fs.isRunning = true
	a.POST("/stop").Expect().Status(httptest.StatusOK)

	if fs.stopCalled != 1 {
		t.Errorf("stop called  = %v, want %v", fs.stopCalled, 1)
	}
}

func Test_WhenFormIsInvalidReturnError(t *testing.T) {
	fs, prom := newFakeSim()
	app := newApp(fs, prom)
	a := httptest.New(t, app)

	a.POST("/start").WithFormField("Rps", "invalid").Expect().Status(httptest.StatusInternalServerError)

	if fs.startCalled != 0 {
		t.Errorf("start called  = %v, want %v", fs.startCalled, 0)
	}
}

func Test_WhenRPSIsGreaterThanValueReturn(t *testing.T) {
	fs, prom := newFakeSim()
	app := newApp(fs, prom)
	a := httptest.New(t, app)

	a.POST("/start").WithFormField("Rps", "1001").Expect().Status(httptest.StatusBadRequest)

	if fs.startCalled != 0 {
		t.Errorf("start called  = %v, want %v", fs.startCalled, 0)
	}
}

func Test_MustPassValuesForSimsToRunConfiguration(t *testing.T) {
	fs, prom := newFakeSim()
	app := newApp(fs, prom)
	a := httptest.New(t, app)

	a.POST("/start").WithFormField("Homepage", "").
		WithFormField("Trips", "").
		Expect().Status(httptest.StatusBadRequest)

	if fs.startCalled != 0 {
		t.Errorf("start called  = %v, want %v", fs.startCalled, 0)
	}
}

func Test_SimsToRunMustBeValuesWeKnowAbout(t *testing.T) {
	fs, prom := newFakeSim()
	app := newApp(fs, prom)
	a := httptest.New(t, app)

	a.POST("/start").WithFormField("Homepage", "nothomepagevalue").
		Expect().Status(httptest.StatusBadRequest)

	a.POST("/start").WithFormField("Trips", "nottripsvalue").
		Expect().Status(httptest.StatusBadRequest)

	if fs.startCalled != 0 {
		t.Errorf("start called  = %v, want %v", fs.startCalled, 0)
	}
}

func Test_MustHaveValidUrl(t *testing.T) {
	fs, prom := newFakeSim()
	app := newApp(fs, prom)
	a := httptest.New(t, app)

	a.POST("/start").WithFormField("Homepage", "homepage").
		WithFormField("baseurl", "http//notvalid").
		Expect().Status(httptest.StatusBadRequest)

	a.POST("/start").WithFormField("Homepage", "homepage").
		WithFormField("baseurl", "").
		Expect().Status(httptest.StatusBadRequest)

	if fs.startCalled != 0 {
		t.Errorf("start called  = %v, want %v", fs.startCalled, 0)
	}
}

func Test_IfSimulatorIsAlreadyRunningDoNotStart(t *testing.T) {
	fs, prom := newFakeSim()
	app := newApp(fs, prom)
	a := httptest.New(t, app)

	fs.isRunning = true
	a.POST("/start").WithFormField("Homepage", "homepage").
		WithFormField("baseurl", "http://valid").
		Expect().Status(httptest.StatusOK)

	if fs.startCalled != 0 {
		t.Errorf("start called  = %v, want %v", fs.startCalled, 0)
	}
}

func Test_IfSimulatorIsNotRunningStart(t *testing.T) {
	fs, prom := newFakeSim()
	app := newApp(fs, prom)
	a := httptest.New(t, app)

	fs.isRunning = false
	a.POST("/start").WithFormField("Homepage", "homepage").
		WithFormField("baseurl", "http://valid").
		Expect().Status(httptest.StatusOK)

	if fs.startCalled != 1 {
		t.Errorf("start called  = %v, want %v", fs.startCalled, 1)
	}
}

func Test_TrimTrailingSlashFromBaseUrl(t *testing.T) {
	fs, prom := newFakeSim()
	app := newApp(fs, prom)
	a := httptest.New(t, app)

	fs.isRunning = false
	a.POST("/start").WithFormField("Homepage", "homepage").
		WithFormField("baseurl", "http://withslash/").
		Expect().Status(httptest.StatusOK)

	if fs.url != "http://withslash" {
		t.Errorf("url called  = %v, want %v", fs.url, "http://withslash")
	}

	a.POST("/start").WithFormField("Homepage", "homepage").
		WithFormField("baseurl", "http://noslash").
		Expect().Status(httptest.StatusOK)

	if fs.url != "http://noslash" {
		t.Errorf("url called  = %v, want %v", fs.url, "http://noslash")
	}
}

type fakeSim struct {
	isRunning   bool
	stopCalled  int
	startCalled int
	url         string
}

var (
	prom = prometheusMiddleware.New("test", 0.3, 1.2, 5.0)
)

func newFakeSim() (*fakeSim, *prometheusMiddleware.Prometheus) {
	return &fakeSim{}, prom
}

func (f *fakeSim) StartSimulator(config SimConfig, sims []Sims) error {
	f.startCalled = f.startCalled + 1
	f.url = config.Baseurl
	return nil
}

func (f *fakeSim) Stop() chan bool {
	f.stopCalled = f.stopCalled + 1
	return nil
}

func (f *fakeSim) IsRunning() bool {
	return f.isRunning
}

func (s *fakeSim) RandomUser() *UserProfile {
	return nil
}

func (s *fakeSim) RandomTrip() *Trip {
	return nil
}
