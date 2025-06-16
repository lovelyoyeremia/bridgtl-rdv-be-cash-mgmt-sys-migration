package main

import (
	"math/big"
	"time"

	"github.com/Bank-Raya/bridgtl-rdv-be-cash-mgmt-sys-migration/db/repository"
	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
)

func StringToPgtypeText(input string) pgtype.Text {
	return pgtype.Text{String: input, Valid: input != ""}
}

func IntToPgtypeInt4(input int) pgtype.Int4 {
	return pgtype.Int4{Int32: int32(input), Valid: input != 0}
}

func IntToPgtypeInt2(input int) pgtype.Int2 {
	return pgtype.Int2{Int16: int16(input), Valid: input != 0}
}

func StringToPgtypeDate(input string) pgtype.Date {
	date, err := time.Parse(time.DateOnly, input)
	if err != nil {
		return pgtype.Date{}
	}
	return pgtype.Date{Time: date, Valid: true}
}

func StringToPgtypeTimestamptz(input string) pgtype.Timestamptz {
	date, err := time.Parse(time.DateTime, input)
	if err != nil {
		return pgtype.Timestamptz{}
	}
	return pgtype.Timestamptz{Time: date, Valid: true}
}

func BoolToPgtypeBool(input bool) pgtype.Bool {
	return pgtype.Bool{Bool: input, Valid: true}
}

func UserStatusToPgtypeUserStatus(input repository.UserStatus) repository.NullUserStatus {
	return repository.NullUserStatus{UserStatus: input, Valid: true}
}

func StringToPgtypeUuid(input string) pgtype.UUID {
	uuid, err := uuid.Parse(input)
	if err != nil {
		return pgtype.UUID{}
	}
	return pgtype.UUID{Bytes: uuid, Valid: true}
}

func PgtypeTimestamptzNow() pgtype.Timestamptz {
	return pgtype.Timestamptz{Time: time.Now(), Valid: true}
}

func IntToPgtypeNumeric(input int) pgtype.Numeric {
	return pgtype.Numeric{Int: big.NewInt(int64(input)), Valid: input != 0}
}

func PgTypeNumericToInt(input pgtype.Numeric) int {
	floatInput, _ := input.Float64Value()
	return int(floatInput.Float64)
}

func PgTypeNumericToFloat(input pgtype.Numeric) float64 {
	floatInput, _ := input.Float64Value()
	return floatInput.Float64
}

// StringSliceToUUIDSlice converts a slice of strings to a slice of UUIDs.
func StringSliceToUUIDSlice(input []string) []uuid.UUID {
	var uuids []uuid.UUID
	for _, str := range input {
		if id, err := uuid.Parse(str); err == nil {
			uuids = append(uuids, id)
		}
	}
	return uuids
}

func StringToTimestamp(input string) (pgtype.Timestamp, error) {
	var timestamp pgtype.Timestamp
	t, err := time.Parse("2006-01-02 15:04:05", input) // Format sesuai string yang diberikan
	if err != nil {
		return timestamp, err
	}
	timestamp.Time = t
	// timestamp.Status = pgtype.Present
	return timestamp, nil
}

func ConvertDateToTimestamp(dateStr string, isStart bool) (pgtype.Timestamp, error) {
	layout := "2006-01-02"
	parsedDate, err := time.Parse(layout, dateStr)
	if err != nil {
		return pgtype.Timestamp{}, err
	}

	if !isStart {
		parsedDate = parsedDate.Add(23*time.Hour + 59*time.Minute + 59*time.Second)
	}

	return pgtype.Timestamp{
		Time:  parsedDate,
		Valid: true,
	}, nil
}
