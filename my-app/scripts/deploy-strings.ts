import { artifacts, network } from "hardhat";

async function main() {
  const artifact = await artifacts.readArtifact("Strings");
  console.log("Reading artifact:", artifact);

  const { viem } = await network.connect({
    network: "hardhatOp",
    chainType: "op",
  });

  const publicClient = await viem.getPublicClient();
  const [deployer, firstClient, _secondClient] = await viem.getWalletClients();
  
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

  const setFirstStringHash = await firstClient.writeContract({
    abi: artifact.abi,
    address: contractAddress,
    functionName: "setString",
    args: ["Hello, World!"],
  });

  const setFirstStringReceipt = await publicClient.waitForTransactionReceipt({
    hash: setFirstStringHash,
  });

  console.log('setFirstStringReceipt', setFirstStringReceipt);

  const setSecondStringHash = await firstClient.writeContract({
    abi: artifact.abi,
    address: contractAddress,
    functionName: "setString",
    args: ["Just a string"],
  });

  const setSecondStringReceipt = await publicClient.waitForTransactionReceipt({
    hash: setSecondStringHash,
  });

  console.log('setSecondStringReceipt', setSecondStringReceipt);
  
  const getStringZeroIndex = await publicClient.readContract({
    abi: artifact.abi,
    address: contractAddress,
    functionName: "getString",
    args: [0n],
  });

  console.log('getStringZeroIndex', getStringZeroIndex);

  const getStringOneIndex = await publicClient.readContract({
    abi: artifact.abi,
    address: contractAddress,
    functionName: "getString",
    args: [1n],
  });

  console.log('getStringOneIndex', getStringOneIndex);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
