package main

import (
	"database/sql"
	"encoding/json"
	"log"
	"net/http"

	_ "modernc.org/sqlite"
)

type PredictionRequest struct {
	JobTitle   string `json:"job_title"`
	Experience string `json:"experience_level"`
	Location   string `json:"location"`
}

type PredictionResponse struct {
	PredictedSalary float64 `json:"predicted_salary"`
}

func main() {
	// Connect to the SQLite database
	db, err := sql.Open("sqlite", "../salary.db")
	if err != nil {
		log.Fatalf("❌ Failed to open database: %v", err)
	}
	defer db.Close()

	// Define /predict route
	http.HandleFunc("/predict", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		var req PredictionRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "Invalid JSON", http.StatusBadRequest)
			return
		}

		var salary float64
		err = db.QueryRow(`
			SELECT predicted_salary FROM predictions
			WHERE job_title = ? AND experience_level = ? AND location = ?
			ORDER BY RANDOM() LIMIT 1
		`, req.JobTitle, req.Experience, req.Location).Scan(&salary)

		if err != nil {
			http.Error(w, "No prediction found", http.StatusNotFound)
			return
		}

		resp := PredictionResponse{PredictedSalary: salary}
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(resp)
	})

	log.Println("Server running at http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
