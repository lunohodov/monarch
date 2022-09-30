# monarch_migrate [![Build Status][ci-image]][ci] [![Gem Version][version-image]][version]

A library for Rails developers who are not willing to leave data migrations to chance.

<br />

## Table of Contents

- [Rationale](#rationale)
- [Install](#install)
- [Usage](#usage)
  - [Create a Data Migration](#create-a-data-migration)
  - [Running Data Migrations](#running-data-migrations)
  - [Display Status of Data Migrations](#display-status-of-data-migrations)
  - [Reverting Data Migrations](#reverting-data-migrations)
- [Testing](#testing)
  - [RSpec](#rspec)
  - [TestUnit](#testunit)
- [Suggested Workflow](#suggested-workflow)
- [Known Issues and Limitations](#known-issues-and-limitations)
- [Trivia](#trivia)
- [Acknowledgments](#acknowledgments)
- [License](#license)


## Rationale
<sup>[(Back to top)](#table-of-contents)</sup>

<blockquote>
  <p>The main purpose of Rails' migration feature is to issue commands that modify the schema using a consistent process. Migrations can also be used to add or modify data. This is useful in an existing database that can't be destroyed and recreated, such as a production database.</p>
  <a href="https://guides.rubyonrails.org/active_record_migrations.html#migrations-and-seed-data">
    <sup>–Migrations and Seed Data, Rails Guide for Active Record Migrations</sup>
  </a>
</blockquote>

The motivation behind Rails' migration mechanism is schema modification.
Using it for data changes in the database comes second. Yet, adding or
modifying data via regular migrations can be problematic.

One issue is that application deployment now depends on the data migration
to be completed. This may not be a problem with small databases but large
databases with millions of records will respond with hanging or failed migrations.

Another issue is that data migration files tend to stay in `db/migrate` for posterity.
As a result, they will run whenever a developer sets up their local development environment.
This is unnecessary for a pristine database. Especially with [scripts][seed-scripts] to
seed the correct data.

The purpose of `monarch_migrate` is to solve the above issues and to:

- Provide a [uniform process](#suggested-workflow) for modifying data in the database.
- Separate data migrations from schema migrations.
- Allow automated testing of data migrations.

It assumes that:

- You run data migrations only on production and rely on seed [scripts][seed-scripts] for local development.
- You run data migrations manually.
- You want to test data migrations in a thorough and automated manner.



## Install
<sup>[(Back to top)](#table-of-contents)</sup>

Add the gem to your Gemfile:

```ruby
gem "monarch_migrate"
```

Run the bundle command to install it.

After you install the gem, you need to run the generator:

```shell
rails generate monarch_migrate:install
```

The install generator creates a schema migration file that adds a `data_migration_records`
table. It is where the gem keeps track of data migrations we have ran.

Run the schema migration to create the table:

```shell
rails db:migrate
```



## Usage
<sup>[(Back to top)](#table-of-contents)</sup>

Data migrations have a similar structure to regular migrations in Rails.
Files follow the same naming pattern but reside in `db/data_migrate`.


### Create a Data Migration

```shell
rails generate data_migration backfill_users_name
```

Edit the newly created file to define the data migration:

```ruby
# db/data_migrate/20220605083010_backfill_users_name.rb
ActiveRecord::Base.connection.execute(<<-SQL)
  UPDATE users SET name = concat(first_name, ' ', last_name) WHERE name IS NULL;
SQL
```

In contrast to regular migrations, there is no need to inherit any classes. It is plain
ruby code where you can refer to any object you need. If the database adapter supports
transactions, each data migration will automatically be wrapped in a separate transaction.


### Running Data Migrations

To run pending data migrations:

```shell
rails data:migrate
```

To run a specific version:

```shell
rails data:migrate VERSION=20220605083010
```


### Display Status of Data Migrations

You can see the status of data migrations with:

```shell
rails data:migrate:status
```


### Reverting Data Migrations

Rollback functionality is not provided by design. Create another data migration instead.



## Testing
<sup>[(Back to top)](#table-of-contents)</sup>

Testing data migrations can be the difference between rerunning
the migration and having to recover from a data loss. This is
why `monarch_migrate` includes test helpers for both RSpec and TestUnit.


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

In certain cases, it makes sense to also test with manually running the data migration
against a production clone of the database.



## Suggested Workflow
<sup>[(Back to top)](#table-of-contents)</sup>

Data migrations become obsolete, once the data manipulation successfully completes. The same applies for the corresponding tests.

The suggested development workflow is:

1. Implement the data migration. Use TDD, if appropriate.
1. Commit, push and wait for CI to pass.
1. Request review from peers.
1. Once approved, remove the test files in a consecutive commit and push again.
1. Merge into trunk.

This will keep the test files in repo's history for posterity.



## Known Issues and Limitations
<sup>[(Back to top)](#table-of-contents)</sup>

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

Here a regular Rails migration:

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
migrations locally. With seed [scripts][seed-scripts], there is no need to run them anyway.

Keep the above in mind when referencing ActiveRecord models in data migrations. Ideally,
limit their use and do as much processing as possible in the database.


### Long-running Tasks in Migrations

As mentioned, each data migration runs in a separate transaction.
A long-running task within a migration keeps the transaction open for
the duration of the task. As a result, the migration may hang or fail.

On the other side, you may want to run such tasks asynchronously:

```ruby
# db/data_migrate/20220605083010_backfill_users_name.rb

# Migration code

SearchIndex::RebuildJob.perform_later
```

However, the task may start before the transaction commits. This is a [known issue][sync-issue].
In addition, the database may suffer from longer commit times.

A naive workaround is to introduce a delay:

```ruby
# db/data_migrate/20220605083010_backfill_users_name.rb

# Migration code

SearchIndex::RebuildJob.set(wait: 5.minutes).perform_later
```

The pragmatic approach is to run such tasks manually after the data migration is complete.
In a future version `monarch_migrate` will provide a better alternative.



## Trivia
<sup>[(Back to top)](#table-of-contents)</sup>

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



## Acknowledgments
<sup>[(Back to top)](#table-of-contents)</sup>

Articles

- [Data Migrations in Rails](https://thoughtbot.com/blog/data-migrations-in-rails)
- [Zero downtime migrations: 500 million rows](https://www.honeybadger.io/blog/zero-downtime-migrations-of-large-databases-using-rails-postgres-and-redis/)
- [Three Useful Data Migration Patterns for Rails](https://www.ombulabs.com/blog/rails/data-migrations/three-useful-data-migrations-patterns-in-rails.html)
- [Ruby on Rails Model Patterns and Anti-patterns](https://blog.appsignal.com/2020/11/18/rails-model-patterns-and-anti-patterns.html)
- [Rails Migrations with Zero Downtime](https://www.cloudbees.com/blog/rails-migrations-zero-downtime)

Alternative gems

- https://github.com/OffgridElectric/rails-data-migrations
- https://github.com/ilyakatz/data-migrate
- https://github.com/jasonfb/nonschema_migrations



## License
<sup>[(Back to top)](#table-of-contents)</sup>

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

[ci-image]: https://github.com/lunohodov/monarch/actions/workflows/ci.yml/badge.svg
[ci]: https://github.com/lunohodov/monarch/actions/workflows/ci.yml
[seed-scripts]: https://thoughtbot.com/blog/priming-the-pump
[sync-issue]: https://github.com/mperham/sidekiq/wiki/FAQ#why-am-i-seeing-a-lot-of-cant-find-modelname-with-id12345-errors-with-sidekiq
[version-image]: https://badge.fury.io/rb/monarch_migrate.svg
[version]: https://badge.fury.io/rb/monarch_migrate
