# Rails + libSQL ActiveRecord Example

This example demonstrates how to use libSQL with a Ruby on Rails.

## Install Dependencies

```bash
bundle
```

## Configure database

Create a database, auth token and configure it inside `.env.development`:

```bash
TURSO_DATABASE_URL=libsql://
TURSO_DATABASE_AUTH_TOKEN=
```

## Migrate the database

Run the following to migrate the database:

```bash
bin/rails db:migrate
```

## Running

Execute the example:

```bash
bin/rails server
```
