class ShopifyQueries {
  static const collections = r'''
    query Collections($first: Int!) {
      collections(first: $first, sortKey: UPDATED_AT) {
        edges {
          node {
            id
            handle
            title
            image { url(transform: { preferredContentType: JPG, maxWidth: 1600 }) altText }
          }
        }
      }
    }
  ''';

  static const products = r'''
    query Products($first: Int!, $after: String) {
      products(first: $first, after: $after, sortKey: BEST_SELLING) {
        pageInfo { hasNextPage endCursor }
        edges {
          node {
            id
            handle
            title
            description
            featuredImage { url(transform: { preferredContentType: JPG, maxWidth: 1200 }) altText }
            priceRange { minVariantPrice { amount currencyCode } }
          }
        }
      }
    }
  ''';

  static const productsByTag = r'''
    query ProductsByTag($first: Int!, $query: String!) {
      products(first: $first, query: $query, sortKey: CREATED_AT, reverse: true) {
        edges {
          node {
            id
            handle
            title
            description
            featuredImage { url(transform: { preferredContentType: JPG, maxWidth: 1200 }) altText }
            priceRange { minVariantPrice { amount currencyCode } }
          }
        }
      }
    }
  ''';

  static const pageByHandle = r'''
    query PageByHandle($handle: String!) {
      pageByHandle(handle: $handle) {
        id
        handle
        title
        body
      }
    }
  ''';

  static const customerAccessTokenCreate = r'''
    mutation CustomerAccessTokenCreate($input: CustomerAccessTokenCreateInput!) {
      customerAccessTokenCreate(input: $input) {
        customerAccessToken { accessToken expiresAt }
        customerUserErrors { field message code }
      }
    }
  ''';

  static const customerAccessTokenDelete = r'''
    mutation CustomerAccessTokenDelete($customerAccessToken: String!) {
      customerAccessTokenDelete(customerAccessToken: $customerAccessToken) {
        deletedAccessToken
        deletedCustomerAccessTokenId
        userErrors { field message }
      }
    }
  ''';

  static const customerOrders = r'''
    query CustomerOrders($customerAccessToken: String!, $first: Int!) {
      customer(customerAccessToken: $customerAccessToken) {
        id
        firstName
        lastName
        email
        orders(first: $first, sortKey: PROCESSED_AT, reverse: true) {
          edges {
            node {
              id
              name
              orderNumber
              processedAt
              financialStatus
              fulfillmentStatus
              statusUrl
              totalPrice { amount currencyCode }
            }
          }
        }
      }
    }
  ''';

  static const productByHandle = r'''
    query ProductByHandle($handle: String!) {
      productByHandle(handle: $handle) {
        id
        handle
        title
        description
        images(first: 10) { edges { node { url(transform: { preferredContentType: JPG, maxWidth: 1600 }) altText } } }
        variants(first: 25) {
          edges {
            node {
              id
              title
              availableForSale
              price { amount currencyCode }
            }
          }
        }
      }
    }
  ''';

  static const cartCreate = r'''
    mutation CartCreate($lines: [CartLineInput!]) {
      cartCreate(input: { lines: $lines }) {
        cart {
          id
          checkoutUrl
          cost { totalAmount { amount currencyCode } }
          lines(first: 50) {
            edges {
              node {
                id
                quantity
                merchandise {
                  ... on ProductVariant {
                    id
                    title
                    product {
                      id
                      handle
                      title
                      description
                      featuredImage { url(transform: { preferredContentType: JPG, maxWidth: 1200 }) altText }
                      priceRange { minVariantPrice { amount currencyCode } }
                    }
                    price { amount currencyCode }
                    availableForSale
                  }
                }
              }
            }
          }
        }
        userErrors { field message }
      }
    }
  ''';

  static const cartGet = r'''
    query CartGet($id: ID!) {
      cart(id: $id) {
        id
        checkoutUrl
        cost { totalAmount { amount currencyCode } }
        lines(first: 50) {
          edges {
            node {
              id
              quantity
              merchandise {
                ... on ProductVariant {
                  id
                  title
                  product {
                    id
                    handle
                    title
                    description
                    featuredImage { url(transform: { preferredContentType: JPG, maxWidth: 1200 }) altText }
                    priceRange { minVariantPrice { amount currencyCode } }
                  }
                  price { amount currencyCode }
                  availableForSale
                }
              }
            }
          }
        }
      }
    }
  ''';

  static const cartLinesAdd = r'''
    mutation CartLinesAdd($cartId: ID!, $lines: [CartLineInput!]!) {
      cartLinesAdd(cartId: $cartId, lines: $lines) {
        cart {
          id
          checkoutUrl
          cost { totalAmount { amount currencyCode } }
          lines(first: 50) {
            edges {
              node {
                id
                quantity
                merchandise {
                  ... on ProductVariant {
                    id
                    title
                    product {
                      id
                      handle
                      title
                      description
                      featuredImage { url(transform: { preferredContentType: JPG, maxWidth: 1200 }) altText }
                      priceRange { minVariantPrice { amount currencyCode } }
                    }
                    price { amount currencyCode }
                    availableForSale
                  }
                }
              }
            }
          }
        }
        userErrors { field message }
      }
    }
  ''';

  static const cartLinesUpdate = r'''
    mutation CartLinesUpdate($cartId: ID!, $lines: [CartLineUpdateInput!]!) {
      cartLinesUpdate(cartId: $cartId, lines: $lines) {
        cart {
          id
          checkoutUrl
          cost { totalAmount { amount currencyCode } }
          lines(first: 50) {
            edges {
              node {
                id
                quantity
                merchandise {
                  ... on ProductVariant {
                    id
                    title
                    product {
                      id
                      handle
                      title
                      description
                      featuredImage { url(transform: { preferredContentType: JPG, maxWidth: 1200 }) altText }
                      priceRange { minVariantPrice { amount currencyCode } }
                    }
                    price { amount currencyCode }
                    availableForSale
                  }
                }
              }
            }
          }
        }
        userErrors { field message }
      }
    }
  ''';

  static const cartLinesRemove = r'''
    mutation CartLinesRemove($cartId: ID!, $lineIds: [ID!]!) {
      cartLinesRemove(cartId: $cartId, lineIds: $lineIds) {
        cart {
          id
          checkoutUrl
          cost { totalAmount { amount currencyCode } }
          lines(first: 50) {
            edges {
              node {
                id
                quantity
                merchandise {
                  ... on ProductVariant {
                    id
                    title
                    product {
                      id
                      handle
                      title
                      description
                      featuredImage { url(transform: { preferredContentType: JPG, maxWidth: 1200 }) altText }
                      priceRange { minVariantPrice { amount currencyCode } }
                    }
                    price { amount currencyCode }
                    availableForSale
                  }
                }
              }
            }
          }
        }
        userErrors { field message }
      }
    }
  ''';
}

