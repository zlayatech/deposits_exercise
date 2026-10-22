# Deposits Exercise


## Requirements

A tradeline on a credit report represents an account, such as a credit card or car loan.

In the codebase, the following exists:

* The `Tradeline` model, which can be used to store tradelines in the database.
* A `Tradeline` controller, which serves both the `index` and `show` routes for tradelines.
* Basic `rspec` tests on the controller with a `tradeline` FactoryBot.

Add in the ability to create deposits for a specific tradeline using a JSON API call. You should store the deposit date (this is most likely a future date), and amount. Expose the outstanding balance for a given tradeline in the JSON output for `TradelinesController#show`, and `TradelinesController#index`. The oustanding balance should be calculated as the `amount` minus all of the deposit amounts.

In addition:

* A deposit should not be able to be created that exceeds the outstanding balance of a tradeline.
* You should return validation errors if a deposit cannot be created.
* Expose endpoints for seeing all deposits for a given tradeline, as well as seeing an individual deposit.

Feel free to add any gems to the `Gemfile`, and touch any of the existing code. For example, if you prefer to use PostgreSQL or MySQL over the included SQLite, or a serializer of your choice, please go ahead. This is not required, but you can be as creative as you want.

This exercise is purely API based, and will not have any frontend components. Please do not spend more than 3 hours on this.

## Setup

The exercise requires Ruby 3.3.0. Simply clone the repo, and run `bundle` to get started. This will install Rails 7.1.2, and the other specified gems.

```sh
bin/rails db:prepare   # create and migrate the database
bin/rails server       # start the API on http://localhost:3000
bundle exec rspec      # run the test suite
```

## API

All endpoints return JSON. Amounts are returned as strings (e.g. `"1000.0"`) to keep decimal precision.

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/tradelines` | List tradelines with their outstanding balance |
| `GET` | `/tradelines/:id` | Show a tradeline with its outstanding balance |
| `GET` | `/tradelines/:tradeline_id/deposits` | List a tradeline's deposits, ordered by date |
| `GET` | `/tradelines/:tradeline_id/deposits/:id` | Show a single deposit |
| `POST` | `/tradelines/:tradeline_id/deposits` | Create a deposit |

### Create a deposit

```sh
curl -X POST http://localhost:3000/tradelines/1/deposits \
  -H 'Content-Type: application/json' \
  -d '{"deposit": {"deposit_date": "2030-01-01", "amount": "250.00"}}'
```

Responds with `201 Created` and the deposit:

```json
{ "id": 1, "tradeline_id": 1, "deposit_date": "2030-01-01", "amount": "250.0", "created_at": "...", "updated_at": "..." }
```

### Tradeline

```json
{ "id": 1, "name": "Car Loan", "amount": "1000.0", "outstanding_balance": "750.0", "created_at": "...", "updated_at": "..." }
```

`outstanding_balance` is the tradeline `amount` minus the sum of all its deposits.

### Errors

| Status | When | Body |
| --- | --- | --- |
| `400` | The `deposit` param is missing | `{ "error": "param is missing or the value is empty: deposit" }` |
| `404` | The tradeline or deposit doesn't exist | `{ "error": "not_found" }` |
| `422` | The deposit is invalid | `{ "errors": { "amount": ["cannot exceed the outstanding balance of 750.0"] } }` |

A deposit requires a `deposit_date` and an `amount` greater than 0 that does not exceed the tradeline's outstanding balance. Deposits are created while holding a lock on the tradeline, so concurrent requests can't overdraw it.

## Submission

Please do not fork the repo; if forked accidentally, please delete the fork. For review, either of the following methods for submission are preferred:

* Cloning the repository and then uploading it under your Github account for review.
* Zipping up the directory. 