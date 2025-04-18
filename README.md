<p align="center">
  <a href="https://tur.so/turso-activerecord">
    <picture>
      <img src="/.github/cover.png" alt="libSQL Ruby" />
    </picture>
  </a>
  <h1 align="center">libSQL ActiveRecord</h1>
</p>

<p align="center">
  Databases for all your Ruby on Rails Apps.
</p>

<p align="center">
  <a href="https://tur.so/turso-activerecord"><strong>Turso</strong></a> ·
  <a href="https://docs.turso.tech"><strong>Docs</strong></a> ·
  <a href="https://turso.tech/blog"><strong>Blog &amp; Tutorials</strong></a>
</p>

<p align="center">
  <a href="LICENSE">
    <picture>
      <img src="https://img.shields.io/github/license/tursodatabase/libsql-activrecord?color=0F624B" alt="MIT License" />
    </picture>
  </a>
  <a href="https://tur.so/discord-activerecord">
    <picture>
      <img src="https://img.shields.io/discord/933071162680958986?color=0F624B" alt="Discord" />
    </picture>
  </a>
  <a href="#contributors">
    <picture>
      <img src="https://img.shields.io/github/contributors/tursodatabase/libsql-activerecord?color=0F624B" alt="Contributors" />
    </picture>
  </a>
  <a href="/examples">
    <picture>
      <img src="https://img.shields.io/badge/browse-examples-0F624B" alt="Examples" />
    </picture>
  </a>
</p>

## Features

- 🚆 Works with [Ruby on Rails](https://rubyonrails.org)
- 🔌 Works offline with [Embedded Replicas](https://docs.turso.tech/features/embedded-replicas/introduction)
- 🌎 Works with remote Turso databases
- ✨ Works with Turso [AI & Vector Search](https://docs.turso.tech/features/ai-and-embeddings)

> [!WARNING]
> This SDK is currently in technical preview. <a href="https://tur.so/discord-activerecord">Join us in Discord</a> to report any issues.

## Install

```bash
gem install libsql_activerecord
```

## Quickstart

The example below uses Ruby on Rails with ActiveRecord:

```yml
default: &default
  adapter: libsql
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  url: <%= ENV['TURSO_DATABASE_URL'] %>
  auth_token: <%= ENV['TURSO_AUTH_TOKEN'] %>
  path: "path/to/local/replica.db"
```

## Documentation

Visit our [official documentation](https://docs.turso.tech).

## Support

Join us [on Discord](https://tur.so/discord-activerecord) to get help using this SDK. Report security issues [via email](mailto:security@turso.tech).

## Contributors

See the [contributing guide](CONTRIBUTING.md) to learn how to get involved.

![Contributors](https://contrib.nn.ci/api?repo=tursodatabase/libsql-activerecord)

<a href="https://github.com/tursodatabase/libsql-activerecord/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22">
  <picture>
    <img src="https://img.shields.io/github/issues-search/tursodatabase/libsql-activerecord?label=good%20first%20issue&query=label%3A%22good%20first%20issue%22%20&color=0F624B" alt="good first issue" />
  </picture>
</a>
