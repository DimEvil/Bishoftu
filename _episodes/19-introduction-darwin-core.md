---
title: "Data cleaning and exploration using R"
start: true
teaching: 60
exercises: 30
questions:
- "Exploring Data in R?"
- "What is Darwin Core?"
objectives:
- "Understand the purpose of Darwin Core."
- "How to explore your data in R"
keypoints:
- "Exploring data in R is never boring"

---

# Data cleaning and exploration using R
By Dimitri Brosens

Data cleaning in R, getting downloaded data ready for analysis

## Presentation: Why Clean Biodiversity Data?

**1. The "Garbage In, Garbage Out" Principle**
The Problem: GBIF is an aggregator, not a primary source. It hosts data from museum records, citizen science apps, and literature.

The Risk: If you feed "dirty" data (wrong coordinates, misspelled names) into an ecological model, your results will be misleading or scientifically invalid.

**2. Common Data "Nightmares"**
Taxonomic Noise: Synonyms, misspellings, and "fuzzy" matches.

Spatial Artifacts:

Centroids: Points mapped to the exact geometric center of a country or province because specific locality was missing.

Zero-Zero: GPS errors placing land animals in the middle of the Atlantic Ocean (0°, 0°).

Institutional Locations: Observations mapped to the headquarters of the museum rather than the field site.

Temporal Decays: Observations from the 1800s being used to predict 2024 habitat suitability.

**3. Biological Relevance**
Basis of Record: Should a fossil specimen (extinct) or a zoo animal (managed) be used to model a wild species' niche? Usually, the answer is no.

Establishment Means: Distinguishing between a native population and an invasive/introduced one in Ethiopia.

## Presentation GBIF Data Exploration & downloading in R

## Exercise 1: The "Data Integrity" Check
Before looking at the animals or plants, you need to see how "messy" the dataset is. This is the "Summary" view.

```
**The Goal:** Identify missing values and coordinate validity.

**Task A:** Use the skimr package or summary() to identify which columns have the most NA values.

**Task B:** GBIF data often has "0,0" coordinates (the "Null Island" effect). Filter your data to find rows where decimalLatitude or decimalLongitude are exactly 0.

**Task C:** Create a frequency table of the basisOfRecord column (e.g., Human Observation vs. Preserved Specimen).
```

Pro Tip: Use library(naniar) to visualize where your data is missing. It’s much more intuitive than a raw table.



#### --- 1. LOAD LIBRARIES ---
```r
library(tidyverse)  # For data manipulation and plotting
library(skimr)      # For the "Exploratory" style summary
library(maps)       # For map backgrounds
library(viridis)    # For color-blind friendly palettes
```

#### --- 2. GENERATE MOCK GBIF DATA (Skip this if you have your own data) ---
name your previously downloaded dataset gbif_data if you have your own dataset already downloaded
```r
set.seed(123)
gbif_data <- tibble(
  species = sample(c("Panthera leo", "Quercus robur", "Danaus plexippus"), 500, replace = TRUE),
  phylum = sample(c("Chordata", "Tracheophyta", "Arthropoda"), 500, replace = TRUE),
  decimalLatitude = runif(500, -40, 60),
  decimalLongitude = runif(500, -120, 140),
  eventDate = seq(as.Date('2010/01/01'), as.Date('2023/01/01'), length.out = 500),
  basisOfRecord = sample(c("HUMAN_OBSERVATION", "PRESERVED_SPECIMEN"), 500, replace = TRUE),
  countryCode = sample(c("US", "ZA", "DE", "BR"), 500, replace = TRUE)
)
```
OR

```r
gbif_data <- yourDAtaSet
```

