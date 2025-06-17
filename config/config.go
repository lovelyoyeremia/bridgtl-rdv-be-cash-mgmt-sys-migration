package config

import (
	"log"
	"os"

	sharedconfig "github.com/Bank-Raya/bridgtl-rcs-go-shared-lib/config"
	"github.com/spf13/viper"
)

type Config struct {
	AppName    string `mapstructure:"APP_NAME"`
	AppVersion string `mapstructure:"APP_VERSION"`
	AppEnv     string `mapstructure:"APP_ENV"`
	AppKey     string `mapstructure:"APP_KEY"`

	DbConnection string `mapstructure:"DB_CONNECTION"`
	DbHost       string `mapstructure:"DB_HOST"`
	DbPort       int    `mapstructure:"DB_PORT"`
	DbDatabase   string `mapstructure:"DB_DATABASE"`
	DbUsername   string `mapstructure:"DB_USERNAME"`
	DbPassword   string `mapstructure:"DB_PASSWORD"`
	DbTz         string `mapstructure:"DB_TZ"`
	DbSeeder     bool   `mapstructure:"DB_SEEDER"`
	DbDebug      bool   `mapstructure:"DB_DEBUG"`
	DbSeederName string `mapstructure:"DB_SEEDER_NAME" example:"user,corporate"`
}

func (c *Config) SetDefault() {
	def := map[string]any{
		"APP_NAME": "bridgtl-rdv-be-cash-mgmt-sys",
	}

	for key, value := range def {
		viper.SetDefault(key, value)
	}
}

func (c *Config) Postprocess() error {
	return nil
}

func New() *Config {
	cfg := new(Config)

	var opts []sharedconfig.Option
	env, exist := os.LookupEnv("APP_ENV")
	if exist && env != "local" {
		opts = append(opts, sharedconfig.WithEnvOnly())
	} else {
		opts = append(opts, sharedconfig.WithConfigFile(".env"), sharedconfig.WithConfigFolder("."))
	}

	if err := sharedconfig.Load(cfg, opts...); err != nil {
		log.Fatal("failed to load config")
	}

	return cfg
}
