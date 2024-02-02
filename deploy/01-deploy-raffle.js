const { network } = require("hardhat")

module.exports = async ({ getNamedAccounts, deployments }) => {
    // const {getNamedAccounts, deployments} = hre
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    const raffle = await deploy("Raffle", {
        from: deployer,
        arge: [],
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
}
