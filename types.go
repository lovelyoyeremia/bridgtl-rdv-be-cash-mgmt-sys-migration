package main

import (
	"fmt"
	"strconv"
	"strings"
	"time"
)

type DateTime struct {
	time.Time
}

func (date *DateTime) MarshalCSV() (string, error) {
	return date.Format(time.DateTime), nil
}

func (date *DateTime) String() string {
	return date.Format(time.DateTime)
}

func (date *DateTime) UnmarshalCSV(csv string) (err error) {
	if csv == "" {
		date.Time = time.Time{}
		return nil
	}
	date.Time, err = time.Parse(time.DateTime, csv)
	return err
}

type Float64 struct {
	float64
}

func (f *Float64) MarshalCSV() (string, error) {
	return f.String(), nil
}

func (f *Float64) String() string {
	return fmt.Sprintf("%.2f", f)
}

func (f *Float64) UnmarshalCSV(csv string) (err error) {
	if csv == "" {
		f.float64 = 0
		return nil
	}
	f.float64, err = parseFloat(csv)
	return err
}

type DateTimeSlash struct {
	time.Time
}

func (date *DateTimeSlash) MarshalCSV() (string, error) {
	return date.Format("02/01/2006"), nil
}

func (date *DateTimeSlash) String() string {
	return date.Format("02/01/2006")
}

func (date *DateTimeSlash) UnmarshalCSV(csv string) (err error) {
	if csv == "" || len(csv) < 2 {
		date.Time = time.Time{}
		return nil
	}
	if strings.Contains(csv, "/9999") {
		csv = strings.ReplaceAll(csv, "/9999", "/2001")
	}

	strSplit := strings.Split(csv, "/")
	if len(strSplit) > 1 {
		month, _ := strconv.Atoi(strSplit[1])
		if month > 12 {
			date.Time = time.Time{}
			return nil
		}
	}
	date.Time, err = time.Parse("02/01/2006", csv)
	return err
}

type Boolean struct {
	bool
}

func (b *Boolean) MarshalCSV() (string, error) {
	return b.String(), nil
}

func (b *Boolean) String() string {
	return fmt.Sprintf("%v", b.bool)
}

func (b *Boolean) UnmarshalCSV(csv string) (err error) {
	if csv == "" || csv == "N" {
		b.bool = false
		return nil
	}

	b.bool = true
	return nil
}
