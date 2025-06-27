import { S3Client, ListObjectsV2Command, GetObjectCommand, DeleteObjectCommand, CopyObjectCommand, ListBucketsCommand, HeadObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

const s3Client = new S3Client({});

export const handler = async (event) => {
  console.log('Event received:', JSON.stringify(event, null, 2));

  const { action, bucket, key, sourceBucket, targetBucket } = JSON.parse(event.body || '{}');

  try {
    switch (action) {
      case 'listFiles':
        return await listAllFiles();
      case 'deleteFile':
        return await deleteFile(bucket, key);
      case 'moveFile':
        return await moveFile(sourceBucket, key, targetBucket);
      case 'getFileMetadata':
        return await getFileMetadata(bucket, key);
      case 'downloadFile':
        return await downloadFile(bucket, key);
      default:
        throw new Error('Unknown action');
    }
  } catch (error) {
    console.error('Error:', error);
    return formatResponse(500, { error: error.message });
  }
};

async function listAllFiles() {
  const listCommand = new ListBucketsCommand({});
  const bucketData = await s3Client.send(listCommand);
  const buckets = bucketData.Buckets
    .map(bucket => bucket.Name)
    .filter(name => name.startsWith('dev') || name.includes('upload'));

  const allFiles = [];

  for (const bucket of buckets) {
    try {
      const command = new ListObjectsV2Command({ Bucket: bucket });
      const response = await s3Client.send(command);

      if (response.Contents) {
        const files = response.Contents.map(file => ({
          bucket,
          key: file.Key,
          size: file.Size,
          lastModified: file.LastModified,
          etag: file.ETag
        }));
        allFiles.push(...files);
      }
    } catch (error) {
      console.warn(`Error listing bucket ${bucket}:`, error.message);
    }
  }

  return formatResponse(200, { files: allFiles });
}

async function deleteFile(bucket, key) {
  const command = new DeleteObjectCommand({ Bucket: bucket, Key: key });
  await s3Client.send(command);
  return formatResponse(200, { message: 'File deleted successfully' });
}

async function moveFile(sourceBucket, key, targetBucket) {
  // Copy file to target bucket
  const copyCommand = new CopyObjectCommand({
    Bucket: targetBucket,
    Key: key,
    CopySource: `${sourceBucket}/${key}`
  });
  await s3Client.send(copyCommand);

  // Delete from source bucket
  await deleteFile(sourceBucket, key);
  return formatResponse(200, { message: 'File moved successfully' });
}

async function getFileMetadata(bucket, key) {
  const command = new GetObjectCommand({ Bucket: bucket, Key: key });
  const response = await s3Client.send(command);

  return formatResponse(200, {
    metadata: {
      contentType: response.ContentType,
      contentLength: response.ContentLength,
      lastModified: response.LastModified,
      etag: response.ETag
    }
  });
}

async function downloadFile(bucket, key) {
  try {
    // Validate input parameters
    if (!bucket || !key) {
      throw new Error('Missing required parameters: bucket and key');
    }

    // Check if the object exists first
    try {
      const headCommand = new HeadObjectCommand({
        Bucket: bucket,
        Key: key
      });
      await s3Client.send(headCommand);
    } catch (headError) {
      console.error('Object not found:', headError);
      throw new Error('File not found');
    }

    // Generate simple presigned URL for download
    const getObjectCommand = new GetObjectCommand({
      Bucket: bucket,
      Key: key
    });

    const downloadURL = await getSignedUrl(s3Client, getObjectCommand, {
      expiresIn: 300 // URL expires in 5 minutes
    });

    console.log('Generated download URL for:', { bucket, key });

    return formatResponse(200, {
      downloadURL: downloadURL,
      bucket: bucket,
      key: key,
      expiresIn: 300,
      filename: key.split('/').pop()
    });

  } catch (error) {
    console.error('Error generating download URL:', error);
    throw new Error(`Failed to generate download URL: ${error.message}`);
  }
}

function formatResponse(statusCode, body) {
  return {
    statusCode,
    headers: {
      'Access-Control-Allow-Origin': 'https://dev.chatwithjunle.com',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Methods': 'OPTIONS,POST'
    },
    body: JSON.stringify(body)
  };
}