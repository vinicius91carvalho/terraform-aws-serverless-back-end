/// <reference types="Cypress" />

// Comando para obter o ID Token
Cypress.Commands.add('getToken', (user, password) => {

  cy.fixture('cred-user-cognito').then((cresUserCognito) => {

    if (user) cresUserCognito.AuthParameters.USERNAME = user;
    if (password) cresUserCognito.AuthParameters.PASSWORD = password;

    return cy.request({
      method: 'POST',
      url: 'https://cognito-idp.us-east-1.amazonaws.com/',
      headers: {
        'Content-Type': 'application/x-amz-json-1.1',
        'X-Amz-Target': 'AWSCognitoIdentityProviderService.InitiateAuth'
      },
      body: cresUserCognito
    }).its('body.AuthenticationResult.IdToken')
      .should('not.be.empty')
      .then((token) => {
        Cypress.env('token', token);
        return token;
      });

  });
});

// Comando para sobrescrever o comando request do Cypress e adicionar o token no header Authorization
Cypress.Commands.overwrite('request', (originalFn, ...options) => {
  if (options.length === 1 && Cypress.env('token')) {
    const headers = options[0].headers;

    if (!headers) options[0].headers = {};

    options[0].headers['Authorization'] = Cypress.env('token');
  }
  return originalFn(...options);
});
