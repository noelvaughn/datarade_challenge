# Datarade Coding Challenge

This repo meets the acceptance criteria presented to me:

* creating a subscription on stripe.com (via subscription UI) creates a simple subscription record in your database
* the initial state of the subscription record should be 'unpaid'
* paying the first invoice of the subscription changes the state of your local subscription record from 'unpaid' to 'paid'
* canceling a subscription changes the state of your subscription record to “canceled” only subscriptions in the state “paid” can be canceled
* the rails application should be easy to spin so it can be tested by any developer

## Setup

### Prerequisites:

* [Docker](https://docs.docker.com)

* [Stripe CLI](https://stripe.com/docs/stripe-cli)

## Let's go!

First clone this repo:

`git clone git@github.com:noelvaughn/datarade_challenge.git`

Go to the root directory:

`cd datarade_challenge`

Start the Stripe CLI

`stripe listen --forward-to localhost:3000/stripe_webhooks`

Copy the webhook signing secret from the output of the previous step into `.env`.  The .env file should now look something like this:
`STRIPE_WEBHOOK_SECRET=whsec_5cbd94d998191147d19a0e58b25a2fcc9305cf5ba381701d18e8e807db4924e5`

Build the containers:

`docker compose build`

Start the containers:

`docker compose up`

Create the databases for dev and test:

`docker compose run web rake db:create`

Run migrations:

`docker compose run web rake db:migrate`

#### Setup DONE!

Now we can open a shell in the web container and view `subscription` records being saved from your activities on the Stripe Subscription UI:

`docker-compose exec web sh`

`$ rails c`

```
Loading development environment (Rails 7.1.2)
irb(main):001> Subscription.last
  Subscription Load (3.0ms)  SELECT "subscriptions".* FROM "subscriptions" ORDER BY "subscriptions"."id" DESC LIMIT $1  [["LIMIT", 1]]
=> nil
irb(main):002> Subscription.last
  Subscription Load (2.0ms)  SELECT "subscriptions".* FROM "subscriptions" ORDER BY "subscriptions"."id" DESC LIMIT $1  [["LIMIT", 1]]
=>
#<Subscription:0x00007efda35bea08
 id: "8977b2ae-1d1e-4a07-8d17-683022ae3689",
 stripe_id: "sub_1OPkrKLrP8TRr1PFCjBDDOKJ",
 state: "unpaid",
 created_at: Thu, 21 Dec 2023 11:56:15.452743000 UTC +00:00,
 updated_at: Thu, 21 Dec 2023 11:56:15.452743000 UTC +00:00>
```