# Down the Rabbit Hole

A Matrix-themed tag game for Grace's birthday party. Every player gets a QR
code. Tag another player on the back, scan their code, and "free their mind."
A live scoreboard tracks who has freed the most minds until the game locks.

## Game play
The game begins when you scan your QR code.

1. **Get a code.** The operator creates a player QR code at `/users/new`
   (or on the Players page, `/users`).
2. **Claim it.** Scan your own QR code with your phone's camera. The first
   scan asks you to choose a name, and saving it signs you in as that player.
3. **Tag someone.** Tag another player on the back, above the waist only.
   Players wearing a **glowstick necklace** are out or opted out: don't touch
   them.
4. **Log the kill.** The tagged player shows their code ("HERE'S MY CODE!").
   You scan it and tap **Free [name]'s mind**. Your kill count goes up on the
   scoreboard.
5. **If you get tagged,** your page shakes and a popup tells you to get a
   glowstick necklace from the operator. Dead players can't free any more
   minds.
6. **Free 5 minds** and see the operator to spin the wheel.
7. **When the countdown on the scoreboard hits zero,** the sentinels arrive:
   the game locks and no more kills can be logged.

Opting out: tap the opt-out link in the welcome popup, or get a glowstick
necklace from the front desk or operator. Any harassment or inappropriate
touching gets a player removed from the party immediately.

### Pages

| Page            | Path            | Who it's for                                       |
| --------------- | --------------- | -------------------------------------------------- |
| FAQ / rules     | `/`             | Everyone                                           |
| Sign in         | `/login`        | Players switching to their account on a new device |
| Player page     | `/users/:id`    | A player's own QR code, status and kill count      |
| Scan            | `/scan?qr_code=…` | Where a QR code takes you; claim a code or log a kill |
| Scoreboard      | `/highscores`   | Live top 5, players remaining, countdown           |
| Players         | `/users`        | Operator: list of everyone                         |
| New player code | `/users/new`    | Operator: create a QR code                         |
| Manual input    | `/manual_input` | Operator: fix a player's status or who killed them |

The operator pages have no password, so don't share those links with
players.

## Running the app locally

### Requirements

- Ruby 3.4.2 (see `.ruby-version`)
- PostgreSQL
- Chrome, only for the browser tests in `test/system`

Redis is only needed in production. In development, live updates (scoreboard,
kill popup) run in-process.

### Setup

1. Install gems and create the database:

   ```sh
   bin/setup
   ```

2. Create a `.env` file in the project root:

   ```sh
   APP_HOST=localhost:3000
   GAME_LOCKS_AT=2026-10-24T23:30:00-04:00
   ```

3. Start the server:

   ```sh
   bin/rails server
   ```

4. Open http://localhost:3000.

### Testing with phones on your Wi-Fi

QR codes link to `APP_HOST`, so phones can't reach `localhost`. To scan codes
from real phones on the same network:

1. Find your computer's local IP address (on a Mac:
   `ipconfig getifaddr en0`).
2. Set `APP_HOST` to it, e.g. `APP_HOST=192.168.1.20:3000`.
3. Start the server so other devices can reach it:

   ```sh
   bin/rails server -b 0.0.0.0
   ```

## Configuration

Set these environment variables in `.env` locally and in your host's config
in production.

| Variable        | Required          | What it does |
| --------------- | ----------------- | ------------ |
| `APP_HOST`      | Yes               | Host (and port) that QR codes link to, e.g. `party.example.com` |
| `GAME_LOCKS_AT` | No                | When the game locks, as an ISO 8601 time **with a time zone offset**, e.g. `2026-10-24T23:30:00-04:00`. Without the offset, the time is read as UTC. If unset or invalid, the game never locks and the scoreboard shows no countdown. |
| `REDIS_URL`     | Production only   | Redis for live updates (Action Cable) |
| `DATABASE_URL`  | Production only   | PostgreSQL connection URL |

After the game locks, players can't log kills or change their status. The
operator's manual input page still works, so mistakes can be corrected.

## Tests

```sh
bin/rails test           # model and controller tests
bin/rails test:system    # browser tests (needs Chrome)
```

## Deployment

The app includes a `Dockerfile`. On your host, set the environment variables
above plus `RAILS_MASTER_KEY` (the contents of `config/master.key`). The container creates or migrates the database when the server
starts.
