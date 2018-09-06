# Author:Sifan Liu
# Date: Fri Aug 31 22:10:53 2018
# --------------
pkgs <- c('dplyr',"RJSONIO","jsonlite",'rvest')
check <- sapply(pkgs,require,warn.conflicts = TRUE,character.only = TRUE)
if(any(!check)){
  pkgs.missing <- pkgs[!check]
  install.packages(pkgs.missing)
  check <- sapply(pkgs.missing,require,warn.conflicts = TRUE,character.only = TRUE)
}

padz <- function(x, n=max(nchar(x))) gsub(" ", "0", formatC(x, width=n)) 

# START HERE =======================================================
# grab all of the downlinks from site
page <- read_html("https://webrobots.io/kickstarter-datasets/")

links <- page %>%
  html_nodes("a") %>%
  html_attr("href") 
js_path = grep(".\\.json\\.gz",links, value = TRUE)
jszip_path = grep(".\\.json\\.zip",links, value = TRUE)

# read gz json
jsdownload <- function(x){
  js <- stream_in(gzcon(url(x)))
  df = js$data %>% select(id,state, goal,pledged,backers_count,location, category,launched_at)
  
  df$location_id <- df$location$id
  df$location_name <- df$location$displayable_name
  df$location_state <- df$location$state
  df$location_country <- df$location$country
  df$category_name <- df$category$name
  df$category_broad <- df$category$slug

  df <- df %>% select(-location,-category) 
  df %>% filter(state != "live")
}

# loop over all links
unionfile = jsdownload(js_path[1])

for (file in js_path[2:28]){
  unionfile <- union(unionfile, jsdownload(file))
}



# zipped file from url
# tmp <- tempfile()
# download.file(jszip_path[2], tmp)
# 
# dat <- jsonlite::fromJSON(sprintf("[%s]", paste(readLines(unzip(tmp,"Kickstarter_2015-06-12.json")), collapse="")))

json_file <- RJSONIO::fromJSON("../../Downloads/Kickstarter_Kickstarter.json" )

temp <- sapply(json_file, function(x) {
  x[sapply(x, is.null)] <- NA
  unlist(x)
})

temp <- rbind_list(temp)
names(temp) <- gsub("projects.","",names(temp))  

temp <- temp %>% select(id,state, goal,pledged,backers_count,launched_at,
                       location.id,location.name, location.state,location.country,
                       category.name,category.slug) 


# unionfile <- union %>% select(-category, -success)
names(temp) <- names(unionfile)

temp <- temp %>%
  filter(state!="live") %>%
  mutate(id = as.integer(id),
         goal = as.numeric(goal),
         pledged = as.numeric(pledged),
         backers_count = as.integer(backers_count),
         launched_at = as.integer(launched_at),
         location_id = as.integer(location_id))

union <- dplyr::union(unionfile, temp)
union$category <- gsub("(\\/.+)","",union$category_broad)
union$success <- ifelse(union$state =="successful", 1,0)

# save the results  ======================================================
save(union, file = "union.Rda")