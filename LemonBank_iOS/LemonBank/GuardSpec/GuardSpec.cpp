//
//  GuardSpec.cpp
//  LemonBank
//
//  Created by Samin Pour on 3/10/18.
//  Copyright © 2018 threatmetrix. All rights reserved.
//
#import "GuardSpec.h"
using namespace std;

int getSeed()
{
    string verStr = SEED;
    string res;
    for (int i = 0; i < verStr.length(); i++)
    {
        if(isdigit(verStr[i]))
        {
            res += verStr[i];
        }
    }
    return stoi(res);
}

int main(int argc, char* argv[])
{
    eit::GuardSpec gs;
    gs.obfuscate(gs.sourceBitcode(), 200);
    gs.obfuscate(gs.function(DO_PROFILE), 400);

    // All these guards are using the default tamper action which does nothing in debug but causes a crash in release
    gs.detectDebugger("debugger_guard",                 // guard name
                      gs.function(INIT).entry()         // invocation location
                      ).setExecutionProbability(0.7);

    gs.detectHooking("hooking_guard",                   // guard name
                     gs.function(DO_PROFILE).entry()    // invocation location
                     ).setExecutionProbability(0.8);

    gs.checksum("checksum_of_src_bitcode",              // guard name
                gs.function(DO_PROFILE).entry(),        // invocation location
                gs.sourceBitcode()                      // guard range
                ).setExecutionProbability(0.9);

    gs.seed(getSeed());
    gs.execute(argc, argv);
    return 0;
}
