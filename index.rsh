'reach 0.1';

const amt = 1

const common = {
  ...hasRandom,
  randNum: Fun([UInt], UInt),
  seeOutcome: Fun([UInt], Null)
}
export const main = Reach.App(() => {
  const A = Participant('Alice', {
    // Specify Alice's interact interface here
    ...common,
    raffleBegin: Fun([], Object({
      nftId: Token,
      ticketNum: UInt,
    })),
    showHash: Fun([Digest], Null)
    
  });
  const B = Participant('Bob', {
    // Specify Bob's interact interface here
    ...common,
    showWinNum:Fun([UInt], Null),
    showNum:Fun([UInt], Null),
    
  });
  init();
  // The first one to publish deploys the contract
  A.only(() => {
    const {nftId, ticketNum} = declassify(interact.raffleBegin());
    const _winningNum = interact.randNum(ticketNum)
    const [_commitA,  _saltA] = makeCommitment(interact, _winningNum)
    const commitA = declassify(_commitA);
  })
  A.publish(nftId, commitA, ticketNum);
  A.interact.showHash(commitA);
  commit();
  A.pay([[amt, nftId]])
  commit();


  unknowable(B, A(_winningNum, _saltA));
  // The second one to publish always attaches
  B.only(() => {
    const numBob = declassify(interact.randNum(ticketNum));
  })
  B.publish(numBob);
  B.interact.showNum(numBob);
  commit();
  A.only(() => {
    const saltA = declassify(_saltA);
    const winningNum = declassify(_winningNum);
  })
  A.publish(saltA, winningNum)
  checkCommitment(commitA, saltA, winningNum);

  B.interact.showWinNum(winningNum);

  const outcome = (numBob === winningNum ? 1 : 0)

  transfer(amt, nftId).to(outcome == 1 ? B : A)

 
 each([A, B], () => {
  interact.seeOutcome(outcome)
 })
 commit();
  // write your program here
  exit();
});