#### --- 3. EXPLORATORY SUMMARY ---
This mimics the "Summary" tab in the Exploratory tool
```r
gbif_data %>% skim()
```
#### --- 4. DATA CLEANING & INTEGRITY CHECK ---
Checking for missing coordinates or the "Null Island" (0,0) effect
```r
clean_data <- gbif_data %>%
  filter(!is.na(decimalLatitude) & !is.na(decimalLongitude)) %>%
  filter(decimalLatitude != 0 | decimalLongitude != 0) %>%
  mutate(year = as.numeric(format(eventDate, "%Y")))

print(paste("Original rows:", nrow(gbif_data)))
print(paste("Cleaned rows:", nrow(clean_data)))
```
#### --- 5. VISUALIZING TEMPORAL TRENDS ---
Count observations per year and phylum
```r
temporal_plot <- clean_data %>%
  count(year, phylum) %>%
  ggplot(aes(x = year, y = n, color = phylum)) +
  geom_line(size = 1) +
  geom_point() +
  theme_minimal() +
  labs(title = "GBIF Observations Over Time",
       subtitle = "Grouped by Phylum",
       x = "Year of Observation",
       y = "Number of Records")

print(temporal_plot)
```

#### --- 6. SPATIAL EXPLORATION (HEXBIN MAP) ---
This prevents points from overlapping so you can see density
```r
world_map <- map_data("world")
```

```r
spatial_plot <- ggplot() +
  # Background world map
  geom_polygon(data = world_map, aes(x = long, y = lat, group = group), 
               fill = "grey95", color = "grey80") +
  # Hexagonal bins for density
  geom_hex(data = clean_data, aes(x = decimalLongitude, y = decimalLatitude), bins = 30) +
  scale_fill_viridis_c(option = "plasma") +
  theme_void() +
  labs(title = "Geographic Density of Observations",
       fill = "Record Count") +
  coord_fixed(1.3) # Keeps the map from looking "stretched"

print(spatial_plot)
```

#### --- 7. THE PIVOT TABLE (ANALYSIS) ---
See which recording methods are used across different phyla
```r
recording_pivot <- clean_data %>%
  group_by(phylum, basisOfRecord) %>%
  summarise(count = n(), .groups = "drop") %>%
  pivot_wider(names_from = basisOfRecord, values_from = count, values_fill = 0)

print(recording_pivot)
```
Quick Tips for your Document:
**The Pipe (%>%):** Remember that this "passes" the data from one function to the next. It’s exactly like the steps listed in the right-hand sidebar of the Exploratory UI.

**geom_hex():** If you get an error saying hexbin package required, just run install.packages("hexbin") in your console.

**coord_fixed(1.3):** This is a small trick for world maps to ensure the Earth doesn't look too "flat" or "tall" in your RStudio plot pane.

#### --- 1. FILTER FOR AFRICA ---
We define the bounding box for the African continent
```r
africa_data <- clean_data %>%
  filter(decimalLongitude >= -20 & decimalLongitude <= 55,
         decimalLatitude >= -35 & decimalLatitude <= 40)
```
#### --- 2. SUMMARY OF AFRICAN RECORDS ---
See which countries in Africa have the most records in your dataset
```r
africa_summary <- africa_data %>%
  group_by(countryCode) %>%
  summarise(total_records = n()) %>%
  arrange(desc(total_records))

print(africa_summary)
```

#### --- 3. SPATIAL PLOT: AFRICA ONLY ---
We use the same 'world_map' data but zoom the plot
```r
africa_map_plot <- ggplot() +
  # Background map (filtered for Africa-related regions for performance)
  geom_polygon(data = world_map, aes(x = long, y = lat, group = group), 
               fill = "grey95", color = "grey80") +
  # Hexbins for observation density
  geom_hex(data = africa_data, aes(x = decimalLongitude, y = decimalLatitude), bins = 25) +
  scale_fill_viridis_c(option = "mako", direction = -1) +
  # Zooming the view to Africa's coordinates
  coord_fixed(xlim = c(-20, 55), ylim = c(-35, 40), ratio = 1.3) +
  theme_minimal() +
  labs(title = "Biodiversity Hotspots in Africa",
       subtitle = "Based on GBIF Occurrence Density",
       fill = "Record Count",
       x = "Longitude", y = "Latitude")

print(africa_map_plot)
```

