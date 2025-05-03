using SQLite, DataFrames, CSV
using CategoricalArrays
using MLJ
using MLJDecisionTreeInterface


# Load data from SQLite

db = SQLite.DB("../salary.db")
df = DBInterface.execute(db, """
    SELECT job_title, experience_level, location, predicted_salary
    FROM predictions
""") |> DataFrame
SQLite.close(db)

 
# Preprocess
 
# Convert to categorical and then to codes (integers)
df.job_title = categorical(df.job_title)
df.experience_level = categorical(df.experience_level)
df.location = categorical(df.location)

# Convert categorical columns to their numeric codes
df.job_title = levelcode.(df.job_title)
df.experience_level = levelcode.(df.experience_level)
df.location = levelcode.(df.location)

 
# Split into features (X) and target (y)
 
y, X = unpack(df, ==(:predicted_salary), colname -> true)
train, test = partition(eachindex(y), 0.8, shuffle=true)

 
# Train model
 
model = DecisionTreeRegressor()
mach = machine(model, X, y)
fit!(mach, rows=train)

 
# Evaluate
 
yhat = predict(mach, rows=test) |> collect
rmse = sqrt(mean((yhat .- y[test]).^2))
println("✅ RMSE: $rmse")
