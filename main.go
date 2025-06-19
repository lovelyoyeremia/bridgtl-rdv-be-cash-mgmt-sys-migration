package main

import (
	"context"
	"log"
	"sync"
	"sync/atomic"

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

	account := make([]*Account, 0)
	accountFilePath := "templates/account.csv"

	if err := parseCsv(&account, accountFilePath); err != nil {
		panic(err)
	}

	deposito := make([]*Deposito, 0)
	depositoFilePath := "templates/deposito.csv"

	if err := parseCsv(&deposito, depositoFilePath); err != nil {
		panic(err)
	}

	corporateDb := make([]*repository.InsertCorporateParams, 0)
	userDb := make([]*repository.InsertUserParams, 0)
	authorizationDb := make([]*repository.InsertUserAuthorizationParams, 0)
	authorizationAccessDb := make([]*repository.InsertUserAuthorizationAccessParams, 0)
	accountDb := make([]*repository.InsertAccountParams, 0)

	userIDMap := make(map[string]string)
	corporateIDMap := make(map[string]string)
	makerMap := make(map[string]string)
	for i := range users {
		if users[i].Status != "ACTIVE" {
			continue
		} else {
			oldID := users[i].UserID
			newID := uuid.NewString()
			userIDMap[oldID] = newID
			corporateIDMap[users[i].CorporateID] = uuid.NewString()
			userRole := checkRole(users[i].UserCode)

			if userRole == "ADMIN" || userRole == "MAKER" {
				if _, ok := makerMap[users[i].CorporateID]; !ok {
					makerMap[users[i].CorporateID] = newID
				}
			}
		}
	}

	for i := range corporates {
		if newID, ok := corporateIDMap[corporates[i].CorporateID]; ok {
			corporates[i].CorporateID = newID
			corporateParams := corporates[i].MapToSchema()
			corporateDb = append(corporateDb, corporateParams)
		}
	}

	for i := range users {
		if newID, ok := userIDMap[users[i].UserID]; ok {
			users[i].UserID = newID
			if corporateID, ok := corporateIDMap[users[i].CorporateID]; ok {
				userRole := checkRole(users[i].UserCode)

				if userRole != "" {
					authorizationSchema := new(repository.InsertUserAuthorizationParams)
					if makerID, ok := makerMap[users[i].CorporateID]; ok {
						authorizationSchema.MakerID = StringToPgtypeUuid(makerID)
						authorizationSchema.ID = uuid.New()
						authorizationSchema.CorporateID = StringToPgtypeUuid(corporateID)
						authorizationSchema.Status = StringToPgtypeText("APPROVED")
						authorizationSchema.Type = StringToPgtypeText("ADD-USER")

						authorizationUserAccessSchema := new(repository.InsertUserAuthorizationAccessParams)
						authorizationUserAccessSchema.AuthorizationID = StringToPgtypeUuid(authorizationSchema.ID.String())
						authorizationUserAccessSchema.Status = StringToPgtypeText("1")
						authorizationUserAccessSchema.Type = userRole
						authorizationUserAccessSchema.UserID = uuid.MustParse(newID)

						userSchema := new(repository.InsertUserParams)
						users[i].CorporateID = corporateID
						users[i].MapToSchema(userSchema)
						userDb = append(userDb, userSchema)
						authorizationDb = append(authorizationDb, authorizationSchema)
						authorizationAccessDb = append(authorizationAccessDb, authorizationUserAccessSchema)
					}
				}
			}
		}
	}

	for i := range account {
		if corpID, ok := corporateIDMap[account[i].CorporateID]; ok {
			accountDbSchema := new(repository.InsertAccountParams)
			accountDbSchema.AccountName = account[i].AccountName
			accountDbSchema.AccountNumber = account[i].AccountNumber
			accountDbSchema.Accessibility = StringToPgtypeText(account[i].Accessibility)
			accountDbSchema.Ownership = StringToPgtypeText(account[i].Ownership)
			accountDbSchema.CorporateID = StringToPgtypeUuid(corpID)
			accountDbSchema.Currency = StringToPgtypeText(account[i].Currency)
			accountDbSchema.IsActive = BoolToPgtypeBool(true)
			accountDbSchema.AccountType = "GIRO"
			accountDb = append(accountDb, accountDbSchema)
		}
	}

	for i := range deposito {
		if corpID, ok := corporateIDMap[deposito[i].CorporateID]; ok {
			accountDbSchema := new(repository.InsertAccountParams)
			accountDbSchema.AccountName = deposito[i].AccountName
			accountDbSchema.AccountNumber = deposito[i].AccountNumber
			accountDbSchema.Break = StringToPgtypeText(deposito[i].Break)
			accountDbSchema.Maturity = StringToPgtypeText(deposito[i].Maturity)
			accountDbSchema.CorporateID = StringToPgtypeUuid(corpID)
			accountDbSchema.Currency = StringToPgtypeText(deposito[i].Currency)
			accountDbSchema.IsActive = BoolToPgtypeBool(true)
			accountDbSchema.AccountType = "TABUNGAN"
			accountDb = append(accountDb, accountDbSchema)
		}
	}

	successCorpCount, failedCorpCount := insertCorporate(ctx, corporateDb, store)
	successUserCount, failedUserCount := insertUser(ctx, userDb, store)
	successAuthorizationCount, failedAuthorizationCount := insertAuthorization(ctx, authorizationDb, store)
	successAuthorizationAccessCount, failedAuthorizationAccessCount := insertAuthorizationAccess(ctx, authorizationAccessDb, store)
	successAccountCount, failedAccountCount := insertAccount(ctx, accountDb, store)

	if err := store.UpdateCorporateAdminFee(ctx); err != nil {
		log.Fatal(err)
	}

	log.Printf("[MIGRATION] TOTAL FAILED CORPORATE = %d, TOTAL SUCCESS CORPORATE = %d", failedCorpCount, successCorpCount)
	log.Printf("[MIGRATION] TOTAL FAILED USER = %d, TOTAL SUCCESS USER = %d", failedUserCount, successUserCount)
	log.Printf("[MIGRATION] TOTAL FAILED AUTHORIZATION = %d, TOTAL SUCCESS AUTHORIZATION = %d", failedAuthorizationCount, successAuthorizationCount)
	log.Printf("[MIGRATION] TOTAL FAILED ACCOUNT = %d, TOTAL SUCCESS ACCOUNT = %d", failedAccountCount, successAccountCount)
	log.Printf("[MIGRATION] TOTAL FAILED AUTHORIZATION ACCESS = %d, TOTAL SUCCESS AUTHORIZATION ACCESS = %d", failedAuthorizationAccessCount, successAuthorizationAccessCount)
}

