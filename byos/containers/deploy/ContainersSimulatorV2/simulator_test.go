package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"reflect"
	"testing"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	vegeta "github.com/tsenart/vegeta/lib"
)

func Test_calculateConfig(t *testing.T) {
	tests := []struct {
		name         string
		args         SimConfig
		wantRate     vegeta.Rate
		wantDuration time.Duration
	}{
		{
			name: "if only home page selection the rps is passed rate, duration returned in seconds",
			args: SimConfig{
				Rps:      20,
				Duration: 30,
				Homepage: "homepage",
			},
			wantRate:     vegeta.Rate{Freq: 20, Per: time.Second},
			wantDuration: time.Duration(30) * time.Second,
		},
		{
			name: "if only trips selection the rps is passed rate, duration returned in seconds",
			args: SimConfig{
				Rps:      20,
				Duration: 30,
				Trips:    "trips",
			},
			wantRate:     vegeta.Rate{Freq: 20, Per: time.Second},
			wantDuration: time.Duration(30) * time.Second,
		},
		{
			name: "if only trips and home selection the rps is divided between the two, duration returned in seconds",
			args: SimConfig{
				Rps:      20,
				Duration: 30,
				Trips:    "trips",
				Homepage: "homepage",
			},
			wantRate:     vegeta.Rate{Freq: 10, Per: time.Second},
			wantDuration: time.Duration(30) * time.Second,
		},
		{
			name: "if neither passed rate is passed, duration returned in seconds",
			args: SimConfig{
				Rps:      20,
				Duration: 30,
			},
			wantRate:     vegeta.Rate{Freq: 20, Per: time.Second},
			wantDuration: time.Duration(30) * time.Second,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			gotRate, gotDuration := calculateConfig(tt.args)
			if !reflect.DeepEqual(gotRate, tt.wantRate) {
				t.Errorf("calculateConfig() got = %v, want %v", gotRate, tt.wantRate)
			}
			if gotDuration != tt.wantDuration {
				t.Errorf("calculateConfig() got1 = %v, want %v", gotDuration, tt.wantDuration)
			}
		})
	}
}

func Test_CallingStopTwiceShouldNotPanic(t *testing.T) {
	server := httptest.NewServer(
		http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusBadRequest)
		}),
	)
	defer server.Close()

	// kick off simulator runing indefinitly
	config := SimConfig{
		Baseurl:  server.URL,
		Homepage: "homepage",
		Duration: 0,
	}

	firstTargeter := fakeTargeter{}
	firstsims := []Sims{
		{
			targeter: firstTargeter.newfakeTargeter(server.URL),
			rate:     vegeta.Rate{Freq: 1, Per: time.Second},
			duration: time.Second * 1,
			simType:  Tripviewer,
			runwith:  "homepage",
		},
	}

	sim := newFakeopenHackSim()

	e := sim.StartSimulator(config, firstsims)
	if e != nil {
		t.Errorf("returned error on first start")
	}

	simdone := sim.Stop()
	// Call second time to see if it fails
	p := catchPanic(func() { sim.Stop() })
	a, ok := p.(error)
	if ok {
		t.Errorf("Should have not paniced: %s", a.Error())
	}

	<-simdone
	if sim.IsRunning() != false {
		t.Errorf("sim.IsRunning() got = %v, want %v", sim.IsRunning(), false)
	}
}

// https://stackoverflow.com/a/41631702/697126
func catchPanic(fn func()) (recovered interface{}) {
	defer func() {
		recovered = recover()
	}()
	fn()
	return
}

func Test_StartSimulatorAlreadyRunningShouldNotCallAnySims(t *testing.T) {
	server := httptest.NewServer(
		http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusBadRequest)
		}),
	)
	defer server.Close()

	// kick off simulator runing indefinitly
	config := SimConfig{
		Baseurl:  server.URL,
		Homepage: "homepage",
		Duration: 0,
	}

	firstTargeter := fakeTargeter{}
	firstsims := []Sims{
		{
			targeter: firstTargeter.newfakeTargeter(server.URL),
			rate:     vegeta.Rate{Freq: 1, Per: time.Second},
			duration: time.Second * 1,
			simType:  Tripviewer,
			runwith:  "homepage",
		},
	}

	sim := newFakeopenHackSim()
	secondTageter := fakeTargeter{}
	second := []Sims{
		{
			targeter: secondTageter.newfakeTargeter(server.URL),
			rate:     vegeta.Rate{Freq: 1, Per: time.Second},
			duration: time.Second * 1,
			simType:  Tripviewer,
			runwith:  "homepage",
		},
	}

	e := sim.StartSimulator(config, firstsims)
	if e != nil {
		t.Errorf("returned error on first start")
	}

	// should return immediatly
	e = sim.StartSimulator(config, second)

	if sim.IsRunning() != true {
		t.Errorf("sim.IsRunning() got = %v, want %v", sim.IsRunning(), true)
	}

	if secondTageter.count != 0 {
		t.Errorf("secondsim got = %v, want %v", secondTageter.count, 0)
	}

	if e == nil {
		t.Errorf("returned but did not set error")
	}

	simdone := sim.Stop()
	<-simdone

	if firstTargeter.count == 0 {
		t.Errorf("secondsim got = %v, want > %v", firstTargeter.count, 0)
	}

	if sim.IsRunning() != false {
		t.Errorf("sim.IsRunning() got = %v, want %v", sim.IsRunning(), false)
	}
}

