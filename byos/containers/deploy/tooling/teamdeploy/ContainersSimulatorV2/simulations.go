package main

import (
	"fmt"
	"github.com/golang/glog"
	vegeta "github.com/tsenart/vegeta/lib"
	"sync"
	"time"
)

type Sims struct {
	targeter vegeta.Targeter
	rate     vegeta.Rate
	duration time.Duration
	simType  simtype
	runwith  string
}

type SimResult struct {
	result  *vegeta.Result
	simType simtype
}

func (s *Sims) RunSim(out chan *SimResult, stop chan interface{}, wg *sync.WaitGroup) {
	defer wg.Done()
	attacker := vegeta.NewAttacker()

	glog.V(0).Infof("starting simulator %s\n", s.simType)
Attack:
	for res := range attacker.Attack(s.targeter, s.rate, s.duration, fmt.Sprintf("%s", s.simType)) {
		select {
		case <-stop:
			glog.V(0).Infof("stopping simulator %s\n", s.simType)
			attacker.Stop()

			break Attack
		default:
			glog.V(2).Infof("result %s\n", s.simType)
			out <- &SimResult{result: res, simType: s.simType}
		}
	}

	glog.V(0).Infof("Exiting %s\n", s.simType)
}
