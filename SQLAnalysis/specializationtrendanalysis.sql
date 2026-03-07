use pokedb;

select p.generation,avg(m.specialization_score) as avg_specialization_score,
std(m.specialization_score) as specialization_spread
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id
group by p.generation;

-- Avg specialization score remains similar for most of the generations

select * from
(select p.pokemon_name,p.generation,m.specialization_score,avg(specialization_score) over (partition by p.generation) as avgspecial,
row_number() over(partition by p.generation order by m.specialization_score desc) as top_specialized
from pokemon_table p
join metrics_table m
on p.pokemon_id = m.pokemon_id) as special_table
where top_specialized<=10;

-- Average Stats across the generations

select p.generation,avg(s.hp) as avghp,avg(s.attack) as avgatk,avg(s.defense) as avgdef,
avg(s.sp_atk) as avgspatk,avg(sp_def) as avgspdef,
avg(speed) as avgspd,count(*) as pokecount
from pokemon_table p
join stats_table s
on p.pokemon_id = s.pokemon_id
group by generation;

-- Avg. HP increases steadily across the generations

-- Avg. Attack increases overtime,gen 7-9 being highest indicating generations
-- favors the attack stats

-- Avg. Defense increases across generations

-- Sp.Atk increases after gen 3 due splitting special stats into sp.atk and spdef

-- Speed decreased in early generations but increased again in recent generation

-- Are pokemon types linked with any specific stats

create view typestats as 
(select p.pokemon_name,p.generation,t.type_name,s.hp,
s.attack,s.defense,s.sp_atk,s.sp_def,s.speed 
from pokemon_table p
join pokemon_types pt
on p.pokemon_id = pt.pokemon_id
join types_table t
on pt.type_id = t.type_id
join stats_table s
on p.pokemon_id = s.pokemon_id);

select type_name as type,avg(hp),avg(attack),avg(defense),
avg(sp_atk),avg(sp_def),avg(speed),
rank() over (order by avg(hp) desc) as TankRank,
rank() over (order by avg(attack) desc) as AtkRank,
rank() over (order by avg(defense) desc) as DefRank,
rank() over (order by avg(sp_atk) desc) as SpatkRank,
rank() over (order by avg(sp_def) desc) as SpdefRank,
rank() over (order by avg(speed) desc) as SpeedRank
from typestats
group by type_name
order by SpdefRank;

-- Flying Type is Specialized in Speed
-- Electric is specialized in both speed and sp_atk making it fast special attacker
-- Dragon is Specializes in most of the stats making it most durable ones
-- Fighting Type is highly specialized in Attack Stats making it Physical Attacker
-- Steel Type is highly specialized in Defense Stats making it physical tank
-- Psychic Type are specialized in both special attack and defense stats making it special attacker
-- Fairy Type are specialized in Special Defense stat making special tank

-- Are Legendaries/Mythical/Normal Pokemons specialized or balanced in stats

select pd.category,avg(s.hp) as avghp,avg(s.attack) as avgatk,avg(s.defense) as avgdef,
avg(s.sp_atk) as avgspatk,avg(s.sp_def) as avgdpdef,avg(s.speed) as avgspd 
from pokedistinct pd
join stats_table s
on pd.pokemon_id = s.pokemon_id
group by pd.category; 

-- Normal Pokemons have stats in balanced manner
-- Mythical pokemons are slightly leaning towards Special Attack
-- Legendary pokemons are stronger on overall stats 

