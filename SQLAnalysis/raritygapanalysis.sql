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

-- Comparison between avgstats of legendary / non-legendary / mythical pokemons

select pd.category,
avg(m.total_stats) as avgstats,std(m.total_stats) as stdstats,count(*) as pokecount,
max(m.total_stats) as maxstats,min(m.total_stats) as minstats
from pokedistinct pd
join metrics_table m
on pd.pokemon_id = m.pokemon_id
group by pd.category;

-- Legendary pokemons are 44% stronger than Non-Legendary Pokemons
-- Mythical Pokemons are 42% stronger than Non-Legendary Pokemons

-- Avg.Stats of Legendary/Mythical/normal pokemons across generations

select pd.generation,pd.category,count(*) as count,
avg(m.total_stats) as avgstats,std(m.total_stats) as stdstats,
max(m.total_stats) as maxstats,min(m.total_stats) as minstats
from pokedistinct pd
join metrics_table m
on pd.pokemon_id = m.pokemon_id
group by pd.category,pd.generation
having count>=2; 

with avglegendstats as (
select pd.generation,avg(m.total_stats) as avglegstats
from pokedistinct pd
join metrics_table m
on pd.pokemon_id = m.pokemon_id
where pd.category = 'Legendary'
group by pd.generation),
avgnormalstats as (
select pd.generation,avg(m.total_stats) as avgnormstats
from pokedistinct pd
join metrics_table m
on pd.pokemon_id = m.pokemon_id
where pd.category = 'Normal'
group by pd.generation)
select l.generation,l.avglegstats,n.avgnormstats,
(l.avglegstats-n.avgnormstats) as powergap
from avglegendstats l
join avgnormalstats n
on l.generation = n.generation;

-- The total stats for legendary pokemons keep decreasing across generations whereas 
-- total stats for non-legendaries gradually increases resulting in decreasing power gap

-- Comparison between Strongest Non-legendaries and weakest legendaries

with topnonlegends as (
select pd.pokemon_name,m.total_stats,row_number() over (order by m.total_stats desc) as ranker
from pokedistinct pd
join metrics_table m
on pd.pokemon_id = m.pokemon_id
where pd.category = 'Normal'
order by m.total_stats desc
limit 10),
weaklegends as (
select pd.pokemon_name,m.total_stats,row_number() over (order by m.total_stats) as ranker
from pokedistinct pd
join metrics_table m
on pd.pokemon_id = m.pokemon_id
where pd.category = 'Legendary'
order by m.total_stats
limit 10)
select n.pokemon_name,n.total_stats,l.pokemon_name,l.total_stats,l.ranker 
from topnonlegends n
join weaklegends l
on n.ranker = l.ranker;

-- Some Legendary Pokemons only exists for story progression rather than power-oriented
-- Except Slaking all pokemons in top 10 are pseudo-legendaries having base stats greater than legendaries