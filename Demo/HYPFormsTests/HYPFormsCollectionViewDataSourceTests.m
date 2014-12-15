@import UIKit;
@import XCTest;

#import "HYPFieldValidation.h"
#import "HYPForm.h"
#import "HYPFormField.h"
#import "HYPFormsCollectionViewDataSource.h"
#import "HYPFormSection.h"
#import "HYPFormsManager.h"
#import "HYPFormTarget.h"

#import "NSJSONSerialization+ANDYJSONFile.h"

@interface HYPFormsCollectionViewDataSourceTests : XCTestCase <HYPFormsLayoutDataSource>

@property (nonatomic, strong) HYPFormsManager *manager;
@property (nonatomic, strong) HYPFormsCollectionViewDataSource *dataSource;

@end

@implementation HYPFormsCollectionViewDataSourceTests

- (void)setUp
{
    [super setUp];

    HYPFormsLayout *layout = [[HYPFormsLayout alloc] init];
    layout.dataSource = self;

    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:[[UIScreen mainScreen] bounds] collectionViewLayout:layout];

    NSArray *JSON = [NSJSONSerialization JSONObjectWithContentsOfFile:@"forms.json"];
    self.manager = [[HYPFormsManager alloc] initWithJSON:JSON
                                           initialValues:nil
                                        disabledFieldIDs:nil
                                                disabled:NO];
    self.dataSource = [[HYPFormsCollectionViewDataSource alloc] initWithCollectionView:collectionView andFormsManager:self.manager];
}

- (void)tearDown
{
    self.manager = nil;
    self.dataSource = nil;

    [super tearDown];
}

- (void)testIndexInForms
{
    [self.dataSource processTarget:[HYPFormTarget hideFieldTargetWithID:@"display_name"]];
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"display_name"]];
    HYPFormField *field = [self.manager fieldWithID:@"display_name" includingHiddenFields:YES];
    NSUInteger index = [field indexInSectionUsingForms:self.manager.forms];
    XCTAssertEqual(index, 2);

    [self.dataSource processTarget:[HYPFormTarget hideFieldTargetWithID:@"username"]];
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"username"]];
    field = [self.manager fieldWithID:@"username" includingHiddenFields:YES];
    index = [field indexInSectionUsingForms:self.manager.forms];
    XCTAssertEqual(index, 2);

    [self.dataSource processTargets:[HYPFormTarget hideFieldTargetsWithIDs:@[@"first_name", @"address", @"username"]]];
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"username"]];
    field = [self.manager fieldWithID:@"username" includingHiddenFields:YES];
    index = [field indexInSectionUsingForms:self.manager.forms];
    XCTAssertEqual(index, 1);
    [self.dataSource processTargets:[HYPFormTarget showFieldTargetsWithIDs:@[@"first_name", @"address"]]];

    [self.dataSource processTargets:[HYPFormTarget hideFieldTargetsWithIDs:@[@"last_name", @"address"]]];
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"address"]];
    field = [self.manager fieldWithID:@"address" includingHiddenFields:YES];
    index = [field indexInSectionUsingForms:self.manager.forms];
    XCTAssertEqual(index, 0);
    [self.dataSource processTarget:[HYPFormTarget showFieldTargetWithID:@"last_name"]];
}

#pragma mark - HYPFormsLayoutDataSource

- (NSArray *)forms
{
    return self.manager.forms;
}

- (NSArray *)collapsedForms
{
    return self.dataSource.collapsedForms;
}

@end