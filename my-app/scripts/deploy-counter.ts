import { artifacts, network } from "hardhat";

async function main() {
  const artifact = await artifacts.readArtifact("Counter");

  const { viem } = await network.connect({
    network: "hardhatOp",
    chainType: "op",
  });

  const publicClient = await viem.getPublicClient();
  const [deployer] = await viem.getWalletClients();

  console.log("Deploying Counter from:", deployer.account.address);

  const deployTxHash = await deployer.deployContract({
    abi: artifact.abi,
    bytecode: artifact.bytecode as `0x${string}`,
  });

  const deployReceipt = await publicClient.waitForTransactionReceipt({
    hash: deployTxHash,
  });

  const contractAddress = deployReceipt.contractAddress;

  if (!contractAddress) {
    throw new Error("Contract deployment failed: missing contract address");
  }

  console.log("Counter deployed at:", contractAddress);

  const readCount = async () =>
    publicClient.readContract({
      abi: artifact.abi,
      address: contractAddress,
      functionName: "getCount",
      args: [],
    });

  console.log("Initial counter value:", await readCount());

  const writeAndConfirm = async (fn: "increment" | "decrement") => {
    const txHash = await deployer.writeContract({
      abi: artifact.abi,
      address: contractAddress,
      functionName: fn,
      args: [],
    });

    await publicClient.waitForTransactionReceipt({ hash: txHash });
  };

  console.log("Calling increment()");
  await writeAndConfirm("increment");
  console.log("Counter after increment:", await readCount());

  console.log("Calling decrement()");
  await writeAndConfirm("decrement");
  console.log("Counter after decrement:", await readCount());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

