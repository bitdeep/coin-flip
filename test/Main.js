const {expect} = require("chai");
const {ethers} = require("hardhat");

describe("Main", function () {
    it("test", async function () {
        const [a, b, c, d, e, f, g, h, i, j, l] = await ethers.getSigners();
        const Main = await ethers.getContractFactory("Main");
        const main = await Main.deploy();
        await main.deployed();
        await test(a);
        await test(b);
        await test(c);
        await test(d);
        await test(e);
        await test(f);
        await test(g);
        await test(h);
        await test(i);
        await test(j);
        await test(l);
        async function test(user){
            const cost = '1000000000000000000';
            const tx = await main.connect(user).flip({value: cost});
            const events = await tx.wait();
            const ev = events.events[0].args;
            const u = ev.user;
            const premium = ev.premium.toString()
            const value = premium/1e18;
            console.log(u, value, value>0 ? 'Win': 'Lost');
        }
        const flipCount = (await main.flipCount.call()).toString();
        for( let i = flipCount; i > 10-flipCount && i>=0 ; i --){
            const flips = await main.flips(i).call();
            console.log(flips);
        }
    });

});
