// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to BPTorrent.h instead.

#import <CoreData/CoreData.h>


extern const struct BPTorrentAttributes {
	__unsafe_unretained NSString *addedDate;
	__unsafe_unretained NSString *desiredAvailable;
	__unsafe_unretained NSString *error;
	__unsafe_unretained NSString *errorString;
	__unsafe_unretained NSString *hashString;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *isFinished;
	__unsafe_unretained NSString *isPendingDeletion;
	__unsafe_unretained NSString *leftUntilDone;
	__unsafe_unretained NSString *magenetLink;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *percentDone;
	__unsafe_unretained NSString *rateDownload;
	__unsafe_unretained NSString *rateUpload;
	__unsafe_unretained NSString *recheckProgress;
	__unsafe_unretained NSString *sortName;
	__unsafe_unretained NSString *status;
	__unsafe_unretained NSString *totalSize;
	__unsafe_unretained NSString *uploadRatio;
} BPTorrentAttributes;

extern const struct BPTorrentRelationships {
} BPTorrentRelationships;

extern const struct BPTorrentFetchedProperties {
} BPTorrentFetchedProperties;






















@interface BPTorrentID : NSManagedObjectID {}
@end

@interface _BPTorrent : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (BPTorrentID*)objectID;





@property (nonatomic, strong) NSNumber* addedDate;



@property int64_t addedDateValue;
- (int64_t)addedDateValue;
- (void)setAddedDateValue:(int64_t)value_;

//- (BOOL)validateAddedDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* desiredAvailable;



@property float desiredAvailableValue;
- (float)desiredAvailableValue;
- (void)setDesiredAvailableValue:(float)value_;

//- (BOOL)validateDesiredAvailable:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* error;



@property int32_t errorValue;
- (int32_t)errorValue;
- (void)setErrorValue:(int32_t)value_;

//- (BOOL)validateError:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* errorString;



//- (BOOL)validateErrorString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* hashString;



//- (BOOL)validateHashString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* id;



@property int32_t idValue;
- (int32_t)idValue;
- (void)setIdValue:(int32_t)value_;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isFinished;



@property BOOL isFinishedValue;
- (BOOL)isFinishedValue;
- (void)setIsFinishedValue:(BOOL)value_;

//- (BOOL)validateIsFinished:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isPendingDeletion;



@property BOOL isPendingDeletionValue;
- (BOOL)isPendingDeletionValue;
- (void)setIsPendingDeletionValue:(BOOL)value_;

//- (BOOL)validateIsPendingDeletion:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* leftUntilDone;



@property int64_t leftUntilDoneValue;
- (int64_t)leftUntilDoneValue;
- (void)setLeftUntilDoneValue:(int64_t)value_;

//- (BOOL)validateLeftUntilDone:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* magenetLink;



@property int32_t magenetLinkValue;
- (int32_t)magenetLinkValue;
- (void)setMagenetLinkValue:(int32_t)value_;

//- (BOOL)validateMagenetLink:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* percentDone;



@property float percentDoneValue;
- (float)percentDoneValue;
- (void)setPercentDoneValue:(float)value_;

//- (BOOL)validatePercentDone:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* rateDownload;



@property float rateDownloadValue;
- (float)rateDownloadValue;
- (void)setRateDownloadValue:(float)value_;

//- (BOOL)validateRateDownload:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* rateUpload;



@property float rateUploadValue;
- (float)rateUploadValue;
- (void)setRateUploadValue:(float)value_;

//- (BOOL)validateRateUpload:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* recheckProgress;



@property float recheckProgressValue;
- (float)recheckProgressValue;
- (void)setRecheckProgressValue:(float)value_;

//- (BOOL)validateRecheckProgress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* sortName;



//- (BOOL)validateSortName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* status;



@property int32_t statusValue;
- (int32_t)statusValue;
- (void)setStatusValue:(int32_t)value_;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* totalSize;



@property int64_t totalSizeValue;
- (int64_t)totalSizeValue;
- (void)setTotalSizeValue:(int64_t)value_;

//- (BOOL)validateTotalSize:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* uploadRatio;



@property float uploadRatioValue;
- (float)uploadRatioValue;
- (void)setUploadRatioValue:(float)value_;

//- (BOOL)validateUploadRatio:(id*)value_ error:(NSError**)error_;





