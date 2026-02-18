---
title: "Introduction to GBIF data cubes (SQL option)"
start: true
teaching: 90
exercises: 90
objectives:
- "Understand the purpose of Cubes"
keypoints:
- "Hip to be Cubed"
---

# Introduction to GBIF data cubes (SQL option)



Traditional downloads give you every single column for every single record. Data Cubes are different: they are multi-dimensional summaries. They are perfect for answering questions like: "How has the number of recorded bird species in Ethiopia changed per year since 1970?"

In this session, we explore the SQL Download API, which allows you to write custom queries to "slice and dice" the GBIF database before you even hit the download button.

Gemini zei
The next logical step in your workshop is the GBIF Data Cube. This is a relatively new and powerful feature that moves away from raw record lists toward "Analysis-Ready" summarized data.

Instead of downloading 1 million individual dots (records) and aggregating them yourself, a Data Cube allows you to ask GBIF's servers to do the math for you—returning a neat table of counts based on time, space, and taxonomy.

Introduction to GBIF Data Cubes (SQL Option)
Traditional downloads give you every single column for every single record. Data Cubes are different: they are multi-dimensional summaries. They are perfect for answering questions like: "How has the number of recorded bird species in Ethiopia changed per year since 1970?"

In this session, we explore the SQL Download API, which allows you to write custom queries to "slice and dice" the GBIF database before you even hit the download button.

## Why use Data Cubes?
Performance: Smaller file sizes (KBs instead of GBs).

Speed: The aggregation happens on GBIF’s high-performance servers.

Flexibility: You choose exactly which "dimensions" (columns) you want.

FAIR Data: Each cube gets its own DOI, making your summarized analysis fully citable.

## The "Golden Rules" of GBIF SQL

| **Rule** | **Constraint** |
| :--- | :--- |
| **Only One Table** | You can only query the `occurrence` table. You cannot use `JOIN` to combine it with other tables (like checklists or environmental layers). |
| **No `SELECT *`** | You must explicitly list the columns you want (e.g., `SELECT scientificName, decimalLatitude`). This keeps the download size manageable. |
| **Single Query** | Sub-queries (queries inside other queries) are generally not supported. |
| **Read-Only** | You can only use `SELECT` commands. You cannot `INSERT`, `UPDATE`, or `DELETE` anything. |



Session Exercises: Thinking in SQL
1. The "Simple Summary" Cube
Goal: Create a cube that counts species per year for a specific group.
Task: Use the "Cube" tab on the GBIF download page. Select Taxonomic (Species) and Temporal (Year) as your dimensions.
Exercise: Run this for Mammals in Ethiopia.
Result: You will get a table with three columns: species, year, and occurrenceCount.

2. Grid-Based Exploration (The Spatial Dimension)
Goal: Summarize data into standardized geographic grids.
Task: Create a cube using a Spatial Dimension (e.g., the EEA 1km grid or the Military Grid Reference System).
Exercise: Pick a specific region in Ethiopia (like the Simien Mountains) and see how many observations exist per grid cell.

3. Customizing with SQL (The "Edit as SQL" Challenge)
Goal: Use SQL to add complex filters like "Life Stage" or "IUCN Category."
Task: Switch to the Edit as SQL view in the GBIF portal.
Exercise: Modify the query to count only records where lifeStage = 'ADULT'.

SQL

```sql
SELECT 
  speciesKey, 
  year, 
  COUNT(*) AS occurrenceCount
FROM occurrence
WHERE 
  countryCode = 'ET' AND 
  lifeStage = 'ADULT' AND
  year >= 2000
GROUP BY speciesKey, year
```

4. The "Uncertainty" Filter
Goal: Create a high-quality data cube by filtering for precision.
Task: Add a constraint to your SQL query to only include records with a coordinateUncertaintyInMeters less than 100m.

```sql
SELECT 
  speciesKey, 
  year, 
  COUNT(*) AS occurrenceCount
FROM occurrence
WHERE 
  countryCode = 'ET' AND 
  coordinateUncertaintyInMeters < 100
GROUP BY speciesKey, year
```


<a href="https://docs.google.com/presentation/d/1gSXkpcZthO6EDHNWfVOsiNSugpjuo5DPOLzHUIkKhvQ/edit?usp=sharing">
    <img src="{{ '/assets/img/cubes2.png' | relative_url }}">
  </a>


<a href="https://docs.google.com/presentation/d/1P3Wt1udes5581cH0gcEj2ANpcr0hZcemQQrTCvAizM8/edit?usp=sharing">
    <img src="{{ '/assets/img/cubes3.png' | relative_url }}">
  </a>


## GBIF SQL Cheat Sheet

### 1. Essential Columns
* `occurrence`: The main table containing all data.
* `speciesKey`: The unique ID for the species.
* `basisOfRecord`: How the data was collected (HUMAN_OBSERVATION, etc).

### 2. Useful SQL Functions
* `COUNT(*)`: Counts the number of records in each group.
* `COUNT(DISTINCT speciesKey)`: Counts how many *unique* species are in that group.
* `GBIF_MGRSCode(gridSize, lat, lon)`: Groups points into military grid cells.

### 3. Basic Query Structure
```sql
SELECT 
  dimensions (e.g., year, speciesKey), 
  measure (e.g., COUNT(*))
FROM occurrence
WHERE filters (e.g., countryCode = 'ET')
GROUP BY dimensions
```




## Presentation Open REfine (optional)

<a href="https://docs.google.com/presentation/d/1wtvqjm8XxbfYOzmkE03yTux42KmN2c-sDyK-EgH_q5M/edit?usp=sharing">
    <img src="{{ '/assets/img/openrefine.PNG' | relative_url }}">
  </a>

You can find the complete user manual [here](https://openrefine.org/docs/manual/starting)

> ## Excercise : Openrefine
> 
> 1. Complete [this](https://drive.google.com/file/d/1KKkqfjAtkaV80Xs1vd0ycTeaJwztxU3b/view?usp=drive_link) exercise
> 
>    
> > ## SOLUTION
> > 1. follow the guidelines in the tutorial document
> > 
> {: .solution}
{: .challenge}

<a href="https://drive.google.com/file/d/1KKkqfjAtkaV80Xs1vd0ycTeaJwztxU3b/view?usp=drive_link">
    <img src="{{ '/assets/img/openrefine_tutorial.PNG' | relative_url }}">
  </a>

