package main

import (
	"time"

	"github.com/Bank-Raya/bridgtl-rdv-be-cash-mgmt-sys-migration/db/repository"
	"github.com/google/uuid"
)

func (u *User) MapToSchema(r *repository.InsertUserParams) {
	r.CorporateID = uuid.MustParse(u.CorporateID)
	r.Name = u.UserName
	r.Address = StringToPgtypeText(u.AlamatID)
	r.Code = u.UserCode
	r.Dob = StringToPgtypeDate(u.TanggalLahir.Format(time.DateOnly))
	r.Email = StringToPgtypeText(u.Email)
	r.ID = uuid.MustParse(u.UserID)
	r.IdentityCreatedBy = StringToPgtypeText(u.PenerbitIdentitas)
	r.IdentityExpired = StringToPgtypeDate(u.BerlakuIdentitas)
	r.CreatedBy = StringToPgtypeUuid(u.CreatedBy)
	r.IdentityNo = StringToPgtypeText(u.NomorIdentitas)
	r.IdentityType = StringToPgtypeText(u.JenisIdentitas)
	r.MotherName = StringToPgtypeText(u.NamaIbu)
	r.NoHandphone = StringToPgtypeText(u.Handphone)
	r.NoTelepon = StringToPgtypeText(u.Telepon)
	r.Pob = StringToPgtypeText(u.TempatLahir)
	r.Position = StringToPgtypeText(u.Jabatan)
	r.PublicIp = StringToPgtypeText(u.IPPublic)
	r.RestrictIp = BoolToPgtypeBool(u.RestrictIP.bool)
	r.Status = UserStatusToPgtypeUserStatus(repository.UserStatus(u.Status))
}

func (a *Authorization) MapToSchema(r *repository.InsertUserAuthorizationParams) {
	r.ID = uuid.MustParse(a.AuthID)
	r.CorporateID = StringToPgtypeUuid(a.CorporateID)
	r.Description = StringToPgtypeText(a.Description)
	r.MakerID = StringToPgtypeUuid(a.MakerID)
	r.MakerIp = StringToPgtypeText(a.MakerIP)
	r.NewData = nil
	r.OldData = nil
	r.Status = StringToPgtypeText("MIGRATION")

	var authType string
	switch a.Type {
	case "ADD USER", "ACTIVATE USER":
		authType = "ADD-USER"
	case "MAINTENANCE USER AUTHORITY":
		authType = "EDIT-USER"
	case "SUSPEND USER":
		authType = "DELETE-USER"
	default:
		authType = a.Type
	}

	r.Type = StringToPgtypeText(authType)
}

func (a *AuthorizationUser) MapToSchema(r *repository.InsertUserAuthorizationAccessParams) {
	r.AuthorizationID = StringToPgtypeUuid(a.AuthID)
	r.AuthorizationIp = StringToPgtypeText(a.AuthIP)
	r.Status = StringToPgtypeText(a.Status)
	r.Type = a.Type
	r.UserID = uuid.MustParse(a.UserID)
}

func (c *Corporate) MapToSchema() *repository.InsertCorporateParams {
	return &repository.InsertCorporateParams{
		ID:                      uuid.MustParse(c.CorporateID),
		AbonemenCode:            StringToPgtypeText(c.Abonemen),
		Address:                 StringToPgtypeText(c.Alamat),
		AddressCity:             StringToPgtypeText(c.Kota),
		AddressPostalCode:       StringToPgtypeText(c.Kodepos),
		AddressProvince:         StringToPgtypeText(c.Propinsi),
		AddressSubDistrict:      StringToPgtypeText(c.Kecamatan),
		AddressVillage:          c.Kelurahan,
		AmendmentDeedDate:       StringToPgtypeDate(c.TanggalAktaPerubahan),
		AmendmentDeedNumber:     StringToPgtypeText(c.AktaPerubahan),
		ApprovalSignerCount:     int16(c.ApprovalSignerCount),
		ApprovalCheckerCount:    int16(c.ApprovalCheckerCount),
		ApprovalType:            StringToPgtypeText(c.ApprovalMode),
		BookingOfficeCode:       StringToPgtypeText(c.BookingOffice),
		BusinessEntityType:      StringToPgtypeText(c.JenisPerusahaan),
		Cif:                     StringToPgtypeText(c.CIFPerusahaan),
		BusinessGroupType:       StringToPgtypeText(c.BidangUsaha),
		Npwp:                    StringToPgtypeText(c.NPWP),
		Code:                    c.CorporateCode,
		Name:                    c.CorporateName,
		Role:                    "CLIENT",
		BusinessSector:          StringToPgtypeText(c.BidangUsaha),
		LegalStatus:             StringToPgtypeText(c.JenisPerusahaan),
		EstablishmentPlace:      StringToPgtypeText(c.TempatPendirian),
		LicenseType:             StringToPgtypeText(c.Legalitas),
		LicenseNumber:           StringToPgtypeText(c.NoLegalitas),
		LicenseIssueDate:        StringToPgtypeDate(c.TanggalTerbit),
		LicenseExpiryDate:       StringToPgtypeDate(c.TanggalKadaluarsa),
		EstablishmentDeedNumber: StringToPgtypeText(c.AktaPendirian),
		EstablishmentDeedDate:   StringToPgtypeDate(c.TanggalAktaPendirian),
		PhoneNumber:             StringToPgtypeText(c.Telepon),
		Fax:                     StringToPgtypeText(c.Facsimile),
		Email:                   StringToPgtypeText(c.Email),
		DailyLimit:              IntToPgtypeNumeric(int(c.LimitTotal.float64)),
		TransactionLimit:        IntToPgtypeNumeric(int(c.LimitRupiah.float64)),
		InitiatorPersonalNumber: StringToPgtypeText(c.AktaPendirian),
		InitiatorName:           StringToPgtypeText(c.AktaPendirian),
		InitiatorWorkUnit:       StringToPgtypeText(c.AktaPendirian),
		Status:                  StringToPgtypeText("ACTIVE"),
	}
}
