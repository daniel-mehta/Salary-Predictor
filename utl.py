import sqlite3
import csv
from datetime import datetime

DB_PATH = "salary.db"
CSV_PATH = "data/salaries.csv"

def populate_database(db_path=DB_PATH, csv_path=CSV_PATH):
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()

    with open(csv_path, newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        inserted = 0

        for row in reader:
            try:
                job_title = row['job_title']
                experience = row['experience_level']
                location = row['employee_residence']
                salary = float(row['salary_in_usd'])
            except (ValueError, KeyError):
                continue

            cur.execute("""
                INSERT INTO predictions (job_title, experience_level, location, predicted_salary, created_at)
                VALUES (?, ?, ?, ?, ?)
            """, (job_title, experience, location, salary, datetime.now()))
            inserted += 1

    conn.commit()
    conn.close()
    print(f"✅ Inserted {inserted} records into '{db_path}'.")

if __name__ == "__main__":
    populate_database()
