@protocol RemoveHeartDelegate <NSObject>

- (void)onWin;
- (void)removeHeart:(int)hitCount;
- (void)removeTutorial;

@end

@interface LevelZero : CCNode <CCPhysicsCollisionDelegate>
{
    CCNode* _auron;
    CCNode* _slimeOne;
    CCNode* _slimeTwo;
    CCNode* _ground;
    CCNode* _heartOne;
    CCNode* _heartTwo;
    CCNode* _levelZero;
    
    CCPhysicsNode* _physicsNode;
}

@property (nonatomic, assign) id <RemoveHeartDelegate> delegate;

@end
