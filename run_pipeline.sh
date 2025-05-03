#!/bin/bash
set -e 

echo "Resetting database..."
sqlite3 salary.db < init.sql

echo "**************************************************"

echo "Populating with Python..."
python3 utl.py

echo "**************************************************"

echo "Training model in Julia..."
julia --project=Julia Julia/train_model.jl

echo "**************************************************"

echo "Starting Go API at http://localhost:8080"
cd go-api
go run main.go
