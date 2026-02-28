use pokedb;
-- Generations based on their avgstats
select p.generation,avg(m.total_stats) as avg_total_stats,rank() over (order by avg(total_stats) desc)
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id
group by p.generation;

-- Top 3 Pokemons from each generation ranked by their total_stats
select * from
(select p.pokemon_name,m.total_stats,
row_number () over (partition by p.generation order by total_stats desc) as rankpergen,
p.generation,avg(total_stats) over (partition by generation) as avgstats
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id) as ranktable
where rankpergen <= 3
order by avgstats desc;

select count(*),total_stats,avg_stats,generation from (select p.pokemon_name,p.generation,total_stats,avg(total_stats) over (partition by p.generation) as avg_stats
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id) as avgtable
group by generation
having total_stats > avg_stats;