create table if not exists members 
(
    name    varchar(100)    not null,
    chat    integer         not null,

    constraint fk_name
        foreign key (name)
            references users(handle)
            on delete cascade,

    constraint fk_chat
        foreign key (chat)
            references chats(id)
            on delete cascade
);
