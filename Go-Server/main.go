package main

import (
	"embed"
	"encoding/json"
	"fmt"
	"io/fs"
	"net/http"
	"os"
	"time"

	"github.com/go-http-utils/cors"
	"github.com/go-ldap/ldap"
	"github.com/gorilla/handlers"
	c "github.com/ostafen/clover"
)

var (
	//go:embed flutter
	flutter embed.FS
	//pages        = map[string]string{
	//    "/cfg": "flutter/index.html",
	//}
	config = readFromConfig()
)

type UserLDAPData struct {
	ID       string
	Email    string
	Name     string
	FullName string
}

type Client struct {
	SessionKey  string
	Username    string
	LastContact time.Time
}

var clients = make(map[string]*Client)

// the port where web server will run
const webServerPort = 9000

func main() {
	//remakeDatabase := true
	remakeDatabase := parseCommandLineArguments()
	db, err := c.Open("clover-db")
	if err != nil {
		panic(err)
	}
	defer db.Close()
	store, _ := db.HasCollection("user")
	if remakeDatabase {
		if store {
			db.DropCollection("user")
			db.CreateCollection("user")
		}
	}

	if !store {
		db.CreateCollection("user")
	}

	var startTime = time.Now()
	var endTime = time.Now()
	allowedCredentials := cors.SetCredentials(true)
	allowedMethods := cors.SetMethods([]string{
		"POST",
		"GET",
		"PUT",
		"OPTIONS",
	})

	allowedOriginValidator := cors.SetAllowOrigin(true)
	allowedHeaders := cors.SetAllowHeaders([]string{
		"Accept",
		"Accept-Language",
		"Content-Language",
		"Origin",
		"Content-Type",
		"authorization",
	})

	mux := http.NewServeMux()
	crosMux := cors.Handler(mux, allowedCredentials, allowedMethods, allowedOriginValidator, allowedHeaders)
	client, err := fs.Sub(flutter, "flutter")
	if err != nil {
		panic(err)
	}
	mux.HandleFunc("/cfg", func(w http.ResponseWriter, r *http.Request) {
		http.Redirect(w, r, "/cfg/index.html", http.StatusSeeOther)
	})
	mux.Handle("/cfg/", http.StripPrefix("/cfg/", handlers.CombinedLoggingHandler(os.Stdout,
		http.FileServer(http.FS(client)))))

	mux.HandleFunc("/login", func(w http.ResponseWriter, r *http.Request) {
		var sessionkey = ""

		r.ParseForm()
		loginRequest := &LoginRequest{}
		err := json.NewDecoder(r.Body).Decode(loginRequest)

		// authenticate via ldap
		ok, _, err := AuthUsingLDAP(loginRequest.Username, loginRequest.Password)
		if !ok {
			returnInWorstCase(w)
			return
		}
		if err != nil {
			returnInWorstCase(w)
			return
		}

		// greet user on success
		returnInBestCase(ok, r, w, sessionkey, loginRequest, db)
		return
	})

	mux.HandleFunc("/admin", func(w http.ResponseWriter, r *http.Request) {

		r.ParseForm()
		loginRequest := &LoginRequest{}
		err := json.NewDecoder(r.Body).Decode(loginRequest)

		// authenticate via ldap
		ok, _, err := AuthUsingLDAP(loginRequest.Username, loginRequest.Password)

		if !ok {
			returnInWorstCase(w)
			return
		}
		if err != nil {
			returnInWorstCase(w)
			return
		}
		if loginRequest.Username == "admin" {
			// greet user on success
			returnInBestCaseAdmin(ok, r, w, loginRequest, db)
			return
		} else {
			returnInWorstCase(w)
			return
		}

	})

	mux.HandleFunc("/start", func(w http.ResponseWriter, r *http.Request) {

		dialogAfterLogin, logged := readRequestAndSeeIfLogged(r, w)
		if logged {
			// greet user on success
			startTimeRecording(db, dialogAfterLogin, startTime, w)
		} else {
			rejectStartTimeRecording(w)
		}

	})

	mux.HandleFunc("/stop", func(w http.ResponseWriter, r *http.Request) {
		dialogAfterLogin, logged := readRequestAndSeeIfLogged(r, w)
		if logged {
			// greet user on success
			stopTimeRecording(db, dialogAfterLogin, endTime, w)
		} else {
			rejectStopTimeRecording(w)
		}

	})

	// Schließe inaktive Clients nach 5 Tagen
	go func() {
		for {
			time.Sleep(1 * time.Hour)
			for id, client := range clients {
				if time.Since(client.LastContact) > 5*24*time.Hour {
					delete(clients, id)
				}
			}
		}
	}()

	portString := fmt.Sprintf(":%d", webServerPort)
	http.ListenAndServe(portString, crosMux)
}

