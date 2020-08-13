package main

import (
	"encoding/json"
	"fmt"
	"reflect"
	"testing"

	vegeta "github.com/tsenart/vegeta/v12/lib"
)

func Test_staticTargeter(t *testing.T) {
	tests := []struct {
		name          string
		targeterToRun func(c SimConfig) vegeta.Targeter
		config        SimConfig
		got           *vegeta.Target
		want          *vegeta.Target
		expectedErr   error
	}{
		{
			name:          "newHomepageTargeter should return GET with configured url",
			targeterToRun: newHomepageTargeter,
			config: SimConfig{
				Baseurl: "http://test",
			},
			got: &vegeta.Target{},
			want: &vegeta.Target{
				Method: "GET",
				URL:    "http://test",
			},
		},
		{
			name:          "newUserTargeter should return GET with configured url and user url appended",
			targeterToRun: newUserTargeter,
			config: SimConfig{
				Baseurl: "http://test",
			},
			got: &vegeta.Target{},
			want: &vegeta.Target{
				Method: "GET",
				URL:    "http://test/api/user",
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			//Targeter returns a fucntion which is invoked with tt.got which is filled
			err := tt.targeterToRun(tt.config)(tt.got)

			if !reflect.DeepEqual(tt.got, tt.want) {
				t.Errorf("target = %v, want %v", tt.got, tt.want)
			}

			if !reflect.DeepEqual(err, tt.expectedErr) {
				t.Errorf("err = %v, want %v", err, tt.expectedErr)
			}
		})
	}
}

func Test_newTripsTargeter(t *testing.T) {
	type args struct {
		config SimConfig
		users  func() *UserProfile
	}
	type want struct {
		target *vegeta.Target
		userid string
	}
	tests := []struct {
		name        string
		args        args
		got         *vegeta.Target
		want        want
		expectedErr error
	}{
		{
			name: "newTripsTargeter of should set body of target",
			args: args{
				config: SimConfig{
					Baseurl: "http://test",
				},
				users: func() *UserProfile { return &UserProfile{ID: "user1234"} },
			},
			got: &vegeta.Target{},
			want: want{
				target: &vegeta.Target{
					Method: "POST",
					URL:    "http://test/api/trips",
				},
				userid: "user1234",
			},
		},
		{
			name: "if no users return nil",
			args: args{
				config: SimConfig{},
				users:  func() *UserProfile { return nil },
			},
			got: &vegeta.Target{},
			want: want{
				target: &vegeta.Target{},
				userid: "",
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			//Targeter returns a fucntion which is invoked with tt.got which is filled
			err := newTripsTargeter(tt.args.config, tt.args.users)(tt.got)

			var tripResult Trip
			json.Unmarshal(tt.got.Body, &tripResult)

			if tripResult.UserID != tt.want.userid {
				t.Errorf("trip user id = %v, want %v", tripResult.UserID, tt.want.userid)
			}

			if tripResult.Name == "" {
				t.Errorf("trip name = %v, want %v", tripResult.Name, "not empty")
			}

			if tt.got.Method != tt.want.target.Method {
				t.Errorf("Method = %v, want %v", tt.got.Method, tt.want.target.Method)
			}

			if tt.got.URL != tt.want.target.URL {
				t.Errorf("URL = %v, want %v", tt.got.Method, tt.want.target.Method)
			}

			if !reflect.DeepEqual(err, tt.expectedErr) {
				t.Errorf("err = %v, want %v", err, tt.expectedErr)
			}
		})
	}
}

