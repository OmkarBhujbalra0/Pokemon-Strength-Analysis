use pokedb;

select generation,count(*) as pokecount
from pokemon_table
where is_legendary is true
group by is_legendary,generation;

select p.is_legendary,avg(m.total_stats) as avg_stats,
std(m.total_stats) as std_stats,max(m.total_stats) as maxstats,
min(m.total_stats),count(*) as pokecount
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id
group by p.is_legendary;

select p.generation,p.is_legendary,avg(m.total_stats) as avg_stats
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id
where p.is_legendary is true
group by p.is_legendary,p.generation;