func Test_StartShouldStartBothTypes(t *testing.T) {
	server := httptest.NewServer(
		http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusBadRequest)
		}),
	)
	defer server.Close()

	// kick off simulator
	config := SimConfig{
		Baseurl:  server.URL,
		Homepage: "homepage",
		Trips:    "trips",
	}

	homeTageter := fakeTargeter{}
	tripsTarger := fakeTargeter{}

	sims := []Sims{
		{
			targeter: homeTageter.newfakeTargeter(server.URL),
			rate:     vegeta.Rate{Freq: 10, Per: time.Second},
			duration: time.Second * 1,
			simType:  Tripviewer,
			runwith:  "homepage",
		},
		{
			targeter: tripsTarger.newfakeTargeter(server.URL),
			rate:     vegeta.Rate{Freq: 10, Per: time.Second},
			duration: time.Second * 1,
			simType:  Trips,
			runwith:  "trips",
		},
	}

	sim := newFakeopenHackSim()
	sim.StartSimulator(config, sims)

	timeout := time.After(1 * time.Second)
	var simdone chan bool
	select {
	case <-timeout:
		simdone = sim.Stop()
	}
	<-simdone

	if sim.IsRunning() != false {
		t.Errorf("sim.IsRunning() got = %v, want %v", sim.IsRunning(), false)
	}

	if homeTageter.count == 0 {
		t.Errorf("homepagesim = %v, want > %v", homeTageter.count, 0)
	}

	if tripsTarger.count == 0 {
		t.Errorf("tripssim = %v, want > %v", tripsTarger.count, 0)
	}
}

func Test_StartCallUserOnSuccessfullCall(t *testing.T) {
	server := httptest.NewServer(
		http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusOK)
			header := w.Header()
			header.Add("Content-Type", "application/json")

			users := []UserProfile{
				UserProfile{
					ID:        "testid",
					FirstName: "firstname",
					LastName:  "lastname",
					UserID:    "userid",
					CreatedAt: time.Now().Format("2006-01-06"),
				},
			}
			body, _ := json.Marshal(&users)
			w.Write(body)
		}),
	)
	defer server.Close()

	config := SimConfig{
		Baseurl:  server.URL,
		Homepage: "homepage",
		Trips:    "trips",
	}

	counterTargeter := fakeTargeter{}
	sims := []Sims{
		{
			targeter: counterTargeter.newfakeTargeter(server.URL),
			rate:     vegeta.Rate{Freq: 1, Per: time.Second},
			duration: time.Second * 1,
			simType:  Userprofile,
			runwith:  "homepage",
		},
	}

	sim := newFakeopenHackSim()
	sim.StartSimulator(config, sims)

	timeout := time.After(2 * time.Second)
	var simdone chan bool
	select {
	case <-timeout:
		simdone = sim.Stop()
	}
	<-simdone

	if sim.IsRunning() != false {
		t.Errorf("sim.IsRunning() got = %v, want %v", sim.IsRunning(), false)
	}

	if counterTargeter.count != 1 {
		t.Errorf("userprofiletargeter = %v, want > %v", counterTargeter.count, 1)
	}

	if len(sim.users) != 1 {
		t.Fatalf("len(sim.users) = %v, want %v", len(sim.users), 1)
	}

	u := sim.users["testid"]
	if u.ID != "testid" {
		t.Errorf("u.ID = %v, want %v", len(sim.users), "testid")
	}
}

func Test_StartAddUserOnSuccessfullCall(t *testing.T) {
	server := httptest.NewServer(
		http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusOK)
			header := w.Header()
			header.Add("Content-Type", "application/json")

			user := UserProfile{

				ID:        "testid",
				FirstName: "firstname",
				LastName:  "lastname",
				UserID:    "userid",
				CreatedAt: time.Now().Format("2006-01-06"),
			}
			body, _ := json.Marshal(&user)
			w.Write(body)
		}),
	)
	defer server.Close()

	config := SimConfig{
		Baseurl:  server.URL,
		Homepage: "homepage",
		Trips:    "trips",
	}

	counterTargeter := fakeTargeter{}
	sims := []Sims{
		{
			targeter: counterTargeter.newfakeTargeter(server.URL),
			rate:     vegeta.Rate{Freq: 1, Per: time.Second},
			duration: time.Second * 1,
			simType:  UserJava,
			runwith:  "homepage",
		},
	}

	sim := newFakeopenHackSim()
	sim.StartSimulator(config, sims)

	timeout := time.After(2 * time.Second)
	var simdone chan bool
	select {
	case <-timeout:
		simdone = sim.Stop()
	}
	<-simdone

	if sim.IsRunning() != false {
		t.Errorf("sim.IsRunning() got = %v, want %v", sim.IsRunning(), false)
	}

	if counterTargeter.count != 1 {
		t.Errorf("userprofiletargeter = %v, want > %v", counterTargeter.count, 1)
	}

	if len(sim.users) != 1 {
		t.Fatalf("len(sim.users) = %v, want %v", len(sim.users), 1)
	}

	u := sim.users["testid"]
	if u.ID != "testid" {
		t.Errorf("u.ID = %v, want %v", len(sim.users), "testid")
	}
}