func Test_newTripsPointsTargeter(t *testing.T) {
	type args struct {
		config SimConfig
		trips  func() *Trip
	}
	type want struct {
		target *vegeta.Target
		tripid string
	}
	tests := []struct {
		name        string
		args        args
		got         *vegeta.Target
		want        want
		expectedErr error
	}{
		{
			name: "newTripsPointsTargeter of should set body of target",
			args: args{
				config: SimConfig{
					Baseurl: "http://test",
				},
				trips: func() *Trip { return &Trip{ID: "trip1234"} },
			},
			got: &vegeta.Target{},
			want: want{
				target: &vegeta.Target{
					Method: "POST",
					URL:    "http://test/api/trips/trip1234/trippoints",
				},
				tripid: "trip1234",
			},
		},
		{
			name: "if no trips return nil",
			args: args{
				config: SimConfig{},
				trips:  func() *Trip { return nil },
			},
			got: &vegeta.Target{},
			want: want{
				target: &vegeta.Target{},
				tripid: "",
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			//Targeter returns a fucntion which is invoked with tt.got which is filled
			err := newTripsPointsTargeter(tt.args.config, tt.args.trips)(tt.got)

			var tripPoint TripPoint
			json.Unmarshal(tt.got.Body, &tripPoint)

			if tripPoint.TripID != tt.want.tripid {
				t.Errorf("trip id = %v, want %v", tripPoint.TripID, tt.want.tripid)
			}

			if tt.got.URL != tt.want.target.URL {
				t.Errorf("URL = %v, want %v", tt.got.URL, tt.want.target.URL)
			}

			if tt.got.Method != tt.want.target.Method {
				t.Errorf("Method = %v, want %v", tt.got.Method, tt.want.target.Method)
			}

			if !reflect.DeepEqual(err, tt.expectedErr) {
				t.Errorf("err = %v, want %v", err, tt.expectedErr)
			}
		})
	}
}

func Test_newPoiTargeter(t *testing.T) {
	type args struct {
		config SimConfig
		trips  func() *Trip
	}
	type want struct {
		target *vegeta.Target
		tripid string
	}
	tests := []struct {
		name        string
		args        args
		got         *vegeta.Target
		want        want
		expectedErr error
	}{
		{
			name: "newPoiTargeter of type should set body of target",
			args: args{
				config: SimConfig{
					Baseurl: "http://test",
				},
				trips: func() *Trip { return &Trip{ID: "trip1234"} },
			},
			got: &vegeta.Target{},
			want: want{
				target: &vegeta.Target{
					Method: "POST",
					URL:    "http://test/api/poi",
					Header: jsonHeader,
				},
				tripid: "trip1234",
			},
		},
		{
			name: "if no trips return nil",
			args: args{
				config: SimConfig{},
				trips:  func() *Trip { return nil },
			},
			got: &vegeta.Target{},
			want: want{
				target: &vegeta.Target{},
				tripid: "",
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			//Targeter returns a fucntion which is invoked with tt.got which is filled
			err := newPoiTargeter(tt.args.config, tt.args.trips)(tt.got)

			var poi Poi
			json.Unmarshal(tt.got.Body, &poi)

			if poi.TripID != tt.want.tripid {
				t.Errorf("trip id = %v, want %v", poi.TripID, tt.want.tripid)
			}

			if tt.got.URL != tt.want.target.URL {
				t.Errorf("URL = %v, want %v", tt.got.URL, tt.want.target.URL)
			}

			if tt.got.Method != tt.want.target.Method {
				t.Errorf("Method = %v, want %v", tt.got.Method, tt.want.target.Method)
			}

			if !reflect.DeepEqual(err, tt.expectedErr) {
				t.Errorf("err = %v, want %v", err, tt.expectedErr)
			}
		})
	}
}

func Test_newUserUpdateTargeter(t *testing.T) {
	type args struct {
		config SimConfig
	}
	type want struct {
		target *vegeta.Target
	}
	tests := []struct {
		name        string
		args        args
		got         *vegeta.Target
		want        want
		expectedErr error
	}{
		{
			name: "newUserUpdateTargeter of type should set body of target",
			args: args{
				config: SimConfig{
					Baseurl: "http://test",
				},
			},
			got: &vegeta.Target{},
			want: want{
				target: &vegeta.Target{
					Method: "POST",
					URL:    "http://test/api/user-java/%s",
					Header: jsonHeader,
				},
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			//Targeter returns a fucntion which is invoked with tt.got which is filled
			err := newUserUpdateTargeter(tt.args.config)(tt.got)

			var user UserProfile
			json.Unmarshal(tt.got.Body, &user)

			if user.ID == "" {
				t.Errorf("new user id = %v, want %v", user.ID, "not empty")
			}

			wantedurl := fmt.Sprintf(tt.want.target.URL, user.ID)
			if tt.got.URL != wantedurl {
				t.Errorf("URL = %v, want %v", tt.got.URL, wantedurl)
			}

			if tt.got.Method != tt.want.target.Method {
				t.Errorf("Method = %v, want %v", tt.got.Method, tt.want.target.Method)
			}

			if !reflect.DeepEqual(err, tt.expectedErr) {
				t.Errorf("err = %v, want %v", err, tt.expectedErr)
			}
		})
	}
}
