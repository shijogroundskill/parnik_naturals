class CustomerAccountQueries {
  static const orders = r'''
    query Orders($first: Int!) {
      customer {
        id
        displayName
        emailAddress { emailAddress }
        orders(first: $first, sortKey: PROCESSED_AT, reverse: true) {
          edges {
            node {
              id
              name
              number
              processedAt
              financialStatus
              fulfillmentStatus
              statusPageUrl
              totalPrice { amount currencyCode }
            }
          }
        }
      }
    }
  ''';
}

