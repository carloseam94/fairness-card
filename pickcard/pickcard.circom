pragma circom 2.0.0;

include "../circomlib/mimcsponge.circom";

// commit to a card
// 0-11 numbers
// 0-3 suites
// 52 cards total
template PickCard() {
    // hash of the selected card (Public)
    signal input argHash;

    // private inputs
    signal input number;
    signal input suit;
    signal input password;

    signal output newHash;
    
    // we hash this in segments instead of hash(number, suit, password) for the purposses of the next question
    component hasher1 = MiMCSponge(2,220,1);
    component hasher2 = MiMCSponge(2,220,1);

    // hash(suit, password)
    hasher1.k <== 0;
    hasher1.ins[0] <== suit;
    hasher1.ins[1] <== password;

    // hash(hash(suit, password), number)
    hasher2.k <== 0;
    hasher2.ins[0] <== hasher1.outs[0];
    hasher2.ins[1] <== number;

    // verify selected card its the same by comparing its hash with computed hash
    newHash <== hasher2.outs[0];
    newHash === argHash;
} 

component main{public[argHash]} = PickCard();
