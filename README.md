#Pokémon Power Analytics

An end-to-end data analytics project that explores power trends, specialization, and design patterns across Pokémon generations using Python, SQL, and Power BI.

## 🚀 Project Overview

This project analyzes Pokémon stats across generations to uncover:

- 📈 Power Creep – Are Pokémon getting stronger over time?

- ⚖️ Rarity Gap – How do Legendary Pokémon compare to non-Legendary?

- 🎯 Specialization Trends – Are Pokémon becoming more specialized or balanced?

- 🔥 Type Identity – How different types behave in terms of offense and defense

The goal is to transform raw API data into meaningful insights through structured data modeling, SQL analysis, and interactive dashboards.

## SCHEMA DIAGRAM
![https://github.com/OmkarBhujbalra0/Pokemon-Strength-Analysis/blob/adcda5aa90d9859b5d48551125b7b856268fe000/PokeSchema.png]

## 🧠 Key Learnings

- Converting API data into a structured dataset
- Designing a relational database schema from flat data
- Creating relationships between multiple tables
- Writing advanced SQL queries using:
  1. CTEs
  2. Window Functions
  3. Subqueries
- Performing statistical analysis (Mean, Std Dev, CV)
- Building interactive dashboards in Power BI

## 🛠️ Tech Stack

- Python – Data collection & preprocessing
- SQL (MySQL) – Data modeling & analysis
- Power BI – Dashboard & visualization
- Pandas  – Data manipulation
  
## 📊 Analysis Breakdown
1. Power Creep
Tracks average total stats across generations
Identifies whether newer Pokémon are stronger

2. Rarity Gap
Compares Legendary vs Non-Legendary Pokémon
Measures differences in average stats and distributions

3. Specialization
Uses Standard Deviation / Coefficient of Variation (CV)
Identifies whether Pokémon are:
- Balanced
- Offensive-focused
- Defensive-focused

4. Type Identity
Handles dual-type Pokémon by expanding them into multiple rows
Analyzes:
- Offensive strength by type
- Defensive strength by type
- Design bias across generations

## 📈 Dashboard Features (Power BI)
- Multi-page navigation dashboard
- Interactive slicers (Generation, Type, Category)
- KPI cards for quick insights
- Trend charts & comparison visuals

## ⚡ Key Insights
- Pokémon stats show a clear power creep trend over generations
- Legendary Pokémon consistently outperform others, but the gap varies
- Modern generations show increased specialization
- Certain types are heavily biased toward offense or defense

### Dataset Link: https://www.kaggle.com/datasets/omkarbhujbalrao/pokemon-dataset-gen-1-9

## Note
This dataset was extracted from PokéAPI and cleaned for analysis purposes. PokéAPI is an educational API and all credit goes to them for providing the data.
https://pokeapi.co/
