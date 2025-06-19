package main

type User struct {
	UserID       string   `csv:"user_id"`
	CorporateID  string   `csv:"corporate_id"`
	UserCode     string   `csv:"user_code"`
	UserName     string   `csv:"user_name"`
	UserPassword string   `csv:"-"`
	CreatedBy    string   `csv:"created_by"`
	CreatedDate  DateTime `csv:"created_date"`
	Jabatan      string   `csv:"jabatan"`

	Telepon          string `csv:"telepon"`
	Handphone        string `csv:"handphone"`
	Email            string `csv:"email"`
	JenisIdentitas   string `csv:"jenis_identitas"`
	NomorIdentitas   string `csv:"nomor_identitas"`
	BerlakuIdentitas string `csv:"berlaku_identitas"`

	PenerbitIdentitas string        `csv:"penerbit_identitas"`
	TempatLahir       string        `csv:"tempat_lahir"`
	TanggalLahir      DateTimeSlash `csv:"tanggal_lahir"`
	AlamatID          string        `csv:"alamat_id"`
	NamaIbu           string        `csv:"nama_ibu"`
	RestrictIP        Boolean       `csv:"restrict_ip"`
	IPPublic          string        `csv:"ip_public"`
	Status            string        `csv:"status"`

	UserPasswordList string `csv:"user_password_list"`
	LastDateCP       string `csv:"last_date_cp"`
}

type Corporate struct {
	CorporateID      string   `csv:"corporate_id"`
	CorporateCode    string   `csv:"corporate_code"`
	CorporateName    string   `csv:"corporate_name"`
	Type             string   `csv:"type"`
	CreatedBy        string   `csv:"created_by"`
	CreatedDate      DateTime `csv:"created_date"`
	KelompokUsaha    string   `csv:"kelompok_usaha"`
	JenisPerusahaan  string   `csv:"jenis_perusahaan"`
	BidangUsaha      string   `csv:"bidang_usaha"`
	BentukPerusahaan string   `csv:"bentuk_perusahaan"`
	TempatPendirian  string   `csv:"tempat_pendirian"`

	Legalitas            string `csv:"legalitas"`
	NoLegalitas          string `csv:"no_legalitas"`
	TanggalTerbit        string `csv:"tanggal_terbit"`
	TanggalKadaluarsa    string `csv:"tanggal_kadaluarsa"`
	AktaPendirian        string `csv:"akta_pendirian"`
	TanggalAktaPendirian string `csv:"tanggal_aktapendirian"`
	AktaPerubahan        string `csv:"akta_perubahan"`
	TanggalAktaPerubahan string `csv:"tanggal_aktaperubahan"`
	NPWP                 string `csv:"npwp"`
	Alamat               string `csv:"alamat"`
	Kodepos              string `csv:"kodepos"`
	Kelurahan            string `csv:"kelurahan"`

	Kecamatan string `csv:"kecamatan"`
	Kota      string `csv:"kota"`
	Propinsi  string `csv:"propinsi"`
	Telepon   string `csv:"telepon"`

	Facsimile string `csv:"facsimile"`
	Email     string `csv:"email"`

	Keterangan  string  `csv:"keterangan"`
	LimitRupiah Float64 `csv:"limit_rupiah"`
	LimitValas  Float64 `csv:"limit_valas"`

	LimitTotal           Float64 `csv:"limit_total"`
	MaxUser              int     `csv:"max_user"`
	BookingOffice        string  `csv:"booking_office"`
	Pemrakarsa           string  `csv:"pemrakarsa"`
	Rekening             string  `csv:"rekening"`
	NamaRekening         string  `csv:"nama_rekening"`
	Status               string  `csv:"status"`
	Abonemen             string  `csv:"abonemen"`
	CIFPerusahaan        string  `csv:"cif_perusahaan"`
	ApprovalMode         string  `csv:"approval_mode"`
	ApprovalCheckerCount int     `csv:"approval_checker_count"`
	ApprovalSignerCount  int     `csv:"approval_signer_count"`
}

type Authorization struct {
	AuthID      string `csv:"auth_id"`
	Type        string `csv:"type"`
	TranType    string `csv:"tran_type"`
	CorporateID string `csv:"corporate_id"`
	MakerID     string `csv:"maker_id"`
	CheckerID   string `csv:"checker_id"`
	SignerID    string `csv:"signer_id"`
	MakerIP     string `csv:"maker_ip"`
	CheckerIP   string `csv:"checker_ip"`
	SignerIP    string `csv:"signer_ip"`
	TranDate    string `csv:"tran_date"`
	CheckDate   string `csv:"check_date"`
	SignDate    string `csv:"sign_date"`
	RejectID    string `csv:"reject_id"`
	RejectIP    string `csv:"reject_ip"`
	RejectDate  string `csv:"reject_date"`
	OldData     string `csv:"olddata"`
	Data        string `csv:"data"`
	Status      string `csv:"status"`
	Description string `csv:"description"`
	AuthMode    string `csv:"auth_mode"`
}

type AuthorizationUser struct {
	AuthID   string `csv:"auth_id"`
	UserID   string `csv:"user_id"`
	Status   string `csv:"status"`
	AuthDate string `csv:"auth_date"`
	AuthIP   string `csv:"auth_ip"`
	Type     string `csv:"type"`
}

type Account struct {
	CorporateID   string `csv:"corporate_id"`
	AccountNumber string `csv:"account"`
	AccountName   string `csv:"account_name"`
	Ownership     string `csv:"ownership"`
	Accessibility string `csv:"accessibility"`
	Currency      string `csv:"currency"`
}

type Deposito struct {
	CorporateID   string `csv:"corporate_id"`
	AccountNumber string `csv:"account"`
	AccountName   string `csv:"account_name"`
	Maturity      string `csv:"maturity"`
	Break         string `csv:"break"`
	Currency      string `csv:"currency"`
}
