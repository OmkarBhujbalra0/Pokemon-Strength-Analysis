use pokedb;

-- Count of pokemons in each type

select count(*) as count,t.type_name
from pokemon_types pt
join types_table t
on pt.type_id = t.type_id
group by t.type_name
order by count(*) desc;

-- Average Total Stats by Type

select t.type_name,avg(total_stats) as avg_stats
from pokemon_types pt
join types_table t
on pt.type_id = t.type_id
join metrics_table m
on m.pokemon_id = pt.pokemon_id
group by t.type_id
order by avg(total_stats) desc;

-- count of pokemons introduced in each generation by types

select p.generation,count(*) as count,t.type_name
from pokemon_table p
join pokemon_types pt
on p.pokemon_id = pt.pokemon_id
join types_table t
on pt.type_id = t.type_id
group by generation,type_name; 

-- Average Offensive Score & Defensive Score by Type

select t.type_name,
avg(offensive_score/2) as avg_off_score,
avg(defensive_score/3) as avg_def_score,
avg(offensive_score/2) - avg(defensive_score/3) as DesignBias
from pokemon_types pt
join types_table t
on pt.type_id = t.type_id
join metrics_table m
on pt.pokemon_id = m.pokemon_id
group by t.type_name
order by avg(offensive_score/2) - avg(defensive_score/3) desc;

-- Average Offensive & Defensive Score across the generations

select type_name,
avg(offensive_score/2) as avg_off_score,
avg(defensive_score/3) as avg_def_score,
generation,
avg(offensive_score/2)-avg(defensive_score/3) as offensive_bias
from pokemon_table p
join pokemon_types pt
on p.pokemon_id = pt.pokemon_id
join types_table t
on pt.type_id = t.type_id
join metrics_table m
on p.pokemon_id = m.pokemon_id
group by generation, type_name
having type_name='Dragon';

-- Create a Dual Type Table

select pt1.pokemon_id,
least(t1.type_name,t2.type_name) as type1,
greatest(t1.type_name,t2.type_name) as type2
from pokemon_types pt1
join pokemon_types pt2
	on pt1.pokemon_id = pt2.pokemon_id and pt1.type_id < pt2.type_id
join types_table t1
	on pt1.type_id = t1.type_id
join types_table t2
	on pt2.type_id = t2.type_id
order by pt1.pokemon_id;

-- Avg Stats of Dual Types 
select avg(m.total_stats) as avgstats,type1,type2 from
(select pt1.pokemon_id,
least(t1.type_name,t2.type_name) as type1,
greatest(t1.type_name,t2.type_name) as type2
from pokemon_types pt1
join pokemon_types pt2
	on pt1.pokemon_id = pt2.pokemon_id and pt1.type_id < pt2.type_id
join types_table t1
	on pt1.type_id = t1.type_id
join types_table t2
	on pt2.type_id = t2.type_id
order by pt1.pokemon_id) as dual_type
join metrics_table m
on dual_type.pokemon_id = m.pokemon_id
group by type1, type2
having count(*)>=3
order by avgstats desc;