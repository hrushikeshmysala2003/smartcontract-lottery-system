const { network, getNamedAccounts, deployments, ethers } = require("hardhat")
const { devlopmentChains, networkconfig } = require("../../helper-hardhat-config")
const { assert } = require("chai")

!devlopmentChains.includes(network.name)
    ? describe.skip
    : describe("Raffle Unit Tests", async function () {
          let raffle, vrfCoordinatorV2Mock
          let chainId
          beforeEach(async function () {
              const { deployer } = await getNamedAccounts()
              await deployments.fixture(["all"])
              raffle = await ethers.getContract("Raffle", deployer)
              vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock", deployer)
              chainId = network.config.chainId
          })

          describe("contructor", async function () {
              it("Initializes the raffle correctly", async function () {
                  const raffleState = await raffle.getRaffleState()
                  const interval = await raffle.getInterval()
                  assert.equal(raffleState.toString(), "0")
                  assert.equal(interval.toString(), networkconfig[chainId]["interval"])
              })
          })
      })
