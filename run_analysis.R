library(data.table)
library(dplyr)
library(plyr)
#read files
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

feat <- read.table("./UCI HAR Dataset/features.txt")

#merge rows
mydata <- rbind(X_train, X_test)
myactivities <- rbind(y_train, y_test)

#search mean and std features
featmean <- grep("mean", feat[, 2], ignore.case = TRUE)
featstd <- grep("std", feat[, 2], ignore.case = TRUE)

#select only mean and std columns
mydata_meanstd <- select(mydata, featmean, featstd)

#merge activities to mydata and read and name activities
mydata_meanstd <- cbind(mydata_meanstd, myactivities)
act_names <- read.table("./UCI HAR Dataset/activity_labels.txt")
mydata_meanstd[, 87] <- mapvalues(myactivities[, 1], act_names$V1, as.character(act_names$V2))
                        
#rename columns with more descriptive names
fmeanstd <- c(featmean, featstd)
varnames <- mapvalues(fmeanstd, feat[, 1], as.character(feat[, 2]))
varnames <- c(varnames, "Activities")
names(mydata_meanstd) <- varnames

#organize by subject and activities and take mean of each variable
subjects <- rbind(subject_train, subject_test)
names(subjects) <- "Subjects"
mytidydata <- cbind(subjects, mydata_meanstd)
mytidydata <- mytidydata %>% group_by(Subjects, Activities) %>% summarise_each(funs(mean))

