const app = require('../../handler.js');
const chai = require('chai');
const expect = chai.expect;

describe('Tests return of function', () => {
    it('verifies successful response', async () => {
        let event, context;
        const result = await app.helloWorld(event, context);

        expect(result).to.be.an('object');
        expect(result.statusCode).to.be.equal(200);
        expect(result.body).to.be.an('string');

        let response = JSON.parse(result.body);

        expect(response).to.be.an('object');
        expect(response.message).to.be.equal("Hello World!");
    });
});