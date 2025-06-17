package main

import (
	"context"
	"log"
	"sync"

	"github.com/Bank-Raya/bridgtl-rdv-be-cash-mgmt-sys-migration/config"
	"github.com/Bank-Raya/bridgtl-rdv-be-cash-mgmt-sys-migration/db"
	"github.com/Bank-Raya/bridgtl-rdv-be-cash-mgmt-sys-migration/db/repository"
	"github.com/google/uuid"
)

func main() {
	ctx := context.Background()

	cfg := config.New()

	conn := db.New(cfg)
	store := repository.NewStore(conn)

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

	authorization := make([]*Authorization, 0)
	authotizationFilePath := "templates/authorization.csv"

	if err := parseCsv(&authorization, authotizationFilePath); err != nil {
		panic(err)
	}

	authorizationUser := make([]*AuthorizationUser, 0)
	authotizationUserFilePath := "templates/authorization_user.csv"

	if err := parseCsv(&authorizationUser, authotizationUserFilePath); err != nil {
		panic(err)
	}

	corporateDb := make([]*repository.InsertCorporateParams, 0)

	// userSchema := new(repository.BulkInsertUserParams)

	authIDMap := map[string]string{}
	for i := range authorization {
		oldID := authorization[i].AuthID
		newID := uuid.NewString()
		authIDMap[oldID] = newID
		authorization[i].AuthID = newID
	}

	userIDMap := map[string]string{}
	corporateIDMap := map[string]string{}
	for i := range users {
		if users[i].Status != "ACTIVE" {
			continue
		} else {
			oldID := users[i].UserID
			newID := uuid.NewString()
			userIDMap[oldID] = newID
			corporateIDMap[users[i].CorporateID] = uuid.NewString()
		}
	}

	for i := range authorizationUser {
		if newID, ok := authIDMap[authorizationUser[i].AuthID]; ok {
			authorizationUser[i].AuthID = newID
		}

		if newID, ok := userIDMap[authorizationUser[i].UserID]; ok {
			authorizationUser[i].UserID = newID
		}
	}

	for i := range corporates {
		if newID, ok := corporateIDMap[corporates[i].CorporateID]; ok {
			log.Printf("[FIND-CORPORATE] find corporate id = %s", corporates[i].CorporateID)
			corporates[i].CorporateID = newID
			corporateParams := corporates[i].MapToSchema()
			corporateDb = append(corporateDb, corporateParams)
		}
	}

	for i := range users {
		if newID, ok := userIDMap[users[i].UserID]; ok {
			users[i].UserID = newID
		}

		if newID, ok := corporateIDMap[users[i].CorporateID]; ok {
			users[i].CorporateID = newID
		}
	}

	var wg sync.WaitGroup
	goroutineCtx := context.WithoutCancel(ctx)
	for _, corp := range corporateDb {
		log.Printf("[MIGRATION-CORPORATE] PROCESSING INSERT CORPORATE, ID=%s", corp.ID)
		wg.Add(1)
		go func() {
			defer wg.Done()

			errTx := store.ExecTx(goroutineCtx, func(q *repository.Queries) error {
				if _, err := q.InsertCorporate(goroutineCtx, *corp); err != nil {
					return err
				}
				log.Printf("[MIGRATION-CORPORATE] FINISH INSERT CORPORATE, ID=%s", corp.ID)
				return nil
			})

			if errTx != nil {
				log.Printf("[ERROR] failed execute corporate insertion, err=%v", errTx)
			}
		}()
	}

	wg.Wait()
}
