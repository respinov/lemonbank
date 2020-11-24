//
//  GuardSpec.hpp
//  LemonBank
//
//  Created by Samin Pour on 3/10/18.
//  Copyright © 2018 threatmetrix. All rights reserved.
//

#ifndef GuardSpec_hpp
#define GuardSpec_hpp

#include "EnsureIT.h"
#include <stdio.h>
#include <string>

#define DEV_SEED 5283877

#define STRING(value) #value
#define STRING_VALUE(value) STRING(value)

#ifndef VERSION_STRING
#define SEED STRING_VALUE(DEV_SEED)
#else
#define SEED STRING_VALUE(VERSION_STRING)
#endif

static const char* DO_PROFILE = "\01-[LBProfileController doProfile]";
static const char* INIT       = "\01-[LBProfileController init]";

int getSeed();

#endif /* GuardSpec_hpp */
