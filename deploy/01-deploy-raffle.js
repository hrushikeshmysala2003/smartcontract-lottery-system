const { network, ethers } = require("hardhat")
const { devlopmentChains, networkconfig } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")
const VRF_SUB_FUND_AMOUNT = ethers.parseEther("2")

module.exports = async ({ getNamedAccounts, deployments }) => {
    // const {getNamedAccounts, deployments} = hre
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    let vrfcoordinatorV2Address, subscriptionId

    if (devlopmentChains.includes(network.name)) {
        const vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
        vrfcoordinatorV2Address = await vrfCoordinatorV2Mock.getAddress()
        const transactionResponse = await vrfCoordinatorV2Mock.createSubscription()
        const transactionReceipt = await transactionResponse.wait(1)
        subscriptionId = transactionReceipt.logs[0].args.subId
        await vrfCoordinatorV2Mock.fundSubscription(subscriptionId, VRF_SUB_FUND_AMOUNT)
    } else {
        vrfcoordinatorV2Address = networkconfig[chainId]["vrfCoordinatorV2"]
        subscriptionId = networkconfig[chainId]["subscriptionId"]
    }

    const entranceFee = networkconfig[chainId]["entranceFee"]
    const gasLane = networkconfig[chainId]["gasLane"]
    const callbackGasLimit = networkconfig[chainId]["callbackGasLimit"]
    const interval = networkconfig[chainId]["interval"]

    const args = [
        vrfcoordinatorV2Address,
        entranceFee,
        gasLane,
        subscriptionId,
        callbackGasLimit,
        interval,
    ]

    const raffle = await deploy("Raffle", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (!devlopmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying....")
        await verify(raffle.address, args)
    }
    log("--------------------------------------")
}

module.exports.tags = ["all", "raffle"]
