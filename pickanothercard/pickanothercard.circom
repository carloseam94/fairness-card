pragma circom 2.0.0;

include "../circomlib/mimcsponge.circom";
include "../circomlib/comparators.circom";

// commit to a card with the same suit as a previous card but not the same number
// 0-12 numbers
// 0-3 suites
// 52 cards total
template PickAnotherCard() {
    // public inputs
    // hash of the selected card
    signal input argHash;
    // hash of the previous selected card
    signal input prevArgHash;

    // private inputs
    signal input number;
    signal input suit;
    signal input password;
    signal suitWithPassword;
    
    component hashers[12];
    component comparers[12];
    component comparersPrev[12];

    // first verify it is not the same card again
    component ie = IsEqual();
    ie.in[0] <== argHash;
    ie.in[1] <== prevArgHash;
    ie.out === 0;
    
    component hasher1 = MiMCSponge(2,220,1);
    
    // hash(suit, password)
    hasher1.k <== 0;
    hasher1.ins[0] <== suit;
    hasher1.ins[1] <== password;
    suitWithPassword <== hasher1.outs[0];

    var oneOfTheNumbersMatch = 0;
    var oneOfTheNumbersMatchPrev = 0;

    // iterate through all the posible numbers for this suit
    // verify if exactly one of then is equal to prevArgHash and one of them is equal to argHash (we previously verified they are not the same)
    for(var i = 0; i < 12; i++) {
        hashers[i] = MiMCSponge(2,220,1);
        hashers[i].k <== 0;
        hashers[i].ins[0] <== suitWithPassword;
        hashers[i].ins[1] <== i;

        comparers[i] = IsEqual();
        comparers[i].in[0] <== argHash;
        comparers[i].in[1] <== hashers[i].outs[0];

        comparersPrev[i] = IsEqual();
        comparersPrev[i].in[0] <== prevArgHash;
        comparersPrev[i].in[1] <== hashers[i].outs[0];

        oneOfTheNumbersMatch = oneOfTheNumbersMatch + comparers[i].out;
        oneOfTheNumbersMatchPrev = oneOfTheNumbersMatchPrev + comparersPrev[i].out;
    }

    oneOfTheNumbersMatch === 1;
    oneOfTheNumbersMatchPrev === 1;
} 

component main{public[argHash, prevArgHash]} = PickAnotherCard();
