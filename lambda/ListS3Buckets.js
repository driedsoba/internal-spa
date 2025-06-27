import { S3Client, ListBucketsCommand } from '@aws-sdk/client-s3';

const s3Client = new S3Client({});

export const handler = async (event) => {
  console.log('Event received:', JSON.stringify(event, null, 2));

  try {
    const command = new ListBucketsCommand({});
    const data = await s3Client.send(command);
    console.log('Raw bucket data:', data);

    // Filter buckets by naming pattern
    const allowedBuckets = data.Buckets
      .map(bucket => bucket.Name)
      .filter(name => name.startsWith('dev') || name.includes('upload'));

    console.log('Filtered buckets:', allowedBuckets);

    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': 'https://dev.chatwithjunle.com',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'OPTIONS,GET'
      },
      body: JSON.stringify({ buckets: allowedBuckets })
    };
  } catch (error) {
    console.error('Error listing buckets:', error);
    return {
      statusCode: 500,
      headers: {
        'Access-Control-Allow-Origin': 'https://dev.chatwithjunle.com',
        'Access-Control-Allow-Headers': 'Content-Type'
      },
      body: JSON.stringify({ error: 'Failed to list buckets' })
    };
  }
};