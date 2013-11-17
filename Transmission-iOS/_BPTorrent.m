// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BPTorrent.m instead.

#import "_BPTorrent.h"

const struct BPTorrentAttributes BPTorrentAttributes = {
	.addedDate = @"addedDate",
	.desiredAvailable = @"desiredAvailable",
	.error = @"error",
	.errorString = @"errorString",
	.hashString = @"hashString",
	.id = @"id",
	.isFinished = @"isFinished",
	.isPendingDeletion = @"isPendingDeletion",
	.leftUntilDone = @"leftUntilDone",
	.magenetLink = @"magenetLink",
	.name = @"name",
	.percentDone = @"percentDone",
	.rateDownload = @"rateDownload",
	.rateUpload = @"rateUpload",
	.recheckProgress = @"recheckProgress",
	.sortName = @"sortName",
	.status = @"status",
	.totalSize = @"totalSize",
	.uploadRatio = @"uploadRatio",
};

const struct BPTorrentRelationships BPTorrentRelationships = {
};

const struct BPTorrentFetchedProperties BPTorrentFetchedProperties = {
};

@implementation BPTorrentID
@end

@implementation _BPTorrent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BPTorrent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BPTorrent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BPTorrent" inManagedObjectContext:moc_];
}

- (BPTorrentID*)objectID {
	return (BPTorrentID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"addedDateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"addedDate"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"desiredAvailableValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"desiredAvailable"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"errorValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"error"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isFinishedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isFinished"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isPendingDeletionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isPendingDeletion"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"leftUntilDoneValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"leftUntilDone"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"magenetLinkValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"magenetLink"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"percentDoneValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"percentDone"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rateDownloadValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rateDownload"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"rateUploadValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rateUpload"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"recheckProgressValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"recheckProgress"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"statusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"totalSizeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"totalSize"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"uploadRatioValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"uploadRatio"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic addedDate;



- (int64_t)addedDateValue {
	NSNumber *result = [self addedDate];
	return [result longLongValue];
}

- (void)setAddedDateValue:(int64_t)value_ {
	[self setAddedDate:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveAddedDateValue {
	NSNumber *result = [self primitiveAddedDate];
	return [result longLongValue];
}

- (void)setPrimitiveAddedDateValue:(int64_t)value_ {
	[self setPrimitiveAddedDate:[NSNumber numberWithLongLong:value_]];
}





@dynamic desiredAvailable;



- (float)desiredAvailableValue {
	NSNumber *result = [self desiredAvailable];
	return [result floatValue];
}

- (void)setDesiredAvailableValue:(float)value_ {
	[self setDesiredAvailable:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveDesiredAvailableValue {
	NSNumber *result = [self primitiveDesiredAvailable];
	return [result floatValue];
}

- (void)setPrimitiveDesiredAvailableValue:(float)value_ {
	[self setPrimitiveDesiredAvailable:[NSNumber numberWithFloat:value_]];
}





@dynamic error;



- (int32_t)errorValue {
	NSNumber *result = [self error];
	return [result intValue];
}

- (void)setErrorValue:(int32_t)value_ {
	[self setError:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveErrorValue {
	NSNumber *result = [self primitiveError];
	return [result intValue];
}

- (void)setPrimitiveErrorValue:(int32_t)value_ {
	[self setPrimitiveError:[NSNumber numberWithInt:value_]];
}





@dynamic errorString;






@dynamic hashString;






@dynamic id;



- (int32_t)idValue {
	NSNumber *result = [self id];
	return [result intValue];
}

- (void)setIdValue:(int32_t)value_ {
	[self setId:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveIdValue {
	NSNumber *result = [self primitiveId];
	return [result intValue];
}

- (void)setPrimitiveIdValue:(int32_t)value_ {
	[self setPrimitiveId:[NSNumber numberWithInt:value_]];
}





@dynamic isFinished;



- (BOOL)isFinishedValue {
	NSNumber *result = [self isFinished];
	return [result boolValue];
}

- (void)setIsFinishedValue:(BOOL)value_ {
	[self setIsFinished:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsFinishedValue {
	NSNumber *result = [self primitiveIsFinished];
	return [result boolValue];
}

- (void)setPrimitiveIsFinishedValue:(BOOL)value_ {
	[self setPrimitiveIsFinished:[NSNumber numberWithBool:value_]];
}





@dynamic isPendingDeletion;



- (BOOL)isPendingDeletionValue {
	NSNumber *result = [self isPendingDeletion];
	return [result boolValue];
}

- (void)setIsPendingDeletionValue:(BOOL)value_ {
	[self setIsPendingDeletion:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsPendingDeletionValue {
	NSNumber *result = [self primitiveIsPendingDeletion];
	return [result boolValue];
}

- (void)setPrimitiveIsPendingDeletionValue:(BOOL)value_ {
	[self setPrimitiveIsPendingDeletion:[NSNumber numberWithBool:value_]];
}





@dynamic leftUntilDone;



- (int64_t)leftUntilDoneValue {
	NSNumber *result = [self leftUntilDone];
	return [result longLongValue];
}

- (void)setLeftUntilDoneValue:(int64_t)value_ {
	[self setLeftUntilDone:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveLeftUntilDoneValue {
	NSNumber *result = [self primitiveLeftUntilDone];
	return [result longLongValue];
}

- (void)setPrimitiveLeftUntilDoneValue:(int64_t)value_ {
	[self setPrimitiveLeftUntilDone:[NSNumber numberWithLongLong:value_]];
}





@dynamic magenetLink;



- (int32_t)magenetLinkValue {
	NSNumber *result = [self magenetLink];
	return [result intValue];
}

- (void)setMagenetLinkValue:(int32_t)value_ {
	[self setMagenetLink:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveMagenetLinkValue {
	NSNumber *result = [self primitiveMagenetLink];
	return [result intValue];
}

- (void)setPrimitiveMagenetLinkValue:(int32_t)value_ {
	[self setPrimitiveMagenetLink:[NSNumber numberWithInt:value_]];
}





@dynamic name;






@dynamic percentDone;



- (float)percentDoneValue {
	NSNumber *result = [self percentDone];
	return [result floatValue];
}

- (void)setPercentDoneValue:(float)value_ {
	[self setPercentDone:[NSNumber numberWithFloat:value_]];
}

- (float)primitivePercentDoneValue {
	NSNumber *result = [self primitivePercentDone];
	return [result floatValue];
}

- (void)setPrimitivePercentDoneValue:(float)value_ {
	[self setPrimitivePercentDone:[NSNumber numberWithFloat:value_]];
}





@dynamic rateDownload;



- (float)rateDownloadValue {
	NSNumber *result = [self rateDownload];
	return [result floatValue];
}

- (void)setRateDownloadValue:(float)value_ {
	[self setRateDownload:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveRateDownloadValue {
	NSNumber *result = [self primitiveRateDownload];
	return [result floatValue];
}

- (void)setPrimitiveRateDownloadValue:(float)value_ {
	[self setPrimitiveRateDownload:[NSNumber numberWithFloat:value_]];
}





@dynamic rateUpload;



- (float)rateUploadValue {
	NSNumber *result = [self rateUpload];
	return [result floatValue];
}

- (void)setRateUploadValue:(float)value_ {
	[self setRateUpload:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveRateUploadValue {
	NSNumber *result = [self primitiveRateUpload];
	return [result floatValue];
}

- (void)setPrimitiveRateUploadValue:(float)value_ {
	[self setPrimitiveRateUpload:[NSNumber numberWithFloat:value_]];
}





@dynamic recheckProgress;



- (float)recheckProgressValue {
	NSNumber *result = [self recheckProgress];
	return [result floatValue];
}

- (void)setRecheckProgressValue:(float)value_ {
	[self setRecheckProgress:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveRecheckProgressValue {
	NSNumber *result = [self primitiveRecheckProgress];
	return [result floatValue];
}

- (void)setPrimitiveRecheckProgressValue:(float)value_ {
	[self setPrimitiveRecheckProgress:[NSNumber numberWithFloat:value_]];
}





@dynamic sortName;






@dynamic status;



- (int32_t)statusValue {
	NSNumber *result = [self status];
	return [result intValue];
}

- (void)setStatusValue:(int32_t)value_ {
	[self setStatus:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveStatusValue {
	NSNumber *result = [self primitiveStatus];
	return [result intValue];
}

- (void)setPrimitiveStatusValue:(int32_t)value_ {
	[self setPrimitiveStatus:[NSNumber numberWithInt:value_]];
}





@dynamic totalSize;



- (int64_t)totalSizeValue {
	NSNumber *result = [self totalSize];
	return [result longLongValue];
}

- (void)setTotalSizeValue:(int64_t)value_ {
	[self setTotalSize:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveTotalSizeValue {
	NSNumber *result = [self primitiveTotalSize];
	return [result longLongValue];
}

- (void)setPrimitiveTotalSizeValue:(int64_t)value_ {
	[self setPrimitiveTotalSize:[NSNumber numberWithLongLong:value_]];
}





@dynamic uploadRatio;



- (float)uploadRatioValue {
	NSNumber *result = [self uploadRatio];
	return [result floatValue];
}

- (void)setUploadRatioValue:(float)value_ {
	[self setUploadRatio:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveUploadRatioValue {
	NSNumber *result = [self primitiveUploadRatio];
	return [result floatValue];
}

- (void)setPrimitiveUploadRatioValue:(float)value_ {
	[self setPrimitiveUploadRatio:[NSNumber numberWithFloat:value_]];
}










+ (NSArray*)fetchAllVisibleTorrents:(NSManagedObjectContext*)moc_ {
	NSError *error = nil;
	NSArray *result = [self fetchAllVisibleTorrents:moc_ error:&error];
	if (error) {
#ifdef NSAppKitVersionNumber10_0
		[NSApp presentError:error];
#else
		NSLog(@"error: %@", error);
#endif
	}
	return result;
}
+ (NSArray*)fetchAllVisibleTorrents:(NSManagedObjectContext*)moc_ error:(NSError**)error_ {
	NSParameterAssert(moc_);
	NSError *error = nil;

	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	
	NSDictionary *substitutionVariables = [NSDictionary dictionary];
	
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"AllVisibleTorrents"
													 substitutionVariables:substitutionVariables];
	NSAssert(fetchRequest, @"Can't find fetch request named \"AllVisibleTorrents\".");

	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}



@end
