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



##Hands-on: Advanced Workflows with rgbif

This session is designed for researchers who need to scale their data collection. We will explore how to automate repetitive tasks and how to interact with GBIF's server-side download system, which is required for datasets larger than 100,000 records.

Session Exercises: Scaling Your Research

### 1. The "Batch Search" (Multi-Species Loop)
Goal: Automate the retrieval of data for a list of species.
Task: Create a vector of scientific names for three Ethiopian endemics. Use a loop or lapply to fetch coordinates for all of them at once.

# Define your target species

```r
target_species <- c("Canis simensis", "Theropithecus gelada", "Tragelaphus buxtoni")
```

# Map over the list to get data for each

```r
multi_species_data <- lapply(target_species, function(sp) {
  occ_data(scientificName = sp, limit = 100, hasCoordinate = TRUE)$data
})
```

# Combine into one large data frame

```r
all_obs <- bind_rows(multi_species_data)
```

# Result: One table containing data for all three species

```r
table(all_obs$species)
```

### 2. Spatial Filtering with WKT (Well-Known Text)
Goal: Filter records using a precise geographic shape rather than just a country code.
Task: Define a polygon for a specific region (like the Ethiopian Highlands) and use it as a filter in occ_data.


# Define a simple polygon around the northern highlands (WKT format)
# Note: WKT must close the loop by repeating the first coordinate at the end.

```r
highlands_wkt <- "POLYGON((36 10, 40 10, 40 14, 36 14, 36 10))"

highland_records <- occ_data(
  geometry = highlands_wkt,
  limit = 200,
  hasCoordinate = TRUE
)$data
```
# Plot to verify sightings are within your custom shape

```r
ggplot(highland_records, aes(x = decimalLongitude, y = decimalLatitude)) +
  borders("world", regions = "Ethiopia") +
  geom_point(aes(color = species)) +
  coord_quickmap(xlim = c(34, 42), ylim = c(8, 16))
```

### 3. Asynchronous Downloads for "Big Data"
Goal: Learn the official way to request massive datasets for publication.
Task: Use occ_download() to request data. Unlike occ_data, this sends a request to GBIF’s servers and gives you a status key to check later.

Note: This exercise requires your GBIF.org username and password.

# Request a large download (requires GBIF credentials)
 
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

# Check the status (it takes time to process)
```r
occ_download_wait(my_download)
```

# Download and load the resulting file

```r 
d <- occ_download_get(my_download) %>% occ_download_import()
```

### 4. Metadata & Citation Extraction
Goal: Ensure your work is citable and transparent.
Task: Extract the dataset metadata from your R object to see which original institutions provided the data.

# Get citation information for your search results

```r
citation_info <- gbif_citation(coffee_data)
```

# Print the DOIs and provider names

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

# This returns the individual citations for each dataset contributing to your result
```{r}
gbif_citation(advanced_search)
```



### Presentation

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
