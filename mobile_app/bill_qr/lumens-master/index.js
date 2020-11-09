const {
  TransactionBuilder,
  Server,
  Keypair,
  BASE_FEE,
  Networks,
  Operation,
  Asset
} = require('stellar-sdk');

const server = new Server('https://horizon-testnet.stellar.org');
const baseFee = BASE_FEE;
const networkPassphrase = Networks.TESTNET;

const createAccount = async () => {
  const pair = Keypair.random();
  return pair.secret();
};

const getPublicKey = async _privateKey => {
  const pair = Keypair.fromSecret(_privateKey);
  return pair.publicKey();
};

const faucet = async _publicKey => {
  try {
    await server.friendbot(_publicKey).call();
  } catch (e) {
    console.log(e);
  }
};

const getNativeBalance = async _publicKey => {
  let account = await server.loadAccount(_publicKey);
  let res = account.balances.find(e => e.asset_type === 'native');
  return res.balance;
};

const createFeeBumpTx = async (_privateKey, _to, _amount) => {
  const keypair = Keypair.fromSecret(_privateKey);
  var innerTx;
  const res = await server.loadAccount(keypair.publicKey()).then(account => {
    innerTx = new TransactionBuilder(account, {
      fee: baseFee,
      networkPassphrase,
      v1: true
    })
      // .addOperation(
      //   Operation.bumpSequence({
      //     bumpTo: '0'
      //   })
      // )
      // .setTimeout(0)
      .addOperation(
        Operation.payment({
          destination: _to,
          // Because Stellar allows transaction in many currencies, you must
          // specify the asset type. The special "native" asset represents Lumens.
          asset: Asset.native(),
          amount: _amount.toString()
        })
      )
      // Wait a maximum of three minutes for the transaction
      .setTimeout(180)
      .build();
    innerTx.sign(keypair);
    return innerTx;
  });
  return res;
};

const submitFeeBumpTrx = async (_privateKey, _trxObj) => {
  console.log(_trxObj);
  const feeSource = Keypair.fromSecret(_privateKey);
  const feeBumpTxn = new TransactionBuilder.buildFeeBumpTransaction(
    feeSource,
    baseFee,
    _trxObj,
    networkPassphrase
  );

  feeBumpTxn.sign(feeSource);
  return server.submitTransaction(feeBumpTxn);
};

const transferLumen = (_privateKey, _to, _amount) => {
  var StellarSdk = require('stellar-sdk');
  var server = new StellarSdk.Server('https://horizon-testnet.stellar.org');
  var sourceKeys = StellarSdk.Keypair.fromSecret(_privateKey);
  var destinationId = _to;
  // Transaction will hold a built transaction we can resubmit if the result is unknown.
  var transaction;

  // First, check to make sure that the destination account exists.
  // You could skip this, but if the account does not exist, you will be charged
  // the transaction fee when the transaction fails.
  server
    .loadAccount(destinationId)
    // If the account is not found, surface a nicer error message for logging.
    .catch(function (error) {
      if (error instanceof StellarSdk.NotFoundError) {
        throw new Error('The destination account does not exist!');
      } else return error;
    })
    // If there was no error, load up-to-date information on your account.
    .then(function () {
      return server.loadAccount(sourceKeys.publicKey());
    })
    .then(function (sourceAccount) {
      // Start building the transaction.
      transaction = new StellarSdk.TransactionBuilder(sourceAccount, {
        fee: StellarSdk.BASE_FEE,
        networkPassphrase: StellarSdk.Networks.TESTNET
      })
        .addOperation(
          StellarSdk.Operation.payment({
            destination: destinationId,
            // Because Stellar allows transaction in many currencies, you must
            // specify the asset type. The special "native" asset represents Lumens.
            asset: StellarSdk.Asset.native(),
            amount: _amount.toString()
          })
        )
        // Wait a maximum of three minutes for the transaction
        .setTimeout(180)
        .build();
      // Sign the transaction to prove you are actually the person sending it.
      transaction.sign(sourceKeys);
      // And finally, send it off to Stellar!
      return server.submitTransaction(transaction);
    })
    .then(function (result) {
      console.log('Success! Results:', result);
    })
    .catch(function (error) {
      console.error('Something went wrong!', error);
      // If the result is unknown (no response body, timeout etc.) we simply resubmit
      // already built transaction:
      // server.submitTransaction(transaction);
    });
};

// createFeeBumpTx(
//   'SAIO6VONEI2GY2LD32LECMHTKJYANHTOPBXDSPQ7BEXBMQ3PTI2NJMKN',
//   'GATNAV6NZ77OUJ3K26ZBR2POHNVCVEV3VUPV5ATBLBNITWQDQ5BZWQJR',
//   100
// ).then(e => {
//   submitFeeBumpTrx('SDEOACSWLLCHBOACI3K6EDAB33XM3JQ4NVG6NVGGTJISCTLVP2WRKVHX', e).then(res =>
//     console.log(res)
//   );
// });

// getPublicKey('SAIO6VONEI2GY2LD32LECMHTKJYANHTOPBXDSPQ7BEXBMQ3PTI2NJMKN').then(e => console.log(e));
// getNativeBalance('GATNAV6NZ77OUJ3K26ZBR2POHNVCVEV3VUPV5ATBLBNITWQDQ5BZWQJR').then(e =>
//   console.log(e)
// );
// faucet('GATNAV6NZ77OUJ3K26ZBR2POHNVCVEV3VUPV5ATBLBNITWQDQ5BZWQJR').then(e => console.log(e));
// createAccount().then(e => console.log(e));
// getPublicKey('SDEOACSWLLCHBOACI3K6EDAB33XM3JQ4NVG6NVGGTJISCTLVP2WRKVHX').then(e => console.log(e));

//Privatekey
//SDEOACSWLLCHBOACI3K6EDAB33XM3JQ4NVG6NVGGTJISCTLVP2WRKVHX
//PublicKey
//GATNAV6NZ77OUJ3K26ZBR2POHNVCVEV3VUPV5ATBLBNITWQDQ5BZWQJR

module.exports = {
  createAccount: createAccount,
  getPublicKey: getPublicKey,
  getNativeBalance: getNativeBalance,
  transferLumen: transferLumen,
  createFeeBumpTx: createFeeBumpTx,
  faucet: faucet,
  submitFeeBumpTrx: submitFeeBumpTrx
};
