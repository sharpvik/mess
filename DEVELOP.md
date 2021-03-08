# Development Instructions

## Dependencies

### Sass

```bash
npm install -g sass # or
brew install sass/sass/sass # if you are on Mac
```

### Elm

See the [official installation guide][elm].

[elm]: https://guide.elm-lang.org/install/elm.html

### Go

See the [official installation guide][go].

[go]: https://golang.org/doc/install

### Docker

Take a look at this [getting started page][docker].

[docker]: https://www.docker.com/get-started

You also need the `docker-compose` command to run Docker services with ease.
Get it with `pip` (hopefully, you have it):

```bash
pip install docker-compose
```

If you don't have `pip`, install it, because you'll need Python anyways!

### Python

Install Python through your package manager of choice or download the latest
version from [the official website][python].

[python]: https://www.python.org/downloads

## TL;DR

Now that you have all the dependencies, you should be able to

```bash
./develop.sh
```

Read on to understand what each command in [`develop.sh`](develop.sh) does.

## Setup

The following script creates the `.env` file and maybe some other fundamental
things to prepare for deployment.

```bash
chmod +x setup.sh # if needed
./setup.sh
```

## Database

```bash
docker-compose up -d db
```

To stop the database when you're done for the day:

```bash
docker stop mess_db
```

## Client

Run this in the `client` folder:

```bash
./build.sh
```

The script will compile Sass styles to proper CSS and build you and Elm web app.
You will see the difference in the [`dist` folder](client/dist).

## Server

### Production Mode

```bash
go build -o mess # compile and output binary called 'mess'
./mess # run it
```

The server will be publically available on the network, running on
`http://0.0.0.0:80`. Use this mode to check how Mess works on devices other than
your PC!

All devices connected to the same network (WiFi or Ethernet) will be able to
access Mess by navigating to your current IP in their browser. Just check your
IP and type it into your browser's URL bar.

### Development Mode

The server will serve on `http://localhost:8000`. Use this mode for development
and internal testing behind closed doors. In this mode, your computer is the
only device that can access Mess.

```bash
go run main.go --dev
```