func insertAuthorization(ctx context.Context, authorizationDb []*repository.InsertUserAuthorizationParams, store *repository.Store) (successCount, failedCount int64) {
	var wgAuth sync.WaitGroup
	for _, auth := range authorizationDb {
		log.Printf("[MIGRATION-AUTH] PROCESSING INSERT AUTH, ID=%s", auth.ID)
		wgAuth.Add(1)

		go func(c *repository.InsertUserAuthorizationParams) {
			defer wgAuth.Done()

			if _, err := store.InsertUserAuthorization(ctx, *c); err != nil {
				atomic.AddInt64(&failedCount, 1)
				log.Printf("[ERROR] failed execute auth insertion, err=%v", err)
			} else {
				atomic.AddInt64(&successCount, 1)
			}
		}(auth)
	}

	wgAuth.Wait()
	return
}

func insertAuthorizationAccess(ctx context.Context, authorizationDb []*repository.InsertUserAuthorizationAccessParams, store *repository.Store) (successCount, failedCount int64) {
	var wgAuth sync.WaitGroup
	for _, auth := range authorizationDb {
		log.Printf("[MIGRATION-AUTH] PROCESSING INSERT AUTH ACCESS, ID=%s", auth.AuthorizationID)
		wgAuth.Add(1)

		go func(c *repository.InsertUserAuthorizationAccessParams) {
			defer wgAuth.Done()

			if err := store.InsertUserAuthorizationAccess(ctx, *c); err != nil {
				atomic.AddInt64(&failedCount, 1)
				log.Printf("[ERROR] failed execute auth access insertion, err=%v", err)
			} else {
				atomic.AddInt64(&successCount, 1)
			}
		}(auth)
	}

	wgAuth.Wait()
	return
}

func insertAccount(ctx context.Context, accountDb []*repository.InsertAccountParams, store *repository.Store) (successCount, failedCount int64) {
	var wgAcc sync.WaitGroup
	for _, acc := range accountDb {
		log.Printf("[MIGRATION-ACCOUNT] PROCESSING INSERT ACCOUNT, NAME=%s", acc.AccountName)
		wgAcc.Add(1)

		go func(c *repository.InsertAccountParams) {
			defer wgAcc.Done()

			if err := store.InsertAccount(ctx, *c); err != nil {
				atomic.AddInt64(&failedCount, 1)
				log.Printf("[ERROR] failed execute account insertion, err=%v", err)
			} else {
				atomic.AddInt64(&successCount, 1)
			}
		}(acc)
	}

	wgAcc.Wait()
	return
}

func insertCorporate(ctx context.Context, corporateDb []*repository.InsertCorporateParams, store *repository.Store) (successCount, failedCount int64) {
	var wgCorporate sync.WaitGroup
	for _, corp := range corporateDb {
		log.Printf("[MIGRATION-CORPORATE] PROCESSING INSERT CORPORATE, ID=%s", corp.ID)
		wgCorporate.Add(1)

		go func(c *repository.InsertCorporateParams) {
			defer wgCorporate.Done()

			errTx := store.ExecTx(ctx, func(q *repository.Queries) error {
				corp, err := q.InsertCorporate(ctx, *c)
				if err != nil {
					return err
				}

				if err := q.InsertTransactionSetting(ctx, StringToPgtypeUuid(corp.ID.String())); err != nil {
					return err
				}

				return nil
			})

			if errTx != nil {
				atomic.AddInt64(&failedCount, 1)
				log.Printf("[ERROR] failed execute corporate insertion, err=%v", errTx)
			} else {
				atomic.AddInt64(&successCount, 1)
			}
		}(corp)
	}

	wgCorporate.Wait()

	return
}

func insertUser(ctx context.Context, userDb []*repository.InsertUserParams, store *repository.Store) (successCount, failedCount int64) {
	var wgUser sync.WaitGroup
	for _, user := range userDb {
		log.Printf("[MIGRATION-USER] PROCESSING INSERT USER, ID=%s", user.ID)
		wgUser.Add(1)

		go func(c *repository.InsertUserParams) {
			defer wgUser.Done()

			if _, err := store.InsertUser(ctx, *c); err != nil {
				atomic.AddInt64(&failedCount, 1)
				log.Printf("[ERROR] failed execute User insertion, err=%v", err)
			} else {
				atomic.AddInt64(&successCount, 1)
			}
		}(user)
	}

	wgUser.Wait()

	return
}
