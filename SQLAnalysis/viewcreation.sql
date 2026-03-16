create view avgstatsrank as 
select p.generation,avg(m.total_stats) as avg_total_stats,rank() over (order by avg(total_stats) desc) as GenRank
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id
group by p.generation;

create view offdefscore as
select generation,avg(offscore) as avg_offscore,
avg(defscore) as avg_defscore
from offdef
group by generation;

create view categorized as 
select * from pokedistinct;

create view designbiasview as 
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
sum(offelite) as eliteoff_count,
round(sum(offelite)*100/count(*),2) as percentoff,
sum(defelite) as elitedef_count,
round(sum(defelite)*100/count(*),2) as percentdef,
round(sum(offelite)*100/count(*),2) - round(sum(defelite)*100/count(*),2) as designbiasdiff
from flagged
group by generation;
 
select * from designbiasview; 

create view topten as
select * from
(select p.pokemon_name,m.total_stats,
row_number () over (partition by p.generation order by total_stats desc) as rankpergen,
p.generation,avg(total_stats) over (partition by generation) as avgstats
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id) as ranktable
where rankpergen <= 10
order by generation,avgstats desc;

select * from topten;