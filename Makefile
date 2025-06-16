BINARY_NAME=go-template

.PHONY: run-local
run-local:
	go run main.go

.PHONY: build
build:
	gen
	GOARCH=amd64 GOOS=darwin go build -a -installsuffix nocgo -o ${BINARY_NAME}-darwin -tags=viper_bind_struct main.go
	GOARCH=amd64 GOOS=linux go build -a -installsuffix nocgo -o ${BINARY_NAME}-linux -tags=viper_bind_struct main.go
	GOARCH=amd64 GOOS=windows go build -a -installsuffix nocgo -o ${BINARY_NAME}-windows -tags=viper_bind_struct main.go

.PHONY: run
run: build
	./${BINARY_NAME}

.PHONY: clean
clean:
	go clean
	rm ${BINARY_NAME}-darwin
	rm ${BINARY_NAME}-linux
	rm ${BINARY_NAME}-windows

.PHONY: test
test:
	go test ./...

.PHONY: test_coverage
test_coverage:
	go test ./... -coverprofile=coverage.out

.PHONY: dep
dep:
	go mod download
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest

.PHONY: vet
vet:
	go vet

.PHONY: lint
lint:
	golangci-lint run
	go mod tidy
	@if ! git diff --quiet; then \
		echo "'go mod tidy' resulted in changes or working tree is dirty:"; \
		git --no-pager diff; \
	fi

.PHONY: gen
gen:
	sqlc generate;
