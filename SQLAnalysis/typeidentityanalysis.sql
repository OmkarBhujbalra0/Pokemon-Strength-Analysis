use pokedb;

-- Count of pokemons in each type

select count(*) as count,t.type_name
from pokemon_types pt
join types_table t
on pt.type_id = t.type_id
group by t.type_name
order by count(*) desc;

-- Average Total Stats by Type

select t.type_name,avg(total_stats) as avg_stats,count(*) as pokecount
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
select avg(m.total_stats) as avgstats,type1,type2,count(*) as pokecount from
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

-- Dragon Type Combination are at top of avg stats even though they have less frequency

-- Type Combinations with high frequency tend to have low avg stats indicating that 
-- these combinations  are most used for early games.

-- Steel type Combos are still above most of the combos even after having less count.

-- Single types Table

select t.type_name,avg(m.total_stats) as avgstats,count(*) as pokecount
from pokemon_types pt
join types_table t
on pt.type_id = t.type_id
join metrics_table m
on pt.pokemon_id = m.pokemon_id
where pt.pokemon_id in (select pokemon_id from pokemon_types group by pokemon_id having count(*)=1)
group by t.type_name
order by avgstats desc;

-- Steel Types remains at the top even without combos
-- Psychic Types have high count and high avgstats
-- Bug Types have low avg stats in both single and dual types strengthening the assumption that bug types are made for early games.

-- Avg. Total Stats Comparison

select avg(m.total_stats) as avgsinglestats
from pokemon_types pt
join metrics_table m
on pt.pokemon_id = m.pokemon_id
where pt.pokemon_id in 
(select pokemon_id from pokemon_types group by pokemon_id having count(*)=1);

select avg(m.total_stats) as avgdualstats
from pokemon_types pt
join metrics_table m
on pt.pokemon_id = m.pokemon_id
where pt.pokemon_id in
(select pokemon_id from pokemon_types group by pokemon_id having count(*)=2);

-- Dual Types are stronger in terms of stats than single types
-- Design Philosophy - Usually dual types are the ones who are fully evolved,pseudolegend or legendary
-- Single Types are one with middle evolutions, early route pokemons.

-- Count of single/dual types
select count(*) as totalcount from(
select count(*) as total 
from pokemon_types
group by pokemon_id
having count(*) = 1) as total;

select count(*) as total_count from
(select count(*) as total
from pokemon_types
group by pokemon_id
having count(*) = 2) as total;

select std(m.total_stats) as stddualstats,type1,type2,count(*) as pokecount from
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
order by stddualstats desc;

select t.type_name,std(m.total_stats) as stdsingstats,count(*) as pokecount
from pokemon_types pt
join types_table t
on pt.type_id = t.type_id
join metrics_table m
on pt.pokemon_id = m.pokemon_id
where pt.pokemon_id in (select pokemon_id from pokemon_types group by pokemon_id having count(*)=1)
group by t.type_name
order by stdsingstats desc;

-- From the results of above queries, single types have stats uniformly distributed among 
-- pokemons whereas dual type pokemon have higher variance (stats drastically greater than mean).