#### Install if you haven't already: install.packages("naniar")
```r
library(naniar)
```
#### 1. Visualize the overall "missingness" 
This shows you which columns are the 'emptiest'
```r
gg_miss_var(africa_data) + 
  labs(title = "Missing Values per Column (Africa GBIF)")
```
#### 2. Look for intersections (The "Upset" Plot)
Do records that miss 'eventDate' also miss 'scientificName'?
(Note: Requires 'UpSetR' package usually)
```r
gg_miss_upset(africa_data, nsets = 5)
```
#### 3. Visualizing missingness in a scatterplot
This is brilliant: it plots points with missing values on the margins so you can see if missing data is clustered in specific areas.
```r
ggplot(africa_data, 
       aes(x = decimalLongitude, y = decimalLatitude)) + 
  geom_miss_point() + 
  coord_fixed(1.3) +
  theme_minimal() +
  labs(title = "Map of Valid vs. Missing Coordinates")
```

| Function | What it does | "Exploratory" Equivalent |
| :--- | :--- | :--- |
| `gg_miss_var()` | Creates a bar chart of $NA$ counts per column. | The red/grey bar at the top of Exploratory columns. |
| `gg_miss_upset()` | Shows how missing values "overlap" between columns. | Advanced data profiling (UpSet plot). |
| `geom_miss_point()` | A ggplot "layer" that plots $NA$ values at 10% below the minimum value so you can still see them. | N/A (Unique to R). |
| `miss_scan_count()` | Searches for "hidden" missing values like "Unknown", "N/A", or "-999". | Data Cleaning / "Replace values". |


## Exercise 2: Temporal Trends (Time Series)
Exploring data is great for quickly seeing if data is "old" or "new." Let’s do that in R.

**The Goal:** Visualize when these observations were recorded.

**Task A:** Convert your eventDate or year column into a proper Date format.

**Task B:** Create a histogram of observations per year. Use ggplot2:

Bonus: Map the fill aesthetic to phylum or class to see if certain groups were recorded more in specific decades.

**Task C:** Filter for the last 20 years and calculate the growth rate of observations year-over-year.

#### --- TASK A: CONVERT TO DATE FORMAT ---
We use lubridate (part of tidyverse) to handle dates easily

```r
library(tidyverse)
library(lubridate)
```
Ensure eventDate is a Date and extract the Year

```r
temporal_data <- africa_data %>%
  mutate(eventDate = as.Date(eventDate),
         year = year(eventDate)) %>%
  filter(!is.na(year)) # Remove records with no date info
```

#### --- TASK B: HISTOGRAM OF OBSERVATIONS ---
In Exploratory, this is a 'Chart' with 'Year' on the X-axis

```r
ggplot(temporal_data, aes(x = year, fill = phylum)) +
  geom_histogram(binwidth = 1, color = "white") +
  scale_fill_brewer(palette = "Set3") +
  theme_minimal() +
  labs(title = "Temporal Distribution of African GBIF Records",
       subtitle = "Observations by Year and Taxonomic Phylum",
       x = "Year",
       y = "Number of Records",
       fill = "Phylum")
```
#### --- TASK C: GROWTH RATE (LAST 20 YEARS) ---
1. Filter for the last 20 years
```r
growth_analysis <- temporal_data %>%
  filter(year >= (year(Sys.Date()) - 20)) %>%
  count(year) %>%
  # 2. Calculate the year-over-year change
  mutate(diff_records = n - lag(n),
         growth_rate = (diff_records / lag(n)) * 100)
```
#### View the growth table

```r
print(growth_analysis)
```
#### Plotting the Growth Rate

```r
ggplot(growth_analysis, aes(x = year, y = growth_rate)) +
  geom_line(color = "steelblue", size = 1) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  theme_minimal() +
  labs(title = "Year-over-Year Growth Rate (%)",
       subtitle = "African Observations (Last 20 Years)",
       y = "Percentage Change",
       x = "Year")
```




