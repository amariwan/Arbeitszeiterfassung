package main

import (
	"flag"
	"io/ioutil"
)

func readFromConfig() *LDAPConfig {
	path := "config.json"
	content, err := ioutil.ReadFile(path)
	if err != nil {
		//debugLevel.Fatal("Error when opening file: " + err.Error())
	}

	//ldapConfig := &LDAPConfig{}
	ldapConfig, _ := UnmarshalLDAPConfig(content)
	//err = json.Unmarshal(content, ldapConfig)
	return &ldapConfig

}

func parseCommandLineArguments() bool {

	var isToBeRestored bool

	flag.BoolVar(&isToBeRestored, "r", false, "if the database should be restored (default false)")

	flag.Parse()

	return isToBeRestored

}
