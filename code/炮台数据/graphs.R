# Load libraries
library(ggplot2)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(readr)
library(tidyverse)
library(maps)

# Get province-level map data for China
china_provinces <- ne_states(country = "China", returnclass = "sf")

china_map <- map_data("world") %>%
  filter(region == "China")

# Load and process your data
df <- read_csv("data/炮台数据/df_merge_nodup_coord.csv") %>%
  filter(coordinate_level %in% c('兴趣点', '住宅区', '村庄', '乡镇')) %>%
  separate(coordinate, into = c("lon", "lat"), sep = ",", convert = TRUE) %>% 
  distinct(operation_year, operation_month, operation_day, lon, lat, .keep_all = TRUE)

# Calculate point density and categorize
df <- df %>%
  group_by(lon, lat) %>%
  summarize(count = n(), .groups = "drop") %>%  # Count appearances of each point
  mutate(
    category = case_when(
      count == 1 ~ "1",
      count > 1 & count <= 10 ~ "1-10",
      count > 10 ~ "10+"
    )
  )

# Create the map
p <- ggplot() +
  geom_polygon(data = china_map, aes(x = long, y = lat, group = group), 
               fill = NA, color = "black", size = 0.4, alpha=1) +
  geom_sf(data = china_provinces, fill = "#E2E2E2", color = "darkgrey", alpha=0.3) +
  # Add points with color based on category
  geom_point(data = df, aes(x = lon, y = lat, color = category), size = 0.2) + 
  # Define custom color scale
  scale_color_manual(values = c("1" = "#9CBBCF", "1-10" = "#21538B", "10+" = "#26456E"),
                     name = "Point Density") +
  # Style and labels
  theme_minimal() +
  labs(x = "Longitude", y = "Latitude")+
  theme(axis.text=element_text(size=10), 
        legend.key.size = unit(0.5, 'cm'),
        plot.background = element_rect(colour = "#FBFBFB"),
        legend.key = element_rect(fill = "#E2E2E2", color = NA)) +
  guides(color = guide_legend(override.aes = list(size = 2)))

# Print the plot
print(p)