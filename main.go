package main

import (
	"github.com/Bank-Raya/bridgtl-rdv-be-cash-mgmt-sys-migration/db/repository"
	"github.com/google/uuid"
)

func main() {
	users := make([]*User, 0)
	filePath := "templates/user.csv"

	if err := parseCsv(&users, filePath); err != nil {
		panic(err)
	}

	corporates := make([]*Corporate, 0)
	corporateFilePath := "templates/corporate.csv"

	if err := parseCsv(&corporates, corporateFilePath); err != nil {
		panic(err)
	}

	corporateDb := make([]*repository.InsertCorporateParams, 0)

	userSchema := new(repository.BulkInsertUserParams)

	for j, corp := range corporates {
		corporateSchema := new(repository.InsertCorporateParams)

		corporateId := uuid.NewString()
		corporates[j].CorporateID = corporateId

		for i, user := range users {
			if user.Status != "ACTIVE" {
				continue
			}

			userId := uuid.NewString()
			users[i].UserID = userId

			if corp.CorporateID == user.CorporateID {
				corporates[j].CorporateID = corporateId
				users[i].CorporateID = corporateId
				users[i].MapToSchema(userSchema)
			}

		}

		corporates[j].MapToSchema(corporateSchema)
		corporateDb = append(corporateDb, corporateSchema)
	}
}
