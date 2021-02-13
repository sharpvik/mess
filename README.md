# mess

Simple and beautiful chat web app.

## Clone & Deploy!

I made it very simple to setup and use. You shouldn't face any problems at all.
Follow the steps:

### Clone

```bash
git clone git@github.com:sharpvik/mess.git
cd mess
```

### Setup

```bash
./setup.sh
```

### Deploy with `docker-compose`

```bash
docker-compose up
```

## Manual Setup For Local Testing

Creates the `.env` file and maybe some other fundamental things to prepare for
production deployment.

```bash
chmod +x setup.sh   # if needed
./setup.sh
```

## Manual Deployment

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
