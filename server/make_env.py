from secrets import choice
from string import ascii_letters as letters, digits


ALPHABET = letters + digits
password = ''.join(choice(ALPHABET) for i in range(40))
TEMPLATE = f"""\
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=mess
POSTGRES_PASSWORD={password}
POSTGRES_DB=mess
POSTGRES_MIGRATIONS=migrations

CLIENT_DIR=client/dist
"""


if __name__ == '__main__':
    with open('.env', 'w') as env:
        env.write(TEMPLATE)
