# install.packages("rvest")

library(rvest)
library(stringr)

# Store web url
lego_movie <- read_html("http://www.imdb.com/title/tt1490017/")

# html_text() extracts the text within a node

# Scrape the website for the movie rating
rating <- lego_movie %>%
    html_nodes("strong span") %>%
    html_text() %>%
    as.numeric()
rating

# Scrape the website for the cast
cast <- lego_movie %>%
    html_nodes("#titleCast td:nth-child(2) a") %>%
    html_text()
cast
cast <- cast %>% str_trim() # trim white-space
cast

# Extract the first review
review <- lego_movie %>%
    html_nodes("#titleUserReviewsTeaser p") %>%
    html_text()
review

# html_attr() extracts the value of one of the attributes
# of an html node

# Scrape the website for the url of the movie poster
poster <- lego_movie %>%
  html_nodes("#title-overview-widget img") %>%
  html_attr("src")
poster

# Automated Browser example
s <- html_session("http://www.imdb.com/title/tt1490017/")


# What I want to do is have the browser follow the link for each actor
# in the Lego Movie. For each actor, we will download the html,
# then we extract the top 10 movies in the filmography (nodes 'b a')
# then we extract the year of each film
# Test for Will Arnett
will_page <- s %>% follow_link("Will Arnett") %>% read_html()
will_page %>%
  html_nodes("b a") %>%
  html_text() %>%
  head(10)
will_page %>% 
  html_nodes("#filmography .year_column") %>%
  html_text() %>%
  head(10) %>%
  str_extract("[0-9]{4}")

# create the empty list for data storage
cast_movies <- list()

# run the loop that will go through the first few actors listed
for(actor_name in cast[1:4]){
    # We use rvest
    actorpage <- s %>% follow_link(actor_name) %>% read_html()
    
    # get the first 10 movies in the actor's filmography
    movies <- actorpage %>%
      html_nodes("b a") %>%
      html_text() %>%
      head(10)
    
    # get the corresponding year values
    years <- actorpage %>%
      html_nodes("#filmography .year_column") %>%
      html_text() %>%
      head(10) %>%
      str_extract("[0-9]{4}")
    
    # insert the actor's name as a new column
    n <- length(years)
    name <- rep(actor_name, n)
    
    cast_movies[[actor_name]] <- data.frame(
      name = name, film = movies, year = years,
      stringsAsFactors = FALSE
    )
}

cast_movies

# Some quick code to combine the data frames into one.
# Not the most efficient, but it works
df <- cast_movies[[1]]  # use the first data.frame as a base
for(i in 2:4){
  df <- rbind(df, cast_movies[[i]]) # append remaining 
}

df
