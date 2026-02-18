---
title: "Hands-on: SQL queries"
start: true
teaching: 0
exercises: 90
questions:
- "Data cleaning with SQLite"
- "Hands on GBIF SQL"

objectives:
- "Understand how SQLite can help cleaning data"
- "Understand how GBIF SQL works"

keypoints:
- SQL can be very useful to clean your data
- Views are great to filter the records and fields you want to keep without changing your original data
- Store your SQL statements under Git
- SQL statements are easy to understand, sustainable and reusable
- GBIF cubes and SQL are very powerful
---

#Hands on: GBIF Data Cubes and SQL

In this session, we stop treating data as a list of individual sightings and start treating it as a statistical grid. By using SQL, we can summarize billions of records into a small, "analysis-ready" table before we even download it.

## Getting Started
Go to GBIF.org.

Apply a filter (e.g., Country: Ethiopia).

Click Download and select the Data Cube format.

Click "Edit as SQL" at the bottom of the pop-up.

Session Exercises
### 1. The "Temporal Trend" Cube
Goal: Track the recording history of Mammals in Ethiopia.
Task: Edit the SQL to count mammal sightings per year.


```sql
SELECT
  year,
  COUNT(*) AS occurrenceCount
FROM occurrence
WHERE
  countryCode = 'ET'
  AND classKey = 359 -- The taxonKey for Mammalia
  AND year >= 1950
GROUP BY
  year
ORDER BY
  year DESC
```
Discovery: Look at the resulting table. Is there a specific decade where the number of mammal records in Ethiopia suddenly spikes? Why do you think that is?

```sql
SELECT
  kingdom,
  kingdomkey,
  phylum,
  phylumkey,
  class,
  classkey,
  "order",
  orderkey,
  family,
  familykey,
  genus,
  genuskey,
  species,
  specieskey,
  "year",
  -- Window functions to calculate counts at higher taxonomic levels
  IF(ISNULL(kingdomkey), NULL, SUM(COUNT(*)) OVER (PARTITION BY kingdomkey, "year")) kingdomcount,
  IF(ISNULL(familykey), NULL, SUM(COUNT(*)) OVER (PARTITION BY familykey, "year")) familycount,
  COUNT(*) occurrences,
  MIN(COALESCE(coordinateuncertaintyinmeters, 1000)) mincoordinateuncertaintyinmeters
FROM
  occurrence
WHERE
  occurrence.countrycode = 'ET'
  AND occurrence.coordinateuncertaintyinmeters <= 58.0 -- Strict spatial filter
  AND occurrence.occurrencestatus = 'PRESENT'
  AND occurrence.hasgeospatialissues = FALSE -- Clean data only
  AND NOT GBIF_STRINGARRAYCONTAINS(occurrence.issue, 'TAXON_MATCH_FUZZY', TRUE) -- High taxonomic certainty
  AND (occurrence.distancefromcentroidinmeters >= 2000.0 OR occurrence.distancefromcentroidinmeters IS NULL) -- Avoid country centroids
  AND NOT occurrence.basisofrecord IN ('FOSSIL_SPECIMEN', 'LIVING_SPECIMEN') -- Wild observations only
GROUP BY
  occurrence.kingdom,
  occurrence.kingdomkey,
  occurrence.phylum,
  occurrence.phylumkey,
  occurrence.class,
  occurrence.classkey,
  occurrence."order",
  occurrence.orderkey,
  occurrence.family,
  occurrence.familykey,
  occurrence.genus,
  occurrence.genuskey,
  occurrence.species,
  occurrence.specieskey,
  occurrence."year"
```

1. Window Functions (OVER PARTITION BY)
This is the "magic" of Data Cubes. While the query groups data by Species, the SUM(COUNT(*)) OVER (PARTITION BY familykey, "year") allows you to see the total count for the entire Family on the same row. This is incredibly useful for calculating the proportion of a specific species relative to its family.

2. Centroid Exclusion
The line occurrence.distancefromcentroidinmeters >= 2000.0 is a professional touch. Many old records are mapped to the exact center of a country or province when specific coordinates are missing. This filter removes those "artificial" clusters.

3. The "Fuzzy" Taxon Filter
Using NOT GBIF_STRINGARRAYCONTAINS(..., 'TAXON_MATCH_FUZZY') ensures that you only include records where the name in the original data was a perfect match to the GBIF backbone. This removes identification uncertainties.

```
Participant Challenge
Task: Identify the spatial uncertainty limit in this query. (Answer: 58 meters).

Modify: Can you change the query to include only data from the year 2000 onwards?

Think: Why are FOSSIL_SPECIMEN and LIVING_SPECIMEN excluded for an Ethiopian biodiversity trend analysis?
```


## Presentation: [SQLite](https://docs.google.com/presentation/d/1oMPNqm4tU9BwnUo1zJxI0nlXMPfIljYeAqh4vEdJZ_0/edit?usp=sharing)

![SQLite](../assets/img/SQLite.png)