func rejectStopTimeRecording(w http.ResponseWriter) {
	response := DialogAfterLogin{}

	response.Username = "notLogin"
	answer, _ := json.Marshal(response)
	w.Write(answer)
}

func stopTimeRecording(db *c.DB, dialogAfterLogin *DialogAfterLogin, endTime time.Time, w http.ResponseWriter) {
	afterUpd, _ := db.Query("user").Skip(10).Limit(100).FindAll()
	userafterUpd := &UserDB{}
	for _, doc3 := range afterUpd {
		doc3.Unmarshal(userafterUpd)
		fmt.Println(userafterUpd)
	}

	dc, _ := db.Query("user").Where(c.Field("Username").Eq(dialogAfterLogin.Username)).FindAll()
	user := &UserDB{}
	dc[len(dc)-1].Unmarshal(user)
	endTime = time.Now()
	fmt.Println(endTime)
	fmt.Println(user.StartTime)
	diff := endTime.Sub(user.StartTime)
	fmt.Println(diff)
	user.ListOfWorkingTime = append(user.ListOfWorkingTime, WorkingTime{DateOfWorking: time.Now(), DurationOfWorking: diff})
	updates := make(map[string]interface{})
	updates["ListOfWorkingTime"] = user.ListOfWorkingTime

	db.Query("user").Where(c.Field("Username").Eq(dialogAfterLogin.Username)).Update(updates)

	worked := []DayAndWorkedTime{}
	var totalDuration = 0 * time.Hour
	day := WorkingDate{}
	day.Year, day.Month, day.Day = user.ListOfWorkingTime[0].DateOfWorking.Date()
	for i := 0; i < len(user.ListOfWorkingTime); i++ {
		toCheckDate := WorkingDate{}
		toCheckDate.Year, toCheckDate.Month, toCheckDate.Day = user.ListOfWorkingTime[i].DateOfWorking.Date()
		toCheckTime := time.Date(toCheckDate.Year, toCheckDate.Month, toCheckDate.Day, 1, 0, 0, 0, time.UTC)

		if day.isEqual(toCheckDate) {
			totalDuration = totalDuration + user.ListOfWorkingTime[i].DurationOfWorking
			if i == len(user.ListOfWorkingTime)-1 {
				if time.Now().Sub(time.Now().AddDate(0, 0, -14)) > time.Now().Sub(toCheckTime) {
					worked = append(worked, DayAndWorkedTime{Day: day, Hasworked: totalDuration.String()})
				}
			}
		} else {
			if time.Now().Sub(time.Now().AddDate(0, 0, -14)) > time.Now().Sub(time.Date(day.Year, day.Month, day.Day, 1, 0, 0, 0, time.UTC)) {
				worked = append(worked, DayAndWorkedTime{Day: day, Hasworked: totalDuration.String()})
			}
			totalDuration = user.ListOfWorkingTime[i].DurationOfWorking
			day.Year, day.Month, day.Day = user.ListOfWorkingTime[i].DateOfWorking.Date()
		}

	}
	response := DialogAfterLogin{}
	response.Dayandworkedtime = worked
	println(worked)
	response.Username = user.Username
	answer, _ := json.Marshal(response)
	w.Write(answer)
}

func rejectStartTimeRecording(w http.ResponseWriter) {
	response := DialogAfterLogin{}

	response.Username = "notLogin"
	answer, _ := json.Marshal(response)
	w.Write(answer)
}

