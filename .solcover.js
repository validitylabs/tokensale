testrpc = '-p 8555 '
    	+ '--account="0x0000000000000000000000000000000000000000000000000000000000000001,1000000000000000000000000", '
    	+ '--account="0x0000000000000000000000000000000000000000000000000000000000000002,1000000000000000000000000", '
    	+ '--account="0x0000000000000000000000000000000000000000000000000000000000000003,1000000000000000000000000", '
    	+ '--account="0x0000000000000000000000000000000000000000000000000000000000000004,1000000000000000000000000", '
    	+ '--account="0x0000000000000000000000000000000000000000000000000000000000000005,1000000000000000000000000", '
    	+ '--account="0x0000000000000000000000000000000000000000000000000000000000000006,1000000000000000000000000", '
    	+ '--account="0x0000000000000000000000000000000000000000000000000000000000000007,1000000000000000000000000"';

// console.log('Testrpc options: ', testrpc);


module.exports = {
    port: 8555,
    testrpcOptions: testrpc,
    copyPackages: ['zeppelin-solidity'],
    testCommand: 'npm run test',
    //norpc: true,
    copyNodeModules: false,
};
