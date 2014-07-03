//
//  SuperRobot.m
//  RobotWar
//
//  Created by George Shamugia on 30/06/2014.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "SuperRobot.h"

typedef NS_ENUM(NSInteger, RobotState) {
    RobotStateDefault,
    RobotStateTurnaround,
    RobotStateFiring,
    RobotStateSearching
};

@implementation SuperRobot
{
    RobotState _currentRobotState;
    
    CGPoint _lastKnownPosition;
    CGFloat _lastKnownPositionTimestamp;
}

- (void)run {
    while (true) {
        if (_currentRobotState == RobotStateFiring) {
            
            if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
                _currentRobotState = RobotStateSearching;
            } else {
                CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
                if (angle >= 0) {
                    [self turnGunRight:abs(angle)];
                } else {
                    [self turnGunLeft:abs(angle)];
                }
                [self shoot];
            }
        }
        
        if (_currentRobotState == RobotStateSearching) {
            [self moveAhead:50];
            [self turnRobotLeft:20];
            [self moveAhead:50];
            [self turnRobotRight:20];
        }
        
        if (_currentRobotState == RobotStateDefault) {
            [self moveAhead:100];
        }
    }
}

- (void)bulletHitEnemy:(Bullet *)bullet {
    // There are a couple of neat things you could do in this handler
     _lastKnownPositionTimestamp = self.currentTimestamp;
}

- (void)gotHit {
    [self cancelActiveAction];
    CGFloat angle = [self angleBetweenGunHeadingDirectionAndWorldPosition:_lastKnownPosition];
    if (angle >= 0) {
        [self turnRobotRight:abs(angle)];
    } else {
        [self turnRobotLeft:abs(angle)];
    }
    [self moveBack:80];
    
    //if ((self.currentTimestamp - _lastKnownPositionTimestamp) > 1.f) {
      //  [self moveAhead:50];
    //} else {
       // [self shoot];
        //
    //}
    
    //NSLog(@"Bounding box -> W: %f, H: %f", self.robotBoundingBox.size.width, self.robotBoundingBox.size.height);
    //NSLog(@"Arena Dimension -> W: %f, H: %f", self.arenaDimensions.width, self.arenaDimensions.height);
    //NSLog(@"Heading Direction -> X: %f, Y: %f", self.headingDirection.x, self.headingDirection.y);
    
}

- (void)scannedRobot:(Robot *)robot atPosition:(CGPoint)position {
    if (_currentRobotState != RobotStateFiring) {
        [self cancelActiveAction];
    }
    
    _lastKnownPosition = position;
    _lastKnownPositionTimestamp = self.currentTimestamp;
    _currentRobotState = RobotStateFiring;
}

- (void)hitWall:(RobotWallHitDirection)hitDirection hitAngle:(CGFloat)angle {
    if (_currentRobotState != RobotStateTurnaround) {
        [self cancelActiveAction];
        
        RobotState previousState = _currentRobotState;
        _currentRobotState = RobotStateTurnaround;
        
        // always turn to head straight away from the wall
        if (angle >= 0) {
            [self turnRobotLeft:abs(angle)];
        } else {
            [self turnRobotRight:abs(angle)];
            
        }
        
        [self moveAhead:20];
        
        _currentRobotState = previousState;
    }
}


@end
