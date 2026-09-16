import pg from 'pg';
const { Client } = pg;

const regions = [
  'ap-south-1',
  'ap-southeast-1',
  'ap-northeast-1',
  'ap-northeast-2',
  'ap-southeast-2',
  'us-east-1',
  'us-west-1',
  'us-east-2',
  'eu-west-1',
  'eu-west-2',
  'eu-central-1',
  'sa-east-1',
  'ca-central-1'
];

async function findRegion() {
  console.log('🔍 Scanning Supabase pooler regions for project owucaqkvostupxibracw...');
  for (const r of regions) {
    const host = `aws-0-${r}.pooler.supabase.com`;
    const user = `postgres.owucaqkvostupxibracw`;
    const connStr = `postgresql://${user}:Ccm-main123%23%40@${host}:6543/postgres`;
    
    const client = new Client({ connectionString: connStr, ssl: { rejectUnauthorized: false }, connectionTimeoutMillis: 3000 });
    try {
      await client.connect();
      console.log(`\n🎉 MATCH FOUND! Region: ${r}, Host: ${host}`);
      await client.end();
      return { host, user, port: 6543 };
    } catch(e) {
      if (e.message.includes('tenant/user') && e.message.includes('not found')) {
        // Wrong region
        process.stdout.write('.');
      } else {
        console.log(`\nResponse from ${r}:`, e.message);
        if (!e.message.includes('ENOTFOUND')) {
          await client.end();
          return { host, user, port: 6543 };
        }
      }
    }
  }
  console.log('\nScan completed.');
}

findRegion();
