# Sensible Data Migrations for Rails

<blockquote>
  <p>The main purpose of Rails' migration feature is to issue commands that modify the schema using a consistent process. Migrations can also be used to add or modify data. This is useful in an existing database that can't be destroyed and recreated, such as a production database.</p>
  <a href="https://guides.rubyonrails.org/active_record_migrations.html#migrations-and-seed-data">
    <sup>–Migrations and Seed Data, Rails Guide for Active Record Migrations</sup>
  </a>
</blockquote>

Schema modification is the main idea behind Rails' migration mechanism. Using migrations
for changing data in the database comes second.

Yet, using regular migrations to add or modify data can be problematic.

The first issue is that application deployment now depends on the data migration
to be completed. This may not be a problem with small databases but large
databases with millions of records will respond with hanging or failed migrations.

Another issue is that data migration files usually stay in `db/migrate` for posterity.
As a result, they will run whenever a developer sets up their local development environment.
For a pristine database, this is unnecessary. Especially when there are [scripts][2] to
seed the correct data.

In addition, using `ActiveRecord` models in migrations can [complicate things further](#using-activerecord-models-in-migrations).

The purpose of `monarch_migrate` is to solve the above issues with separating data
from schema migrations. It assumes that:

- You run data migrations *only* on production and use [scripts][2] i.e. `dev:prime` for local development.
- You run data migrations manually.

## Install

Add the gem to your Gemfile:

```ruby
gem "monarch_migrate"
```

Run the bundle command to install it.

After you install MonarchMigrate, you need to run the generator:

```shell
rails generate monarch_migrate:install
```

The above will generate a schema migration that creates a table to keep track
of ran data migrations.


## Usage

Data migrations in MonarchMigrate follow a similar structure to regular migrations
in Rails. Migration files are put into `db/data_migrate`.

To create a new data migration, run:

```shell
rails generate monarch_migrate:data_migration downcase_usernames
```

In contrast to regular migrations, however, you don't need to inherit any
classes in the file:

```ruby
# db/data_migrate/200107010930_downcase_usernames.rb
ActiveRecord::Base.connection.execute(<<-SQL)
  UPDATE users SET username = lower(username);
SQL

SearchIndex.rebuild
```

As seen above, it is plain ruby code where you can refer to any object you
need. In addition, each migration runs in a separate transaction.

To run all pending data migrations:

```shell
rails db:data:migrate
```

Or a specific version:

```shell
rails db:data:migrate VERSION=200107010930
```

## Known Issues and Limitations

### Using ActiveRecord Models in Migrations

<blockquote>
  <p>The Active Record way claims that intelligence belongs in your models, not in the database.</p>
  <a href="https://guides.rubyonrails.org/active_record_migrations.html#active-record-and-referential-integrity">
    <sup>–Active Record and Referential Integrity, Rails Guide for Active Record Migrations</sup>
  </a>
</blockquote>

In general, data migrations relate closely to business models. In an ideal Rails world,
data manipulations would depend on model logic to enforce validation, conform to
business rules, etc. Naturally, we might use `ActiveRecord` models in migrations.

Lets imagine we have designed our users to have first and last names. Time passes and
we realise this is [wrong][3]. Now, we want to put things right.

Here's the plan:

1. Add a `name` column to `users` table to hold the entire name of a person.
2. Change the `User` model and use a data migration to update existing records.
3. Drop `first_name` and `last_name` columns.

And here is what our data migration looks like:

```ruby
# db/migrate/some_migration.rb
def up
  User.all.each do |user|
    user.name = "#{user.first_name} #{user.last_name}"
    user.save
  end
end
```

The code above is problematic because:

- It iterates through every user.
- It invokes validations and callbacks, which may have unintended consequences.
- It does not check if the user has already been migrated.
- It will fail when a future developer runs the migration during local development setup after `first_name` and `last_name` columns are gone.

Keep the above in mind when referencing `ActiveRecord` models in data migrations. Ideally,
limit the use of models and do as much processing as possible in Postgres.


## Trivia

One of the most impressive migrations on Earth is the multi-generational
round trip of the monarch butterfly.

Each year, millions of monarch butterflies leave their northern ranges
and fly south, where they gather in huge roosts to survive the winter.
When spring arrives, the monarchs start their return journey north.
The population cycles through three to five generations to reach their
destination. In the end, a new generation of butterflies complete the
journey their great-great-great-grandparents started.

It is still a mystery to scientists how the new generations know where to go,
but they appear to navigate using a combination of the Earth's magnetic field
and the position of the sun.

Genetically speaking, this is a truly incredible data migration!


## See Also

Alternative gems

- [nonschema_migrations](https://github.com/jasonfb/nonschema_migrations) - Exactly like schema migrations but for data.
- [data-migrate](https://github.com/ilyakatz/data-migrate) - A gem to run data migrations alongside schema migrations.

Articles

- [Data Migrations in Rails](https://thoughtbot.com/blog/data-migrations-in-rails)
- [Zero downtime migrations: 500 million rows](https://www.honeybadger.io/blog/zero-downtime-migrations-of-large-databases-using-rails-postgres-and-redis/)
- [Three Useful Data Migration Patterns for Rails](https://www.ombulabs.com/blog/rails/data-migrations/three-useful-data-migrations-patterns-in-rails.html)
- [Ruby on Rails Model Patterns and Anti-patterns](https://blog.appsignal.com/2020/11/18/rails-model-patterns-and-anti-patterns.html)
- [Rails Migrations with Zero Downtime](https://www.cloudbees.com/blog/rails-migrations-zero-downtime)


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[2]: https://thoughtbot.com/blog/priming-the-pump
[3]: https://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/