+ (NSArray*)fetchAllVisibleTorrents:(NSManagedObjectContext*)moc_ ;
+ (NSArray*)fetchAllVisibleTorrents:(NSManagedObjectContext*)moc_ error:(NSError**)error_;




@end

@interface _BPTorrent (CoreDataGeneratedAccessors)

@end

@interface _BPTorrent (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAddedDate;
- (void)setPrimitiveAddedDate:(NSNumber*)value;

- (int64_t)primitiveAddedDateValue;
- (void)setPrimitiveAddedDateValue:(int64_t)value_;




- (NSNumber*)primitiveDesiredAvailable;
- (void)setPrimitiveDesiredAvailable:(NSNumber*)value;

- (float)primitiveDesiredAvailableValue;
- (void)setPrimitiveDesiredAvailableValue:(float)value_;




- (NSNumber*)primitiveError;
- (void)setPrimitiveError:(NSNumber*)value;

- (int32_t)primitiveErrorValue;
- (void)setPrimitiveErrorValue:(int32_t)value_;




- (NSString*)primitiveErrorString;
- (void)setPrimitiveErrorString:(NSString*)value;




- (NSString*)primitiveHashString;
- (void)setPrimitiveHashString:(NSString*)value;




- (NSNumber*)primitiveId;
- (void)setPrimitiveId:(NSNumber*)value;

- (int32_t)primitiveIdValue;
- (void)setPrimitiveIdValue:(int32_t)value_;




- (NSNumber*)primitiveIsFinished;
- (void)setPrimitiveIsFinished:(NSNumber*)value;

- (BOOL)primitiveIsFinishedValue;
- (void)setPrimitiveIsFinishedValue:(BOOL)value_;




- (NSNumber*)primitiveIsPendingDeletion;
- (void)setPrimitiveIsPendingDeletion:(NSNumber*)value;

- (BOOL)primitiveIsPendingDeletionValue;
- (void)setPrimitiveIsPendingDeletionValue:(BOOL)value_;




- (NSNumber*)primitiveLeftUntilDone;
- (void)setPrimitiveLeftUntilDone:(NSNumber*)value;

- (int64_t)primitiveLeftUntilDoneValue;
- (void)setPrimitiveLeftUntilDoneValue:(int64_t)value_;




- (NSNumber*)primitiveMagenetLink;
- (void)setPrimitiveMagenetLink:(NSNumber*)value;

- (int32_t)primitiveMagenetLinkValue;
- (void)setPrimitiveMagenetLinkValue:(int32_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitivePercentDone;
- (void)setPrimitivePercentDone:(NSNumber*)value;

- (float)primitivePercentDoneValue;
- (void)setPrimitivePercentDoneValue:(float)value_;




- (NSNumber*)primitiveRateDownload;
- (void)setPrimitiveRateDownload:(NSNumber*)value;

- (float)primitiveRateDownloadValue;
- (void)setPrimitiveRateDownloadValue:(float)value_;




- (NSNumber*)primitiveRateUpload;
- (void)setPrimitiveRateUpload:(NSNumber*)value;

- (float)primitiveRateUploadValue;
- (void)setPrimitiveRateUploadValue:(float)value_;




- (NSNumber*)primitiveRecheckProgress;
- (void)setPrimitiveRecheckProgress:(NSNumber*)value;

- (float)primitiveRecheckProgressValue;
- (void)setPrimitiveRecheckProgressValue:(float)value_;




- (NSString*)primitiveSortName;
- (void)setPrimitiveSortName:(NSString*)value;




- (NSNumber*)primitiveStatus;
- (void)setPrimitiveStatus:(NSNumber*)value;

- (int32_t)primitiveStatusValue;
- (void)setPrimitiveStatusValue:(int32_t)value_;




- (NSNumber*)primitiveTotalSize;
- (void)setPrimitiveTotalSize:(NSNumber*)value;

- (int64_t)primitiveTotalSizeValue;
- (void)setPrimitiveTotalSizeValue:(int64_t)value_;




- (NSNumber*)primitiveUploadRatio;
- (void)setPrimitiveUploadRatio:(NSNumber*)value;

- (float)primitiveUploadRatioValue;
- (void)setPrimitiveUploadRatioValue:(float)value_;




@end
