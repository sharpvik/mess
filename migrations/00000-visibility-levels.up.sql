create table if not exists visibility_levels
(
    lvl     text    primary key
);

insert into visibility_levels (lvl)
values ('public')
on conflict do nothing;

insert into visibility_levels (lvl)
values ('private')
on conflict do nothing;
