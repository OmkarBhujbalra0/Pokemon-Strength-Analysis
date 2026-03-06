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