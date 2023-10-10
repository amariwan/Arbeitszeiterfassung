package main

import (
	"encoding/json"
	"time"

	"bytes"
	"fmt"
	"io/ioutil"
	"net/http"

)

func main() {
	httpposturl := "http://localhost:9000/login"
	fmt.Println("HTTP JSON POST URL:", httpposturl)

	var jsonData = []byte(`{
				   "username": "amariwan",
				   "password": "9999"}`)
	request, error := http.NewRequest("POST", httpposturl, bytes.NewBuffer(jsonData))
	request.Header.Set("Content-Type", "application/json; charset=UTF-8")

	client := &http.Client{}
	response, error := client.Do(request)
	if error != nil {
		panic(error)
	}
	defer response.Body.Close()

	fmt.Println("response Status:", response.Status)
	fmt.Println("response Headers:", response.Header)
	body, _ := ioutil.ReadAll(response.Body)
	fmt.Println("response Body:", string(body))
	dialogAfterLogin, _ := UnmarshalDialogAfterLogin(body)
	jsonData = []byte(`{
		"username": "amariwan",
		"id": "` + dialogAfterLogin.Id + `"}`)
	httppostur2 := "http://localhost:9000/start"
	request, error = http.NewRequest("POST", httppostur2, bytes.NewBuffer(jsonData))
	request.Header.Set("Content-Type", "application/json; charset=UTF-8")

	client = &http.Client{}
	response, error = client.Do(request)
	if error != nil {
		panic(error)
	}
	defer response.Body.Close()

	fmt.Println("response Status:", response.Status)
	fmt.Println("response Headers:", response.Header)
	body, _ = ioutil.ReadAll(response.Body)
	fmt.Println("response Body:", string(body))

	httppostur3 := "http://localhost:9000/stop"
	request, error = http.NewRequest("POST", httppostur3, bytes.NewBuffer(jsonData))
	request.Header.Set("Content-Type", "application/json; charset=UTF-8")

	client = &http.Client{}
	response, error = client.Do(request)
	if error != nil {
		panic(error)
	}
	defer response.Body.Close()

	fmt.Println("response Status:", response.Status)
	fmt.Println("response Headers:", response.Header)
	body, _ = ioutil.ReadAll(response.Body)
	fmt.Println("response Body:", string(body))

}

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
	Username string `json:"username"`
	Id       string `json:"id"`
}
type UserDB struct {
	Id                string        `clover:"id"`
	Username          string        `clover:"username"`
	startTime         time.Time     `clover:"startTime"`
	endTime           time.Time     `clover:"endTime"`
	ListOfWorkingTime []WorkingTime `clover:"ListOfWorkingTime"`
	Status            bool          `clover:"status"`
}

type UserJson struct {
	Id                string        `json:"id"`
	Username          string        `json:"username"`
	startTime         time.Time     `json:"startTime"`
	endTime           time.Time     `json:"endTime"`
	ListOfWorkingTime []WorkingTime `json:"ListOfWorkingTime"`
	Status            bool          `json:"status"`
}

type WorkingTime struct {
	DateOfWorking     time.Time
	DurationOfWorking time.Duration
}
