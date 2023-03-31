describe('api test', () => {
  it('passes', () => {
    cy.request("POST", Cypress.env('API_URL'), {})
      .then((response) => {
        expect(response.status).to.eq(200)
        expect(response.body).to.not.be.null
      })
  })
})