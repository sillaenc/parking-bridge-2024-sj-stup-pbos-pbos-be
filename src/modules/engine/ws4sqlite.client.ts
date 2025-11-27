import axios, { AxiosInstance } from 'axios';

export class Ws4sqliteClient {
  private client: AxiosInstance;
  constructor() {
    this.client = axios.create({
      headers: { 'Content-Type': 'application/json' },
      timeout: 5000,
    });
  }

  async query(url: string, queryId: string, values?: Record<string, any>) {
    const body = {
      transaction: [
        {
          query: queryId.startsWith('#') ? queryId : `#${queryId}`,
          ...(values ? { values } : {}),
        },
      ],
    };
    const res = await this.client.post(url, body);
    const results = res.data?.results?.[0]?.resultSet ?? [];
    return results;
  }

  // raw SQL query (no leading # added)
  async queryRaw(url: string, sql: string, values?: Record<string, any>) {
    const body = {
      transaction: [
        {
          query: sql,
          ...(values ? { values } : {}),
        },
      ],
    };
    const res = await this.client.post(url, body);
    const results = res.data?.results?.[0]?.resultSet ?? [];
    return results;
  }

  async statement(url: string, statementId: string, values: Record<string, any>) {
    const body = {
      transaction: [
        {
          statement: statementId.startsWith('#') ? statementId : `#${statementId}`,
          values,
        },
      ],
    };
    const res = await this.client.post(url, body);
    return res.data;
  }

  async batch(url: string, transactions: Record<string, any>[]) {
    const body = { transaction: transactions };
    const res = await this.client.post(url, body);
    return res.data;
  }
}