## 1. Setup and Authentication
Before diving into the data, you need the right tools. While many GBIF functions work without an account, downloading data requires your GBIF credentials.

Key Package: install.packages("rgbif")

Best Practice: Use .Renviron to store your GBIF_USER, GBIF_PWD, and GBIF_EMAIL so you don't hardcode them into your script.


## 2. Data Exploration (The "Discovery" Phase)
Before downloading millions of rows, you want to "shop around." GBIF uses a backbone taxonomy, so you need to match your species name to their specific usageKey.

Finding the Taxon Key
```r
library(rgbif)
```
```r
# Find the unique ID for Monarch Butterflies
species_info <- name_backbone(name = "Danaus plexippus")
taxon_key <- species_info$usageKey
```
Quick Metadata Check
You can check how many records exist before committing to a download:

```r
occ_count(taxonKey = taxon_key) — Gives you the total record count.
```

```r
occ_search(taxonKey = taxon_key, limit = 10) — Returns a small preview of the data.
```

3. Requesting a Download
For scientific reproducibility, you should use occ_download(). This triggers a request to GBIF’s servers, which prepare a .zip file for you.

The Download Trigger

```r
download_request <- occ_download(
  pred("taxonKey", taxon_key),
  pred("hasCoordinate", TRUE),
  pred("occurrenceStatus", "PRESENT"),
  pred_in("basisOfRecord", c("OBSERVATION", "HUMAN_OBSERVATION")),
  format = "SIMPLE_CSV"
)

```
**Note: The pred() functions act as filters (e.g., only records with coordinates).**

4. Monitoring and Importing
Since large downloads take time, your script needs to wait for the server to finish "cooking" the data.

Check Status: 

```r
occ_download_wait(download_request)
```

Download to Disk: 

```r
occ_download_get(download_request)
```

Load into R: 

```r
my_data <- occ_download_import()
```

5. Data Cleaning (The "Don't Skip" Step)
GBIF data is massive but often "noisy." Common issues include:

Coordinates at (0,0): Often used as a placeholder for missing data.

Country Centroids: Coordinates that point to the exact center of a country rather than an observation.

Duplicate Records: Multiple entries for the same event.

Pro-tip: The CoordinateCleaner package. It’s the industry standard for automated cleaning of GBIF records.

| Function | Purpose |
| :--- | :--- |
| `name_backbone()` | Matches your species name to the GBIF ID. |
| `occ_count()` | Checks how many records are available. |
| `occ_download()` | Starts the server-side data preparation. |
| `occ_download_get()` | Downloads the prepared file to your computer. |
| `occ_download_import()` | Reads the .csv or .parquet into your R environment. |

In these examples, we will use the CoordinateCleaner and bdc packages to turn "raw" records into "research-ready" data.


### Exercise 1: The "Visual Audit"
Goal: Detect obvious errors before running any automated tools.
Task: Map the raw occurrences and look for "out-of-place" points.


# Load libraries
```r
library(rgbif)
library(ggplot2)
library(dplyr)
```

# Download raw data for the Ethiopian Wolf

```r
raw_data <- occ_search(scientificName = "Canis simensis", limit = 1000)$data
```


# Simple Map

```r
ggplot(raw_data, aes(x = decimalLongitude, y = decimalLatitude)) +
  borders("world", regions = "Ethiopia") +
  geom_point(color = "red") +
  theme_minimal() +
  labs(title = "Raw Observations: Canis simensis")
```
*Challenge: Zoom out. Are there any wolves in the middle of the ocean or in Europe? Why might they be there?*

###Exercise 2: Automated Scrubbing
Goal: Use CoordinateCleaner to flag multiple issues at once.
Task: Run the standard suite of tests.

```r
library(CoordinateCleaner)
```

