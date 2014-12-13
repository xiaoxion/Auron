@interface MainScene : CCNode
{
    CCNode* _levelZero;
    CCNode* _heartOne;
    CCNode* _heartTwo;
}

- (void)removeHeart:(int)hitCount;

@end