func startTimeRecording(db *c.DB, dialogAfterLogin *DialogAfterLogin, startTime time.Time, w http.ResponseWriter) {

	dc, _ := db.Query("user").Where(c.Field("Username").Eq(dialogAfterLogin.Username)).FindAll()
	user := &UserDB{}
	dc[len(dc)-1].Unmarshal(user)
	startTime = time.Now()
	fmt.Println(startTime)
	updates := make(map[string]interface{})
	updates["StartTime"] = startTime

	err := db.Query("user").Where(c.Field("Username").Eq(dialogAfterLogin.Username)).Update(updates)
	if err != nil {

	}

	dc4, _ := db.Query("user").FindAll()

	for i := 0; i < len(dc4); i++ {
		user4 := &UserDB{}
		dc4[i].Unmarshal(user4)
	}
	dc2, _ := db.Query("user").Where(c.Field("Username").Eq(dialogAfterLogin.Username)).FindAll()
	user2 := &UserDB{}
	dc2[len(dc2)-1].Unmarshal(user2)

	worked := []DayAndWorkedTime{}
	var totalDuration = 0 * time.Hour
	day := WorkingDate{}
	if len(user.ListOfWorkingTime) > 0 {
		day.Year, day.Month, day.Day = user.ListOfWorkingTime[0].DateOfWorking.Date()
		for i := 0; i < len(user.ListOfWorkingTime); i++ {
			toCheckDate := WorkingDate{}
			toCheckDate.Year, toCheckDate.Month, toCheckDate.Day = user.ListOfWorkingTime[i].DateOfWorking.Date()
			toCheckTime := time.Date(toCheckDate.Year, toCheckDate.Month, toCheckDate.Day, 1, 0, 0, 0, time.UTC)
			x := time.Now().Sub(time.Now().AddDate(0, 0, -14))
			y := time.Now().Sub(toCheckTime)
			if x > y {
				if day.isEqual(toCheckDate) {
					totalDuration = totalDuration + user.ListOfWorkingTime[i].DurationOfWorking
					if i == len(user.ListOfWorkingTime)-1 {
						if time.Now().Sub(time.Now().AddDate(0, 0, -14)) > time.Now().Sub(toCheckTime) {
							worked = append(worked, DayAndWorkedTime{Day: day, Hasworked: totalDuration.String()})
						}
					}
				} else {
					if time.Now().Sub(time.Now().AddDate(0, 0, -14)) > time.Now().Sub(time.Date(day.Year, day.Month, day.Day, 1, 0, 0, 0, time.UTC)) {
						worked = append(worked, DayAndWorkedTime{Day: day, Hasworked: totalDuration.String()})
					}
					totalDuration = user.ListOfWorkingTime[i].DurationOfWorking
					day.Year, day.Month, day.Day = user.ListOfWorkingTime[i].DateOfWorking.Date()
				}
			}

		}
	}

	response := DialogAfterLogin{}
	response.Username = user.Username
	response.Dayandworkedtime = worked
	answer, _ := json.Marshal(response)
	w.Write(answer)
}

func readRequestAndSeeIfLogged(r *http.Request, w http.ResponseWriter) (*DialogAfterLogin, bool) {
	r.ParseForm()
	dialogAfterLogin := &DialogAfterLogin{}
	json.NewDecoder(r.Body).Decode(dialogAfterLogin)
	updated := updateCookies(r, w, dialogAfterLogin.Sessionkey)
	return dialogAfterLogin, updated
}

func returnInBestCase(ok bool, r *http.Request, w http.ResponseWriter, sessionkey string, loginRequest *LoginRequest, db *c.DB) {
	if ok {
		r.ParseForm()
		dialogAfterLogin := &DialogAfterLogin{}
		json.NewDecoder(r.Body).Decode(dialogAfterLogin)
		updated := updateCookies(r, w, dialogAfterLogin.Sessionkey)
		if updated || dialogAfterLogin.Sessionkey == "" {
			sessionkey = createCookies(r, w, loginRequest.Username)
		}

		userJson := &UserJson{}
		userJson.Username = loginRequest.Username
		doc := c.NewDocumentOf(userJson)
		dc4, _ := db.Query("user").Where(c.Field("Username").Eq(loginRequest.Username)).FindAll()

		if len(dc4) == 0 {
			db.InsertOne("user", doc)
		}

		dc43, _ := db.Query("user").FindAll()
		userafterUpd := &UserDB{}
		for _, doc3 := range dc43 {
			doc3.Unmarshal(userafterUpd)
			fmt.Println(userafterUpd)
		}

	}

	response := DialogAfterLogin{}

	response.Sessionkey = sessionkey
	response.Username = loginRequest.Username
	answer, _ := json.Marshal(response)
	w.Write(answer)
}

func returnInBestCaseAdmin(ok bool, r *http.Request, w http.ResponseWriter, loginRequest *LoginRequest, db *c.DB) {
	response := Users{}
	userName := ""
	if ok {
		r.ParseForm()
		userJson := &UserJson{}
		userJson.Username = loginRequest.Username

		dc, _ := db.Query("user").FindAll()
		user := &UserDB{}
		for _, doc3 := range dc {
			doc3.Unmarshal(user)
			if userName == "" {
				userName = user.Username
				userWorkedTime := calculateWorkedTimeForUserName(db, userName, user)
				response.UserWithWorkedTime = append(response.UserWithWorkedTime, userWorkedTime)
			}
			if userName != user.Username {
				userName = user.Username
				userWorkedTime := calculateWorkedTimeForUserName(db, userName, user)
				response.UserWithWorkedTime = append(response.UserWithWorkedTime, userWorkedTime)
			}
			fmt.Println(user)
		}

	}
	answer, _ := json.Marshal(response)
	w.Write(answer)
}

