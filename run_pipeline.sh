#!/bin/bash

echo "Resetting database..."
sqlite3 salary.db < init.sql

echo "Populating with Python..."
python3 utl.py

echo "Training model in Julia..."
julia --project=Julia Julia/train_model.jl

echo "Starting Go API..."
cd go-api
go run main.go
