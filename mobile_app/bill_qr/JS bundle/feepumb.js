const {
  TransactionBuilder,
  Server,
  Keypair,
  BASE_FEE,
  Networks,
  Operation,
  StrKey
} = require('stellar-sdk');
const axios = require('axios');

const server = new Server('https://horizon-testnet.stellar.org');
const keypair = Keypair.fromSecret('SAIO6VONEI2GY2LD32LECMHTKJYANHTOPBXDSPQ7BEXBMQ3PTI2NJMKN');
const baseFee = BASE_FEE;
const networkPassphrase = Networks.TESTNET;
const feeSource = Keypair.fromSecret('SDH2PWNRWGLOKY4D5IEJH6I7BTQ3JZ3FMCLW64ZL3TBKDOJSEBVNIXRZ');

try {
  await server.friendbot(keypair.publicKey()).call();

  await server.friendbot(feeSource.publicKey()).call();
} catch (err) {}
