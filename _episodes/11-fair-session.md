---
title: "Intro to R & GBIF-Related R packages ((rgbif, finch,..)"
start: true
teaching: 45
exercises: 0
questions:
- "What is R"
objectives:
- "Getting familiar with R and packages "

keypoints:
- "Getting familiar with R and packages "
---

# Intro to R & GBIF-Related R packages ((rgbif, finch,..)
By Lena Thöle



## R Biodiversity Cheat Sheet

### 1. Installation & Setup


```r
install.packages("rgbif")
install.packages("finch")
library(rgbif)
```

# Introduction to R & GBIF-Related Packages

Why use R for biodiversity data? While the GBIF portal is powerful, R allows for **reproducible, automated, and large-scale science**. By using a programmatic interface, you can move from raw data to sophisticated visualizations and models in a single script.

In this session, we introduce the core tools developed by the **rOpenSci** community that allow R to "talk" directly to the GBIF servers.



---

### Core R Packages for this Session

* **rgbif**: The primary interface for the GBIF API. It allows you to search for species, check taxonomic names against the GBIF backbone, and request bulk data downloads directly from your R console.
* **finch**: A specialized tool used to parse **Darwin Core Archive (DwC-A)** files. When you download large datasets, `finch` helps R read the complex structure of these zip files effortlessly.
* **CoordinateCleaner**: A vital companion package used to "scrub" your data—automatically flagging records that fall in the ocean, at city centers, or inside museum coordinates.

---

### Session Exercises: R Programming for Biodiversity

#### 1. The "Hello GBIF" Script
* **Goal:** Successfully connect R to the GBIF API.
* **Task:** Install and load `rgbif`. Use the `name_backbone()` function to find the unique `usageKey` for an Ethiopian endemic, such as the **Mountain Nyala** (*Tragelaphus buxtoni*).
* **Discovery:** Why is the `usageKey` more reliable than just searching for the name string?

#### 2. Rapid Mapping with `occ_data`
* **Goal:** Visualize sightings in under five lines of code.
* **Task:** Use the `occ_data()` function to pull the last 500 records of **Coffee** (*Coffea arabica*) in Ethiopia.
* **Exercise:** Pipe the results into a quick plot.
* **Discovery:** Identify any obvious spatial outliers in the resulting map.

#### 3. Parsing the Archive with `finch`
* **Goal:** Handle bulk downloads that are too large for simple CSVs.
* **Task:** Take a local **Darwin Core Archive (.zip)** from our Bishoftu Bioblitz.
* **Exercise:** Use `finch::dwca_read()` to explore the "metadata" and "core" data tables hidden inside the zip.

#### 4. The "Cleaner" Challenge
* **Goal:** Automated data quality control.
* **Task:** Run a set of Ethiopian occurrence records through the `clean_coordinates()` function.
* **Exercise:** Identify how many records were flagged as "invalid" because they were exactly at 0,0 or located at the coordinates of a known herbarium.


## Starter Kit

## --- PREPARATION: Install and Load Packages ---

### Run these once to set up your environment

install.packages(c("rgbif", "finch", "CoordinateCleaner", "ggplot2", "dplyr"))


```r
library(rgbif)
library(rgbif)
library(finch)
library(CoordinateCleaner)
library(ggplot2)
library(dplyr)
```

### --- EXERCISE 1: The "Hello GBIF" Script ---
#### Finding the unique Taxon Key for the Mountain Nyala

```r
nyala_lookup <- name_backbone(name = "Tragelaphus buxtoni")
nyala_key <- nyala_lookup$usageKey
```

```r
print(paste("The usageKey for Mountain Nyala is:", nyala_key))
```

Discovery: The usageKey is a unique ID that prevents issues with synonyms or common names.


### --- EXERCISE 2: Rapid Mapping with occ_data ---
#### Pull the last 500 records of Coffee (Coffea arabica) in Ethiopia

```r
coffee_data <- occ_data(
  scientificName = "Coffea arabica", 
  country = "ET",            # ISO code for Ethiopia
  hasCoordinate = TRUE,      # Only get records we can map
  limit = 500
)
```
#### Extract the data frame

```r
coffee_df <- coffee_data$data
```

#### Quick visualization

```r
ggplot(coffee_df, aes(x = decimalLongitude, y = decimalLatitude)) +
  geom_point(color = "darkgreen", alpha = 0.5) +
  theme_minimal() +
  labs(title = "Coffea arabica Occurrences in Ethiopia")
```

### --- EXERCISE 3: Parsing the Archive with finch ---

Replace 'path/to/your/bioblitz.zip' with the actual file path

```r
bioblitz_archive <- dwca_read("path/to/your/bioblitz.zip", read = TRUE)
```

### Explore the contents

```r
View(bioblitz_archive$data[[1]]) # View the main occurrence table
```

### --- EXERCISE 4: The "Cleaner" Challenge ---
#### Clean the coffee data using automated tests

```r
cleaned_coffee <- clean_coordinates(
  x = coffee_df, 
  lon = "decimalLongitude", 
  lat = "decimalLatitude",
  species = "species",
  tests = c("capitals", "centroids", "equal", "zeros", "institutions")
)
```

### summary of flags found

```r
summary(cleaned_coffee)
```

### Keep only the 'clean' records

```r
coffee_final <- coffee_df[cleaned_coffee$.summary, ]
```


### Presentation (optional Extra informatio)

<a href="https://docs.google.com/presentation/d/1HR6RyRdKEuOZoGXaUw193Ka6oxsSYWv6e3Mjqvwa7X8/edit?usp=sharing">
    <img src="{{ '/assets/img/openscience.PNG' | relative_url }}">
  </a>

> ## Excercise : FAIR data & Open Science
> 
> 1. What is the difference between FAIR and OPEN data?
> 2. Check the FAIR Self assessment tool [here](https://ardc.edu.au/resource/fair-data-self-assessment-tool/) Think about a dataset you know and run over the assessment
> 3. What could you do to make your data more FAIR?
> 4. Is data published through GBIF FAIR?
> 5. Is all data published by GBIF considered as open data?
>    
> > ## SOLUTION
> > 1. FAIR data is not always open, FAIR data is findable and good documented. Open data per definition is not always FAIR. (Just an Excel somewhere on a website is considered as open data)
> > 2. <img src="{{ 'assets/img/extra/fair.PNG' | relative_url }}" alt="fair" width="400">{: .image-with-shadow }
> > 3. Publish your data in GBIF or in another open repository like Zenodo 
> > 3. YES
> > 4. No, CC-BY-NC is not considered as open data
> > 
> {: .solution}
{: .challenge}

## Presentation

<a href="https://docs.google.com/presentation/d/1aMJSoK26h-RxvYUhMC5m0Q1_0buUu6V4QcnZVLnbjEE/edit?usp=sharing">
    <img src="{{ '/assets/img/license.PNG' | relative_url }}">
  </a>

> ## Excercise : Creative commons license chooser
> 
> 1. Check the [Creative commons license chooser](https://chooser-beta.creativecommons.org/)
> 2. Learn how to find an appropriate license for your biodiversity data
> 3. Is this license alowed for GBIF?
> 4. Is CC-BY-NC an open data license?
>    
> > ## SOLUTION
> > 1. <img src="{{ 'assets/img/extra/creativecommons.PNG' | relative_url }}" alt="cc" width="400">{: .image-with-shadow }
> > 2. Check the license chooser
> > 3. The only licenses allowed for GBIF are CC0 ; CC_BY ; and CC_BY_NC
> > 4. CC-BY-NC is not considered as an open data license 
> > 
> {: .solution}
{: .challenge}
