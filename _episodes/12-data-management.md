---
title: "Hands on: Working with rGBIF"
start: true
teaching: 
exercises: 90
questions:
- "What is a Biodiversity dataset?"
objectives:
- "Distinction between data quality and fitness for use"
- "Make sure your data are tidy data"
- "Learn some best practices"
keypoints:
- "rGBIF is the best"
- "Best data management practices"
- "Organize your Data and Metadata"
---

## Hands-on: Advanced Workflows with rgbif

This session is designed for researchers who need to scale their data collection. We will explore how to automate repetitive tasks and how to interact with GBIF's server-side download system, which is required for datasets larger than 100,000 records.

Session Exercises: Scaling Your Research

### 1. Installation & Setup


```r
library(rgbif)
library(dplyr)
library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
```

```{r}
library(httr)
set_config(config(http_version = 1.1))
```


### 1. The "Batch Search" (Multi-Species Loop)

Goal: Automate the retrieval of data for a list of species.
Task: Create a vector of scientific names for three Ethiopian endemics. Use a loop or lapply to fetch coordinates for all of them at once.
Change the species names to the one you have an interest in!

## Define your target species

```r
target_species <- c("Canis simensis", "Theropithecus gelada", "Tragelaphus buxtoni")
```

## Map over the list to get data for each

```r
multi_species_data <- lapply(target_species, function(sp) {
  occ_data(scientificName = sp, limit = 100, hasCoordinate = TRUE)$data
})
```

## Combine into one large data frame

```r
all_obs <- bind_rows(multi_species_data)
```

## Result: One table containing data for all three species

```r
table(all_obs$species)
```

### 2. Spatial Filtering with WKT (Well-Known Text)
Goal: Filter records using a precise geographic shape rather than just a country code.
Task: Define a polygon for a specific region (like the Ethiopian Highlands) and use it as a filter in occ_data.


Define a simple polygon around the northern highlands (WKT format)
Note: WKT must close the loop by repeating the first coordinate at the end.

