package main

import (
	"encoding/json"
	"fmt"
	"github.com/golang/glog"
	"sync"
	"time"

	"github.com/brianvoe/gofakeit"

	"github.com/prometheus/client_golang/prometheus"
	vegeta "github.com/tsenart/vegeta/v12/lib"
)

var (
	slowAddRate = vegeta.Rate{Freq: 2, Per: time.Minute}
	fastAddRate = vegeta.Rate{Freq: 10, Per: time.Minute}
)

// OpenHackSimulator runs the simulations for TripViewer and APIs
type OpenHackSimulator struct {
	isRunning          bool
	isRunningMutex     sync.Mutex
	stopCh             chan interface{}
	done               chan bool
	wg                 *sync.WaitGroup
	metricsMutex       sync.RWMutex
	metrics            vegeta.Metrics
	userAvaliableMutex sync.RWMutex
	users              map[string]UserProfile

	tripsAvaliableMutex sync.RWMutex
	trips               map[string]Trip
	opsProcessed        *prometheus.CounterVec
}

// Simulator manages running only a single simulator at a time
type Simulator interface {
	IsRunning() bool
	StartSimulator(config SimConfig, sims []Sims) error
	Stop() chan bool
	RandomTrip() *Trip
	RandomUser() *UserProfile
}

// SimConfig is the paramaters to start the simulator
type SimConfig struct {
	Baseurl  string
	Rps      int
	Duration int
	Homepage string
	Trips    string
}

// NewSimulator creates a new simulator that is not running
func NewSimulator(opsProcessed *prometheus.CounterVec) *OpenHackSimulator {
	gofakeit.Seed(time.Now().UnixNano())
	return &OpenHackSimulator{
		opsProcessed: opsProcessed,
		isRunning:    false,
		users:        make(map[string]UserProfile),
		trips:        make(map[string]Trip),
	}
}

func calculateConfig(config SimConfig) (vegeta.Rate, time.Duration) {
	var rate vegeta.Rate
	if config.Homepage == "homepage" && config.Trips == "trips" {
		rate = vegeta.Rate{Freq: config.Rps / 2, Per: time.Second}
	} else {
		rate = vegeta.Rate{Freq: config.Rps, Per: time.Second}
	}

	duration := time.Duration(config.Duration) * time.Second

	return rate, duration
}

func (s *OpenHackSimulator) reset() {
	s.stopCh = make(chan interface{})
	s.wg = &sync.WaitGroup{}
	s.setSimState(true)
	s.metrics = vegeta.Metrics{}
	s.done = make(chan bool)
}

// StartSimulator Starts an instance of the simluator in not already running
func (s *OpenHackSimulator) StartSimulator(config SimConfig, sims []Sims) error {
	if s.isRunning {
		glog.V(0).Infof("Simulator was already running.\n")
		return fmt.Errorf("simulator already running")
	}
	s.reset()

	// Start simulations
	out := make(chan *SimResult)
	for _, sim := range sims {

		// https://github.com/golang/go/wiki/CommonMistakes#using-goroutines-on-loop-iterator-variables
		simTorun := sim
		if config.Homepage == sim.runwith {
			s.wg.Add(1)
			go simTorun.RunSim(out, s.stopCh, s.wg)

		}

		if config.Trips == sim.runwith {
			s.wg.Add(1)
			go simTorun.RunSim(out, s.stopCh, s.wg)
		}
	}

	go s.waitForSimToFinish(out)

	return nil
}

func (s *OpenHackSimulator) waitForSimToFinish(out chan *SimResult) {
	// Wait for all the go processes to shut down
	// then trigger shut down of sim
	go func() {
		s.wg.Wait()
		s.setSimState(false)
		s.metrics.Close()
		s.printmetrics()
		close(s.done)
	}()

Stop:
	for {
		select {
		case <-s.done:
			glog.V(0).Infof("stopped\n")
			break Stop
		case r := <-out:
			glog.V(2).Infof("result from simulator: %s\n", r.simType)
			s.setMetric(r.result)
			s.opsProcessed.WithLabelValues(fmt.Sprintf("%s", r.simType), fmt.Sprintf("%v", r.result.Code)).Inc()

			s.processValues(r)

			if r.result.Error != "" {
				glog.Errorf("error calling targeter %s with error %s\n", r.simType, r.result.Error)
			}
		}
	}
}

func (s *OpenHackSimulator) processValues(result *SimResult) {
	switch result.simType {
	case Tripviewer:
		break
	case Userprofile:
		var usersResult []UserProfile
		json.Unmarshal(result.result.Body, &usersResult)

		glog.V(3).Infof("parseduser result: %v\n", usersResult)
		if len(usersResult) > 0 {
			s.addUserAvaliable(usersResult[0])
		}

		break
	case Trips:
		var tripResult Trip
		json.Unmarshal(result.result.Body, &tripResult)

		if tripResult.ID != "" {
			s.addTripsAvaliable(tripResult)
		}

		break
	case TripPoints:
		break
	case PointsOfInterest:
		break
	case UserJava:
		var usersResult UserProfile
		json.Unmarshal(result.result.Body, &usersResult)

		if usersResult.ID != "" {
			s.addUserAvaliable(usersResult)
		}
	}
}

func (s *OpenHackSimulator) printmetrics() {
	glog.V(0).Infof("99th percentile: %s\n", s.metrics.Latencies.P99)
	glog.V(0).Infof("Success percentile: %v\n", s.metrics.Success)
	glog.V(0).Infof("total requests: %v\n", s.metrics.Requests)
	glog.V(0).Infof("total duration: %v\n", s.metrics.Duration)
	glog.V(0).Infof("total rate: %v\n", s.metrics.Rate)
}

func (s *OpenHackSimulator) setMetric(res *vegeta.Result) {
	s.metricsMutex.Lock()
	defer s.metricsMutex.Unlock()

	s.metrics.Add(res)
}

func (s *OpenHackSimulator) addUserAvaliable(userToAdd UserProfile) {
	s.userAvaliableMutex.Lock()
	defer s.userAvaliableMutex.Unlock()

	s.users[userToAdd.ID] = userToAdd
}

func (s *OpenHackSimulator) addTripsAvaliable(tripToAdd Trip) {
	s.tripsAvaliableMutex.Lock()
	defer s.tripsAvaliableMutex.Unlock()

	s.trips[tripToAdd.ID] = tripToAdd
}

// Stop stops all simulators running
func (s *OpenHackSimulator) Stop() chan bool {
	defer func() {
		if r := recover(); r != nil {
			glog.V(0).Infof("recovered from panic while stopping closed channel: %v", r)
		}
	}()
	close(s.stopCh)
	return s.done
}

func (s *OpenHackSimulator) setSimState(isRunning bool) {
	s.isRunningMutex.Lock()
	s.isRunning = isRunning
	s.isRunningMutex.Unlock()
}

// IsRunning reports if instance of simulator is running
func (s *OpenHackSimulator) IsRunning() bool {
	s.isRunningMutex.Lock()
	defer s.isRunningMutex.Unlock()
	return s.isRunning
}

// RandomUser returns random user
func (s *OpenHackSimulator) RandomUser() *UserProfile {
	if len(s.users) == 0 {
		return nil
	}

	uk := randomUser(s.users)
	u := s.users[uk]
	return &u
}

// RandomTrip return random trip
func (s *OpenHackSimulator) RandomTrip() *Trip {
	if len(s.trips) == 0 {
		return nil
	}

	tk := randomTrip(s.trips)
	trip := s.trips[tk]
	return &trip
}
