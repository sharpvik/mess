create table if not exists chats
(
    id      serial          primary key,
    name    varchar(100)    default null,
    visibility      text        not null,

    constraint fk_visibility
        foreign key (visibility)
            references visibility_levels(lvl)
);

insert into chats
(
    name,
    visibility
)
select
    'COZY CHAT',
    'public'
where not exists
(
    select * from chats 
    where name = 'COZY CHAT'
);
