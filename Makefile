# Rails on Tap Monorepo Makefile
# Quick commands for development

.PHONY: help setup rails android docker db test lint clean logs stop

help:
	@echo "Rails on Tap - Development Commands"
	@echo "===================================="
	@echo ""
	@echo "Setup & Installation:"
	@echo "  make setup          - Install all dependencies"
	@echo ""
	@echo "Running Services:"
	@echo "  make rails          - Start Rails server (port 3000)"
	@echo "  make android        - Start Android emulator"
	@echo "  make android-build  - Build Android app"
	@echo "  make docker         - Run everything in Docker"
	@echo ""
	@echo "Database Commands:"
	@echo "  make db-create      - Create development database"
	@echo "  make db-migrate     - Run database migrations"
	@echo "  make db-seed        - Seed database with sample data"
	@echo "  make db-reset       - Reset database (⚠️  deletes data)"
	@echo "  make db-console     - Open Rails console"
	@echo ""
	@echo "Testing & Quality:"
	@echo "  make test           - Run all tests"
	@echo "  make test-models    - Run model tests"
	@echo "  make test-android   - Run Android tests"
	@echo "  make lint           - Run linters"
	@echo "  make security       - Run security checks"
	@echo ""
	@echo "Utilities:"
	@echo "  make logs           - View Rails logs"
	@echo "  make clean          - Clean build artifacts"
	@echo "  make stop           - Stop all services"
	@echo "  make api-key        - Generate new API key"
	@echo ""

# Setup
setup:
	@echo "Setting up Rails on Tap monorepo..."
	@bin/setup
	@echo "✓ Setup complete!"

# Rails
rails:
	@echo "Starting Rails server on http://localhost:3000"
	@bin/rails server

rails-console:
	@bin/rails console

# Android
android:
	@echo "Starting Android emulator..."
	@emulator -avd Pixel_6_API_31 &
	@echo "Waiting for emulator to be ready..."
	@sleep 10
	@cd android && ./gradlew run

android-build:
	@echo "Building Android app..."
	@cd android && ./gradlew build

android-install:
	@echo "Installing Android app on emulator/device..."
	@cd android && ./gradlew installDebug

android-clean:
	@echo "Cleaning Android build..."
	@cd android && ./gradlew clean

# Docker
docker:
	@echo "Starting services with Docker Compose..."
	@docker-compose up

docker-build:
	@echo "Building Docker images..."
	@docker-compose build

docker-stop:
	@echo "Stopping Docker services..."
	@docker-compose down

# Database
db-create:
	@echo "Creating development database..."
	@bin/rails db:create

db-migrate:
	@echo "Running database migrations..."
	@bin/rails db:migrate

db-seed:
	@echo "Seeding database with sample data..."
	@bin/rails db:seed

db-reset:
	@echo "⚠️  Resetting database (this deletes all data)..."
	@read -p "Are you sure? (y/n) " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		bin/rails db:reset; \
	fi

db-console:
	@echo "Opening Rails console..."
	@bin/rails console

db-dump:
	@echo "Dumping database schema..."
	@bin/rails db:schema:dump

# Testing
test:
	@echo "Running all tests..."
	@bin/rails test

test-models:
	@echo "Running model tests..."
	@bin/rails test test/models

test-controllers:
	@echo "Running controller tests..."
	@bin/rails test test/controllers

test-android:
	@echo "Running Android tests..."
	@cd android && ./gradlew test

test-coverage:
	@echo "Running tests with coverage..."
	@bin/rails test COVERAGE=true

# Linting & Quality
lint:
	@echo "Running RuboCop linter..."
	@bin/rubocop

lint-fix:
	@echo "Auto-fixing RuboCop issues..."
	@bin/rubocop -a

lint-android:
	@echo "Running Android lint checks..."
	@cd android && ./gradlew lint

security:
	@echo "Running Brakeman security scan..."
	@bin/brakeman

# Logs
logs:
	@echo "Tailing Rails logs (Ctrl+C to stop)..."
	@tail -f log/development.log

logs-android:
	@echo "Viewing Android logs (Ctrl+C to stop)..."
	@adb logcat | grep -i railsontap

# Utilities
api-key:
	@echo "Generating new API key..."
	@bin/rails runner 'key = ApiKey.create!(name: "Development Key - $$(date)"); puts "API Key: $${key.token}"'

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf tmp/cache/*
	@rm -rf log/*
	@cd android && ./gradlew clean
	@echo "✓ Clean complete!"

stop:
	@echo "Stopping all services..."
	@pkill -f "bin/rails server" || true
	@pkill -f emulator || true
	@docker-compose down 2>/dev/null || true
	@echo "✓ Services stopped!"

ps:
	@echo "Running processes:"
	@pgrep -fl "rails|emulator|gradle" || echo "No Rails on Tap processes running"

# Combination commands
dev: rails android

dev-docker: docker-build docker

fresh-setup: clean setup db-reset

# Device commands
adb-forward:
	@echo "Setting up adb forward for port 3000..."
	@adb forward tcp:3000 tcp:3000

adb-logs:
	@echo "Viewing device logs..."
	@adb logcat

adb-shell:
	@echo "Opening adb shell..."
	@adb shell

# Info commands
info:
	@echo "Rails on Tap - Project Information"
	@echo "===================================="
	@echo "Rails Version: $$(bin/rails -v)"
	@echo "Ruby Version: $$(ruby -v)"
	@echo "Node Version: $$(node -v)"
	@echo "Docker: $$(docker --version)"
	@echo ""
	@echo "Database:"
	@bin/rails db:version 2>/dev/null || echo "Database not initialized"
	@echo ""
	@echo "Services:"
	@make ps || true