# Clean the data
```r
flags <- clean_coordinates(
  x = raw_data,
  lon = "decimalLongitude", 
  lat = "decimalLatitude",
  countries = "countryCode",
  tests = c("capitals", "centroids", "equal", "zeros", "institutions")
)
```

# See the summary of what was caught
```r
summary(flags)
```

*Challenge: How many records were flagged as "Centroids"? These are often hidden errors that look fine on a map until you zoom in.*


### Exercise 3: The "Biological Filter"
Goal: Ensure the data is relevant to modern wild populations.
Task: Remove fossils and introduced species.



# Filter by basis of record and establishment means
```r
clean_research_data <- raw_data %>%
  filter(!basisOfRecord %in% c("FOSSIL_SPECIMEN", "LIVING_SPECIMEN")) %>%
  filter(!establishmentMeans %in% c("INTRODUCED", "MANAGED", "INVASIVE")) %>%
  filter(year >= 1970) # Keeping only 'recent' history

print(paste("Records remaining:", nrow(clean_research_data)))
```

### Exercise 4: Taxonomic Harmonization
Goal: Group synonyms so you don't miss half your data.
Task: Compare the scientificName (what the observer wrote) with species (GBIF’s interpreted name).

# Check for multiple names for the same species

```r
unique_names <- raw_data %>% 
  group_by(scientificName, species) %>% 
  tally()
```

```r
print(unique_names)
```

*Challenge: Did GBIF correctly group misspelled names under the same speciesKey?*

### Summary Table: Your Cleaning Checklist

| Step | R Function / Filter | Purpose |
| :--- | :--- | :--- |
| **Coordinate Check** | `clean_coordinates()` | Flags points at 0,0, capitals, or museums. |
| **Modern Only** | `filter(year > 1970)` | Removes historical records that may no longer be valid. |
| **Wild Only** | `filter(basisOfRecord == "HUMAN_OBSERVATION")` | Excludes fossils and zoo animals. |
| **De-duplication** | `distinct(lon, lat, species, .keep_all = TRUE)` | Removes multiple records at the exact same spot. |














### Presentation Darwin Core (Optional)


<a href="https://docs.google.com/presentation/d/12BeC_M63xG6PCl4bVmOW0YE8etWt2lTfGXBjjG5JeJQ/edit?usp=sharing">
    <img src="{{ '/assets/img/standards.PNG' | relative_url }}">
  </a>



