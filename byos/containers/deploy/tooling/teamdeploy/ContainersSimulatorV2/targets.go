package main

import (
	"encoding/json"
	"fmt"
	"github.com/brianvoe/gofakeit"
	"github.com/golang/glog"
	"time"

	vegeta "github.com/tsenart/vegeta/lib"
)

type simtype int

//go:generate stringer -type=simtype
const (
	Tripviewer       simtype = 0
	Userprofile      simtype = 1
	Trips            simtype = 2
	TripPoints       simtype = 3
	PointsOfInterest simtype = 4
	UserJava         simtype = 5
)

var (
	jsonHeader = map[string][]string{
		"Content-Type": []string{"application/json"},
		"Accept":       []string{"application/json"},
	}
)

func newHomepageTargeter(config SimConfig) vegeta.Targeter {
	return vegeta.NewStaticTargeter(vegeta.Target{
		Method: "GET",
		URL:    config.Baseurl,
	})
}

func newUserTargeter(config SimConfig) vegeta.Targeter {
	return vegeta.NewStaticTargeter(vegeta.Target{
		Method: "GET",
		URL:    fmt.Sprintf("%s/api/user", config.Baseurl),
	})
}

func newTripsTargeter(config SimConfig, getRandomUser func() *UserProfile) vegeta.Targeter {
	return func(t *vegeta.Target) error {
		if t == nil {
			return vegeta.ErrNilTarget
		}

		u := getRandomUser()
		if u == nil {
			glog.V(0).Infoln("no users loaded yet")
			return nil
		}

		glog.V(1).Infof("creating trip for user %s", u.ID)

		t.Method = "POST"
		t.URL = fmt.Sprintf("%s/api/trips", config.Baseurl)
		t.Body, _ = json.Marshal(&Trip{
			ID:                  gofakeit.UUID(),
			Name:                gofakeit.Name(),
			CreatedAt:           time.Now(),
			AverageSpeed:        gofakeit.Number(15, 60),
			Distance:            gofakeit.Number(10, 100),
			EndtimeStamp:        gofakeit.DateRange(time.Now(), time.Now().Add(time.Duration(6000)*time.Minute)).Format("02-Jan-2006"),
			FuelUsed:            gofakeit.Number(1, 40),
			HardAccelerations:   gofakeit.Number(1, 10),
			HardStops:           gofakeit.Number(1, 5),
			HasSimulatedOBDData: gofakeit.Bool(),
			IsComplete:          gofakeit.Bool(),
			Rating:              gofakeit.Number(1, 5),
			RecordedtimeStamp:   gofakeit.DateRange(time.Now(), time.Now().Add(time.Duration(6000)*time.Minute)).Format("02-Jan-2006"),
			UserID:              u.ID,
		})

		return nil
	}
}

func newTripsPointsTargeter(config SimConfig, getRandomTrip func() *Trip) vegeta.Targeter {

	return func(t *vegeta.Target) error {
		if t == nil {
			return vegeta.ErrNilTarget
		}

		t1 := getRandomTrip()
		if t1 == nil {
			glog.V(0).Infoln("no trips loaded yet")
			return nil
		}

		glog.V(1).Infof("creating trip points for trip  %s\n", t1.ID)
		t.URL = fmt.Sprintf("%s/api/trips/%s/trippoints", config.Baseurl, t1.ID)
		glog.V(2).Infof("trip url: %s\n", t.URL)

		t.Method = "POST"
		t.Body, _ = json.Marshal(&TripPoint{
			ID:                  gofakeit.UUID(),
			CreatedAt:           time.Now(),
			HasSimulatedOBDData: gofakeit.Bool(),
			TripID:              t1.ID,
			Latitude:            gofakeit.Address().Latitude,
			Longitude:           gofakeit.Address().Longitude,
			Speed:               gofakeit.Number(10, 150),
		})

		return nil
	}
}

func newPoiTargeter(config SimConfig, getRandomTrip func() *Trip) vegeta.Targeter {
	return func(t *vegeta.Target) error {
		if t == nil {
			return vegeta.ErrNilTarget
		}

		t1 := getRandomTrip()
		if t1 == nil {
			glog.V(0).Infof("no trips loaded yet\n")
			return nil
		}

		glog.V(1).Infof("creating point of interest for trip  %s\n", t1.ID)
		t.Method = "POST"
		t.URL = fmt.Sprintf("%s/api/poi", config.Baseurl)
		t.Header = jsonHeader

		t.Body, _ = json.Marshal(&Poi{
			ID:        gofakeit.UUID(),
			TripID:    t1.ID,
			Timestamp: time.Now(),
			PoiType:   gofakeit.Number(0, 3),
			Latitude:  gofakeit.Address().Latitude,
			Longitude: gofakeit.Address().Longitude,
		})

		return nil
	}
}

func newUserUpdateTargeter(config SimConfig) vegeta.Targeter {
	return func(t *vegeta.Target) error {
		if t == nil {
			return vegeta.ErrNilTarget
		}

		userid := gofakeit.UUID()
		glog.V(1).Infof("creating new user with id %s\n", userid)

		t.Method = "POST"
		t.Header = jsonHeader

		t.URL = fmt.Sprintf("%s/api/user-java/%s", config.Baseurl, userid)
		glog.V(2).Infof("user url: %s\n", t.URL)

		t.Body, _ = json.Marshal(&UserProfile{
			ID:                userid,
			FirstName:         gofakeit.FirstName(),
			LastName:          gofakeit.LastName(),
			UserID:            gofakeit.Username(),
			CreatedAt:         time.Now().Format("2006-01-06"),
			Rating:            gofakeit.Number(1, 5),
			Ranking:           gofakeit.Number(1, 1000),
			TotalDistance:     gofakeit.Float64Range(100, 6000),
			TotalTrips:        gofakeit.Number(1, 1000),
			HardStops:         gofakeit.Number(1, 50),
			HardAccelerations: gofakeit.Number(1, 200),
		})

		return nil
	}
}
