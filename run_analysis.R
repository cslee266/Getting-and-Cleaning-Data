library(reshape2)

# Read data
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract the index of the columns we wanted
selected_features <- grep(".*mean.*|.*std.*", features[,2])
selected_features.names <- features[selected_features,2]

# Replace '-mean' with 'Mean' & '-std' with 'Std' & Removes ()
selected_features.names <- gsub('-mean', 'Mean', selected_features.names)
selected_features.names <- gsub('-std', 'Std', selected_features.names)
selected_features.names <- gsub('[-()]', '', selected_features.names)

# Load train & test data
train <- read.table("UCI HAR Dataset/train/X_train.txt")[selected_features]
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_subjects, train_activities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[selected_features]
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_subjects, test_activities, test)

# Combine train and test set 
combined <- rbind(train, test)
colnames(combined) <- c("subject", "activity", selected_features.names)

# Turn activities & subjects into factors
combined$activity <- factor(combined$activity, levels = activity_labels[,1], labels = activity_labels[,2])
combined$subject <- as.factor(combined$subject)

combined.melted <- melt(combined, id = c("subject", "activity"))
combined.mean <- dcast(combined.melted, subject + activity ~ variable, mean)

write.table(combined.mean, "tidy.txt", row.names = FALSE, quote = FALSE)