package main

import (
	"os"
	"strconv"
	"strings"

	"github.com/gocarina/gocsv"
)

func parseCsv[T any](schema *[]*T, filePath string) error {
	files, err := os.OpenFile(filePath, os.O_RDONLY, os.ModePerm)
	if err != nil {
		return err
	}
	defer files.Close()

	return gocsv.UnmarshalFile(files, schema)
}

func parseFloat(input string) (float64, error) {
	input = strings.TrimSpace(input)

	dotCount := strings.Count(input, ".")
	commaCount := strings.Count(input, ",")

	cleaned := input

	if commaCount == 1 && dotCount > 0 && strings.LastIndex(input, ",") > strings.LastIndex(input, ".") {
		cleaned = strings.ReplaceAll(input, ".", "")
		cleaned = strings.ReplaceAll(cleaned, ",", ".")
	} else {
		cleaned = strings.ReplaceAll(input, ",", "")
	}

	return strconv.ParseFloat(cleaned, 64)
}

func checkRole(userCode string) string {
	lowerCode := strings.ToLower(userCode)

	switch strings.ToLower(lowerCode) {
	case "admin":
		return "ADMIN"
	case "sysadmin":
		return "SYSADMIN"
	case "maker":
		return "MAKER"
	case "checker":
		return "CHECKER"
	case "signer":
		return "SIGNER"
	}
	return ""
}
