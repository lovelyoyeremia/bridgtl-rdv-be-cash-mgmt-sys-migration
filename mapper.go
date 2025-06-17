package main

import (
	"time"

	"github.com/Bank-Raya/bridgtl-rdv-be-cash-mgmt-sys-migration/db/repository"
	"github.com/google/uuid"
)

func (u *User) MapToSchema(r *repository.User) {
	r.CorporateID = uuid.MustParse(u.CorporateID)
	r.Name = u.UserName
	r.Address = StringToPgtypeText(u.AlamatID)
	r.Code = u.UserCode
	r.CreatedAt = StringToPgtypeTimestamptz(u.CreatedDate.Format(time.DateTime))
	r.Dob = StringToPgtypeDate(u.TanggalLahir.Format(time.DateOnly))
	r.Email = StringToPgtypeText(u.Email)
	r.ID = uuid.MustParse(u.UserID)
	r.IdentityCreatedBy = StringToPgtypeText(u.PenerbitIdentitas)
	r.IdentityExpired = StringToPgtypeDate(u.BerlakuIdentitas)
	r.IdentityNo = StringToPgtypeText(u.NomorIdentitas)
	r.IdentityType = StringToPgtypeText(u.JenisIdentitas)
	r.MotherName = StringToPgtypeText(u.NamaIbu)
	r.LastDateCp = StringToPgtypeTimestamptz(u.LastDateCP)
	r.NoHandphone = StringToPgtypeText(u.Handphone)
	r.NoTelepon = StringToPgtypeText(u.Telepon)
	r.Pob = StringToPgtypeText(u.TempatLahir)
	r.Position = StringToPgtypeText(u.Jabatan)
	r.PasswordList = StringToPgtypeText(u.UserPasswordList)
	r.PublicIp = StringToPgtypeText(u.IPPublic)
	r.RestrictIp = BoolToPgtypeBool(u.RestrictIP.bool)
	r.Status = UserStatusToPgtypeUserStatus(repository.UserStatus(u.Status))
}

func (c *Corporate) MapToSchema(r *repository.InsertCorporateParams) {
	r.ID = uuid.MustParse(c.CorporateID)
	r.AbonemenCode = StringToPgtypeText(c.Abonemen)
	r.Address = StringToPgtypeText(c.Alamat)
	r.AddressCity = StringToPgtypeText(c.Kota)
	r.AddressPostalCode = StringToPgtypeText(c.Kodepos)
	r.AddressProvince = StringToPgtypeText(c.Propinsi)
	r.AddressSubDistrict = StringToPgtypeText(c.Kecamatan)
	r.AddressVillage = c.Kelurahan
	r.AmendmentDeedDate = StringToPgtypeDate(c.TanggalAktaPendirian)
	r.AmendmentDeedNumber = StringToPgtypeText(c.AktaPendirian)

	r.ApprovalSignerCount = int16(c.ApprovalSignerCount)
	r.ApprovalCheckerCount = int16(c.ApprovalCheckerCount)
	r.ApprovalType = StringToPgtypeText(c.ApprovalMode)
	r.BookingOfficeCode = StringToPgtypeText(c.BookingOffice)

	r.BusinessEntityType = StringToPgtypeText(c.JenisPerusahaan)
	r.Cif = StringToPgtypeText(c.CIFPerusahaan)
	r.BusinessGroupType = StringToPgtypeText(c.BidangUsaha)
	r.CustomerNumber = StringToPgtypeText(c.NPWP)
}
