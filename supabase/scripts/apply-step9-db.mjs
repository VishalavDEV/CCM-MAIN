import pg from 'pg';
import fs from 'fs';
import path from 'path';

const pool = new pg.Pool({
    connectionString: process.env.DATABASE_URL || 'postgresql://postgres:Ccm-main123%23%40@127.0.0.1:5432/postgres'
});

async function main() {
    const client = await pool.connect();
    try {
        console.log('Applying Step 9 database migrations...');
        const migrationFiles = [
            '053_create_documents.sql',
            '054_create_step9_permissions.sql',
            '055_create_step9_indexes.sql',
            '056_create_step9_rls.sql',
            '057_seed_step9_data.sql'
        ];

        for (const file of migrationFiles) {
            const filePath = path.join(process.cwd(), 'supabase', 'migrations', file);
            console.log(`Executing ${file}...`);
            const sql = fs.readFileSync(filePath, 'utf-8');
            await client.query(sql);
        }
        console.log('✅ Step 9 database migrations applied successfully!');
    } catch (err) {
        console.error('❌ Failed to apply Step 9 migrations:', err);
        process.exit(1);
    } finally {
        client.release();
        await pool.end();
    }
}

main();
