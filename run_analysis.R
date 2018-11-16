### This script merges different tables into one tidy dataset

# download data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destfile <- paste0(getwd(),"/","data.zip")
#download zip file
download.file(url,destfile,method = "curl")
#unzip file
unzip("data.zip")

## read all the data tables
## and set some first meaningful variable names

# mapping of feature number and feature name
features <- read.table("UCI HAR Dataset/features.txt")
colnames(features) <- c("index","featurename")

# mapping of activity number and label
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
colnames(activities) <- c("index","activityname")
# make the name a bit nicer for later use
activities$activityname <- sub("_", "", tolower(activities$activityname))

# read test data
subjecttest <- read.table("UCI HAR Dataset/test/subject_test.txt")
colnames(subjecttest) <- "subject"
xtest <- read.table("UCI HAR Dataset/test/X_test.txt")
colnames(xtest) <- features$featurename
ytest <- read.table("UCI HAR Dataset/test/y_test.txt")
colnames(ytest) <- "activity"

# read train data
subjecttrain <- read.table("UCI HAR Dataset/train/subject_train.txt")
colnames(subjecttrain) <- "subject"
xtrain <- read.table("UCI HAR Dataset/train/X_train.txt")
colnames(xtrain) <- features$featurename
ytrain <- read.table("UCI HAR Dataset/train/y_train.txt")
colnames(ytrain) <- "activity"

## put parts together
test <- cbind(subjecttest, ytest)
test <- cbind(test, xtest)
train <- cbind(subjecttrain, ytrain)
train <- cbind(train, xtrain)

## merge training and test data into one dataframe (df)
df <- rbind(train, test)

## only select mean and std features, but not meanFreq
## as this is a weighted average 
# preserve subject and activity columns 1 and 2
df_means_stds <- df[,grep('mean\\(\\)|std',colnames(df))]
df_means_stds <- cbind(df[,1:2],df_means_stds) 

## use descriptive activity names
df_means_stds$activity <- as.factor(df_means_stds$activity)
levels(df_means_stds$activity) <- as.character(activities$activityname)

## use descriptive variable names
#remove brackets for readability
names(df_means_stds) <- gsub("\\(\\)","",names(df_means_stds)) 
# as t and f might be difficult to distinguish replace them with time and frequency
names(df_means_stds) <- gsub("tBody","timeBody",names(df_means_stds))
names(df_means_stds) <- gsub("tGravity","timeGravity",names(df_means_stds))
names(df_means_stds) <- gsub("fBody","freqBody",names(df_means_stds))
names(df_means_stds) <- gsub("fGravity","freqGravity",names(df_means_stds))
# the other things are fine because they are decribed properly in the readme

## save a tidy dataset with average of each variable for each activity and subject
tidydf <- aggregate(.~subject+activity,data = df_means_stds,mean)
write.table(tidydf, "tidydataframe.txt", row.names = FALSE)
