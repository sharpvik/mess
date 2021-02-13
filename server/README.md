# Mess Server

## Setup

Create the `.env` file.

```bash
python make_env.py
```

## Run

### Database

```bash
docker-compose up -d db
```

### Server

#### Production Mode

The server will be publically available on the network, running on `0.0.0.0`
port `80`. Use this mode when you're production-ready!

```bash
go build -o mess
./mess
```

#### Development Mode

The server will serve on `localhost` port `8080`. Use this mode for development
and internal testing behind closed doors.

```bash
go run main.go -dev
```