func Test_StartTripOnSuccessfullCall(t *testing.T) {
	server := httptest.NewServer(
		http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusOK)
			header := w.Header()
			header.Add("Content-Type", "application/json")

			trip := Trip{
				ID:        "testid",
				UserID:    "userid",
				CreatedAt: time.Now(),
			}
			body, _ := json.Marshal(&trip)
			w.Write(body)
		}),
	)
	defer server.Close()

	config := SimConfig{
		Baseurl:  server.URL,
		Homepage: "homepage",
		Trips:    "trips",
	}

	counterTargeter := fakeTargeter{}
	sims := []Sims{
		{
			targeter: counterTargeter.newfakeTargeter(server.URL),
			rate:     vegeta.Rate{Freq: 1, Per: time.Second},
			duration: time.Second * 1,
			simType:  Trips,
			runwith:  "homepage",
		},
	}

	sim := newFakeopenHackSim()
	sim.StartSimulator(config, sims)

	timeout := time.After(2 * time.Second)
	var simdone chan bool
	select {
	case <-timeout:
		simdone = sim.Stop()
	}
	<-simdone

	if sim.IsRunning() != false {
		t.Errorf("sim.IsRunning() got = %v, want %v", sim.IsRunning(), false)
	}

	if counterTargeter.count != 1 {
		t.Errorf("userprofiletargeter = %v, want > %v", counterTargeter.count, 1)
	}

	if len(sim.trips) != 1 {
		t.Fatalf("len(sim.users) = %v, want %v", len(sim.users), 1)
	}

	trip := sim.trips["testid"]
	if trip.ID != "testid" {
		t.Errorf("u.ID = %v, want %v", len(sim.trips), "testid")
	}
}

type fakeTargeter struct {
	count int
}

func (f *fakeTargeter) newfakeTargeter(url string) vegeta.Targeter {
	return func(t *vegeta.Target) error {
		if t == nil {
			return vegeta.ErrNilTarget
		}

		t.Method = "POST"
		t.URL = url

		f.count = f.count + 1

		return nil
	}
}

func newFakeopenHackSim() *OpenHackSimulator {
	// don't register for unit tests
	opsProcessed := prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "simulator_requests_total",
			Help: "The total number of simulator requets",
		},
		[]string{"service", "status"},
	)
	return NewSimulator(opsProcessed)
}

func TestOpenHackSimulator_RandomUser(t *testing.T) {
	sim := newFakeopenHackSim()

	niluser := sim.RandomUser()
	if niluser != nil {
		t.Errorf("niluser = %v, want %v", niluser, nil)
	}

	user := UserProfile{ID: "testid"}

	sim.addUserAvaliable(user)

	randomuser := sim.RandomUser()

	if randomuser.ID != user.ID {
		t.Errorf("randomuser.ID = %v, want %v", randomuser.ID, user.ID)
	}

	// add another user
	user2 := UserProfile{ID: "testid2"}
	sim.addUserAvaliable(user2)

	for i := 0; i < 100; i++ {
		randomuser2 := sim.RandomUser()
		if randomuser2.ID != user.ID && randomuser2.ID != user2.ID {
			t.Errorf("randomuser.ID = %v, want %v or %v", randomuser2.ID, user.ID, user2.ID)
		}
	}
}

func TestOpenHackSimulator_RandomTrip(t *testing.T) {
	sim := newFakeopenHackSim()

	niltrip := sim.RandomTrip()
	if niltrip != nil {
		t.Errorf("niltrip = %v, want %v", niltrip, nil)
	}

	trip := Trip{ID: "testid"}

	sim.addTripsAvaliable(trip)

	randomtrip := sim.RandomTrip()

	if randomtrip.ID != trip.ID {
		t.Errorf("randomtrip.ID = %v, want %v", randomtrip.ID, trip.ID)
	}

	// add another trip
	trip2 := Trip{ID: "testid2"}
	sim.addTripsAvaliable(trip2)

	for i := 0; i < 100; i++ {
		randomtrip2 := sim.RandomTrip()
		if randomtrip2.ID != trip.ID && randomtrip2.ID != trip2.ID {
			t.Errorf("randomtrip.ID = %v, want %v or %v", randomtrip2.ID, trip.ID, trip2.ID)
		}
	}
}
