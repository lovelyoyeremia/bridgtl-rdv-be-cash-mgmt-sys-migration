package main

import (
	"github.com/Bank-Raya/bridgtl-rdv-be-cash-mgmt-sys-migration/db/repository"
	"github.com/google/uuid"
)

func (u *User) MapToSchema(r *repository.BulkInsertUserParams) {
	r.CorporateID = append(r.CorporateID, uuid.MustParse(u.CorporateID))
	r.Name = append(r.Name, u.UserName)
	r.Address = append(r.Address, u.AlamatID)
	r.Code = append(r.Code, u.UserCode)
	r.Dob = append(r.Dob, u.TanggalLahir.Time)
	r.Email = append(r.Email, u.Email)
	r.ID = append(r.ID, uuid.MustParse(u.UserID))
	r.IdentityCreatedBy = append(r.IdentityCreatedBy, u.PenerbitIdentitas)
	r.IdentityExpired = append(r.IdentityExpired, StringToPgtypeTimestamptz(u.BerlakuIdentitas).Time)
	r.IdentityNo = append(r.IdentityNo, u.NomorIdentitas)
	r.IdentityType = append(r.IdentityType, u.JenisIdentitas)
	r.MotherName = append(r.MotherName, u.NamaIbu)
	r.NoHandphone = append(r.NoHandphone, u.Handphone)
	r.NoTelepon = append(r.NoTelepon, u.Telepon)
	r.Pob = append(r.Pob, u.TempatLahir)
	r.Position = append(r.Position, u.Jabatan)
	r.PasswordList = append(r.PasswordList, u.UserPasswordList)
	r.PublicIp = append(r.PublicIp, u.IPPublic)
	r.RestrictIp = append(r.RestrictIp, u.RestrictIP.bool)
}

func (c *Corporate) MapToSchema(r *repository.InsertCorporateParams) {
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
