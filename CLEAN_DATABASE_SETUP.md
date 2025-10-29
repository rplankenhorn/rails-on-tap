# Clean Database Setup

## Overview

Your local Rails development environment is now configured to run **without seed data** by default. This gives you a clean slate to create your own data.

## How It Works

The database seed process now checks the `SKIP_SEED_DATA` environment variable:

- **`SKIP_SEED_DATA=true`** → No sample data is loaded
- **`SKIP_SEED_DATA=false`** → Sample data is loaded (users, beverages, kegs, etc.)

## Configuration

The setting is stored in `.env`:

```bash
SKIP_SEED_DATA=true
```

## Database Commands

### Reset database without seed data
```bash
bin/rails db:reset
```

### Reset database WITH seed data
```bash
SKIP_SEED_DATA=false bin/rails db:reset
```

### Manually run seeds
```bash
bin/rails db:seed
```

### Create fresh database without seeds
```bash
bin/rails db:drop db:create db:migrate
```

## Starting Fresh

Your current development database is **empty**. To use the application, you'll need to:

1. **Create a user account** through the signup form
2. **Add beverages** (beers, wines, etc.)
3. **Configure hardware** (kegboard config, then initialize hardware)
4. **Create taps** and assign flow meters
5. **Add kegs** and attach them to taps

## If You Want Sample Data Back

Simply change `.env`:

```bash
SKIP_SEED_DATA=false
```

Then reset the database:

```bash
bin/rails db:reset
```

This will create:
- Admin user (username: `admin`, password: `password`)
- Guest user
- Sample beverage producers (Sierra Nevada, Stone, etc.)
- Sample beverages
- Sample kegs

## Production Note

This seed control **only affects development and test** environments. Production uses the Docker entrypoint configuration which already has seed prevention built in.
