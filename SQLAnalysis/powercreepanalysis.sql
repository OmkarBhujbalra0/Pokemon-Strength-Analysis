use pokedb;

-- Generations based on their avgstats
select p.generation,avg(m.total_stats) as avg_total_stats,rank() over (order by avg(total_stats) desc) as GenRank
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id
group by p.generation;

-- Does Top 10 pokemons with highest total stats contribute to overall average stats of their generations.

select generation,sum(total_stats),max(sumstats),
round(sum(total_stats)*100/max(sumstats)) as contributepercent from
(select generation,pokemon_name,total_stats,avg(total_stats) over (partition by generation) as avgstats,
sum(total_stats) over (partition by generation) as sumstats,
row_number() over(partition by generation order by total_stats desc) as statsrank
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id) as avgrank
where statsrank <=10
group by generation;

-- Top 3 Pokemons from each generation ranked by their total_stats
select * from
(select p.pokemon_name,m.total_stats,
row_number () over (partition by p.generation order by total_stats desc) as rankpergen,
p.generation,avg(total_stats) over (partition by generation) as avgstats
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id) as ranktable
where rankpergen <= 3
order by generation,avgstats desc;

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

-- Pokemons whose offensive score is greater than average of their generation.

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

-- Pokemons whose defensive score is greater than average of their generation

with defelite as 
(select defscore,pokemon_name,generation,
avg(defscore) over (partition by generation) as avgdef,
std(defscore) over (partition by generation) as stddef
from offdef),
flagged as (
select generation,
case
when defscore > (avgdef + stddef) then 1
else 0
end as iselite
from defelite)
select generation,count(*) as total_count,
sum(iselite) as elite_count,
round(sum(iselite)*100/count(*),2) as defpercent
from flagged
group by generation;

-- Design Bias throughout the generations

with designbias as (
select offscore,defscore,generation,avg(offscore) over (partition by generation) as avgoff,
std(offscore) over (partition by generation) as stdoff,
avg(defscore) over (partition by generation) as avgdef,
std(defscore) over (partition by generation) as stddef
from offdef),
flagged as (
select generation,
case
when (offscore > avgoff + stdoff) then 1
else 0
end as offelite,
case
when (defscore > avgdef+ stddef) then 1
else 0
end as defelite
from designbias) 
select generation,
count(*) as total_count,
sum(offelite) as elite_count,
round(sum(offelite)*100/count(*),2) as percentoff,
sum(defelite) as elite_count,
round(sum(defelite)*100/count(*),2) as percentdef,
round(sum(offelite)*100/count(*),2) - round(sum(defelite)*100/count(*),2) as designbiasdiff
from flagged
group by generation;
 
-- Do Legendary pokemons contributes more to offensive score or defensive score percentage
with offordefelite as (
select o.offscore,o.defscore,o.generation,o.pokemon_name,p.is_legendary,
avg(offscore) over (partition by generation) as avg_off,
std(offscore) over (partition by generation) as std_off,
avg(defscore) over (partition by generation) as avg_def,
std(defscore) over (partition by generation) as std_def
from offdef o
join pokemon_table p
on o.pokemon_name = p.pokemon_name),
flagged as (
select generation,is_legendary,
case
when offscore > (avg_off + std_off) then 1
else 0
end as isoffelite,
case
when defscore > (avg_def + std_def) then 1
else 0
end as isdefelite
from offordefelite)
select generation,count(*) as total_count,
sum(is_legendary),
sum(isoffelite),
sum(isdefelite),
sum(case when isoffelite = 1 and is_legendary=1 then 1 else 0 end) as legendoffelite,
sum(case when isdefelite = 1 and is_legendary=1 then 1 else 0 end) as legenddefelite,
round(sum(case when isoffelite = 1 and is_legendary=1 then 1 else 0 end)*100/sum(isoffelite),2) as legend_to_off_ratio,
round(sum(case when isdefelite = 1 and is_legendary=1 then 1 else 0 end)*100/sum(isdefelite),2) as legend_to_def_ratio
from flagged
group by generation;

-- Based on results of above queries, legendary pokemon consistently contribute to both 
-- offensive and defensive outliers without primarily driving it and there is 
-- no dramatic escalation.

-- The analysis indicates:
-- 1. Power creep exists, but in structural waves rather than steady escalation.
-- 2. Gen 4 marks a significant inflation inflection point.
-- 3. Modern generations (7–9) show renewed upward pressure.
-- 4. Inflation appears ecosystem-wide rather than elite-concentrated.
-- 5. Legendary Pokémon contribute to extremes but do not monopolize them.
-- 6. No strong evidence supports increasing stat concentration among top Pokémon.