# Darwin Core - A global community of data sharing and integration
Darwin Core is a data standard to mobilize and share biodiversity data. Over the years, the Darwin Core standard has expanded to enable exchange and sharing of diverse types of biological observations from citizen scientists, ecological monitoring, eDNA, animal telemetry, taxonomic treatments, and many others. Darwin Core is applicable to any observation of an organism (scientific name, OTU, or other methods of defining a species) at a particular place and time. In Darwin Core this is an `occurrence`. To learn more about the foundations of Darwin Core read [Wieczorek et al. 2012](https://doi.org/10.1371/journal.pone.0029715).

### Demonstrated Use of Darwin Core
The power of Darwin Core is most evident in the data aggregators that harvest data using that standard. The one we will refer to most frequently in this workshop is [Global Biodiversity Information Facility](https://www.gbif.org/) (learn more about [GBIF](https://vimeo.com/434831655)). Another prominent one is the [Ocean Biodiversity Information System](https://obis.org/) (learn more about [OBIS](https://youtu.be/E6NblAC-1uE))  . It's also used by the Atlas of Living Australia, iDigBio, among others. 

### Darwin Core Archives
Darwin Core Archives are what OBIS and GBIF harvest into their systems. Fortunately the software created and maintained by GBIF, the [Integrated Publishing Toolkit](https://www.gbif.org/ipt), produces Darwin Core Archives for us. Darwin Core Archives are pretty simple. It's a zipped folder containing the data (one or several files depending on how many extensions you use), an Ecological Metadata Language (EML) XML file, and a meta.xml file that describes what's in the zipped folder.

> ## Exercise
> 
> Challenge: Download this [Darwin Core Archive](https://ipt-obis.gbif.us/archive.do?r=tpwd_harc_texasaransasbay_bagseine&v=2.3) and examine what's in it. Did you find anything unusual or that you don't understand what it is?
> 
> > ## Solution
> > ```Folder
> >  dwca-tpwd_harc_texasaransasbay_bagseine-v2.3
> >  |-- eml.xml
> >  |-- event.txt
> >  |-- extendedmeasurementorfact.txt
> >  |-- meta.xml
> >  |-- occurrence.txt
> > ```
> {: .solution}
{: .challenge}

### Darwin Core Mapping
Now that we understand a bit more about why Darwin Core was created and how it is used today we can begin the work of mapping data to the standard. The key resource when mapping data to Darwin Core is the [Darwin Core Quick Reference Guide](https://dwc.tdwg.org/terms/). This document provides an easy-to-read reference of the currently recommended terms for the Darwin Core standard. There are a lot of terms there and you won't use them all for every dataset (or even use them all on any dataset) but as you apply the standard to more datasets you'll become more familiar with the terms.

> ## Tip 
> If your raw column headers are Darwin Core terms verbatim then you can skip this step! Next time you plan data collection use the standard DwC term headers!
{: .callout}

> ## Exercise
> 
> **Challenge:** Find the matching Darwin Core term for these column headers.
> 
> 1. SAMPLE_DATE (example data: 09-MAR-21 05.45.00.000000000 PM)
> 2. lat (example data: 32.6560)
> 3. depth_m (example data: 6 meters)
> 4. COMMON_NAME (example data: staghorn coral)
> 5. percent_cover (example data: 15)
> 6. COUNT (example data: 2 Females)
> 
> > ## Solution
> > 1. [`eventDate`](https://dwc.tdwg.org/terms/#dwc:eventDate)
> > 2. [`decimalLatitude`](https://dwc.tdwg.org/terms/#dwc:decimalLatitude)
> > 3. [`minimumDepthInMeters`](https://dwc.tdwg.org/terms/#dwc:minimumDepthInMeters) and [`maximumDepthInMeters`](https://dwc.tdwg.org/terms/#dwc:maximumDepthInMeters)
> > 4. [`vernacularName`](https://dwc.tdwg.org/terms/#dwc:vernacularName)
> > 5. [`organismQuantity`](https://dwc.tdwg.org/terms/#dwc:organismQuantity) and [`organismQuantityType`](https://dwc.tdwg.org/terms/#dwc:organismQuantityType)
> > 6. This one is tricky- it's two terms combined and will need to be split. [`indvidualCount`](https://dwc.tdwg.org/terms/#dwc:individualCount) and [`sex`](https://dwc.tdwg.org/terms/#dwc:sex)
> >
> > {: .output}
> {: .solution}
{: .challenge}

> ## Tip 
> To make the mapping step easier on yourself, we recommend starting a mapping document/spreadsheet (or document it as a comment in your script). List out all of your column headers in one column and document the appropriate Dawin Core term(s) in a second column. For example:
> 
> | my term | DwC term |
> |---------|----------|
> | lat | decimalLatitude |
> | date | eventDate |
> | species | scientificName |
{: .callout}


### What are the **required** Darwin Core terms for publishing to GBIF?
When doing your mapping some required information may be missing. Below are the Darwin Core terms that are required to share your data to OBIS plus a few that are needed for GBIF.

| Darwin Core Term | Definition | Comment | Example |
|------------------|------------------------------------|---------------------------------------|-----------------|
| [`occurrenceID`](https://dwc.tdwg.org/terms/#dwc:occurrenceID) | An identifier for the Occurrence (as opposed to a particular digital record of the occurrence). In the absence of a persistent global unique identifier, construct one from a combination of identifiers in the record that will most closely make the occurrenceID globally unique. | To construct a globally unique identifier for each occurrence you can usually concatenate station + date + scientific name (or something similar) but you'll need to check this is unique for each row in your data. It is preferred to use the fields that are least likely to change in the future for this. For ways to check the uniqueness of your occurrenceIDs see the [QA / QC]({{ page.root }}/06-qa-qc/index.html) section of the workshop. | Station_95_Date_09JAN1997:14:35:00.000_Atractosteus_spatula |
| [`basisOfRecord`](https://dwc.tdwg.org/terms/#dwc:basisOfRecord) | The specific nature of the data record.  | Pick from these controlled vocabulary terms: [HumanObservation](http://rs.tdwg.org/dwc/terms/HumanObservation), [MachineObservation](http://rs.tdwg.org/dwc/terms/MachineObservation), [MaterialSample](http://rs.tdwg.org/dwc/terms/MaterialSample), [PreservedSpecimen](http://rs.tdwg.org/dwc/terms/PreservedSpecimen), [LivingSpecimen](http://rs.tdwg.org/dwc/terms/LivingSpecimen), [FossilSpecimen](http://rs.tdwg.org/dwc/terms/FossilSpecimen) | HumanObservation |
| [`scientificName`](https://dwc.tdwg.org/terms/#dwc:scientificName) | The full scientific name, with authorship and date information if known. When forming part of an Identification, this should be the name in lowest level taxonomic rank that can be determined. This term should not contain identification qualifications, which should instead be supplied in the `identificationQualifier` term. | Note that cf., aff., etc. need to be parsed out to the `identificationQualifier` term. For a more thorough review of `identificationQualifier` see [this paper](https://doi.org/10.3389/fmars.2021.620702). | Atractosteus spatula |
| [`eventDate`](https://dwc.tdwg.org/terms/#dwc:eventDate) | The date-time or interval during which an Event occurred. For occurrences, this is the date-time when the event was recorded. Not suitable for a time in a geological context. | Must follow [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601). See more information on dates in the [Data Cleaning]({{ page.root }}/03-data-cleaning/index.html) section of the workshop. | 2009-02-20T08:40Z |
| [`decimalLatitude`](https://dwc.tdwg.org/terms/#dwc:decimalLatitude) | The geographic latitude (in decimal degrees, using the spatial reference system given in geodeticDatum) of the geographic center of a Location. Positive values are north of the Equator, negative values are south of it. Legal values lie between -90 and 90, inclusive. | For OBIS and GBIF the required `geodeticDatum` is WGS84. Uncertainty around the geographic center of a Location (e.g. when sampling event was a transect) can be recorded in `coordinateUncertaintyInMeters`. See more information on coordinates in the [Data Cleaning]({{ page.root }}/03-data-cleaning/index.html) section of the workshop. | -41.0983423 |
| [`decimalLongitude`](https://dwc.tdwg.org/terms/#dwc:decimalLongitude) | The geographic longitude (in decimal degrees, using the spatial reference system given in geodeticDatum) of the geographic center of a Location. Positive values are east of the Greenwich Meridian, negative values are west of it. Legal values lie between -180 and 180, inclusive | For OBIS and GBIF the required `geodeticDatum` is WGS84. See more information on coordinates in the [Data Cleaning]({{ page.root }}/03-data-cleaning/index.html) section of the workshop. | -121.1761111 |
| [`countryCode`](https://dwc.tdwg.org/terms/#dwc:countryCode) | The standard code for the country in which the location occurs. | Use an [ISO 3166-1-alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code. Not required for OBIS but GBIF prefers to have this for their system. For international waters, leave blank. | US, MX, CA |
| [`kingdom`](https://dwc.tdwg.org/terms/#dwc:kingdom) | The full scientific name of the kingdom in which the taxon is classified.| Not required for OBIS but GBIF needs this to disambiguate scientific names that are the same but in different kingdoms. | Animalia |
| [`geodeticDatum`](https://dwc.tdwg.org/terms/#dwciri:geodeticDatum) | The ellipsoid, geodetic datum, or spatial reference system (SRS) upon which the geographic coordinates given in decimalLatitude and decimalLongitude as based. | Must be [WGS84](https://epsg.io/4326) for data shared to OBIS and GBIF but it's best to state explicitly that it is. | WGS84 |

### What other terms should be considered?
While these terms are not required for publishing data to GBIF, they are extremely helpful for downstream users because without them the data are less useful for future analyses. For instance, `depth` is a crucial piece of information for marine observations, but it is not always included. For the most part the ones listed below are not going to be sitting there in the data, so you'll have to determine what the values should be and add them in. Really try your hardest to include them if you can.

| Darwin Core Term | Definition | Comment | Example |
|------------------|------------------------------------|---------------------------------------|--| 
| [`coordinateUncertaintyInMeters`](https://dwc.tdwg.org/terms/#dwc:coordinateUncertaintyInMeters) | 	The horizontal distance (in meters) from the given decimalLatitude and decimalLongitude describing the smallest circle containing the whole of the Location. Leave the value empty if the uncertainty is unknown, cannot be estimated, or is not applicable (because there are no coordinates). Zero is not a valid value for this term | There's always uncertainty associated with locations. Recording the uncertainty is crucial for downstream analyses. | 15 |
| [`occurrenceStatus`](https://dwc.tdwg.org/terms/#dwc:occurrenceStatus) | A statement about the presence or absence of a Taxon at a Location. | For GBIF & OBIS, only valid values are `present` and `absent`. | present |
| [`samplingProtocol`](https://dwc.tdwg.org/terms/#dwc:samplingProtocol) | The names of, references to, or descriptions of the methods or protocols used during an Event. |  | Bag Seine |
| [`taxonRank`](https://dwc.tdwg.org/terms/#dwc:taxonRank) | The taxonomic rank of the most specific name in the scientificName. | Also helps with disambiguation of scientific names. | Species |
| [`organismQuantity`](https://dwc.tdwg.org/terms/#dwc:organismQuantity) | A number or enumeration value for the quantity of organisms. | OBIS and GBIF also likes to see this in the Extended Measurement or Fact extension. | 2.6 |
| [`organismQuantityType`](https://dwc.tdwg.org/terms/#dwc:organismQuantityType) | The type of quantification system used for the quantity of organisms. |  | Relative Abundance |
| [`datasetName`](https://dwc.tdwg.org/terms/#dwc:datasetName) | The name identifying the data set from which the record was derived. |  | TPWD HARC Texas Coastal Fisheries Aransas Bag Bay Seine |
| [`dataGeneralizations`](https://dwc.tdwg.org/terms/#dwc:dataGeneralizations) | Actions taken to make the shared data less specific or complete than in its original form. Suggests that alternative data of higher quality may be available on request. | This veers somewhat into the realm of metadata and will not be applicable to all datasets but if the data were modified such as due to sensitive species then it's important to note that for future users. | Coordinates generalized from original GPS coordinates to the nearest half degree grid cell |
| [`informationWithheld`](https://dwc.tdwg.org/terms/#dwc:informationWithheld) | 	Additional information that exists, but that has not been shared in the given record. | Also useful if the data have been modified this way for sensitive species or for other reasons. | location information not given for endangered species |
| [`institutionCode`](https://dwc.tdwg.org/terms/#dwc:institutionCode) | 	The name (or acronym) in use by the institution having custody of the object(s) or information referred to in the record. |  | TPWD |

Other than these specific terms, work through the data that you have and try to crosswalk it to the Darwin Core terms that match best. 

> ## Exercise
> 
> Challenge: Create some crosswalk notes for your dataset.
> 
> Compare your data files to the table(s) above to devise a plan to crosswalk your data columns into the DwC terms. 
> 
{: .challenge}

{% include links.md %}

