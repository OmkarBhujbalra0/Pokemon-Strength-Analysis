use pokedb;

create view pokedistinct as
select pokemon_id,pokemon_name,generation,is_legendary,is_mythical,
case
when is_legendary is true then "Legendary"
when is_mythical is true then "Mythical"
else "Normal"
end as category
from pokemon_table;

select * from pokedistinct
where category = "Normal";

select count(*),avg(m.total_stats),p.category
from pokedistinct p
join metrics_table m
on p.pokemon_id = m.pokemon_id
group by p.category;

-- Comparison between avgstats of legendary and non-legendary pokemons

select p.is_legendary,avg(m.total_stats) as avg_stats,
std(m.total_stats) as std_stats,max(m.total_stats) as maxstats,
min(m.total_stats),count(*) as pokecount
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id
group by p.is_legendary;

-- Avg.Stats of Legendary pokemons across generations

select p.generation,avg(m.total_stats) as avg_stats
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id
where p.is_legendary is true
group by p.is_legendary,p.generation;