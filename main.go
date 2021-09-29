package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"takeoff-projects/artem_z_events_api/eventsdb"

	"github.com/gorilla/mux"
)

// Event model
type Event struct {
	ID       string `json:"id"`
	Title    string `json:"title"`
	Location string `json:"location"`
	When     string `json:"when"`
}

// Events array
var Events []Event

func home(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Welcome to the Events API!")
	fmt.Println("Endpoint Hit: homeP")
}

func handleRequests() {
	myRouter := mux.NewRouter().StrictSlash(true)
	myRouter.HandleFunc("/", home)
	myRouter.HandleFunc("/events", getEvents).Methods("GET")
	myRouter.HandleFunc("/events/{id}", getEventbyID).Methods("GET")
	myRouter.HandleFunc("/events", createEvent).Methods("POST")
	myRouter.HandleFunc("/events/{id}", updateEvent).Methods("PUT")
	myRouter.HandleFunc("/events/{id}", deleteEvent).Methods("DELETE")

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("Server running on Port: %s\n", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), myRouter))
}

func getEvents(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Endpoint Hit: getEvents")
	events := eventsdb.GetEvents()
	json.NewEncoder(w).Encode(events)
}

func getEventbyID(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Endpoint Hit: getEventbyID")
	vars := mux.Vars(r)
	key := vars["id"]

	fmt.Printf("Key: %s\n", key)

	event, err := eventsdb.GetEventbyID(key)
	if err != nil {
		fmt.Println("GetEventbyID returned error :(")
	}
	fmt.Println("Requested event: ", event)
	json.NewEncoder(w).Encode(event)
}

func createEvent(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Endpoint Hit: createEvent")

	reqBody, _ := ioutil.ReadAll(r.Body)
	var event eventsdb.Event
	json.Unmarshal(reqBody, &event)

	eventsdb.AddEvent(event)

	json.NewEncoder(w).Encode(event)
}

func updateEvent(w http.ResponseWriter, r *http.Request) {

	vars := mux.Vars(r)
	id := vars["id"]

	fmt.Println("Endpoint Hit: updateEvent")

	reqBody, _ := ioutil.ReadAll(r.Body)
	var event eventsdb.Event
	json.Unmarshal(reqBody, &event)

	eventsdb.UpdateEvent(id, event)

	json.NewEncoder(w).Encode(event)
}

func deleteEvent(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]
	eventsdb.DeleteEvent(id)
}

func main() {
	handleRequests()
}
