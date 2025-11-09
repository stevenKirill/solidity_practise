import { artifacts, network } from "hardhat";

async function main() {
  const artifact = await artifacts.readArtifact("SimpleBank");

  console.log("Reading artifact:", artifact);

  const { viem } = await network.connect({
    network: "hardhatOp",
    chainType: "op",
  });

  const publicClient = await viem.getPublicClient();
  const [deployer, firstClient, secondClient] = await viem.getWalletClients();

  const deployTransactionHash = await deployer.deployContract({
    abi: artifact.abi,
    bytecode: artifact.bytecode,
  });

  const deployReceipt = await publicClient.waitForTransactionReceipt({
    hash: deployTransactionHash,
  });

  const contractAddress = deployReceipt.contractAddress;

  if (!contractAddress) {
    throw new Error("Contract deployment failed: missing contract address");
  }

  const balance = await publicClient.readContract({
    abi: artifact.abi,
    address: contractAddress,
    functionName: "getBalance",
    args: [],
    account: firstClient.account,
  });

  const depositMoneyHash = await firstClient.writeContract({
    abi: artifact.abi,
    address: contractAddress,
    functionName: "deposit",
    args: [],
    value: 4n,
  });

  const depositReceipt = await publicClient.waitForTransactionReceipt({
    hash: depositMoneyHash,
  });

  console.log("depositReceipt", depositReceipt);

  const getBalance = await publicClient.readContract({
    abi: artifact.abi,
    address: contractAddress,
    functionName: "getBalance",
    account: firstClient.account,
    args: [],
  });

  console.log("getBalance", getBalance);

  try {
    const withdrawMoneyHash = await firstClient.writeContract({
      abi: artifact.abi,
      address: contractAddress,
      functionName: "withdraw",
      args: [2n],
      account: firstClient.account,
    });
    await publicClient.waitForTransactionReceipt({
      hash: withdrawMoneyHash,
    });
  } catch (error: any) {
    console.log("Ошибка при выводе денег: ", error.message);
  }

  const getBalanceAfterWithdraw = await publicClient.readContract({
    abi: artifact.abi,
    address: contractAddress,
    functionName: "getBalance",
    account: firstClient.account,
    args: [],
  });

  console.log("getBalanceAfterWithdraw", getBalanceAfterWithdraw);

  //   console.log('deployTransactionHash', deployTransactionHash);

  //   console.log('deployReceipt', deployReceipt);

  //   console.log("Deploying SimpleBank from:", deployer.account.address);
}

main().catch((error) => {
  console.log(error);
  process.exitCode = 1;
});
