import pg from 'pg';
import fs from 'fs';
import path from 'path';

const pool = new pg.Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://postgres:Ccm-main123%23%40@127.0.0.1:5432/postgres'
});

async function main() {
    const client = await pool.connect();
    try {
        console.log('Applying Step 10 database migration...');
        const filePath = path.join(process.cwd(), 'supabase', 'migrations', '058_create_step10_permissions.sql');
        const sql = fs.readFileSync(filePath, 'utf-8');
        await client.query(sql);
        console.log('✅ Step 10 database migration applied successfully!');
    } catch (err) {
        console.error('❌ Failed to apply Step 10 migration:', err);
        process.exit(1);
    } finally {
        client.release();
        await pool.end();
    }
}

main();