You can draw WKT polygons here: [https://wktmap.com/](https://wktmap.com/)

<<<<<<< HEAD
### Spatial Filtering with WKT (Well-Known Text)

Define your polygon in WKT
You can draw WKT polygons here: https://wktmap.com/

### a. Define WKT and convert to spatial object

```{r}
wkt_text <- "POLYGON((35.599152 8.667918, 36.346321 7.449624, 37.313245 7.623887, 37.92856 8.494105, 37.005587 9.535749, 35.599152 8.667918))"
wkt_sf <- st_as_sfc(wkt_text, crs = 4326)
```

### b. Get data and convert to spatial points

```{r}
pts_sf <- occ_data(geometry = wkt_text, limit = 50)$data %>%
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)
```

### c. Plot (The WKT acts as the background/container)

```{r}
ggplot() +
  geom_sf(data = wkt_sf, fill = "lightblue", alpha = 0.3) +
  geom_sf(data = pts_sf, aes(color = species)) +
  theme_minimal()


### 3. Asynchronous Downloads for "Big Data"
Goal: Learn the official way to request massive datasets for publication.
Task: Use occ_download() to request data. Unlike occ_data, this sends a request to GBIF’s servers and gives you a status key to check later.

Note: This exercise requires your GBIF.org username and password.

### Request a large download (requires GBIF credentials)
 
```r 
 my_download <- occ_download(
   pred("taxonKey", 2433257),        # Key for Canis simensis
   pred("country", "ET"),
   format = "DWCA",
   user = "YOUR_USERNAME", 
   pwd = "YOUR_PASSWORD", 
   email = "YOUR_EMAIL"
 )
```

```{r}
 my_download <- occ_download(
   pred("taxonKey", 2433257),        # Key for Canis simensis
   pred("country", "ET")
    )
```

OR 

```{r}
my_download2 <- occ_download(
  pred("scientificName", "Canis simensis"),
  pred("hasCoordinate", TRUE)
)
```

### Check the status (it takes time to process)
```r
occ_download_wait(my_download)
```

### Download and load the resulting file

```r 
my_dataset <- occ_download_get(my_download) %>% occ_download_import()
```

### 4. Metadata & Citation Extraction
Goal: Ensure your work is citable and transparent.
Task: Extract the dataset metadata from your R object to see which original institutions provided the data.

#### Get citation information for your search results

```r
citation_info <- gbif_citation(coffee_data)
```

#### Print the DOIs and provider names

```r
print(citation_info)
```

### R Markdown Template: Advanced rgbif
Copy this code into a new R Markdown file to follow along with the advanced exercises.

---
title: "Advanced GBIF Workflows"
output: html_document
---

### Step 1: Batch Name Resolution
Before searching, we resolve names to keys to ensure 100% accuracy.

```{r}
species_list <- c("Canis simensis", "Loxodonta africana")
keys <- sapply(species_list, function(x) name_backbone(name=x)$usageKey)
```

### Step 2: Complex Filtering
We search using the keys, limited to Human Observations in Ethiopia.

```{r}
advanced_search <- occ_data(
  taxonKey = keys, 
  country = "ET", 
  basisOfRecord = "HUMAN_OBSERVATION",
  limit = 200
)
```

### Step 3: Global Data Citation
Every research project must cite the data correctly.

```{r}
# Combine the data parts of the two species into one table
all_data <- bind_rows(
  advanced_search[[1]]$data,
  advanced_search[[2]]$data
)
```

```{r}
dataset_summary <- all_data %>%
  group_by(datasetKey) %>%
  tally(sort = TRUE)

print(dataset_summary)
head(all_data)
```

#### Get a list of all unique datasets involved

```{r}
dataset_counts <- all_data %>%
  group_by(datasetKey) %>%
  tally()
```

#### Create a vector of keys and their record counts
```{r}
citation_keys <- setNames(dataset_counts$n, dataset_counts$datasetKey)
```

#### 1. Get unique keys
```{r}
unique_keys <- unique(all_data$datasetKey)
```

#### 2. Map through keys using the updated function: dataset_get()

```{r}
dataset_titles <- map_chr(unique_keys, function(x) {
  Sys.sleep(0.1) # Small pause to prevent API flickering
  res <- dataset_get(x)
  return(res$title)
})
```

#### 3. Create a clean reference table

```{r}
citation_table <- data.frame(
  datasetKey = unique_keys,
  Title = dataset_titles
)

print(citation_table)
```

<img src="{{ '/assets/img/session_over3.png' | relative_url }}">




### Presentation (optional)

<a href="https://docs.google.com/presentation/d/1xgCBYw0HCd2RHagOH4cL4xxK8fMSTyIPbqEQ8smULyo/edit?usp=sharing">
    <img src="{{ '/assets/img/data_management.PNG' | relative_url }}">
  </a>

> ## Exercise
> 
> **Challenge:** Make this data tidy.
> 1. Download this [SAMPLE_DATE](https://docs.google.com/spreadsheets/d/1SJ6Ng1Jol-zbDiLQlu-o2sqpbg73lViA/edit?usp=drive_link&ouid=106540432290122943029&rtpof=true&sd=true)
> 2. Open in spreadsheet programme (Excel, LibreOffice, Openoffice,....)
> 3. Make this data Tidy (Each variable forms a column and contains values, Each observation forms a row, Each type of observational unit forms a table)
>    [Open this link for the complete excercise and tips](https://docs.google.com/document/d/1SJAcA83LBozLP0y2LGuFTP2KJcvZzgkP/edit#heading=h.gjdgxs)
>    
> > ## Solution
> > 1. ![screenshot]({{ page.root }}/fig/tidy_data_solution.png){: .image-with-shadow }
> >
> > {: .output}
> {: .solution}
{: .challenge}
