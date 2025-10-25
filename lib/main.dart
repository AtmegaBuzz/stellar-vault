import 'package:flutter/material.dart';
import 'package:stellar_flutter_sdk/stellar_flutter_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final StellarSDK sdk = StellarSDK.TESTNET;

  Future<void> test() async {
    // String accountId =
    //     "GASYKQXV47TPTB6HKXWZNB6IRVPMTQ6M6B27IM5L2LYMNYBX2O53YJAL";
    // AccountResponse account = await sdk.accounts.account(accountId);
    // print("sequence number: ${account.sequenceNumber}");

    // create a completely new and unique pair of keys.
    KeyPair keyPair = KeyPair.random();

    print("${keyPair.accountId}");
    print("${keyPair.secretSeed}");

    String mnemonic = await Wallet.generate24WordsMnemonic();
    print(mnemonic);

    Wallet wallet = await Wallet.from(mnemonic);

    KeyPair keyPair0 = await wallet.getKeyPair(index: 0);
    print("${keyPair0.accountId} : ${keyPair0.secretSeed}");

    KeyPair keyPair1 = await wallet.getKeyPair(index: 1);
    print("${keyPair1.accountId} : ${keyPair1.secretSeed}");

    bool funded = await FriendBot.fundTestAccount(keyPair.accountId);
    print("funded: ${funded}");

    AccountResponse account = await sdk.accounts.account(keyPair.accountId);

    for (Balance balance in account.balances) {
      switch (balance.assetType) {
        case Asset.TYPE_NATIVE:
          print("Balance: ${balance.balance} XLM");
          break;
        default:
          print(
              "Balance: ${balance.balance} ${balance.assetCode} Issuer: ${balance.assetIssuer}");
      }
    }

    print("Sequence number: ${account.sequenceNumber}");

    for (Signer signer in account.signers) {
      print("Signer public key: ${signer.accountId}");
    }

    for (String key in account.data.keys) {
      print("Data key: ${key} value: ${account.data[key]}");
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: test,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
