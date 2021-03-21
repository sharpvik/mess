create table if not exists messages (
    id serial primary key,
    chat integer not null,
    author varchar(100) not null,
    date date not null,
    time time not null,
    text varchar(1000) not null,
    constraint fk_author foreign key (author) references users(handle) on delete restrict on update cascade,
    constraint fk_chat foreign key (chat) references chats(id) on delete cascade
);