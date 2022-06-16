create table if not exists members (
    handle varchar(100) not null,
    chat integer not null,
    constraint fk_name foreign key (handle) references users(handle) on delete cascade on update cascade,
    constraint fk_chat foreign key (chat) references chats(id) on delete cascade
);