## Exercise 1 : Download from GBIF.org
### Instructions
- Select at least one of the use cases
- Follow the use case dataset links:
    - A. [iNaturalist Research-grade Observations](https://www.gbif.org/dataset/50c9509d-22c7-4a22-a47d-8c48425ef4a7)
    - B.[Italian official Adriatic  landings between 1953 and 2012](https://www.gbif.org/dataset/6e0f65ad-8ffb-4a07-ac53-2efe9153e994)
    - C.[Naturgucker](https://www.gbif.org/dataset/6ac3f774-d9fb-4796-b3e9-92bf6c81c084)
    - D.[Trawl survey data from the Jabuka Pit area](https://www.gbif.org/dataset/29719761-2d0e-4fef-bfcb-764b20c07d40)
- Click on the **occurrences** button
- On the left panel, filter by **CountryOrArea**
- How many occurrences to you see for **Ethiopia**?
- ⬇️ Download in **simple CSV** format
- Open the downloaded file with a text editor

### Solution 1
- Your downloads should looks like this:
	- A. [GBIF Download](https://doi.org/10.15468/dl.t2hj6v) (116,575 occurrences)
	- B. [GBIF Download](https://doi.org/10.15468/dl.6gfwt3) (15,077 occurrences)
	- C. [GBIF Download](https://doi.org/10.15468/dl.qy93m6) (13,668 occurrences)
	- D. [GBIF Download](https://doi.org/10.15468/dl.6mf27m) (9,723 occurrences)

## Exercise 2 : Import data
### Instructions
- Open the DBrowser application
- Create a new empty database
- Import the GBIF downloaded data into an SQL table named ‘occ’
- How many records do you have?
- Save your database

### Solution 2
```sql
select count(*) from occ;
```

## Exercise 3 : Explore data
### Instructions
- (Re)Open your database with DBBrowser
- Do you ALWAYS have **scientificName, date and coordinates**?
- How complete are the data? (describe)
- Put special attention to **individualCount, taxonRank, coordinatesUncertainty, license, issues** fields
- Are all records suitable for your study(**fitness for use**)? Explain why?
- Would you **filter out** some data? Explain why?

### Solution 3
```sql
select * from occ where scientificName is null;
select * from occ where eventdate is null;
select * from occ where year is null or month is null or day is null;
select * from occ where decimalLatitude is null or decimalLongitude is null;

select count(*) from occ where individualCount is null;
select taxonRank, count(*) from occ group by taxonRank;
select phylum, count(*) from occ group by phylum;
select license, count(*) from occ group by license;
```

## Exercice 4 : Discard data
### Instructions
- Do you have absence data? (see **occurrenceStatus** field)
- Discard absence data
- Create a **trusted** view to eliminate **absence data** and data with **taxonRank different from SPECIES**
- How many records do you have in this trusted view?

### Solution 4
```sql
select count(*) from occ where occurrenceStatus='ABSENT';

create view trusted as select * from occ where occurrenceStatus='PRESENT' and taxonRank='SPECIES';
select count(*) from trusted;
```


## Exercice 5 : Filter data
### Instructions
- Do you have data without **coordinatesUncertaintyInMeters**?
- Do you have data with coordinates uncertainty > 10 km?
- Update your **trusted** view to filter out these **records**
- Select only these **fields** in your view:
    - scientificName, Date, coordinates, uncertainty and occurrenceID
- How many records do you have now?

### Solution 5
```sql
select count(*) from occ where coordinateUncertaintyInMeters is null;
select coordinateUncertaintyInMeters, count(*) from occ group by coordinateUncertaintyInMeters;
select * from occ where CAST(coordinateUncertaintyInMeters as INTEGER) > 10000;

drop view if exists trusted ;
create view trusted as select scientificName, year,month,day,decimalLatitude, decimalLongitude,  CAST(coordinateUncertaintyInMeters as INTEGER) as uncertainty, occurrenceID from occ where occurrenceStatus='PRESENT'  and taxonRank='SPECIES' and uncertainty <= 10000;
select count(*) from trusted;

select eventdate, strftime('%d',eventdate) as day, strftime('%m',eventdate) as month, strftime('%Y', eventdate) as year from occ;
```

## Exercice 6 : Annotate data
### Instructions
- IndividualCound is not a mandatory field, set it to 1 when null
- Add a **withMedia** field,  set it to True when mediaType is not null
- Add these two fields to your **trusted** view
- Export the **trusted** view results in a CSV file
- (Now you are ready to merge this online data with your own data)
 
### Solution 6
```sql
update occ set individualCount=1 where individualCount is null;

drop view if exists trusted ;
create view trusted as select scientificName, year,month,day,decimalLatitude, decimalLongitude,  CAST(coordinateUncertaintyInMeters as INTEGER) as uncertainty, occurrenceID, individualCount, mediaType is not null as withMedia from occ where occurrenceStatus='PRESENT' and taxonRank='SPECIES' and uncertainty <= 10000;
```
