#!/bin/bash 

# compile circuit
circom pickanothercard.circom --r1cs --wasm --sym --c

# generate witness using c++ (because is faster for large circuits)
cd ./pickanothercard_cpp
make
cp ../input.json ./input.json
./pickanothercard input.json witness.wtns
mv ./witness.wtns ../witness.wtns
cd ..

# Generating a trusted setup to use the Groth16 zk-SNARK protocol

# Part 1: the powers of tau (independent of the circuit)
# start a new powersoftau ceremony
snarkjs powersoftau new bn128 15 pot15_0000.ptau -v
# contribute to the ceremony
snarkjs powersoftau contribute pot15_0000.ptau pot15_0001.ptau --name="First contribution" -v

# Part 2: (circuit dependent)
# start the generation of this phase
snarkjs powersoftau prepare phase2 pot15_0001.ptau pot15_final.ptau -v
# generate a .zkey file that will contain the proving and verification keys together with all phase 2 contributions
snarkjs groth16 setup pickanothercard.r1cs pot15_final.ptau pickanothercard_0000.zkey
# Contribute to the phase 2 of the ceremony
snarkjs zkey contribute pickanothercard_0000.zkey pickanothercard_0001.zkey --name="1st Contributor Name" -v
# Export the verification key
snarkjs zkey export verificationkey pickanothercard_0001.zkey verification_key.json

# Generating a proof
# generate a zk-proof associated to the circuit and the witness
snarkjs groth16 prove pickanothercard_0001.zkey witness.wtns proof.json public.json

# Verifying a proof
snarkjs groth16 verify verification_key.json public.json proof.json

# Optional
# generate a Solidity verifier that allows verifying proofs on Ethereum blockchain
snarkjs zkey export solidityverifier pickanothercard_0001.zkey verifier.sol
# generate the parameters of the call (testing purposes)
snarkjs generatecall

