create database Pokedb;
use Pokedb;

create table Pokemon_Table (
pokemon_id int primary key,
pokemon_name varchar(50) not null,
generation varchar(10) not null,
is_legendary boolean not null,
is_pseudolegend boolean not null
);

create table Stats_Table (
pokemon_id int primary key,
hp int not null,
attack int not null,
defense int not null,
sp_atk int not null,
sp_def int not null,
speed int not null,
foreign key (pokemon_id)
references Pokemon_Table(pokemon_id)
on delete cascade
);

create table Metrics_Table (
pokemon_id int primary key,
total_stats int not null,
offensive_score int not null,
defensive_score int not null,
specialization_score float not null,
foreign key (pokemon_id)
references Pokemon_Table(pokemon_id)
on delete cascade
);

create table Types_Table (
type_id int primary key auto_increment,
type_name varchar(30) unique not null
);

create table Pokemon_Types (
pokemon_id int,
type_id int,
foreign key (pokemon_id)
references Pokemon_Table(pokemon_id)
on delete cascade,
foreign key (type_id)
references Types_Table(type_id)
on delete restrict
);

select * from pokemon_table left join stats_table on pokemon_table.pokemon_id = stats_table.pokemon_id;
select * from pokemon_table left join metrics_table on pokemon_table.pokemon_id = metrics_table.pokemon_id;
select * from pokemon_table right join pokemon_types on pokemon_table.pokemon_id = pokemon_types.pokemon_id;
select * from pokemon_types right join types_table on pokemon_types.type_id = types_table.type_id;