//
//  ALListener.m
//  ObjectAL
//
//  Created by Karl Stenerud on 10-01-07.
//
// Copyright 2009 Karl Stenerud
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Note: You are NOT required to make the license available from within your
// iOS application. Including it in your project is sufficient.
//
// Attribution is not required, but appreciated :)
//

#import "ALListener.h"
#import "ObjectALMacros.h"
#import "ALWrapper.h"
#import "ALContext.h"


@implementation ALListener

#pragma mark Object Management

+ (id) listenerForContext:(ALContext*) context
{
	return [[[self alloc] initWithContext:context] autorelease];
}

- (id) initWithContext:(ALContext*) contextIn
{
	if(nil != (self = [super init]))
	{
		context = contextIn;
		gain = 1.0f;
		suspendLock = [[SuspendLock lockWithTarget:nil
									  lockSelector:nil
									unlockSelector:nil] retain];
	}
	return self;
}

- (void) dealloc
{
	[suspendLock release];
	[super dealloc];
}

#pragma mark Properties

@synthesize context;

- (bool) muted
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return muted;
	}
}

- (void) setMuted:(bool) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(suspendLock.locked)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		muted = value;
		float resultingGain = muted ? 0 : gain;
		self.gain = resultingGain;
	}
}

- (float) gain
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		return gain;
	}
}

- (void) setGain:(float) value
{
	OPTIONALLY_SYNCHRONIZED(self)
	{
		if(suspendLock.locked)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		gain = value;
		if(muted)
		{
			value = 0;
		}
		[ALWrapper listenerf:AL_GAIN value:value];
	}
}

- (ALOrientation) orientation
{
	ALOrientation result;
	OPTIONALLY_SYNCHRONIZED(self)
	{
		[ALWrapper getListenerfv:AL_ORIENTATION values:(float*)&result];
	}
	return result;
}

- (void) setOrientation:(ALOrientation) value
{
	OPTIONALLY_SYNCHRONIZED_STRUCT_OP(self)
	{
		if(suspendLock.locked)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper listenerfv:AL_ORIENTATION values:(float*)&value];
	}
}

- (ALPoint) position
{
	ALPoint result;
	OPTIONALLY_SYNCHRONIZED(self)
	{
		[ALWrapper getListener3f:AL_POSITION v1:&result.x v2:&result.y v3:&result.z];
	}
	return result;
}

- (void) setPosition:(ALPoint) value
{
	OPTIONALLY_SYNCHRONIZED_STRUCT_OP(self)
	{
		if(suspendLock.locked)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper listener3f:AL_POSITION v1:value.x v2:value.y v3:value.z];
	}
}

- (ALVector) velocity
{
	ALVector result;
	OPTIONALLY_SYNCHRONIZED(self)
	{
		[ALWrapper getListener3f:AL_VELOCITY v1:&result.x v2:&result.y v3:&result.z];
	}
	return result;
}

- (void) setVelocity:(ALVector) value
{
	OPTIONALLY_SYNCHRONIZED_STRUCT_OP(self)
	{
		if(suspendLock.locked)
		{
			OAL_LOG_DEBUG(@"%@: Called mutator on suspended object", self);
			return;
		}
		
		[ALWrapper listener3f:AL_VELOCITY v1:value.x v2:value.y v3:value.z];
	}
}

- (bool) suspended
{
	// No need to synchronize since SuspendLock does that already.
	return suspendLock.suspendLock;
}

- (void) setSuspended:(bool) value
{
	// No need to synchronize since SuspendLock does that already.
	suspendLock.suspendLock = value;
}

- (bool) interrupted
{
	// No need to synchronize since SuspendLock does that already.
	return suspendLock.interruptLock;
}

- (void) setInterrupted:(bool) value
{
	// No need to synchronize since SuspendLock does that already.
	suspendLock.interruptLock = value;
}

@end
