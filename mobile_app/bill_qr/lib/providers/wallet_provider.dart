import 'dart:developer';

import 'package:bill_qr/providers/providers.dart';
import 'package:jdenticon_dart/jdenticon_dart.dart';
import 'package:random_string/random_string.dart';

class WalletProvider {
  static String privateKey;
  static String address;
  static String svgAvatar;

  static init({String privKey}) async {
    if (privKey != null && privKey != '') {
      privateKey = privKey;
      address = await getAddress();
      svgAvatar = Jdenticon.toSvg(address);
    } else {
      await getPrivateKeyStored();
      if (privateKey == null) {
        privateKey = await createNewWallet();
        address = await getAddress();
        await faucet();
      }
      address = await getAddress();
      svgAvatar = Jdenticon.toSvg(address);
    }
    await savePrivateKey();
  }

  static getPrivateKeyStored() async {
    privateKey = await Providers.secureStorage.read(key: 'privateKey');
  }

  static savePrivateKey() async {
    await Providers.secureStorage.write(key: 'privateKey', value: privateKey);
  }

  static Future<String> createNewWallet() async {
    String tag = randomAlpha(5);
    Providers.jsContext.evalJavascript("""
      contract.createAccount()
      .then(
        value => {
          nativeCommunicator.postMessage(JSON.stringify({tag: '$tag', data: value}));
        }
      );
    """);
    dynamic res = await Providers.waitJSMessage(tag);
    return res.toString();
  }

  static getAddress() async {
    String tag = randomAlpha(5);
    Providers.jsContext.evalJavascript("""
      contract.getPublicKey('$privateKey')
      .then(
        value => {
          nativeCommunicator.postMessage(JSON.stringify({tag: '$tag', data: value}));
        }
      );
    """);
    dynamic res = await Providers.waitJSMessage(tag);
    return res.toString();
  }

  static faucet() async {
    String tag = randomAlpha(5);
    Providers.jsContext.evalJavascript("""
      contract.faucet('$address')
      .then(
        value => {
          nativeCommunicator.postMessage(JSON.stringify({tag: '$tag', data: value}));
        }
      );
    """);
    dynamic res = await Providers.waitJSMessage(tag);
    return res.toString();
  }

  static Future<String> getBalance() async {
    String tag = randomAlpha(5);
    Providers.jsContext.evalJavascript("""
      contract.getNativeBalance('$address')
      .then(
        value => {
          nativeCommunicator.postMessage(JSON.stringify({tag: '$tag', data: value}));
        }
      );
    """);
    dynamic res = await Providers.waitJSMessage(tag);
    print(res);
    return res;
  }

  static Future<String> createTransaction(
    String toAddress,
    double amount,
  ) async {
    String tag = randomAlpha(5);
    Providers.jsContext.evalJavascript("""
      contract.createFeeBumpTx('$privateKey', '$toAddress', $amount)
      .then(
        value => {
          nativeCommunicator.postMessage(JSON.stringify({tag: '$tag', data: value}));
        }
      );
    """);
    dynamic res = await Providers.waitJSMessage(tag);
    log(res);
    return res.toString();
  }

  static Future<dynamic> createFeebump(String objTx) async {
    log(objTx);
    String tag = randomAlpha(5);
    Providers.jsContext.evalJavascript("""
      contract.submitFeeBumpTrx('$privateKey', '$objTx')
      .then(
        value => {
          nativeCommunicator.postMessage(JSON.stringify({tag: '$tag', data: value}));
       }
      );
    """);
    dynamic res = await Providers.waitJSMessage(tag);
    log(res);
    return res.toString();
  }

  static transferLumen(
      String privateKey, String toAddress, double parse) async {
    String tag = randomAlpha(5);
    Providers.jsContext.evalJavascript("""
      contract.transferLumen('$privateKey', '$toAddress' ,'$parse')
      .then(
        value => {
          nativeCommunicator.postMessage(JSON.stringify({tag: '$tag', data: value}));
       }
      );
    """);
    dynamic res = await Providers.waitJSMessage(tag);
    if (res.toString().toLowerCase().contains("error")) {
      return false;
    } else {
      return true;
    }
  }
}
