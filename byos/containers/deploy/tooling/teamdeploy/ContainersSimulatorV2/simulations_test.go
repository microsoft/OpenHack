package main

import (
	"sync"
	"testing"
	"time"

	"net/http"
	"net/http/httptest"

	vegeta "github.com/tsenart/vegeta/lib"
)

func TestSims_RunSim(t *testing.T) {
	server := httptest.NewServer(
		http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusBadRequest)
		}),
	)
	defer server.Close()

	targeter := vegeta.NewStaticTargeter(vegeta.Target{URL: server.URL, Method: "GET"})

	s := &Sims{
		targeter: targeter,
		rate:     vegeta.Rate{Freq: 1, Per: time.Second * 1},
		duration: time.Second * 1,
		simType:  Trips,
	}

	// Start running sim
	out := make(chan *SimResult)
	stop := make(chan interface{})
	wg := &sync.WaitGroup{}
	wg.Add(1)
	go s.RunSim(out, stop, wg)

	// Wait for the sim to finish running
	done := make(chan bool)
	go func() {
		wg.Wait()
		done <- true
	}()

	var count int
Test:
	for {
		select {
		case r := <-out:
			if r.simType != Trips {
				t.Errorf("simType got = %v, want %v", r.simType, Trips)
			}
			count = count + 1
			break
		case <-done:
			break Test
		}
	}

	if count != 1 {
		t.Errorf("count got = %v, want %v", count, 1)
	}
}

func TestSims_RunSimShouldStopWhenCalled(t *testing.T) {
	server := httptest.NewServer(
		http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.WriteHeader(http.StatusBadRequest)
		}),
	)
	defer server.Close()

	targeter := vegeta.NewStaticTargeter(vegeta.Target{URL: server.URL, Method: "GET"})

	s := &Sims{
		targeter: targeter,
		rate:     vegeta.Rate{Freq: 1, Per: time.Second * 1},
		duration: time.Second * 10,
		simType:  Trips,
	}

	// Start running sim
	out := make(chan *SimResult)
	stop := make(chan interface{})
	wg := &sync.WaitGroup{}
	wg.Add(1)
	go s.RunSim(out, stop, wg)

	// Close it after 1 second
	go func() {
		timeout := time.After(1 * time.Second)
		select {
		case <-timeout:
			close(stop)
		}
	}()

	// Wait for the sim to finish running
	done := make(chan bool)
	go func() {
		wg.Wait()
		done <- true
	}()

	var count int
Test:
	for {
		select {
		case r := <-out:
			if r.simType != Trips {
				t.Errorf("simType got = %v, want %v", r.simType, Trips)
			}
			count = count + 1
			break
		case <-done:
			break Test
		}
	}

	if count >= 10 {
		t.Errorf("count got < %v, want %v", count, 10)
	}
}
