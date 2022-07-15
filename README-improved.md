# Sensible Data Migrations for Rails

A library for Rails developers who are not willing to leave data migrations to chance.

## Why?

<blockquote>
  <p>The main purpose of Rails' migration feature is to issue commands that modify the schema using a consistent process. Migrations can also be used to add or modify data. This is useful in an existing database that can't be destroyed and recreated, such as a production database.</p>
  <a href="https://guides.rubyonrails.org/active_record_migrations.html#migrations-and-seed-data">
    <sup>–Migrations and Seed Data, Rails Guide for Active Record Migrations</sup>
  </a>
</blockquote>

The motivation behind Rails' migration mechanism is schema modification. Using it
for data changes in the database comes second. Yet, adding or modifying data via
regular migrations can be problematic.

The first issue is that application deployment now depends on the data migration
to be completed. This may not be a problem with small databases but large
databases with millions of records will respond with hanging or failed migrations.

Another issue is that data migration files tend to stay in `db/migrate` for posterity.
As a result, they will run whenever a developer sets up their local development environment.
This is unnecessary for a pristine database. Especially when there are [scripts][2] to
seed the correct data.

The purpose of `monarch_migrate` is to solve the above issues by separating data from schema migrations.

It is assumed that:

- You run data migrations *only* on production and rely on seed [scripts][2] i.e. `dev:prime` for local development.
- You run data migrations manually.
- You want to test your data migrations in a thorough and automated manner.



## Install

Add the gem to your Gemfile:

```ruby
gem "monarch_migrate"
```

Run the bundle command to install it.

After you install the gem, you need to run the generator:

```shell
rails generate monarch_migrate:install
```

The install generator creates a migration file that adds a `data_migration_records`
table. It is where the gem keeps track of data migrations we have already ran.



## Usage

Data migrations have a similar structure to regular migrations in Rails. Files are
put into `db/data_migrate` and follow the same naming pattern.

Let's start with an example.

Suppose we have designed a system where users have first and last names. Time passes and
it becomes clear this is [wrong][3]. Now, we want to put things right and come
up with the following plan:

1. Add a `name` column to `users` table to hold person's full name.
2. Adapt the `User` model and use a data migration to update existing records.
3. Drop `first_name` and `last_name` columns.

To create the data migration to update existing user records, run:

```shell
rails generate data_migration backfill_users_name
```

In contrast to regular migrations, there is no need to inherit any classes:

```ruby
# db/data_migrate/20220605083010_backfill_users_name.rb
ActiveRecord::Base.connection.execute(<<-SQL)
  UPDATE users SET name = concat(first_name, ' ', last_name) WHERE name IS NULL;
SQL

SearchIndex::RebuildJob.perform_later
```

As seen above, it is plain ruby code where you can refer to any object you
need. Each data migration runs in a separate transaction.

To run pending data migrations:

```shell
rails data:migrate
```

Or a specific version:

```shell
rails data:migrate VERSION=20220605083010
```


## Testing

Testing data migrations can be the difference between simply rerunning
the migration and having to recover from a data loss.

This is why `monarch_migrate` includes test helpers for both RSpec and TestUnit.

### RSpec

For `rspec`, add the following line to your `spec/rails_helper.rb`:

```ruby
require "monarch_migrate/rspec"
```

Then:

```ruby
# spec/data_migrations/20220605083010_backfill_users_name_spec.rb
describe "20220605083010_backfill_users_name", type: :data_migration do
  subject { run_data_migration }

  it "assigns user's name" do
    user = users(:without_name_migrated)
    # or if you're using FactoryBot:
    # user = create(:user, first_name: "Guybrush", last_name: "Threepwood", name: nil)

    expect { subject }.to change { user.reload.name }.to("Guybrush Threepwood")
  end

  it "does not assign name to already migrated users" do
    user = users(:with_name_migrated)
    # or if you're using FactoryBot:
    # user = create(:user, first_name: "", last_name: "", name: "Guybrush Threepwood")

    expect { subject }.not_to change { user.reload.name }
  end

  context "when the user has no last name" do
    it "does not leave a trailing space" do
      user = users(:without_name_migrated)
      # or if you're using FactoryBot:
      # user = create(:user, first_name: "Guybrush", last_name: nil, name: nil)

      expect { subject }.to change { user.reload.name }.to("Guybrush")
    end
  end

  # And so on ...
end
```

### TestUnit

For `test_unit`, add this line to your `test/test_helper.rb`:

