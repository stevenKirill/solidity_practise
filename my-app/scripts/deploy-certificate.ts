import { artifacts, network } from "hardhat";

async function main() {
  const artifact = await artifacts.readArtifact("Certificate");
  console.log("Reading artifact:", artifact);

  const { viem } = await network.connect({
    network: "hardhatOp",
    chainType: "op",
  });

  const publicClient = await viem.getPublicClient();
  const [deployer] = await viem.getWalletClients();

  console.log("Deploying Counter from:", deployer.account.address);

  const deployTransactionHash = await deployer.deployContract({
    abi: artifact.abi,
    bytecode: artifact.bytecode as `0x${string}`,
    args: [],
  });

  const deployReceipt = await publicClient.waitForTransactionReceipt({
    hash: deployTransactionHash,
  });

  console.log("Deploy receipt:", deployReceipt);

  const certificateAddress = deployReceipt.contractAddress;


  if (!certificateAddress) {
    throw new Error("Contract deployment failed: missing contract address");
  }

  console.log("Certificate deployed at:", certificateAddress);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
