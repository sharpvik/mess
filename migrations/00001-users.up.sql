create table if not exists users (
    handle varchar(100) primary key,
    name varchar(100),
    hash varchar(64) not null,
    salt bytea not null
);