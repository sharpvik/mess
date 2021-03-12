from secrets import choice
from string import ascii_letters as letters, digits


ALPHABET = letters + digits
password = ''.join(choice(ALPHABET) for i in range(40))
jwt_signing_key = ''.join(choice(ALPHABET) for i in range(64))
TEMPLATE = f"""\
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=mess
POSTGRES_PASSWORD={password}
POSTGRES_DB=mess
POSTGRES_MIGRATIONS=migrations

CLIENT_DIST_DIR=client/dist
STORAGE_DIR=storage

JWT_SIGNING_KEY={jwt_signing_key}
"""


if __name__ == '__main__':
    print(TEMPLATE)
