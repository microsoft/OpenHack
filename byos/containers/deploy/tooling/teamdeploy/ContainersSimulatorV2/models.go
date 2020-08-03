package main

import (
	"time"
)

type UserProfile struct {
	ID                string      `json:"id"`
	FirstName         interface{} `json:"firstName"`
	LastName          string      `json:"lastName"`
	UserID            interface{} `json:"userId"`
	ProfilePictureURI interface{} `json:"profilePictureUri"`
	Rating            int         `json:"rating"`
	Ranking           int         `json:"ranking"`
	TotalDistance     float64     `json:"totalDistance"`
	TotalTrips        int         `json:"totalTrips"`
	TotalTime         int         `json:"totalTime"`
	HardStops         int         `json:"hardStops"`
	HardAccelerations int         `json:"hardAccelerations"`
	FuelConsumption   int         `json:"fuelConsumption"`
	MaxSpeed          int         `json:"maxSpeed"`
	Version           interface{} `json:"version"`
	CreatedAt         string      `json:"createdAt"`
	UpdatedAt         string      `json:"updatedAt"`
	Deleted           bool        `json:"deleted"`
}

type Trip struct {
	ID                  string      `json:"id"`
	Name                interface{} `json:"name"`
	UserID              string      `json:"userId"`
	RecordedtimeStamp   interface{} `json:"recordedtimeStamp"`
	EndtimeStamp        interface{} `json:"endtimeStamp"`
	Rating              int         `json:"rating"`
	IsComplete          bool        `json:"isComplete"`
	HasSimulatedOBDData bool        `json:"hasSimulatedOBDData"`
	AverageSpeed        int         `json:"averageSpeed"`
	FuelUsed            int         `json:"fuelUsed"`
	HardStops           int         `json:"hardStops"`
	HardAccelerations   int         `json:"hardAccelerations"`
	Distance            int         `json:"distance"`
	CreatedAt           time.Time   `json:"createdAt"`
	UpdatedAt           time.Time   `json:"updatedAt"`
	Deleted             bool        `json:"deleted"`
}

type TripPoint struct {
	ID                           interface{} `json:"id"`
	TripID                       string      `json:"tripId"`
	Latitude                     float64     `json:"latitude"`
	Longitude                    float64     `json:"longitude"`
	Speed                        int         `json:"speed"`
	RecordedTimeStamp            string      `json:"recordedTimeStamp"`
	Sequence                     int         `json:"sequence"`
	Rpm                          int         `json:"rpm"`
	ShortTermFuelBank            int         `json:"shortTermFuelBank"`
	LongTermFuelBank             int         `json:"longTermFuelBank"`
	ThrottlePosition             int         `json:"throttlePosition"`
	RelativeThrottlePosition     int         `json:"relativeThrottlePosition"`
	Runtime                      int         `json:"runtime"`
	DistanceWithMalfunctionLight int         `json:"distanceWithMalfunctionLight"`
	EngineLoad                   int         `json:"engineLoad"`
	MassFlowRate                 int         `json:"massFlowRate"`
	EngineFuelRate               int         `json:"engineFuelRate"`
	Vin                          Vin         `json:"vin"`
	HasOBDData                   bool        `json:"hasOBDData"`
	HasSimulatedOBDData          bool        `json:"hasSimulatedOBDData"`
	CreatedAt                    time.Time   `json:"createdAt"`
	UpdatedAt                    time.Time   `json:"updatedAt"`
	Deleted                      bool        `json:"deleted"`
}

type Vin struct {
	String interface{} `json:"string"`
	Valid  bool        `json:"valid"`
}

type Poi struct {
	ID        interface{} `json:"id"`
	TripID    string      `json:"tripId"`
	Latitude  float64     `json:"latitude"`
	Longitude float64     `json:"longitude"`
	PoiType   int         `json:"poiType"`
	Timestamp time.Time   `json:"timestamp"`
	Deleted   bool        `json:"deleted"`
}
