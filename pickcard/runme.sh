#!/bin/bash 

# compile circuit
circom pickcard.circom --r1cs --wasm --sym --c

# generate witness using c++ (because is faster for large circuits)
cd ./pickcard_cpp
make
cp ../input.json ./input.json
./pickcard input.json witness.wtns
mv ./witness.wtns ../witness.wtns
cd ..

# Generating a trusted setup to use the Groth16 zk-SNARK protocol

# Part 1: the powers of tau (independent of the circuit)
# start a new powersoftau ceremony
snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
# contribute to the ceremony
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# Part 2: (circuit dependent)
# start the generation of this phase
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
# generate a .zkey file that will contain the proving and verification keys together with all phase 2 contributions
snarkjs groth16 setup pickcard.r1cs pot12_final.ptau pickcard_0000.zkey
# Contribute to the phase 2 of the ceremony
snarkjs zkey contribute pickcard_0000.zkey pickcard_0001.zkey --name="1st Contributor Name" -v
# Export the verification key
snarkjs zkey export verificationkey pickcard_0001.zkey verification_key.json

# Generating a proof
# generate a zk-proof associated to the circuit and the witness
snarkjs groth16 prove pickcard_0001.zkey witness.wtns proof.json public.json

# Verifying a proof
snarkjs groth16 verify verification_key.json public.json proof.json

# Optional
# generate a Solidity verifier that allows verifying proofs on Ethereum blockchain
snarkjs zkey export solidityverifier pickcard_0001.zkey verifier.sol
# generate the parameters of the call (testing purposes)
snarkjs generatecall

