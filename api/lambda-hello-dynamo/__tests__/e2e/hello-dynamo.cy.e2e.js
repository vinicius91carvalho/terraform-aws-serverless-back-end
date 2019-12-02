/// <reference types="Cypress" />

describe('Hello World Dynamo', () => {

  describe('Check successfully flow', () => {

    before(() => {
      cy.getToken();
    });

    it('should returns a field called name that have the content: "A"', () => {

      cy.request({
        url: '/data?id=1',
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
        }
      }).as('response');

      cy.get('@response').its('status').should('be.equal', 200);
      cy.get('@response').its('body.name').should('be.equal', 'A');
      cy.get('@response').its('body.event').should('be.an', 'object');
    });

  });

});