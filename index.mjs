import {loadStdlib} from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(100);

const [ accAlice, accBob ] =
  await stdlib.newTestAccounts(2, startingBalance);
console.log('Hello, Alice and Bob!');

console.log('Launching...');
const ctcAlice = accAlice.contract(backend);
const ctcBob = accBob.contract(backend, ctcAlice.getInfo());

console.log("Creator is creating a testing Punk NFT");
const Nft = await stdlib.launchToken(accAlice, "Crypto Punk", "NFT", {supply: 1});
const OUTCOME = ["Your number doesn't match", "Your number matches"]

const nftParams = {
  nftId: Nft.id,
  ticketNum : 10,
}

await accBob.tokenAccept(nftParams.nftId)

const common = {
  randNum: (ticketNum) => {
    const num = Math.floor(Math.random() * ticketNum + 1)
    return num;
  },
  seeOutcome: (num) => {
    console.log(`${OUTCOME[num]}`);
  }
}


console.log('Starting backends...');
await Promise.all([
  backend.Alice(ctcAlice, {
    ...stdlib.hasRandom,
    // implement Alice's interact object here
    ...common,
    raffleBegin: () => {
      console.log('Sending Punk Nft parameters to the backend');
      return nftParams;
    },

    showHash: (hash) => {
      console.log(`Hidden winning number ${hash}`);
    }
  }),
  backend.Bob(ctcBob, {
    ...stdlib.hasRandom,
    ...common,
    showNum: (num) => {
      console.log(`Your Raffle number is ${num}`);
    },
    showWinNum: (winNum) => {
      console.log(`Winning number is ${winNum}`);
    }
    // implement Bob's interact object here
   
  }),
]);

console.log('Goodbye, Alice and Bob!');
