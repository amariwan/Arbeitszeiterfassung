package main

import (
	"encoding/json"
	"time"
)

func UnmarshalLDAPConfig(data []byte) (LDAPConfig, error) {
	var r LDAPConfig
	err := json.Unmarshal(data, &r)
	return r, err
}

func (r *LDAPConfig) Marshal() ([]byte, error) {
	return json.Marshal(r)
}

type LDAPConfig struct {
	LDAPServer   string `json:"ldapServer"`
	LDAPPort     int64  `json:"ldapPort"`
	LDAPBindDN   string `json:"ldapBindDN"`
	LDAPPassword string `json:"ldapPassword"`
	LDAPSearchDN string `json:"ldapSearchDN"`
}

func UnmarshalLoginRequest(data []byte) (LoginRequest, error) {
	var r LoginRequest
	err := json.Unmarshal(data, &r)
	return r, err
}

func (r *LoginRequest) Marshal() ([]byte, error) {
	return json.Marshal(r)
}

type LoginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

func UnmarshalDialogAfterLogin(data []byte) (DialogAfterLogin, error) {
	var r DialogAfterLogin
	err := json.Unmarshal(data, &r)
	return r, err
}

func (r *DialogAfterLogin) Marshal() ([]byte, error) {
	return json.Marshal(r)
}

type DialogAfterLogin struct {
	Username         string             `json:"username"`
	Sessionkey       string             `json:"sessionkey"`
	Dayandworkedtime []DayAndWorkedTime `json:"dayandworkedtime"`
}

type UserWorkedTime struct {
	Username         string             `json:"username"`
	Dayandworkedtime []DayAndWorkedTime `json:"dayandworkedtime"`
}

type Users struct {
	UserWithWorkedTime []UserWorkedTime `json:"UserWithWorkedTime"`
}

type DayAndWorkedTime struct {
	Day       WorkingDate `json:"day"`
	Hasworked string      `json:"hasworked"`
}

type WorkingDate struct {
	Year  int        `json:"year"`
	Month time.Month `json:"month"`
	Day   int        `json:"day"`
}

func (r *WorkingDate) isEqual(day WorkingDate) bool {
	return r.Day == day.Day && r.Month == day.Month && r.Year == day.Year
}

type UserDB struct {
	Username          string        `clover:"username"`
	StartTime         time.Time     `clover:"startTime"`
	ListOfWorkingTime []WorkingTime `clover:"listOfWorkingTime"`
}

type UserJson struct {
	Username          string        `json:"username"`
	StartTime         time.Time     `json:"startTime"`
	ListOfWorkingTime []WorkingTime `json:"listOfWorkingTime"`
}

type WorkingTime struct {
	DateOfWorking     time.Time
	DurationOfWorking time.Duration
}
