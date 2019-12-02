/// <reference types="Cypress" />

describe('Hello', () => {

  describe('Check successfully flow', () => {

    it('should returns a message "Hello World!"', () => {
      cy.request({
        url: '/hello',
        method: 'GET'
      }).as('response');

      cy.get('@response').its('status').should('be.equal', 200);
      cy.get('@response').its('body.message').should('be.equal', 'Hello World!');
      cy.get('@response').its('body.input').should('be.an', 'object');
    });

  });

});