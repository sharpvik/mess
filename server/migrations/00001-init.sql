create table users
(
    name text primary key,
    hash text not null
);

create table chats
(
    id serial primary key,
    name text default null
);

create table members
(
    name text not null,
    chat integer not null,

    constraint fk_name
        foreign key (name)
            references users(name)
            on delete cascade,

    constraint fk_chat
        foreign key (chat)
            references chats(id)
            on delete cascade
);

create table messages
(
    id serial primary key,
    chat integer not null,
    author text not null,
    date date not null,
    time time not null,
    text text not null,

    constraint fk_author
        foreign key (author)
            references users(name),

    constraint fk_chat
        foreign key (chat)
            references chats(id)
            on delete cascade
);

