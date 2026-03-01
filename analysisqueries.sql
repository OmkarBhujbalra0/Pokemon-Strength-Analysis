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

-- Pokemons whose total_stats are greater than avg_total_stats of their generation
create view aboveavg as
select generation,avg_stats_per_gen,count(*) as avgcount from (
select p.pokemon_name,p.generation,total_stats,
avg(total_stats) over (partition by generation) as avg_stats_per_gen
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id) as avgtable
where total_stats > avg_stats_per_gen
group by generation,avg_stats_per_gen;

drop view aboveavg;

create view countview as
select count(*) as total_count,generation 
from pokemon_table
group by generation;

drop view countview;

select * from countview;

select ab.generation,ab.avgcount,ab.avgcount*100/total_count as percentage
from aboveavg ab
join countview co
on ab.generation = co.generation;

-- Average Offensive & Defensive Score of pokemon across generations

create view offdef as 
select pokemon_name,generation,
(offensive_score)/2 as offscore,
(defensive_score)/3 as defscore
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id; 

select generation,avg(offscore) as avg_offscore,
avg(defscore) as avg_defscore
from offdef
group by generation;

-- Standard Deviation of Offensive Score & Defensive Score to check 
-- whether the score is concentrated in few pokemon or spread across all pokemons.

select generation,std(offscore) as std_offscore,
std(defscore) as std_defscore
from offdef
group by generation;

with offelite as (
select offscore,generation,pokemon_name,avg(offscore) over (partition by generation) as gen_avg,std(offscore) over (partition by generation) as gen_std,
(avg(offscore) over (partition by generation) + std(offscore) over (partition by generation)) as sum_off
from offdef),
flagged as (
select generation,
case
when offscore > sum_off then 1
else 0
end as iselite
from offelite
)
select generation,count(*) as total_count,sum(iselite) as elitecount,
round(100*sum(iselite)/count(*),2) as percentelite 
from flagged
group by generation;