```ruby
require "monarch_migrate/test_unit"
```

Then:

```ruby
# test/data_migrations/20220605083010_backfill_users_name_test.rb
class BackfillUsersNameTest < MonarchMigrate::TestCase
  def test_assigns_users_name
    user = users(:without_name_migrated)
    # or if you're using FactoryBot:
    # user = create(:user, first_name: "Guybrush", last_name: "Threepwood", name: nil)

    run_data_migration

    assert_equal "Guybrush Threepwood", user.reload.name
  end

  def test_does_not_assign_name_to_alredy_migrated_users
    user = users(:with_name_migrated)
    # or if you're using FactoryBot:
    # user = create(:user, first_name: "", last_name: "", name: "Guybrush Threepwood")

    run_data_migration

    assert_equal "Guybrush Threepwood", user.reload.name
  end

  def test_does_not_leave_trailing_space_when_user_has_no_last_name
    user = users(:without_name_migrated)
    # or if you're using FactoryBot:
    # user = create(:user, first_name: "Guybrush", last_name: nil, name: nil)

    run_data_migration

    assert_equal "Guybrush", user.reload.name
  end

  # And so on ...
end
```

### Considerations

Data migrations become obsolete, once the data manipulation successfully completes.
So are the corresponding tests. These will fail after database columns are dropped
e.g. `first_name` and `last_name`.

One solution is to use the following development workflow:

1. Implement the data migration using TDD.
1. Commit, push and wait for CI to pass.
1. Request review from peers.
1. Once approved, remove the test files in a consecutive commit and push again.
1. Merge into trunk.

This will also keep the test files in repo's history for posterity.

## Known Issues and Limitations

The following issues and limitations are not necessary inherent to `monarch_migrate`.
Some are innate to migrations in general.


### Using Models in Migrations

<blockquote>
  <p>The Active Record way claims that intelligence belongs in your models, not in the database.</p>
  <a href="https://guides.rubyonrails.org/active_record_migrations.html#active-record-and-referential-integrity">
    <sup>–Active Record and Referential Integrity, Rails Guide for Active Record Migrations</sup>
  </a>
</blockquote>

Typically, data migrations relate closely to business models. In an ideal Rails world,
data manipulations would depend on model logic to enforce validation, conform to
business rules, etc. Hence, it is very tempting to use ActiveRecord models in migrations.

Here is a regular Rails migration for our example:

```ruby
# db/migrate/20220605083010_backfill_users_name.rb
def up
  User.all.each do |user|
    user.name = "#{user.first_name} #{user.last_name}"
    user.save
  end
end
```

The code above is problematic because:

1. It iterates through every user.
2. It invokes validations and callbacks, which may have unintended consequences.
3. It does not check if the user has already been migrated.
4. It will fail when a future developer runs the migration during local development setup after `first_name` and `last_name` columns are gone.

To avoid issues 1-3, we can rewrite the migration to:

```ruby
# db/migrate/20220605083010_backfill_users_name.rb
def up
  User.where(name: nil).find_each do |user|
    user.update_column(:name, "#{user.first_name} #{user.last_name}")
  end
end
```

Unfortunately, with regular Rails migrations we will still face issue 4.

To avoid it, we need to separate data from schema migrations and not run data
migrations locally. With seed [scripts][2], there is no need to run them anyway.

Keep the above in mind when referencing ActiveRecord models in data migrations. Ideally,
limit their use and do as much processing as possible in Postgres.


### Long-running Tasks in Migrations

As mentioned, each data migration runs in a separate transaction.
A long-running task within a migration keeps the transaction open for
the duration of the task. As a result, the migration may hang or fail.

To avoid this, run such tasks asynchronously.



## Trivia

One of the most impressive migrations on Earth is the multi-generational
round trip of the monarch butterfly.

Each year, millions of monarch butterflies leave their northern ranges
and fly south, where they gather in huge roosts to survive the winter.
When spring arrives, the monarchs start their return journey north.
The population cycles through three to five generations to reach their
destination. In the end, a new generation of butterflies complete the
journey their great-great-great-grandparents started.

It is a mystery to scientists how the new generations know where to go,
but they appear to navigate using a combination of the Earth's magnetic field
and the position of the sun.

Genetically speaking, this is an incredible data migration!



## See Also

Alternative gems

- https://github.com/OffgridElectric/rails-data-migrations
- https://github.com/ilyakatz/data-migrate
- https://github.com/jasonfb/nonschema_migrations

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
