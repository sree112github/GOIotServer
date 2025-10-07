package db

// import (
//     "database/sql"
//     "log"

//     _ "github.com/lib/pq"
// )

// var DB *sql.DB

// func Init() {
//     var err error
//     DB, err = sql.Open("postgres", "postgres://postgres:148115@localhost:5432/samyojak?sslmode=disable")
//     if err != nil {
//         log.Fatal("failed to connect to database:", err)
//     }
//     if err = DB.Ping(); err != nil {
//         log.Fatal("database unreachable:", err)
//     }
// }
