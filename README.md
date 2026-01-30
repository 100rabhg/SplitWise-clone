# Splitwise Clone (Rails)

A simplified expense sharing application inspired by Splitwise.  
This project demonstrates core Ruby on Rails concepts such as authentication, relational data modeling, and expense settlement between users.

The goal of this project was to implement the backend and UI logic required to track shared expenses, manage friends, and calculate balances between users.

## Features

- User authentication using Devise
- Add and manage friends
- Record shared expenses
- Split expenses between multiple users
- Track balances between users
- Dashboard overview of expenses and balances
- Friend-specific expense view

## Tech Stack

- Ruby 3.0
- Rails 6.1
- PostgreSQL / SQLite
- Devise (Authentication)
- Bootstrap
- jQuery
- Webpacker

## Application Architecture

The project follows a standard Rails MVC structure:

- **Models**
  - User
  - Expense
  - Friendship
  - Split

- **Controllers**
  - Dashboard controller
  - Friends controller
  - Expenses controller

- **Views**
  - Server-rendered Rails views
  - Bootstrap based UI

## Key Concepts Demonstrated

- Authentication with Devise
- Relational data modeling
- Handling many-to-many relationships
- Controller driven business logic
- Rails routing and resource structure
- MVC architecture

## Setup Instructions

### Requirements

- Ruby 3.0+
- Rails 6+
- Node
- Yarn

### Installation

Clone the repository

```bash
git clone https://github.com/100rabhg/SplitWise-clone.git
cd SplitWise-clone
```

Install dependencies

```bash
bundle install
yarn install
```

Setup database

```bash
rails db:setup
```

Start the server

```bash
rails s
```

Visit ```http://localhost:3000```


### Default Seed Users

The application seeds some sample users for testing.

You can login with seeded credentials or create a new account.