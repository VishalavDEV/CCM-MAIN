import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const connectionString = process.env.DATABASE_URL || 'postgresql://postgres:Ccm-main123%23%40@127.0.0.1:5432/postgres';

const pool = new pg.Pool({
    connectionString,
    max: 10,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 5000,
});

export async function query<T = any>(sql: string, params: any[] = []): Promise<T[]> {
    const client = await pool.connect();
    try {
        const res = await client.query(sql, params);
        return res.rows;
    } finally {
        client.release();
    }
}

export async function queryOne<T = any>(sql: string, params: any[] = []): Promise<T | null> {
    const rows = await query<T>(sql, params);
    return rows.length > 0 ? rows[0] : null;
}

export async function withTransaction<T>(callback: (client: pg.PoolClient) => Promise<T>): Promise<T> {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        const result = await callback(client);
        await client.query('COMMIT');
        return result;
    } catch (err) {
        await client.query('ROLLBACK');
        throw err;
    } finally {
        client.release();
    }
}

export { pool };
