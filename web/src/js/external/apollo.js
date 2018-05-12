'use strict';

import { ApolloClient } from 'apollo-client';
import { HttpLink } from 'apollo-link-http';
import { InMemoryCache } from 'apollo-cache-inmemory';
import { contentServer } from '../config';

const link = new HttpLink({ uri: `${contentServer()}/gql` });
let apolloClient;
apolloClient = new ApolloClient({
  link,
  cache: new InMemoryCache(),
  shouldBatch: true
});

export { apolloClient };
