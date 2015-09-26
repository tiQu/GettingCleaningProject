## 0. Downloads and unzips file within data directory
if (!file.exists("data")) {
  dir.create("data")
}

# 0.a installs plyr package if necessary
if("plyr" %in% rownames(installed.packages()) == F) {install.packages("plyr")}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/motion.zip", method = "curl")

unzip("./data/motion.zip",exdir="./data/")

dateDownloaded <- date()

## 1. Merges the training and the test sets to create one data set.

# 1.a reads train dataset
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
X_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
train_total <- cbind(subject_train,y_train,X_train)

# 1.b reads test dataset
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
X_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
test_total <- cbind(subject_test,y_test,X_test)

# 1.c merges the two
data_total <- rbind(test_total,train_total)
colnames(data_total) <- c("Activity_Subject","Activity_Labels",1:(ncol(data_total)-2))

## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 2.a reads in features.txt
features <- read.table("./data/UCI HAR Dataset/features.txt",stringsAsFactors = F)

# 2.b creates vectors to store the row numbers and the names of the measurements on the mean and sd
matches_names <- vector()
matches_rows <- vector()

for (i in 1:nrow(features)) {
    if (grepl("-mean\\(\\)",features[i,2]) | grepl("-std\\(\\)",features[i,2]))  {
    matches_names <- c(matches_names,features[i,2])
    matches_rows <- c(matches_rows, as.numeric(i))
  }
}

# 2.c creates new extracted data set and assign column names from the matches in features.txt
data_extr <- data_total[,c("Activity_Subject","Activity_Labels",as.character(matches_rows))]
colnames(data_extr) <- c("Activity_Subject","Activity_Labels",as.character(matches_names))

## 3. Uses descriptive activity names to name the activities in the data set
# 3.a reads activity_labels.txt
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
colnames(activity_labels) <- c("Activity_Labels","Activity_Names")

# 3.b adds the activity names to the end of the data set, 
# then reorders columns so that the first 2 are the activity names and subject IDs, dropping the unnecessary Activity_Labels
data_descr <- plyr::join(data_extr, activity_labels, by = "Activity_Labels")
data_descr <- data_descr[,c(ncol(data_descr),1,3:(ncol(data_descr)-1))]

## 4. Appropriately labels the data set with descriptive variable names. 
# 4.a simple reformatting to replace brackets and make capitalization more intuitive
cols_data_descr <- colnames(data_descr)
cols_data_descr <- gsub("\\(\\)","",cols_data_descr)
cols_data_descr <- gsub("mean","Mean",cols_data_descr)
cols_data_descr <- gsub("std","SD",cols_data_descr)

# 4.b replaces prefixes with their Time and Frequency
cols_data_descr <- gsub("^t", "Time", cols_data_descr)
cols_data_descr <- gsub("^f", "Freq", cols_data_descr)

colnames(data_descr) <- cols_data_descr

## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# 5.a creates a long shaped data set from the wide shaped data set created at 3.b
data_descr_molten <- melt(data_descr, id.vars = c("Activity_Names", "Activity_Subject"))

# 5.b transforms the long shaped data set back into a wide shaped one, aggregating on Activity Name and Subject, using mean to aggregate
data_descr_cast <- dcast(data_descr_molten, Activity_Names+Activity_Subject ~ variable, fun.aggregate=mean)

# 5.c writes data set
write.table(data_descr_cast,"tidy_data_descr_cast.txt", row.name=FALSE)

rm(list = ls())