func calculateWorkedTimeForUserName(db *c.DB, userName string, user *UserDB) UserWorkedTime {
	dc2, _ := db.Query("user").Where(c.Field("Username").Eq(userName)).FindAll()
	user2 := &UserDB{}
	dc2[len(dc2)-1].Unmarshal(user2)

	worked := []DayAndWorkedTime{}
	var totalDuration = 0 * time.Hour
	day := WorkingDate{}
	if len(user.ListOfWorkingTime) > 0 {
		day.Year, day.Month, day.Day = user.ListOfWorkingTime[0].DateOfWorking.Date()
		for i := 0; i < len(user.ListOfWorkingTime); i++ {
			toCheckDate := WorkingDate{}
			toCheckDate.Year, toCheckDate.Month, toCheckDate.Day = user.ListOfWorkingTime[i].DateOfWorking.Date()
			toCheckTime := time.Date(toCheckDate.Year, toCheckDate.Month, toCheckDate.Day, 1, 0, 0, 0, time.UTC)
			x := time.Now().Sub(time.Now().AddDate(0, 0, -14))
			y := time.Now().Sub(toCheckTime)
			if x > y {
				if day.isEqual(toCheckDate) {
					totalDuration = totalDuration + user.ListOfWorkingTime[i].DurationOfWorking
					if i == len(user.ListOfWorkingTime)-1 {
						if time.Now().Sub(time.Now().AddDate(0, 0, -14)) > time.Now().Sub(toCheckTime) {
							worked = append(worked, DayAndWorkedTime{Day: day, Hasworked: totalDuration.String()})
						}
					}
				} else {
					if time.Now().Sub(time.Now().AddDate(0, 0, -14)) > time.Now().Sub(time.Date(day.Year, day.Month, day.Day, 1, 0, 0, 0, time.UTC)) {
						worked = append(worked, DayAndWorkedTime{Day: day, Hasworked: totalDuration.String()})
					}
					totalDuration = user.ListOfWorkingTime[i].DurationOfWorking
					day.Year, day.Month, day.Day = user.ListOfWorkingTime[i].DateOfWorking.Date()
				}
			}

		}
	}
	userWorkedTime := UserWorkedTime{}
	userWorkedTime.Username = userName
	userWorkedTime.Dayandworkedtime = worked
	return userWorkedTime
}

func returnInWorstCase(w http.ResponseWriter) {
	response := DialogAfterLogin{}
	response.Sessionkey = ""
	response.Username = ""
	answer, _ := json.Marshal(response)
	w.Write(answer)
}

func createCookies(r *http.Request, w http.ResponseWriter, username string) string {
	session, err := r.Cookie("session")
	if err != nil {

		session = &http.Cookie{
			Name:    "session",
			Value:   fmt.Sprintf("%d", time.Now().UnixNano()),
			Expires: time.Now().AddDate(0, 0, 5),
		}
		http.SetCookie(w, session)

		client := &Client{
			SessionKey:  session.Value,
			LastContact: time.Now(),
			Username:    username,
		}
		clients[session.Value] = client

	} else {

		session.Expires = time.Now().AddDate(0, 0, 5)
		http.SetCookie(w, session)

		client := clients[session.Value]
		client.LastContact = time.Now()

	}
	return session.Value
}

func updateCookies(r *http.Request, w http.ResponseWriter, id string) bool {

	for k := range clients {
		if k == id {
			clients[id].LastContact = time.Now()
			return true
		}
	}
	return false
}

// contact with LDAP Server using this function
func AuthUsingLDAP(username, password string) (bool, *UserLDAPData, error) {
	l, err := ldap.Dial("tcp", fmt.Sprintf("%s:%d", config.LDAPServer, config.LDAPPort))
	if err != nil {
		return false, nil, err
	}
	defer l.Close()
	err = l.Bind(config.LDAPBindDN, config.LDAPPassword)
	if err != nil {
		return false, nil, err
	}
	searchRequest := ldap.NewSearchRequest(
		config.LDAPSearchDN,
		ldap.ScopeWholeSubtree,
		ldap.NeverDerefAliases,
		0,
		0,
		false,
		fmt.Sprintf("(&(objectClass=organizationalPerson)(password=%s)(uid=%s))", password, username),
		[]string{"dn", "cn", "sn", "mail"},
		nil,
	)

	sr, err := l.Search(searchRequest)
	if err != nil {
		return false, nil, err
	}

	if len(sr.Entries) == 0 {
		return false, nil, fmt.Errorf("User not found")
	}
	entry := sr.Entries[0]
	err = l.Bind(config.LDAPBindDN, config.LDAPPassword)
	if err != nil {
		return false, nil, err
	}

	data := new(UserLDAPData)
	data.ID = username

	for _, attr := range entry.Attributes {
		switch attr.Name {
		case "sn":
			data.Name = attr.Values[0]
		case "mail":
			data.Email = attr.Values[0]
		case "cn":
			data.FullName = attr.Values[0]
		}
	}

	return true, data, nil

}
