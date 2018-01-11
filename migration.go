package main

import (
	"database/sql"
	"github.com/mattes/migrate"
	"github.com/mattes/migrate/database/postgres"
	_ "github.com/lib/pq"
	_ "github.com/mattes/migrate/source/file"
	"log"
	"github.com/jinzhu/gorm"
)

func main() {
	_, err := gorm.Open("postgres", "postgres://rpuser:rppass@postgres/reportportal?sslmode=disable")
	checkError(err)

	db, err := sql.Open("postgres", "postgres://rpuser:rppass@postgres/reportportal?sslmode=disable")
	checkError(err)

	driver, err := postgres.WithInstance(db, &postgres.Config{})
	checkError(err)

	m, err := migrate.NewWithDatabaseInstance(
		"file://./migrations",
		"reportportal", driver)
	checkError(err)

	m.Steps(2)
}

func checkError(err error) {
	if nil != err {
		log.Fatal(err)
	}
}
