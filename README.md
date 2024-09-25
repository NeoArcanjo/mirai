# Polling App

This is a simple polling application built with Phoenix LiveView. The application allows users to create new polls, vote in polls, and see real-time updates of the poll results. All data is stored in application memory, and no external dependencies such as databases or disk storage are used.

## Features

- User account creation by entering a username
- Create new polls
- Vote in existing polls
- Real-time updates of poll results
- Each user can vote only once per poll
- Non-blocking user actions
 
## Requirements
 
- Elixir 1. 14 or later
- Erlang/OTP 26 or later
- Phoenix 1. 7 or later

## Setup

__1. Clone the repository:__

``` bash
git clone https://github.com/NeoArcanjo/mirai.git polling_app
cd polling_app
```

__2. Install dependencies:__

``` bash
mix deps.get
```

__3. Start the Phoenix server:__

``` bash
mix phx.server
```

__4. Access the application:__ Open your web browser and navigate to `http://localhost:4000`.

## Usage

__1. Create an account:__

- Enter a username to create an account.

__2. Create a new poll:__

- Navigate to the “Create Poll” section.
- Enter the poll question and options.
- Submit to create the poll.

__3. Vote in a poll:__

- Navigate to the poll you want to vote in.
- Select an option and submit your vote.

__4. View real-time poll results:__

- Poll results will update in real-time as votes are cast.

## Design Decisions

- __In-memory storage__: All data is stored in application memory to meet the requirement of not using external dependencies. Implemented using Agents managed by a Registry (native process implementation that couples GenServer and Ets Table).
- __Phoenix LiveView__: Used for real-time updates and interactive user interfaces.
- __Tailwind CSS Framework__: Any open-source CSS framework can be used for styling.

## Testing

The core business functionality is covered by unit tests.
To run the tests, use the following command:

``` bash
mix test
```

## How works

``` mermaid
graph TD
    A[Users] -->|Web Browser| B[Polling Application]
    B -->|Phoenix LiveView| C[In-Memory Data Store]
    B -->|Handles user sessions| C
    B -->|Manages polls and votes| C
    B -->|Real-time updates| C
    C -->|Stores user accounts| D[View Components]
    C -->|Stores poll data| D
    C -->|Stores votes| D
    D -->|Provides UI styling| A
```
